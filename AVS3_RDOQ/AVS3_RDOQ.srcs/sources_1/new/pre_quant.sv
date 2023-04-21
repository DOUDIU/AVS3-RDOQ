`include "rdoq_header.vh"

module pre_quant(      
//system clk and rest           
    input                                           clk                                         ,
    input                                           rst_n                                       ,

//input parameter                                               
    input           [`w_q_value         - 1 : 0]    q_value                                     ,
    input           [`w_q_bits          - 1 : 0]    i_q_bits                                    ,

//input data                    
    input                                           i_valid                                     ,
    input   signed  [`w_data_in         - 1 : 0]    i_data              [0 : 31]                ,

//output parameter              
    output          [`w_q_bits          - 1 : 0]    o_q_bits                                    ,

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
reg             [`w_q_bits          - 1 : 0]    i_q_bits_d          [0 :  3]                        ;

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
assign  o_q_bits        =   i_q_bits_d[3];


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
                i_q_bits_d[i]           <=  0;
            end
        end
        else begin
            i_valid_d[0]            <=      i_valid;
            i_q_bits_d[0]           <=      i_q_bits;
            for(i = 0; i < 32; i = i + 1)begin
                src_coef_sign[0][i]     <=  i_data[i][15]; 
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
                i_q_bits_d[i]           <=  i_q_bits_d[i-1];
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

//16x16
    initial begin 
    integer fp_pq_w0,fp_pq_w1;
    integer wr_pq_j,wr_pq_k;
    reg     signed  [63: 0]     pq_data        [0 : 63]    ;
        #10;
        fp_pq_w0 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_16x16_0.txt", "w");
        fp_pq_w1 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_16x16_1.txt", "w");
        for (wr_pq_j = 0; wr_pq_j < 16; wr_pq_j = wr_pq_j + 1) begin
            for (wr_pq_k = 0; wr_pq_k < 32; wr_pq_k = wr_pq_k + 1) begin
                pq_data[wr_pq_k] = o_data[wr_pq_k];
            end
            #2;
            $fwrite(fp_pq_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pq_data[0 ], pq_data[1 ], pq_data[2 ], pq_data[3 ], pq_data[4 ], pq_data[5 ], pq_data[6 ], pq_data[7 ], 
                pq_data[8 ], pq_data[9 ], pq_data[10], pq_data[11], pq_data[12], pq_data[13], pq_data[14], pq_data[15]);
            $fwrite(fp_pq_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pq_data[16], pq_data[17], pq_data[18], pq_data[19], pq_data[20], pq_data[21], pq_data[22], pq_data[23], 
                pq_data[24], pq_data[25], pq_data[26], pq_data[27], pq_data[28], pq_data[29], pq_data[30], pq_data[31]);
        end
        $fclose(fp_pq_w0);
        $fclose(fp_pq_w1);
    end
    
//32x32
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

//8x8
    initial begin 
    integer fp_pq_w0,fp_pq_w1,fp_pq_w2,fp_pq_w3;
    integer wr_pq_j,wr_pq_k;
    reg     signed  [63: 0]     pq_data        [0 : 63]    ;
        #106;
        fp_pq_w0 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_8x8_0.txt", "w");
        fp_pq_w1 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_8x8_1.txt", "w");
        fp_pq_w2 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_8x8_2.txt", "w");
        fp_pq_w3 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_8x8_3.txt", "w");
        for (wr_pq_j = 0; wr_pq_j < 8; wr_pq_j = wr_pq_j + 1) begin
            for (wr_pq_k = 0; wr_pq_k < 32; wr_pq_k = wr_pq_k + 1) begin
                pq_data[wr_pq_k] = o_data[wr_pq_k];
            end
            #2;
            $fwrite(fp_pq_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pq_data[0 ], pq_data[1 ], pq_data[2 ], pq_data[3 ], pq_data[4 ], pq_data[5 ], pq_data[6 ], pq_data[7 ]);
            $fwrite(fp_pq_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pq_data[8 ], pq_data[9 ], pq_data[10], pq_data[11], pq_data[12], pq_data[13], pq_data[14], pq_data[15]);
            $fwrite(fp_pq_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pq_data[16], pq_data[17], pq_data[18], pq_data[19], pq_data[20], pq_data[21], pq_data[22], pq_data[23]);
            $fwrite(fp_pq_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pq_data[24], pq_data[25], pq_data[26], pq_data[27], pq_data[28], pq_data[29], pq_data[30], pq_data[31]);
        end
        $fclose(fp_pq_w0);
        $fclose(fp_pq_w1);
        $fclose(fp_pq_w2);
        $fclose(fp_pq_w3);
    end

//4x4
    initial begin 
    integer fp_pq_w0,fp_pq_w1,fp_pq_w2,fp_pq_w3,fp_pq_w4,fp_pq_w5,fp_pq_w6,fp_pq_w7;
    integer wr_pq_j,wr_pq_k;
    reg     signed  [63: 0]     pq_data        [0 : 63]    ;
        #122;
        fp_pq_w0 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_4x4_0.txt", "w");
        fp_pq_w1 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_4x4_1.txt", "w");
        fp_pq_w2 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_4x4_2.txt", "w");
        fp_pq_w3 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_4x4_3.txt", "w");
        fp_pq_w4 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_4x4_4.txt", "w");
        fp_pq_w5 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_4x4_5.txt", "w");
        fp_pq_w6 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_4x4_6.txt", "w");
        fp_pq_w7 = $fopen("../../../../../result/pq/pq_fpga_coeff/pq_fpga_4x4_7.txt", "w");
        for (wr_pq_j = 0; wr_pq_j < 4; wr_pq_j = wr_pq_j + 1) begin
            for (wr_pq_k = 0; wr_pq_k < 32; wr_pq_k = wr_pq_k + 1) begin
                pq_data[wr_pq_k] = o_data[wr_pq_k];
            end
            #2;
            $fwrite(fp_pq_w0, "%6d %6d %6d %6d \n", 
                pq_data[0 ], pq_data[1 ], pq_data[2 ], pq_data[3 ]);
            $fwrite(fp_pq_w1, "%6d %6d %6d %6d \n", 
                pq_data[4 ], pq_data[5 ], pq_data[6 ], pq_data[7 ]);
            $fwrite(fp_pq_w2, "%6d %6d %6d %6d \n", 
                pq_data[8 ], pq_data[9 ], pq_data[10], pq_data[11]);
            $fwrite(fp_pq_w3, "%6d %6d %6d %6d \n", 
                pq_data[12], pq_data[13], pq_data[14], pq_data[15]);
            $fwrite(fp_pq_w4, "%6d %6d %6d %6d \n", 
                pq_data[16], pq_data[17], pq_data[18], pq_data[19]);
            $fwrite(fp_pq_w5, "%6d %6d %6d %6d \n", 
                pq_data[20], pq_data[21], pq_data[22], pq_data[23]);
            $fwrite(fp_pq_w6, "%6d %6d %6d %6d \n", 
                pq_data[24], pq_data[25], pq_data[26], pq_data[27]);
            $fwrite(fp_pq_w7, "%6d %6d %6d %6d \n", 
                pq_data[28], pq_data[29], pq_data[30], pq_data[31]);
        end
        $fclose(fp_pq_w0);
        $fclose(fp_pq_w1);
        $fclose(fp_pq_w2);
        $fclose(fp_pq_w3);
        $fclose(fp_pq_w4);
        $fclose(fp_pq_w5);
        $fclose(fp_pq_w6);
        $fclose(fp_pq_w7);
    end

`endif

endmodule