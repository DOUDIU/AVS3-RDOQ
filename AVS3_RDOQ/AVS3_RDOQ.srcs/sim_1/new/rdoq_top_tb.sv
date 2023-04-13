`timescale 1ns / 1ns
`include "../../sources_1/new/rdoq_header.vh"

module rdoq_top_tb();

localparam  Y_C         = 3'd0  ,
            U_C         = 3'd1  ,
            V_C         = 3'd2  ;
localparam  SIZE4       = 3'd2  ,
            SIZE8       = 3'd3  ,
            SIZE16      = 3'd4  ,
            SIZE32      = 3'd5  ,
            SIZE64      = 3'd6  ;

integer fp_r, fp_w, rd_i, rd_j, rd_k, rd_l, wr_i, wr_j, wr_k, rd_z, rd_y;

//system input
    reg                                             clk             ;
    reg                                             reset           ;
//input parameter       
    reg             [`w_q_value     - 1 : 0]        q_value         ;
    reg             [`w_q_bits      - 1 : 0]        q_bits          ;

    reg             [`w_size        - 1 : 0]        cu_width_log2   ;
    reg             [`w_size        - 1 : 0]        cu_height_log2  ;
    reg     signed  [`w_err_scale   - 1 : 0]        err_scale       ;
    reg     signed  [`w_diff_scale  - 1 : 0]        diff_scale      ;
    reg     signed  [`w_lambda      - 1 : 0]        lambda          ;

    reg             [0                  : 0]        is_intra        ;


//input data
    reg                                             i_valid                     ;
    reg     signed  [`w_data_in         - 1 : 0]    i_data          [0 : 31]    ;
    reg             [`w_pos             - 1 : 0]    left_pos        [0 : 31]    ;
    reg             [`w_pos             - 1 : 0]    bottom_pos      [0 : 31]    ;
    reg             [31                     : 0]    rdoq_est_cbf    [0 :  2][0 :  1];
    reg             [`w_rdoq_est_last   - 1 : 0]    rdoq_est_last   [0 :  5][0 : 11][0 : 1];
    reg             [`w_rdoq_est_level  - 1 : 0]    rdoq_est_level  [0 : 23][0 :  1];
    reg             [`w_rdoq_est_run    - 1 : 0]    rdoq_est_run    [0 : 23][0 :  1];


//output parameter 
    wire            [3 : 0]     final_X             ;
    wire            [3 : 0]     final_y             ;
//output coeff  
    wire                        o_valid             ;
    wire    signed  [15: 0]     o_data  [0 : 31]    ;

//txt rd/wr 
    reg     signed  [15 : 0]    rd_data [0 : 63]    ;
    reg     signed  [15 : 0]    wr_data [0 : 63]    ;

    reg             [31: 0]     rdoq_data           ;

rdoq_top u_rdoq_top(
    //system clk and rest
    .clk                    (clk            ),
    .rst_n                  (reset          ),

    //input block information
    .q_value                (q_value        ),
    .q_bits                 (q_bits         ),

    .cu_width_log2          (cu_width_log2  ),//the value is between 2 and 4
    .cu_height_log2         (cu_height_log2 ),//the value is between 2 and 4
    .err_scale              (err_scale      ),
    .lambda                 (lambda         ),
    .diff_scale             (diff_scale     ),

    .rdoq_est_last          (rdoq_est_last  ),
    .rdoq_est_level         (rdoq_est_level ),
    .rdoq_est_run           (rdoq_est_run   ),
    .left_pos               (left_pos       ),
    .bottom_pos             (bottom_pos     ),

    //input block data
    .i_valid                (i_valid        ),
    .src_coef               (i_data         ),

    //output block data
    .o_valid                (o_valid        )
);


always #1 begin
    clk <= ~clk;
end
  

//read
initial begin
    clk             =       0;
    reset           =       0;

    q_value         =       `w_q_value'd0;
    q_bits          =       `w_q_bits'd0;
    cu_width_log2   =       `w_size'd0;
    cu_height_log2  =       `w_size'd0;
    err_scale       =       0;
    lambda          =       `w_lambda'd0;
    diff_scale      =       0;

    i_valid         =       0;
    

        
    for (rd_i = 0; rd_i < 32; rd_i = rd_i + 1) begin
        i_data[rd_i] = 0;
    end
    for (rd_z = 0; rd_z < 32; rd_z = rd_z + 1) begin
        left_pos[rd_z] = 0;
    end
    for (rd_y = 0; rd_y < 32; rd_y = rd_y + 1) begin
        bottom_pos[rd_y] = 0;
    end

    for (rd_i = 0; rd_i < 3; rd_i = rd_i + 1) begin
        for(rd_j = 0; rd_j < 2; rd_j = rd_j + 1)begin
            rdoq_est_cbf[rd_i][rd_j] = 0;
        end
    end
    for(rd_j = 0; rd_j < 6; rd_j = rd_j + 1)begin
        for(rd_k = 0; rd_k < 12; rd_k = rd_k + 1)begin
            for(rd_l = 0; rd_l < 2; rd_l = rd_l + 1)begin
                rdoq_est_last[rd_j][rd_k][rd_l] = 0;
            end
        end
    end
    for (rd_i = 0; rd_i < 24; rd_i = rd_i + 1) begin
        for(rd_j = 0; rd_j < 2; rd_j = rd_j + 1)begin
            rdoq_est_level[rd_i][rd_j] = 0;
        end
    end
    for (rd_i = 0; rd_i < 24; rd_i = rd_i + 1) begin
        for(rd_j = 0; rd_j < 2; rd_j = rd_j + 1)begin
            rdoq_est_run[rd_i][rd_j] = 0;
        end
    end
    #2;
    reset = 1;
    //Start

//16x16
    i_valid         =   1                           ;

    fp_r = $fopen("../../../../../result/origin_data/q_value/q_value_16x16.txt", "r");
    $fscanf(fp_r, "%d ", q_value);
    $fclose(fp_r);
    fp_r = $fopen("../../../../../result/origin_data/q_bits/q_bits_16x16.txt", "r");
    $fscanf(fp_r, "%d ", q_bits);
    $fclose(fp_r);
    fp_r = $fopen("../../../../../result/origin_data/cu_width_log2/cu_width_log2_16x16.txt", "r");
    $fscanf(fp_r, "%d ", cu_width_log2);
    $fclose(fp_r);
    fp_r = $fopen("../../../../../result/origin_data/cu_height_log2/cu_height_log2_16x16.txt", "r");
    $fscanf(fp_r, "%d ", cu_height_log2);
    $fclose(fp_r);

    rd_l = $fopen("../../../../../result/origin_data/lambda/lambda_16x16.txt", "r");
    $fscanf(rd_l, "%d ", lambda);
    $fclose(rd_l);
    rd_l = $fopen("../../../../../result/origin_data/err_scale/err_scale_16x16.txt", "r");
    $fscanf(rd_l, "%d ", err_scale);
    $fclose(rd_l);
    rd_l = $fopen("../../../../../result/origin_data/diff_scale/diff_scale_16x16.txt", "r");
    $fscanf(rd_l, "%d ", diff_scale);
    $fclose(rd_l);


    fp_r = $fopen("../../../../../result/origin_data/rdoq_est_cbf/est_cbf_16x16.txt", "r");
        for (rd_i = 0; rd_i < 3; rd_i = rd_i + 1) begin
            for(rd_j = 0; rd_j < 2; rd_j = rd_j + 1)begin
                $fscanf(fp_r, "%d ", rdoq_data);
                rdoq_est_cbf[rd_i][rd_j] = rdoq_data;
            end
        end
    $fclose(fp_r);
    
    fp_r = $fopen("../../../../../result/origin_data/rdoq_est_last/est_last_16x16.txt", "r");
        for(rd_j = 0; rd_j < 6; rd_j = rd_j + 1)begin
            for(rd_k = 0; rd_k < 12; rd_k = rd_k + 1)begin
                for(rd_l = 0; rd_l < 2; rd_l = rd_l + 1)begin
                    $fscanf(fp_r, "%d ", rdoq_data);
                    rdoq_est_last[rd_j][rd_k][rd_l] = rdoq_data;
                end
            end
        end
    $fclose(fp_r);
    
    fp_r = $fopen("../../../../../result/origin_data/rdoq_est_level/est_level_16x16.txt", "r");
        for (rd_i = 0; rd_i < 24; rd_i = rd_i + 1) begin
            for(rd_j = 0; rd_j < 2; rd_j = rd_j + 1)begin
                $fscanf(fp_r, "%d ", rdoq_data);
                rdoq_est_level[rd_i][rd_j] = rdoq_data;
            end
        end
    $fclose(fp_r);

    fp_r = $fopen("../../../../../result/origin_data/rdoq_est_run/est_run_16x16.txt", "r");
        for (rd_i = 0; rd_i < 24; rd_i = rd_i + 1) begin
            for(rd_j = 0; rd_j < 2; rd_j = rd_j + 1)begin
                $fscanf(fp_r, "%d ", rdoq_data);
                rdoq_est_run[rd_i][rd_j] = rdoq_data;
            end
        end
    $fclose(fp_r);

    fp_r = $fopen("../../../../../result/origin_data/left_pos/left_pos_16x16.txt", "r");
        $fscanf(fp_r, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
            rd_data[0 ], rd_data[1 ], rd_data[2 ], rd_data[3 ], rd_data[4 ], rd_data[5 ], rd_data[6 ], rd_data[7 ],
            rd_data[8 ], rd_data[9 ], rd_data[10], rd_data[11], rd_data[12], rd_data[13], rd_data[14], rd_data[15]);

        for (rd_k = 0; rd_k < 16; rd_k = rd_k + 1) begin
            left_pos[rd_k] = rd_data[rd_k];
        end
    $fclose(fp_r);

    fp_r = $fopen("../../../../../result/origin_data/bottom_pos/bottom_pos_16x16.txt", "r");
        $fscanf(fp_r, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
            rd_data[0 ], rd_data[1 ], rd_data[2 ], rd_data[3 ], rd_data[4 ], rd_data[5 ], rd_data[6 ], rd_data[7 ],
            rd_data[8 ], rd_data[9 ], rd_data[10], rd_data[11], rd_data[12], rd_data[13], rd_data[14], rd_data[15]);

        for (rd_k = 0; rd_k < 16; rd_k = rd_k + 1) begin
            bottom_pos[rd_k] = rd_data[rd_k];
        end
    $fclose(fp_r);


    fp_r = $fopen("../../../../../result/origin_data/src/origin_data_16x16.txt", "r");
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


//32x32
    i_valid         =   1                           ;

    fp_r = $fopen("../../../../../result/origin_data/q_value/q_value_32x32.txt", "r");
    $fscanf(fp_r, "%d ", q_value);
    $fclose(fp_r);
    fp_r = $fopen("../../../../../result/origin_data/q_bits/q_bits_32x32.txt", "r");
    $fscanf(fp_r, "%d ", q_bits);
    $fclose(fp_r);
    fp_r = $fopen("../../../../../result/origin_data/cu_width_log2/cu_width_log2_32x32.txt", "r");
    $fscanf(fp_r, "%d ", cu_width_log2);
    $fclose(fp_r);
    fp_r = $fopen("../../../../../result/origin_data/cu_height_log2/cu_height_log2_32x32.txt", "r");
    $fscanf(fp_r, "%d ", cu_height_log2);
    $fclose(fp_r);

    rd_l = $fopen("../../../../../result/origin_data/lambda/lambda_32x32.txt", "r");
    $fscanf(rd_l, "%d ", lambda);
    $fclose(rd_l);
    rd_l = $fopen("../../../../../result/origin_data/err_scale/err_scale_32x32.txt", "r");
    $fscanf(rd_l, "%d ", err_scale);
    $fclose(rd_l);
    rd_l = $fopen("../../../../../result/origin_data/diff_scale/diff_scale_32x32.txt", "r");
    $fscanf(rd_l, "%d ", diff_scale);
    $fclose(rd_l);


    fp_r = $fopen("../../../../../result/origin_data/rdoq_est_cbf/est_cbf_32x32.txt", "r");
        for (rd_i = 0; rd_i < 3; rd_i = rd_i + 1) begin
            for(rd_j = 0; rd_j < 2; rd_j = rd_j + 1)begin
                $fscanf(fp_r, "%d ", rdoq_data);
                rdoq_est_cbf[rd_i][rd_j] = rdoq_data;
            end
        end
    $fclose(fp_r);
    
    fp_r = $fopen("../../../../../result/origin_data/rdoq_est_last/est_last_32x32.txt", "r");
        for(rd_j = 0; rd_j < 6; rd_j = rd_j + 1)begin
            for(rd_k = 0; rd_k < 12; rd_k = rd_k + 1)begin
                for(rd_l = 0; rd_l < 2; rd_l = rd_l + 1)begin
                    $fscanf(fp_r, "%d ", rdoq_data);
                    rdoq_est_last[rd_j][rd_k][rd_l] = rdoq_data;
                end
            end
        end
    $fclose(fp_r);
    
    fp_r = $fopen("../../../../../result/origin_data/rdoq_est_level/est_level_32x32.txt", "r");
        for (rd_i = 0; rd_i < 24; rd_i = rd_i + 1) begin
            for(rd_j = 0; rd_j < 2; rd_j = rd_j + 1)begin
                $fscanf(fp_r, "%d ", rdoq_data);
                rdoq_est_level[rd_i][rd_j] = rdoq_data;
            end
        end
    $fclose(fp_r);

    fp_r = $fopen("../../../../../result/origin_data/rdoq_est_run/est_run_32x32.txt", "r");
        for (rd_i = 0; rd_i < 24; rd_i = rd_i + 1) begin
            for(rd_j = 0; rd_j < 2; rd_j = rd_j + 1)begin
                $fscanf(fp_r, "%d ", rdoq_data);
                rdoq_est_run[rd_i][rd_j] = rdoq_data;
            end
        end
    $fclose(fp_r);

    fp_r = $fopen("../../../../../result/origin_data/left_pos/left_pos_32x32.txt", "r");
        $fscanf(fp_r, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
            rd_data[0 ], rd_data[1 ], rd_data[2 ], rd_data[3 ], rd_data[4 ], rd_data[5 ], rd_data[6 ], rd_data[7 ],
            rd_data[8 ], rd_data[9 ], rd_data[10], rd_data[11], rd_data[12], rd_data[13], rd_data[14], rd_data[15], 
            rd_data[16], rd_data[17], rd_data[18], rd_data[19], rd_data[20], rd_data[21], rd_data[22], rd_data[23], 
            rd_data[24], rd_data[25], rd_data[26], rd_data[27], rd_data[28], rd_data[29], rd_data[30], rd_data[31]);

        for (rd_k = 0; rd_k < 32; rd_k = rd_k + 1) begin
            left_pos[rd_k] = rd_data[rd_k];
        end
    $fclose(fp_r);

    fp_r = $fopen("../../../../../result/origin_data/bottom_pos/bottom_pos_32x32.txt", "r");
        $fscanf(fp_r, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
            rd_data[0 ], rd_data[1 ], rd_data[2 ], rd_data[3 ], rd_data[4 ], rd_data[5 ], rd_data[6 ], rd_data[7 ],
            rd_data[8 ], rd_data[9 ], rd_data[10], rd_data[11], rd_data[12], rd_data[13], rd_data[14], rd_data[15], 
            rd_data[16], rd_data[17], rd_data[18], rd_data[19], rd_data[20], rd_data[21], rd_data[22], rd_data[23], 
            rd_data[24], rd_data[25], rd_data[26], rd_data[27], rd_data[28], rd_data[29], rd_data[30], rd_data[31]);

        for (rd_k = 0; rd_k < 32; rd_k = rd_k + 1) begin
            bottom_pos[rd_k] = rd_data[rd_k];
        end
    $fclose(fp_r);


    fp_r = $fopen("../../../../../result/origin_data/src/origin_data_32x32.txt", "r");
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



//8x8
    i_valid = 1;
    cu_width_log2   =   SIZE8           ;
    cu_height_log2  =   SIZE8           ;
    lambda          =   `w_lambda'd10131659    ;
    fp_r = $fopen("../../../../../result/origin_data/src/origin_data_8x8.txt", "r");
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
    lambda          =   `w_lambda'd10131659    ;
    fp_r = $fopen("../../../../../result/origin_data/src/origin_data_4x4.txt", "r");
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
    lambda          =   `w_lambda'd10131659    ;
    fp_r = $fopen("../../../../../result/origin_data/src/origin_data_32x32.txt", "r");
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


end







endmodule
