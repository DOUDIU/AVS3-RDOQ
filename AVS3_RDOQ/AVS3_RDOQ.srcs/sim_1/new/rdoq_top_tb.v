`timescale 1ns / 1ns

module rdoq_top_tb();

localparam  BIT_DEPTH   = 16    ,
            OUT_WIDTH   = 16    ;
localparam  Y_C         = 3'd0  ,
            U_C         = 3'd1  ,
            V_C         = 3'd2  ;
localparam  SIZE4       = 3'd2  ,
            SIZE8       = 3'd3  ,
            SIZE16      = 3'd4  ,
            SIZE32      = 3'd5  ,
            SIZE64      = 3'd6  ;

integer fp_r, fp_w, rd_i, rd_j, rd_k, wr_i, wr_j, wr_k;

//system input
    reg                                 clk                 ;
    reg                                 reset               ;
//input parameter       
    reg             [2 : 0]             cu_width_log2       ;
    reg             [2 : 0]             cu_height_log2      ;
    reg             [6 : 0]             qp                  ;
    reg             [2 : 0]             ch_type             ;
    reg             [0 : 0]             is_intra            ;
    reg     signed  [63: 0]             lambda              ;
    reg             [3 : 0]             bit_depth           ;
//input data
    reg                                 i_valid;
    reg     signed  [BIT_DEPTH - 1 : 0] i_data[0 : 31]      ;
//output parameter 
    wire            [3 : 0]             final_X             ;
    wire            [3 : 0]             final_y             ;
//output coeff
    wire                                o_valid             ;
    wire    signed  [OUT_WIDTH - 1 : 0] o_data[0 : 31]      ;

//txt rd/wr
    reg     signed  [BIT_DEPTH - 1 : 0] rd_data[0 : 63]     ;
    reg     signed  [OUT_WIDTH - 1 : 0] wr_data[0 : 63]     ;


rdoq_top #(
    .IN_WIDTH               (BIT_DEPTH      ),
    .OUT_WIDTH              (OUT_WIDTH      )
)u_rdoq_top(
    //system clk and rest
    .clk                    (clk            ),
    .rst_n                  (reset          ),

    //input block information
    .cu_width_log2          (cu_width_log2  ),//the value is between 2 and 4
    .cu_height_log2         (cu_height_log2 ),//the value is between 2 and 4
    .qp                     (qp             ),
    .ch_type                (ch_type        ),//Y_C 0; U_C 1; Y_C 2;
    .is_intra               (is_intra       ),
    .lambda                 (lambda         ),
    .bit_depth              (bit_depth      ),

    //input block data
    .i_valid                (i_valid        ),
    .src_coef_0             (i_data[0 ]     ),
    .src_coef_1             (i_data[1 ]     ),
    .src_coef_2             (i_data[2 ]     ),
    .src_coef_3             (i_data[3 ]     ),
    .src_coef_4             (i_data[4 ]     ),
    .src_coef_5             (i_data[5 ]     ),
    .src_coef_6             (i_data[6 ]     ),
    .src_coef_7             (i_data[7 ]     ),
    .src_coef_8             (i_data[8 ]     ),
    .src_coef_9             (i_data[9 ]     ),
    .src_coef_10            (i_data[10]     ),
    .src_coef_11            (i_data[11]     ),
    .src_coef_12            (i_data[12]     ),
    .src_coef_13            (i_data[13]     ),
    .src_coef_14            (i_data[14]     ),
    .src_coef_15            (i_data[15]     ),
    .src_coef_16            (i_data[16]     ),
    .src_coef_17            (i_data[17]     ),
    .src_coef_18            (i_data[18]     ),
    .src_coef_19            (i_data[19]     ),
    .src_coef_20            (i_data[20]     ),
    .src_coef_21            (i_data[21]     ),
    .src_coef_22            (i_data[22]     ),
    .src_coef_23            (i_data[23]     ),
    .src_coef_24            (i_data[24]     ),
    .src_coef_25            (i_data[25]     ),
    .src_coef_26            (i_data[26]     ),
    .src_coef_27            (i_data[27]     ),
    .src_coef_28            (i_data[28]     ),
    .src_coef_29            (i_data[29]     ),
    .src_coef_30            (i_data[30]     ),
    .src_coef_31            (i_data[31]     ),

    //output block data
    .o_valid                (o_valid        ),
    .dst_coef_0             (o_data[0 ]     ),
    .dst_coef_1             (o_data[1 ]     ),
    .dst_coef_2             (o_data[2 ]     ),
    .dst_coef_3             (o_data[3 ]     ),
    .dst_coef_4             (o_data[4 ]     ),
    .dst_coef_5             (o_data[5 ]     ),
    .dst_coef_6             (o_data[6 ]     ),
    .dst_coef_7             (o_data[7 ]     ),
    .dst_coef_8             (o_data[8 ]     ),
    .dst_coef_9             (o_data[9 ]     ),
    .dst_coef_10            (o_data[10]     ),
    .dst_coef_11            (o_data[11]     ),
    .dst_coef_12            (o_data[12]     ),
    .dst_coef_13            (o_data[13]     ),
    .dst_coef_14            (o_data[14]     ),
    .dst_coef_15            (o_data[15]     ),
    .dst_coef_16            (o_data[16]     ),
    .dst_coef_17            (o_data[17]     ),
    .dst_coef_18            (o_data[18]     ),
    .dst_coef_19            (o_data[19]     ),
    .dst_coef_20            (o_data[20]     ),
    .dst_coef_21            (o_data[21]     ),
    .dst_coef_22            (o_data[22]     ),
    .dst_coef_23            (o_data[23]     ),
    .dst_coef_24            (o_data[24]     ),
    .dst_coef_25            (o_data[25]     ),
    .dst_coef_26            (o_data[26]     ),
    .dst_coef_27            (o_data[27]     ),
    .dst_coef_28            (o_data[28]     ),
    .dst_coef_29            (o_data[29]     ),
    .dst_coef_30            (o_data[30]     ),
    .dst_coef_31            (o_data[31]     ),

    //the last none zero position
    .final_X                (final_X        ),
    .final_y                (final_y        )
);


always #1 begin
    clk <= ~clk;
end

//read
initial begin
    clk             =       0;
    reset           =       0;

    cu_width_log2   =   3 'd0;
    cu_height_log2  =   3 'd0;
    qp              =   7 'd0;
    ch_type         =   3 'd0;
    is_intra        =   1 'd0;
    lambda          =   64'd0;
    bit_depth       =   4 'd0;

    i_valid         =       0;
    
    for (rd_i = 0; rd_i < 32; rd_i = rd_i + 1) begin
        i_data[rd_i] = 0;
    end
    #2;
    reset = 1;
    //Start
    //16x16
    i_valid = 1;
    cu_width_log2   =   SIZE16          ;
    cu_height_log2  =   SIZE16          ;
    qp              =   7 'd63          ;
    ch_type         =   Y_C             ;
    is_intra        =   1 'd1           ;
    lambda          =   64'd10131659    ;
    bit_depth       =   4 'd10          ;
    fp_r = $fopen("../../../../../result/origin_data/origin_data_16x16.txt", "r");
    for (rd_i = 0; rd_i < 16; rd_i = rd_i + 1) begin
        $fscanf(fp_r, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
            rd_data[0 ], rd_data[1 ], rd_data[2 ], rd_data[3 ], rd_data[4 ], rd_data[5 ], rd_data[6 ], rd_data[7 ],
            rd_data[8 ], rd_data[9 ], rd_data[10], rd_data[11], rd_data[12], rd_data[13], rd_data[14], rd_data[15]);

            for (rd_k = 0; rd_k < 16; rd_k = rd_k + 1) begin
                i_data[rd_k] = rd_data[rd_k];
            end
            #2;
            i_valid = 0;
    end
    $fclose(fp_r);


    for (rd_i = 0; rd_i < 32; rd_i = rd_i + 1) begin
        i_data[rd_i] = 0;
    end
    //8x8
    i_valid = 1;
    cu_width_log2   =   SIZE8           ;
    cu_height_log2  =   SIZE8           ;
    qp              =   7 'd63          ;
    ch_type         =   Y_C             ;
    is_intra        =   1 'd1           ;
    lambda          =   64'd10131659    ;
    bit_depth       =   4 'd10          ;
    fp_r = $fopen("../../../../../result/origin_data/origin_data_8x8.txt", "r");
    for (rd_i = 0; rd_i < 8; rd_i = rd_i + 1) begin
        $fscanf(fp_r, "%d %d %d %d %d %d %d %d", 
            rd_data[0 ], rd_data[1 ], rd_data[2 ], rd_data[3 ], rd_data[4 ], rd_data[5 ], rd_data[6 ], rd_data[7 ]);

        for (rd_k = 0; rd_k < 8; rd_k = rd_k + 1) begin
            i_data[rd_k] = rd_data[rd_k];
        end
        #2;
        i_valid = 0;
    end
    $fclose(fp_r);

    for (rd_i = 0; rd_i < 32; rd_i = rd_i + 1) begin
        i_data[rd_i] = 0;
    end
    //4x4
    i_valid = 1;
    cu_width_log2   =   SIZE4           ;
    cu_height_log2  =   SIZE4           ;
    qp              =   7 'd63          ;
    ch_type         =   Y_C             ;
    is_intra        =   1 'd1           ;
    lambda          =   64'd10131659    ;
    bit_depth       =   4 'd10          ;
    fp_r = $fopen("../../../../../result/origin_data/origin_data_4x4.txt", "r");
    for (rd_i = 0; rd_i < 4; rd_i = rd_i + 1) begin
        $fscanf(fp_r, "%d %d %d %d", rd_data[0 ], rd_data[1 ], rd_data[2 ], rd_data[3 ]);

        for (rd_k = 0; rd_k < 4; rd_k = rd_k + 1) begin
            i_data[rd_k] = rd_data[rd_k];
        end
        #2;
        i_valid = 0; 
    end
    $fclose(fp_r);

    
    for (rd_i = 0; rd_i < 32; rd_i = rd_i + 1) begin
        i_data[rd_i] = 0;
    end
    //32x32
    i_valid = 1;
    cu_width_log2   =   SIZE32          ;
    cu_height_log2  =   SIZE32          ;
    qp              =   7 'd63          ;
    ch_type         =   Y_C             ;
    is_intra        =   1 'd1           ;
    lambda          =   64'd10131659    ;
    bit_depth       =   4 'd10          ;
    fp_r = $fopen("../../../../../result/origin_data/origin_data_32x32.txt", "r");
    for (rd_i = 0; rd_i < 32; rd_i = rd_i + 1) begin
        $fscanf(fp_r, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
            rd_data[0 ], rd_data[1 ], rd_data[2 ], rd_data[3 ], rd_data[4 ], rd_data[5 ], rd_data[6 ], rd_data[7 ], 
            rd_data[8 ], rd_data[9 ], rd_data[10], rd_data[11], rd_data[12], rd_data[13], rd_data[14], rd_data[15], 
            rd_data[16], rd_data[17], rd_data[18], rd_data[19], rd_data[20], rd_data[21], rd_data[22], rd_data[23], 
            rd_data[24], rd_data[25], rd_data[26], rd_data[27], rd_data[28], rd_data[29], rd_data[30], rd_data[31]);
            
        for (rd_k = 0; rd_k < 32; rd_k = rd_k + 1) begin
            i_data[rd_k] = rd_data[rd_k];
        end
        #2;
        i_valid = 0; 
    end
    $fclose(fp_r);

    for (rd_i = 0; rd_i < 32; rd_i = rd_i + 1) begin
        i_data[rd_i] = 0;
    end
    //64x64
    i_valid = 1;
    cu_width_log2   =   SIZE64          ;
    cu_height_log2  =   SIZE64          ;
    qp              =   7 'd63          ;
    ch_type         =   Y_C             ;
    is_intra        =   1 'd1           ;
    lambda          =   64'd10131659    ;
    bit_depth       =   4 'd10          ;
    fp_r = $fopen("../../../../../result/origin_data/origin_data_64x64.txt", "r");
    for (rd_i = 0; rd_i < 128; rd_i = rd_i + 1) begin
        $fscanf(fp_r, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
            rd_data[0 ], rd_data[1 ], rd_data[2 ], rd_data[3 ], rd_data[4 ], rd_data[5 ], rd_data[6 ], rd_data[7 ], 
            rd_data[8 ], rd_data[9 ], rd_data[10], rd_data[11], rd_data[12], rd_data[13], rd_data[14], rd_data[15], 
            rd_data[16], rd_data[17], rd_data[18], rd_data[19], rd_data[20], rd_data[21], rd_data[22], rd_data[23], 
            rd_data[24], rd_data[25], rd_data[26], rd_data[27], rd_data[28], rd_data[29], rd_data[30], rd_data[31]);
            
        for (rd_k = 0; rd_k < 32; rd_k = rd_k + 1) begin
            i_data[rd_k] = rd_data[rd_k];
        end
        #2;
        i_valid = 0; 
    end
    $fclose(fp_r);

    for (rd_i = 0; rd_i < 32; rd_i = rd_i + 1) begin
        i_data[rd_i] = 0;
    end

end

/*
//write
initial begin 
    #2;
    #558; //delay 279 clk
//DCT2
    //64x64
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_64x64.txt", "w");
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 4; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31], 
            wr_data[32], wr_data[33], wr_data[34], wr_data[35], wr_data[36], wr_data[37], wr_data[38], wr_data[39], wr_data[40], wr_data[41], wr_data[42], wr_data[43], wr_data[44], wr_data[45], wr_data[46], wr_data[47], 
            wr_data[48], wr_data[49], wr_data[50], wr_data[51], wr_data[52], wr_data[53], wr_data[54], wr_data[55], wr_data[56], wr_data[57], wr_data[58], wr_data[59], wr_data[60], wr_data[61], wr_data[62], wr_data[63]);
    end
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    end
    $fclose(fp_w);
    //32x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_32x32.txt", "w");
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //16x16
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_16x16.txt", "w");
    for (wr_i = 0; wr_i < 16; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //8x8
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_8x8.txt", "w");
    for (wr_i = 0; wr_i < 4; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //4x4
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_4x4.txt", "w"); 
    for (wr_i = 0; wr_i < 1; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //32x64
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_32x64.txt", "w");
    for (wr_i = 0; wr_i < 64; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //64x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_64x32.txt", "w");
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 4; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31], 
            wr_data[32], wr_data[33], wr_data[34], wr_data[35], wr_data[36], wr_data[37], wr_data[38], wr_data[39], wr_data[40], wr_data[41], wr_data[42], wr_data[43], wr_data[44], wr_data[45], wr_data[46], wr_data[47], 
            wr_data[48], wr_data[49], wr_data[50], wr_data[51], wr_data[52], wr_data[53], wr_data[54], wr_data[55], wr_data[56], wr_data[57], wr_data[58], wr_data[59], wr_data[60], wr_data[61], wr_data[62], wr_data[63]);
    end
    $fclose(fp_w);
    //4x16
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_4x16.txt", "w"); 
    for (wr_i = 0; wr_i < 4; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //64x8
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_64x8.txt", "w");
    for (wr_i = 0; wr_i < 8; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 4; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31], 
            wr_data[32], wr_data[33], wr_data[34], wr_data[35], wr_data[36], wr_data[37], wr_data[38], wr_data[39], wr_data[40], wr_data[41], wr_data[42], wr_data[43], wr_data[44], wr_data[45], wr_data[46], wr_data[47], 
            wr_data[48], wr_data[49], wr_data[50], wr_data[51], wr_data[52], wr_data[53], wr_data[54], wr_data[55], wr_data[56], wr_data[57], wr_data[58], wr_data[59], wr_data[60], wr_data[61], wr_data[62], wr_data[63]);
    end
    $fclose(fp_w);
    //8x4
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_8x4.txt", "w");
    for (wr_i = 0; wr_i < 2; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //32x8
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_32x8.txt", "w");
    for (wr_i = 0; wr_i < 8; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //8x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_8x32.txt", "w");
    for (wr_i = 0; wr_i < 16; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //32x4
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_32x4.txt", "w");
    for (wr_i = 0; wr_i < 4; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //16x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_16x32.txt", "w");
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //16x64
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_16x64.txt", "w");
    for (wr_i = 0; wr_i < 64; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    #256;
    //64x64
    fp_w = $fopen("../../../../../result/fpga_coeff/dct2/fpga_coeff_dct2_64x64.txt", "w");
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 4; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31], 
            wr_data[32], wr_data[33], wr_data[34], wr_data[35], wr_data[36], wr_data[37], wr_data[38], wr_data[39], wr_data[40], wr_data[41], wr_data[42], wr_data[43], wr_data[44], wr_data[45], wr_data[46], wr_data[47], 
            wr_data[48], wr_data[49], wr_data[50], wr_data[51], wr_data[52], wr_data[53], wr_data[54], wr_data[55], wr_data[56], wr_data[57], wr_data[58], wr_data[59], wr_data[60], wr_data[61], wr_data[62], wr_data[63]);
    end
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    end
    $fclose(fp_w);
//DST7
    //32x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_32x32.txt", "w");
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //16x16
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_16x16.txt", "w");
    for (wr_i = 0; wr_i < 16; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //8x8
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_8x8.txt", "w");
    for (wr_i = 0; wr_i < 4; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //4x4
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_4x4.txt", "w"); 
    for (wr_i = 0; wr_i < 1; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //4x16
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_4x16.txt", "w"); 
    for (wr_i = 0; wr_i < 4; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //32x8
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_32x8.txt", "w");
    for (wr_i = 0; wr_i < 8; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //8x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_8x32.txt", "w");
    for (wr_i = 0; wr_i < 16; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //32x4
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_32x4.txt", "w");
    for (wr_i = 0; wr_i < 4; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //16x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_16x32.txt", "w");
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //8x4
    fp_w = $fopen("../../../../../result/fpga_coeff/dst7/fpga_coeff_dst7_8x4.txt", "w");
    for (wr_i = 0; wr_i < 2; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
//DCT8
    // #100;
    //32x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_32x32.txt", "w");
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //16x16
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_16x16.txt", "w");
    for (wr_i = 0; wr_i < 16; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //8x8
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_8x8.txt", "w");
    for (wr_i = 0; wr_i < 4; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //4x4
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_4x4.txt", "w"); 
    for (wr_i = 0; wr_i < 1; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //4x16
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_4x16.txt", "w"); 
    for (wr_i = 0; wr_i < 4; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11]);
        $fwrite(fp_w, "%6d %6d %6d %6d\n", wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //32x8
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_32x8.txt", "w");
    for (wr_i = 0; wr_i < 8; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //8x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_8x32.txt", "w");
    for (wr_i = 0; wr_i < 16; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //32x4
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_32x4.txt", "w");
    for (wr_i = 0; wr_i < 4; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 2; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15], 
            wr_data[16], wr_data[17], wr_data[18], wr_data[19], wr_data[20], wr_data[21], wr_data[22], wr_data[23], wr_data[24], wr_data[25], wr_data[26], wr_data[27], wr_data[28], wr_data[29], wr_data[30], wr_data[31]);
    end
    $fclose(fp_w);
    //16x32
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_16x32.txt", "w");
    for (wr_i = 0; wr_i < 32; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
    //8x4
    fp_w = $fopen("../../../../../result/fpga_coeff/dct8/fpga_coeff_dct8_8x4.txt", "w");
    for (wr_i = 0; wr_i < 2; wr_i = wr_i + 1) begin
        for (wr_j = 0; wr_j < 1; wr_j = wr_j + 1) begin
            for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
                wr_data[wr_k + wr_j * 16] = o_data[wr_k];
            end
            #2;
        end
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ]);
        $fwrite(fp_w, "%6d %6d %6d %6d %6d %6d %6d %6d\n", 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w);
end       
*/


endmodule
