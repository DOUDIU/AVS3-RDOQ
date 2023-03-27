module pre_quant(      
//system clk and rest           
    input                       clk                                                 ,
    input                       rst_n                                               ,

//input parameter                               
    input           [21: 0]     q_value                                             ,
    input           [4 : 0]     q_bits                                              ,

    input           [2 : 0]     i_width_log2                                        ,//the value is between 2 and 6
    input           [2 : 0]     i_height_log2                                       ,//the value is between 2 and 6
    input           [2 : 0]     i_ch_type                                           ,//Y_C 0; U_C 1; V_C 2;
    input           [4 : 0]     i_q_bits                                            ,
    input   signed  [29: 0]     i_err_scale                                         ,
    input   signed  [63: 0]     i_lambda                                            ,

    input           [31: 0]     i_rdoq_est_cbf      [0 :  2][0 :  1]                ,//pending
    input           [31: 0]     i_rdoq_est_last     [0 :  1][0 :  5][0 : 11][0 : 1] ,//pending
    input           [31: 0]     i_rdoq_est_level    [0 : 23][0 :  1]                ,//pending
    input           [31: 0]     i_rdoq_est_run      [0 : 23][0 :  1]                ,//pending
    input           [9 : 0]     i_left_pos          [0 : 31]                        ,//the max value is 1023
    input           [9 : 0]     i_bottom_pos        [0 : 31]                        ,//the max value is 1023

//input data                    
    input                       i_valid                                             ,
    input   signed  [15: 0]     i_data              [0 : 31]                        ,

//output parameter              
    output          [2 : 0]     o_width_log2                                        ,//the value is between 2 and 6
    output          [2 : 0]     o_height_log2                                       ,//the value is between 2 and 6
    output          [2 : 0]     o_ch_type                                           ,//Y_C 0; U_C 1; V_C 2;
    output          [4 : 0]     o_q_bits                                            ,
    output  signed  [29: 0]     o_err_scale                                         ,
    output  signed  [63: 0]     o_lambda                                            ,

    output          [31: 0]     o_rdoq_est_cbf      [0 :  2][0 :  1]                ,//pending
    output          [31: 0]     o_rdoq_est_last     [0 :  1][0 :  5][0 : 11][0 : 1] ,//pending
    output          [31: 0]     o_rdoq_est_level    [0 : 23][0 :  1]                ,//pending
    output          [31: 0]     o_rdoq_est_run      [0 : 23][0 :  1]                ,//pending
    output          [9 : 0]     o_left_pos          [0 : 31]                        ,//the max value is 1023
    output          [9 : 0]     o_bottom_pos        [0 : 31]                        ,//the max value is 1023

//output data       
    output                      o_valid                                             ,
    output  signed  [63: 0]     o_level_double      [0 : 31]                        ,
    output  signed  [15: 0]     o_data              [0 : 31]                            
);

//parameter definition
parameter   COM_INT32_MAX   =   64'h7FFFFFFF    ;


//integer definition
integer i,j,k,l,m   ;
genvar  o,p,q,r     ;



//reg definition
reg     signed  [63: 0]     temp_level          [0 : 31]                                ;//16 + 22 = 38
reg     signed  [63: 0]     level_double        [0 : 31]                                ;
reg     signed  [63: 0]     level_double_d1     [0 : 31]                                ;
reg     signed  [63: 0]     level_double_d2     [0 : 31]                                ;
reg             [31: 0]     max_abs_level       [0 : 31]                                ;
reg             [31: 0]     max_abs_level_t     [0 : 31]                                ;

reg                         src_coef_sign       [0 : 3][0 : 31]                         ;

reg             [4 : 0]     q_bits_d1                                                   ;   
reg             [4 : 0]     q_bits_d2                                                   ;   
reg             [4 : 0]     q_bits_d3                                                   ;

reg                         i_valid_d           [0 :  3]                                ;
reg             [2 : 0]     i_width_log2_d      [0 :  3]                                ;
reg             [2 : 0]     i_height_log2_d     [0 :  3]                                ;
reg             [2 : 0]     i_ch_type_d         [0 :  3]                                ;
reg             [4 : 0]     i_q_bits_d          [0 :  3]                                ;
reg     signed  [29: 0]     i_err_scale_d       [0 :  3]                                ;
reg     signed  [63: 0]     i_lambda_d          [0 :  3]                                ;

reg             [31: 0]     i_rdoq_est_cbf_d    [0 :  3][0 :  2][0 :  1]                ;//pending
reg             [31: 0]     i_rdoq_est_last_d   [0 :  3][0 :  1][0 :  5][0 : 11][0 : 1] ;//pending
reg             [31: 0]     i_rdoq_est_level_d  [0 :  3][0 : 23][0 :  1]                ;//pending
reg             [31: 0]     i_rdoq_est_run_d    [0 :  3][0 : 23][0 :  1]                ;//pending
reg             [9 : 0]     i_left_pos_d        [0 :  3][0 : 31]                        ;
reg             [9 : 0]     i_bottom_pos_d      [0 :  3][0 : 31]                        ;

reg                         o_en                                                        ;

//wire definition   
wire            [15: 0]     i_data_abs          [0 : 31]                                ;
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
assign  o_ch_type       =   i_ch_type_d[3];
assign  o_q_bits        =   i_q_bits_d[3];
assign  o_err_scale     =   i_err_scale_d[3];
assign  o_lambda        =   i_lambda_d[3];
assign  o_left_pos      =   i_left_pos_d[3]; 
assign  o_bottom_pos    =   i_bottom_pos_d[3];

generate
    for (o = 0; o < 3; o = o + 1) begin
        for(p = 0; p < 2; p = p + 1)begin
            assign o_rdoq_est_cbf[o][p] = i_rdoq_est_cbf_d[3][o][p];
        end
    end
    for (o = 0; o < 2; o = o + 1) begin
        for(p = 0; p < 6; p = p + 1)begin
            for(q = 0; q < 12; q = q + 1)begin
                for(r = 0; r < 2; r = r + 1)begin
                    assign o_rdoq_est_last[o][p][q][r] = i_rdoq_est_last_d[3][o][p][q][r];
                end
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
                i_ch_type_d[i]          <=  0;
                i_q_bits_d[i]           <=  0;
                i_err_scale_d[i]        <=  0;
                i_lambda_d[i]           <=  0;
            end
            for(i = 0; i < 4; i = i + 1)begin
                for(j = 0; j < 32; j = j + 1)begin
                    i_left_pos_d[i][j]      <=  0;
                    i_bottom_pos_d[i][j]    <=  0;
                end
            end
            for(m = 0; m < 4; m = m + 1)begin
                for (i = 0; i < 3; i = i + 1) begin
                    for(j = 0; j < 2; j = j + 1)begin
                        i_rdoq_est_cbf_d[m][i][j] <= 0;
                    end
                end
                for (i = 0; i < 2; i = i + 1) begin
                    for(j = 0; j < 6; j = j + 1)begin
                        for(k = 0; k < 12; k = k + 1)begin
                            for(l = 0; l < 2; l = l + 1)begin
                                i_rdoq_est_last_d[m][i][j][k][l] <= 0;
                            end
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
            i_ch_type_d[0]          <=      i_ch_type;
            i_q_bits_d[0]           <=      i_q_bits;
            i_err_scale_d[0]        <=      i_err_scale;
            i_lambda_d[0]           <=      i_lambda;
            
            for(j = 0; j < 32; j = j + 1)begin
                i_left_pos_d[0][j]      <=  i_left_pos[j]       ;
                i_bottom_pos_d[0][j]    <=  i_bottom_pos[j]     ;
            end
            for (i = 0; i < 3; i = i + 1) begin
                for(j = 0; j < 2; j = j + 1)begin
                    i_rdoq_est_cbf_d[0][i][j] <= i_rdoq_est_cbf[i][j];
                end
            end
            for (i = 0; i < 2; i = i + 1) begin
                for(j = 0; j < 6; j = j + 1)begin
                    for(k = 0; k < 12; k = k + 1)begin
                        for(l = 0; l < 2; l = l + 1)begin
                            i_rdoq_est_last_d[0][i][j][k][l] <= i_rdoq_est_last[i][j][k][l];
                        end
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
                i_ch_type_d[i]          <=  i_ch_type_d[i-1];
                i_q_bits_d[i]           <=  i_q_bits_d[i-1];
                i_err_scale_d[i]        <=  i_err_scale_d[i-1];
                i_lambda_d[i]           <=  i_lambda_d[i-1];
            end
            
            
            for(i = 1; i < 4; i = i + 1)begin
                for(j = 0; j < 32; j = j + 1)begin
                    i_left_pos_d[i][j]      <=  i_left_pos_d[i-1][j]  ;
                    i_bottom_pos_d[i][j]    <=  i_bottom_pos_d[i-1][j];
                end
            end

            for(m = 1; m < 4; m = m + 1)begin
                for (i = 0; i < 3; i = i + 1) begin
                    for(j = 0; j < 2; j = j + 1)begin
                        i_rdoq_est_cbf_d[m][i][j] <= i_rdoq_est_cbf_d[m-1][i][j];
                    end
                end
                for (i = 0; i < 2; i = i + 1) begin
                    for(j = 0; j < 6; j = j + 1)begin
                        for(k = 0; k < 12; k = k + 1)begin
                            for(l = 0; l < 2; l = l + 1)begin
                                i_rdoq_est_last_d[m][i][j][k][l] <= i_rdoq_est_last_d[m-1][i][j][k][l];
                            end
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
                src_coef_sign[0][i]     <=  0;   
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                temp_level[i]           <=  i_data_abs[i] * q_value ;
                src_coef_sign[0][i]     <=  i_data[i][15]; 
            end
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            q_bits_d1   <=  0           ;
        end
        else begin
            q_bits_d1   <=  q_bits      ;
        end
    end


//pipe 2

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            q_bits_d2   <=  0           ;
        end
        else begin
            q_bits_d2   <=  q_bits_d1   ;
        end
    end


    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double[i]     <=  0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double[i]     <=  temp_level[i] > COM_INT32_MAX - (1 << (q_bits_d1 - 1)) ? COM_INT32_MAX - (1 << (q_bits_d1 - 1)) : temp_level[i] ;
            end
        end
    end

//pipe 3

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            q_bits_d3   <=  0           ;
            for(i = 0; i < 32; i = i + 1)begin
                level_double_d1[i]      <=  0;
            end
        end
        else begin
            q_bits_d3   <=  q_bits_d2   ;
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
                max_abs_level[i]    <=  level_double[i] >> q_bits_d2;
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
                max_abs_level_t[i]      <=      (level_double_d1[i] - (max_abs_level[i] << q_bits_d3)) < (1 << (q_bits_d3 - 1)) ? max_abs_level[i] : max_abs_level[i] + 1;
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


// //test bench
// integer fp_r, fp_w, rd_i, rd_j, rd_k, rd_l, wr_i, wr_j, wr_k;
// reg     signed  [15: 0]     wr_data [0 : 63]    ;
// initial begin 
//     #2;
//     #8;
//     //16x16
//     fp_w = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_16x16.txt", "w");
//     for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
//         for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
//             wr_data[wr_k] = o_data[wr_k];
//         end
//         #2;
//         $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
//             wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
//             wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
//     end
//     $fclose(fp_w);
// end



endmodule