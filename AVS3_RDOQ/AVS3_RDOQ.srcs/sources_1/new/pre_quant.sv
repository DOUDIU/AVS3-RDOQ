`include "rdoq_header.vh"

module pre_quant(      
//system clk and rest           
    input                                           clk                                         ,
    input                                           rst_n                                       ,

//input parameter                                               
    input           [`w_q_value         - 1 : 0]    q_value                                     ,

    input           [`w_size            - 1 : 0]    i_width_log2                                ,//the value is between 2 and 6
    input           [`w_size            - 1 : 0]    i_height_log2                               ,//the value is between 2 and 6
    input           [`w_q_bits          - 1 : 0]    i_q_bits                                    ,
    input   signed  [`w_err_scale       - 1 : 0]    i_err_scale                                 ,
    input   signed  [`w_lambda          - 1 : 0]    i_lambda                                    ,
    input   signed  [`w_diff_scale      - 1 : 0]    i_diff_scale                                ,

    input           [`w_rdoq_est_last   - 1 : 0]    i_rdoq_est_last     [0 :  5][0 : 11][0 : 1] ,
    input           [`w_rdoq_est_level  - 1 : 0]    i_rdoq_est_level    [0 : 23][0 :  1]        ,
    input           [`w_rdoq_est_run    - 1 : 0]    i_rdoq_est_run      [0 : 23][0 :  1]        ,
    input           [`w_pos             - 1 : 0]    i_left_pos          [0 : 31]                ,//the max value is 1023
    input           [`w_pos             - 1 : 0]    i_bottom_pos        [0 : 31]                ,//the max value is 1023

//input data                    
    input                                           i_valid                                     ,
    input   signed  [`w_data_in         - 1 : 0]    i_data              [0 : 31]                ,

//output parameter              
    output          [`w_size            - 1 : 0]    o_width_log2                                ,//the value is between 2 and 6
    output          [`w_size            - 1 : 0]    o_height_log2                               ,//the value is between 2 and 6
    output          [`w_q_bits          - 1 : 0]    o_q_bits                                    ,
    output  signed  [`w_err_scale       - 1 : 0]    o_err_scale                                 ,
    output  signed  [`w_lambda          - 1 : 0]    o_lambda                                    ,
    output  signed  [`w_diff_scale      - 1 : 0]    o_diff_scale                                ,

    output          [`w_rdoq_est_last   - 1 : 0]    o_rdoq_est_last     [0 :  5][0 : 11][0 : 1] ,
    output          [`w_rdoq_est_level  - 1 : 0]    o_rdoq_est_level    [0 : 23][0 :  1]        ,
    output          [`w_rdoq_est_run    - 1 : 0]    o_rdoq_est_run      [0 : 23][0 :  1]        ,
    output          [`w_pos             - 1 : 0]    o_left_pos          [0 : 31]                ,//the max value is 1023
    output          [`w_pos             - 1 : 0]    o_bottom_pos        [0 : 31]                ,//the max value is 1023

//output data       
    output                                          o_valid                                     ,
    output  signed  [`w_level_double    - 1 : 0]    o_level_double      [0 : 31]                ,
    output  signed  [`w_preq_o_data     - 1 : 0]    o_data              [0 : 31]                            
);

//parameter definition
parameter   COM_INT32_MAX   =   64'h7FFFFFFF    ;


//integer definition
integer i,j,k,l,m   ;
genvar  o,p,q,r     ;



//reg definition
reg     signed  [`w_level_double    - 1 : 0]    level_double        [0 : 31]                        ;
reg     signed  [`w_level_double    - 1 : 0]    level_double_d1     [0 : 31]                        ;
reg     signed  [`w_level_double    - 1 : 0]    level_double_d2     [0 : 31]                        ;
reg     signed  [`w_temp_level      - 1 : 0]    temp_level          [0 : 31]                        ;

reg             [`w_max_abs_level   - 1 : 0]    max_abs_level       [0 : 31]                        ;
reg             [`w_max_abs_level   - 1 : 0]    max_abs_level_t     [0 : 31]                        ;

reg                                             src_coef_sign       [0 :  3][0 : 31]                ;


reg                                             i_valid_d           [0 :  3]                        ;
reg             [`w_size            - 1 : 0]    i_width_log2_d      [0 :  3]                        ;
reg             [`w_size            - 1 : 0]    i_height_log2_d     [0 :  3]                        ;
reg             [`w_q_bits          - 1 : 0]    i_q_bits_d          [0 :  3]                        ;
reg     signed  [`w_err_scale       - 1 : 0]    i_err_scale_d       [0 :  3]                        ;
reg     signed  [`w_lambda          - 1 : 0]    i_lambda_d          [0 :  3]                        ;
reg     signed  [`w_diff_scale      - 1 : 0]    i_diff_scale_d      [0 :  3]                        ;

reg             [`w_rdoq_est_last   - 1 : 0]    i_rdoq_est_last_d   [0 :  3][0 :  5][0 : 11][0 : 1] ;
reg             [`w_rdoq_est_level  - 1 : 0]    i_rdoq_est_level_d  [0 :  3][0 : 23][0 :  1]        ;
reg             [`w_rdoq_est_run    - 1 : 0]    i_rdoq_est_run_d    [0 :  3][0 : 23][0 :  1]        ;
reg             [`w_pos             - 1 : 0]    i_left_pos_d        [0 :  3][0 : 31]                ;
reg             [`w_pos             - 1 : 0]    i_bottom_pos_d      [0 :  3][0 : 31]                ;

reg                                             o_en                                                ;

//wire definition   
wire            [`w_data_in         - 1 : 0]    i_data_abs          [0 : 31]                        ;
//assignment

generate
    for(o = 0; o < 32; o = o + 1)begin
        assign i_data_abs[o]   =  i_data[o] > 0 ? i_data[o] : (~i_data[o] + 1) ;
    end
endgenerate


generate
    for(o = 0; o < 32; o = o + 1)begin
        assign o_data[o]            =   o_en ? (src_coef_sign[3][o] ? -max_abs_level_t[o] : max_abs_level_t[o]) : 0 ;
        assign o_level_double[o]    =   level_double_d2[o] ;
    end
endgenerate

assign  o_valid         =   i_valid_d[3];
assign  o_width_log2    =   i_width_log2_d[3]; 
assign  o_height_log2   =   i_height_log2_d[3];
assign  o_q_bits        =   i_q_bits_d[3];
assign  o_err_scale     =   i_err_scale_d[3];
assign  o_lambda        =   i_lambda_d[3];
assign  o_left_pos      =   i_left_pos_d[3]; 
assign  o_bottom_pos    =   i_bottom_pos_d[3];
assign  o_diff_scale    =   i_diff_scale_d[3];

generate
    for(p = 0; p < 6; p = p + 1)begin
        for(q = 0; q < 12; q = q + 1)begin
            for(r = 0; r < 2; r = r + 1)begin
                assign o_rdoq_est_last[p][q][r] = i_rdoq_est_last_d[3][p][q][r];
            end
        end
    end
    for (o = 0; o < 24; o = o + 1) begin
        for(p = 0; p < 2; p = p + 1)begin
            assign o_rdoq_est_level[o][p] = i_rdoq_est_level_d[3][o][p];
        end
    end
    for (o = 0; o < 24; o = o + 1) begin
        for(p = 0; p < 2; p = p + 1)begin
            assign o_rdoq_est_run[o][p] = i_rdoq_est_run_d[3][o][p];
        end
    end
endgenerate


//delay operation
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 4; i = i + 1)begin
                i_valid_d[i]            <=  0;
            end
            for(i = 0; i < 4; i = i + 1)begin
                for(j = 0; j < 32; j = j + 1)begin
                    src_coef_sign[i][j]     <=  0;
                end
            end
            for(i = 0; i < 4; i = i + 1)begin
                i_width_log2_d[i]       <=  0;
                i_height_log2_d[i]      <=  0;
                i_q_bits_d[i]           <=  0;
                i_err_scale_d[i]        <=  0;
                i_lambda_d[i]           <=  0;
                i_diff_scale_d[i]       <=  0;
            end
            for(i = 0; i < 4; i = i + 1)begin
                for(j = 0; j < 32; j = j + 1)begin
                    i_left_pos_d[i][j]      <=  0;
                    i_bottom_pos_d[i][j]    <=  0;
                end
            end
            for(m = 0; m < 4; m = m + 1)begin
                for(j = 0; j < 6; j = j + 1)begin
                    for(k = 0; k < 12; k = k + 1)begin
                        for(l = 0; l < 2; l = l + 1)begin
                            i_rdoq_est_last_d[m][j][k][l] <= 0;
                        end
                    end
                end
                for (i = 0; i < 24; i = i + 1) begin
                    for(j = 0; j < 2; j = j + 1)begin
                        i_rdoq_est_level_d[m][i][j] <= 0;
                    end
                end
                for (i = 0; i < 24; i = i + 1) begin
                    for(j = 0; j < 2; j = j + 1)begin
                        i_rdoq_est_run_d[m][i][j] <= 0;
                    end
                end
            end
        end
        else begin
            i_valid_d[0]            <=      i_valid;
            i_width_log2_d[0]       <=      i_width_log2;
            i_height_log2_d[0]      <=      i_height_log2;
            i_q_bits_d[0]           <=      i_q_bits;
            i_err_scale_d[0]        <=      i_err_scale;
            i_lambda_d[0]           <=      i_lambda;
            i_diff_scale_d[0]       <=      i_diff_scale;
            
            for(i = 0; i < 32; i = i + 1)begin
                src_coef_sign[0][i]     <=  i_data[i][15]; 
            end
            
            for(j = 0; j < 32; j = j + 1)begin
                i_left_pos_d[0][j]      <=  i_left_pos[j];
                i_bottom_pos_d[0][j]    <=  i_bottom_pos[j];
            end
            for(j = 0; j < 6; j = j + 1)begin
                for(k = 0; k < 12; k = k + 1)begin
                    for(l = 0; l < 2; l = l + 1)begin
                        i_rdoq_est_last_d[0][j][k][l] <= i_rdoq_est_last[j][k][l];
                    end
                end
            end
            for (i = 0; i < 24; i = i + 1) begin
                for(j = 0; j < 2; j = j + 1)begin
                    i_rdoq_est_level_d[0][i][j] <= i_rdoq_est_level[i][j];
                end
            end
            for (i = 0; i < 24; i = i + 1) begin
                for(j = 0; j < 2; j = j + 1)begin
                    i_rdoq_est_run_d[0][i][j] <= i_rdoq_est_run[i][j];
                end
            end

            for(i = 1; i < 4; i = i + 1)begin
                i_valid_d[i]        <=  i_valid_d[i-1];
            end
            for(i = 1; i < 4; i = i + 1)begin
                for(j = 0; j < 32; j = j + 1)begin
                    src_coef_sign[i][j]     <=  src_coef_sign[i-1][j];
                end
            end
            for(i = 1; i < 4; i = i + 1)begin
                i_width_log2_d[i]       <=  i_width_log2_d[i-1];
                i_height_log2_d[i]      <=  i_height_log2_d[i-1];
                i_q_bits_d[i]           <=  i_q_bits_d[i-1];
                i_err_scale_d[i]        <=  i_err_scale_d[i-1];
                i_lambda_d[i]           <=  i_lambda_d[i-1];
                i_diff_scale_d[i]       <=  i_diff_scale_d[i-1];
            end
            
            
            for(i = 1; i < 4; i = i + 1)begin
                for(j = 0; j < 32; j = j + 1)begin
                    i_left_pos_d[i][j]      <=  i_left_pos_d[i-1][j];
                    i_bottom_pos_d[i][j]    <=  i_bottom_pos_d[i-1][j];
                end
            end

            for(m = 1; m < 4; m = m + 1)begin
                for(j = 0; j < 6; j = j + 1)begin
                    for(k = 0; k < 12; k = k + 1)begin
                        for(l = 0; l < 2; l = l + 1)begin
                            i_rdoq_est_last_d[m][j][k][l] <= i_rdoq_est_last_d[m-1][j][k][l];
                        end
                    end
                end
                for (i = 0; i < 24; i = i + 1) begin
                    for(j = 0; j < 2; j = j + 1)begin
                        i_rdoq_est_level_d[m][i][j] <= i_rdoq_est_level_d[m-1][i][j];
                    end
                end
                for (i = 0; i < 24; i = i + 1) begin
                    for(j = 0; j < 2; j = j + 1)begin
                        i_rdoq_est_run_d[m][i][j] <= i_rdoq_est_run_d[m-1][i][j];
                    end
                end
            end

        end
    end




//pipe 1

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                temp_level[i]           <=  0; 
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                temp_level[i]           <=  i_data_abs[i] * q_value ;
            end
        end
    end



//pipe 2

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double[i]     <=  0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double[i]     <=  temp_level[i] > COM_INT32_MAX - (1 << (i_q_bits_d[0] - 1)) ? COM_INT32_MAX - (1 << (i_q_bits_d[0] - 1)) : temp_level[i] ;
            end
        end
    end

//pipe 3

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double_d1[i]      <=  0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double_d1[i]      <=  level_double[i];
            end
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                max_abs_level[i]    <=  0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                max_abs_level[i]    <=  level_double[i] >> i_q_bits_d[1];
            end
        end
    end

//pipe 4

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double_d2[i]      <=  0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double_d2[i]      <=  level_double_d1[i];
            end
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                max_abs_level_t[i]      <=      0;   
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                max_abs_level_t[i]      <=      (level_double_d1[i] - (max_abs_level[i] << i_q_bits_d[2])) < (1 << (i_q_bits_d[2] - 1)) ? max_abs_level[i] : max_abs_level[i] + 1;
            end
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            o_en    <=  0;
        end
        else if(i_valid_d[2])begin
            o_en    <=  1;
        end
    end

`ifdef file_write    //test bench

    initial begin 
    integer fp_pq_w1;
    integer wr_pq_j,wr_pq_k;
    reg     signed  [63: 0]     pq_data        [0 : 63]    ;
        #10;
        fp_pq_w1 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_16x16.txt", "w");
        for (wr_pq_j = 0; wr_pq_j < 16; wr_pq_j = wr_pq_j + 1) begin
            for (wr_pq_k = 0; wr_pq_k < 16; wr_pq_k = wr_pq_k + 1) begin
                pq_data[wr_pq_k] = o_data[wr_pq_k];
            end
            #2;
            $fwrite(fp_pq_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pq_data[0 ], pq_data[1 ], pq_data[2 ], pq_data[3 ], pq_data[4 ], pq_data[5 ], pq_data[6 ], pq_data[7 ], 
                pq_data[8 ], pq_data[9 ], pq_data[10], pq_data[11], pq_data[12], pq_data[13], pq_data[14], pq_data[15]);
        end
        $fclose(fp_pq_w1);
    end
    
    initial begin 
    integer fp_pq_w1;
    integer wr_pq_j,wr_pq_k;
    reg     signed  [63: 0]     pq_data        [0 : 63]    ;
        #42;
        fp_pq_w1 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_32x32.txt", "w");
        for (wr_pq_j = 0; wr_pq_j < 32; wr_pq_j = wr_pq_j + 1) begin
            for (wr_pq_k = 0; wr_pq_k < 32; wr_pq_k = wr_pq_k + 1) begin
                pq_data[wr_pq_k] = o_data[wr_pq_k];
            end
            #2;
            $fwrite(fp_pq_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            pq_data[0 ], pq_data[1 ], pq_data[2 ], pq_data[3 ], pq_data[4 ], pq_data[5 ], pq_data[6 ], pq_data[7 ],
            pq_data[8 ], pq_data[9 ], pq_data[10], pq_data[11], pq_data[12], pq_data[13], pq_data[14], pq_data[15], 
            pq_data[16], pq_data[17], pq_data[18], pq_data[19], pq_data[20], pq_data[21], pq_data[22], pq_data[23], 
            pq_data[24], pq_data[25], pq_data[26], pq_data[27], pq_data[28], pq_data[29], pq_data[30], pq_data[31]);
        end
        $fclose(fp_pq_w1);
    end

    initial begin 
    integer fp_pq_w1;
    integer wr_pq_j,wr_pq_k;
    reg     signed  [63: 0]     pq_data        [0 : 63]    ;
        #106;
        fp_pq_w1 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_8x8.txt", "w");
        for (wr_pq_j = 0; wr_pq_j < 8; wr_pq_j = wr_pq_j + 1) begin
            for (wr_pq_k = 0; wr_pq_k < 8; wr_pq_k = wr_pq_k + 1) begin
                pq_data[wr_pq_k] = o_data[wr_pq_k];
            end
            #2;
            $fwrite(fp_pq_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
            pq_data[0 ], pq_data[1 ], pq_data[2 ], pq_data[3 ], pq_data[4 ], pq_data[5 ], pq_data[6 ], pq_data[7 ]);
        end
        $fclose(fp_pq_w1);
    end

    initial begin 
    integer fp_pq_w1;
    integer wr_pq_j,wr_pq_k;
    reg     signed  [63: 0]     pq_data        [0 : 63]    ;
        #122;
        fp_pq_w1 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_4x4.txt", "w");
        for (wr_pq_j = 0; wr_pq_j < 4; wr_pq_j = wr_pq_j + 1) begin
            for (wr_pq_k = 0; wr_pq_k < 4; wr_pq_k = wr_pq_k + 1) begin
                pq_data[wr_pq_k] = o_data[wr_pq_k];
            end
            #2;
            $fwrite(fp_pq_w1, "%6d %6d %6d %6d \n", 
            pq_data[0 ], pq_data[1 ], pq_data[2 ], pq_data[3 ]);
        end
        $fclose(fp_pq_w1);
    end












`endif

endmodule