`include "rdoq_header.vh"

module ocd(      
//system clk and rest       
    input                                           clk                                             ,
    input                                           rst_n                                           ,

//input parameter                                           
    input           [`w_size            - 1 : 0]    i_width_log2                                    ,//the value is between 2 and 6
    input           [`w_size            - 1 : 0]    i_height_log2                                   ,//the value is between 2 and 6
    input           [`w_q_bits          - 1 : 0]    i_q_bits                                        ,
    input   signed  [`w_err_scale       - 1 : 0]    i_err_scale                                     ,
    input   signed  [`w_lambda          - 1 : 0]    i_lambda                                        ,
    input   signed  [`w_diff_scale      - 1 : 0]    i_diff_scale                                    ,
    
    input           [`w_rdoq_est_last   - 1 : 0]    i_rdoq_est_last         [0 :  5][0 : 11][0 : 1] ,
    input           [`w_rdoq_est_level  - 1 : 0]    i_rdoq_est_level        [0 : 23][0 :  1]        ,
    input           [`w_rdoq_est_run    - 1 : 0]    i_rdoq_est_run          [0 : 23][0 :  1]        ,
    input           [`w_pos             - 1 : 0]    i_left_pos              [0 : 31]                ,//the max value is 1023
    input           [`w_pos             - 1 : 0]    i_bottom_pos            [0 : 31]                ,//the max value is 1023

//input data                            
    input                                           i_valid                                         ,
    input   signed  [`w_level_double    - 1 : 0]    i_level_double          [0 : 31]                ,
    input   signed  [`w_preq_o_data     - 1 : 0]    i_data                  [0 : 31]                ,
                        
//output parameter                      
    output          [`w_size            - 1 : 0]    o_width_log2                                    ,//the value is between 2 and 6
    output          [`w_size            - 1 : 0]    o_height_log2                                   ,//the value is between 2 and 6
                        
//output data                       
    output                                          o_valid                                         ,
    output          [15 : 0]                        o_level_opt             [0 : 31]                ,
    output                                          o_tmp_dst_coef_sign     [0 : 31]                ,//the sign of tmp_dst_coef 1- 0+
    output  signed  [`w_rdoq_est_last   - 1 : 0]    o_d64_cost_last_zero    [0 : 31]                ,
    output  signed  [`w_rdoq_est_last   - 1 : 0]    o_d64_cost_last_one     [0 : 31]                , 
    output  signed  [33 : 0]                        o_base_cost_buffer_tmp  [0 : 31]                
);

parameter delay_period                  =   3;

//local parameter definition
localparam  Y_C                         =   2'd0        ,
            U_C                         =   2'd1        ,
            V_C                         =   2'd2        ;
localparam  ERR_SCALE_PRECISION_BITS    =   5'd20       ;
localparam  GET_IEP_RATE                =   16'd32768   ;



//integer definition
integer i,j,k,l,m   ;
genvar  o,p,q,r     ;


//reg definition
reg     signed  [`w_preq_o_data     - 1 : 0]    i_data_d1           [0 : 31]                    ;
reg     signed  [`w_level_double    - 1 : 0]    i_level_double_d1   [0 : 31]                    ;
reg     signed  [`w_level_double    - 1 : 0]    i_level_double_d2   [0 : 31]                    ;
reg             [`w_temp_coef       - 1 : 0]    temp_coef_abs_d1    [0 : 31]                    ;
reg             [`w_temp_coef       - 1 : 0]    temp_coef_abs_d2    [0 : 31]                    ;
reg             [`w_temp_coef       - 1 : 0]    temp_coef_abs_d3    [0 : 31]                    ;
reg                                             temp_coef_sign_d1   [0 : 31]                    ;
reg                                             temp_coef_sign_d2   [0 : 31]                    ;
reg                                             temp_coef_sign_d3   [0 : 31]                    ;


reg             [`w_pos             - 1: 0]     left_pos            [0 : 31]                    ;//the max value is 1023
reg             [`w_pos             - 1: 0]     i_bottom_pos_d1     [0 : 31]                    ;//the max value is 1023
reg             [`w_pos             - 1: 0]     left_pos_tem        [0 : 31]                    ;//shift operation after the calculation of scan position

reg             [31                     : 0]    pre_level           [0 : 31]                    ;
reg             [15                     : 0]    run                 [0 : 31]                    ;
reg             [15                     : 0]    run_tem             [0 : 31]                    ;

reg     signed  [33                     : 0]    uncoded_cost_tem    [0 : 31]                    ;
reg     signed  [33                     : 0]    coded_cost_tem      [0 : 31]                    ;
reg     signed  [33                     : 0]    coded_cost_tem_all  [0 : 31]                    ;
reg     signed  [33                     : 0]    dCurrCost_extra     [0 : 31]                    ;
reg             [31                     : 0]    level_opt           [0 : 31]                    ;
reg             [31                     : 0]    level_opt_d1        [0 : 31]                    ;
reg     signed  [23                     : 0]    dCurrCost           [0 :  1][0 : 31]            ;
reg     signed  [23                     : 0]    dCurrCost_tem       [0 :  2][0 :  1][0 : 31]    ;
reg     signed  [17                     : 0]    err1                [0 : 31]                    ;
reg     signed  [31                     : 0]    err1_tem            [0 : 31]                    ;
reg     signed  [11                     : 0]    err                 [0 :  1][0 : 31]            ;
reg     signed  [31                     : 0]    err_tem             [0 :  1][0 : 31]            ;
reg     signed  [23                     : 0]    err_x_err           [0 :  1][0 : 31]            ;


reg             [6                      : 0]    column_cnt                                      ;
reg             [6                      : 0]    column_cnt_d1                                   ;

reg                                             i_valid_d           [0 :  delay_period - 1]                         ;
reg             [`w_size            - 1 : 0]    i_width_log2_d      [0 :  delay_period - 1]                         ;
reg             [`w_size            - 1 : 0]    i_height_log2_d     [0 :  delay_period - 1]                         ;
reg             [`w_q_bits          - 1 : 0]    i_q_bits_d          [0 :  delay_period - 1]                         ;
reg     signed  [`w_err_scale       - 1 : 0]    i_err_scale_d       [0 :  delay_period - 1]                         ;
reg     signed  [`w_diff_scale      - 1 : 0]    i_diff_scale_d      [0 :  delay_period - 1]                         ;
reg     signed  [`w_lambda          - 1 : 0]    i_lambda_d          [0 :  delay_period - 1]                         ;
reg             [`w_rdoq_est_last   - 1 : 0]    i_rdoq_est_last_d   [0 :  delay_period - 1][0 :  5][0 : 11][0 : 1]  ;
reg             [`w_rdoq_est_level  - 1 : 0]    i_rdoq_est_level_d  [0 :  delay_period - 1][0 : 23][0 :  1]         ;
reg             [`w_rdoq_est_run    - 1 : 0]    i_rdoq_est_run_d    [0 :  delay_period - 1][0 : 23][0 :  1]         ;

reg     signed  [`w_rdoq_est_last   - 1 : 0]    d64_cost_last_zero      [0 : 31]            ;
reg     signed  [`w_rdoq_est_last   - 1 : 0]    d64_cost_last_one       [0 : 31]            ; 
reg     signed  [33                     : 0]    base_cost_buffer_tmp    [0 : 31]            ;


//wire definition   
wire            [`w_temp_coef       - 1 : 0]    temp_coef_abs           [0 : 31]            ;
wire            [`w_pos             - 1 : 0]    scan_pos                [0 : 31]            ;//zigzag scan position of each row
wire            [4                      : 0]    ctx_run                 [0 : 31]            ;
wire            [4                      : 0]    ctx_level               [0 : 31]            ;
wire    signed  [18                     : 0]    i64Delta                [0 :  1][0 : 31]    ;
wire    signed  [31                     : 0]    i64Delta_tem            [0 :  1][0 : 31]    ;


//assignment





//delay operation
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < delay_period; i = i + 1)begin
                i_valid_d[i]            <=  0;
            end

            for(i = 0; i < delay_period; i = i + 1)begin
                i_width_log2_d[i]       <=  0;
                i_height_log2_d[i]      <=  0;
                i_q_bits_d[i]           <=  0;
                i_err_scale_d[i]        <=  0;
                i_diff_scale_d[i]       <=  0;
                i_lambda_d[i]           <=  0;
            end

            for(m = 0; m < delay_period; m = m + 1)begin
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
            i_valid_d[0]                <=      i_valid;
            i_width_log2_d[0]           <=      i_width_log2;
            i_height_log2_d[0]          <=      i_height_log2;
            i_q_bits_d[0]               <=      i_q_bits;
            i_err_scale_d[0]            <=      i_err_scale;
            i_diff_scale_d[0]           <=      i_diff_scale;
            i_lambda_d[0]               <=      i_lambda;

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

            for(i = 1; i < delay_period; i = i + 1)begin
                i_valid_d[i]            <=      i_valid_d[i-1];
            end
            for(i = 1; i < delay_period; i = i + 1)begin
                i_width_log2_d[i]       <=      i_width_log2_d[i-1];
                i_height_log2_d[i]      <=      i_height_log2_d[i-1];
                i_q_bits_d[i]           <=      i_q_bits_d[i-1];
                i_err_scale_d[i]        <=      i_err_scale_d[i-1];
                i_diff_scale_d[i]       <=      i_diff_scale_d[i-1];
                i_lambda_d[i]           <=      i_lambda_d[i-1];
            end
            
            for(m = 1; m < delay_period; m = m + 1)begin
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

//pipe 0
    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  temp_coef_abs[o]    =   i_data[o][`w_preq_o_data     - 1 ] ? (~i_data[o] + 1) : i_data[o];
        end
    endgenerate

    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  i64Delta_tem[0][o]  =   i_level_double[o] - (temp_coef_abs[o] << i_q_bits);
            assign  i64Delta_tem[1][o]  =   i_level_double[o] - ((temp_coef_abs[o] - 1) << i_q_bits);
        end
    endgenerate

    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  i64Delta[0][o]  =   i64Delta_tem[0][o][18 : 0];
            assign  i64Delta[1][o]  =   i64Delta_tem[1][o][18 : 0];
        end
    endgenerate


//pipe 1

    //calculate column count
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                column_cnt      <=  0;
            end
            else if(i_valid) begin
                column_cnt      <=  0;
            end
            else begin
                column_cnt      <=  column_cnt + 1'b1;
            end
        end

    //delay one cycle
        always@(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
                for(i = 0; i < 32; i = i + 1)begin
                    i_data_d1[i]            <=      0;
                    i_level_double_d1[i]    <=      0;
                    i_bottom_pos_d1[i]      <=      0;
                    temp_coef_abs_d1[i]     <=      0;
                end
        end
        else begin
                for(i = 0; i < 32; i = i + 1)begin
                    i_data_d1[i]            <=      i_data[i]           ;
                    i_level_double_d1[i]    <=      i_level_double[i]   ;
                    i_bottom_pos_d1[i]      <=      i_bottom_pos[i]     ;
                    temp_coef_abs_d1[i]     <=      temp_coef_abs[i]    ;
                end
        end
        end

        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    temp_coef_sign_d1[i]    <=  0;
                end
            end
            else begin
                for(i = 0; i < 32; i = i + 1)begin
                    temp_coef_sign_d1[i]    <=  i_data[i][`w_preq_o_data     - 1];
                end
            end
        end

    //calculate err
        generate
            for(o = 0; o < 32; o = o + 1)begin
                always@(posedge clk or negedge rst_n)begin
                    if(!rst_n)begin
                        err_tem[0][o]   <=      0;
                    end
                    else if(temp_coef_abs[o] == 0) begin 
                        err_tem[0][o]   <=      0;
                    end
                    else begin
                        err_tem[0][o]   <=  (i64Delta[0][o] * i_diff_scale) >>> ERR_SCALE_PRECISION_BITS;
                    end
                end
            end
        endgenerate

        generate
            for(o = 0; o < 32; o = o + 1)begin
                always@(posedge clk or negedge rst_n)begin
                    if(!rst_n)begin
                        err_tem[1][o]   <=      0;
                    end
                    else if((temp_coef_abs[o] == 0) || (temp_coef_abs[o] == 1)) begin 
                        err_tem[1][o]   <=      0;
                    end
                    else begin
                        err_tem[1][o]   <=  (i64Delta[1][o] * i_diff_scale) >>> ERR_SCALE_PRECISION_BITS;
                    end
                end
            end
        endgenerate

    generate
        for(p = 0; p < 2; p = p + 1)begin
            for(o = 0; o < 32; o = o + 1)begin
                assign  err[p][o]  =   err_tem[p][o][11 : 0];
            end
        end
    endgenerate


    //calculate err1
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    err1_tem[i]     <=  0;
                end
            end
            else begin
                for(i = 0; i < 32; i = i + 1)begin
                    err1_tem[i]     <=  (i_level_double[i] * i_diff_scale) >>> ERR_SCALE_PRECISION_BITS;
                end
            end
        end

    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  err1[o]  =   err1_tem[o][17 : 0];
        end
    endgenerate


//pipe 2 pre_level  level_opt 

    //delay one cycle
        always@(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
                for(i = 0; i < 32; i = i + 1)begin
                    i_level_double_d2[i]    <=  0;
                end
        end
        else begin
                for(i = 0; i < 32; i = i + 1)begin
                    i_level_double_d2[i]    <=  i_level_double_d1[i];
                end
        end
        end

        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    temp_coef_sign_d2[i]    <=  0;
                end
            end
            else begin
                for(i = 0; i < 32; i = i + 1)begin
                    temp_coef_sign_d2[i]    <=  temp_coef_sign_d1[i];
                end
            end
        end

        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                column_cnt_d1   <=  0;
                for(i = 0; i < 32; i = i + 1)begin
                    temp_coef_abs_d2[i]     <=  0;
                end
            end
            else begin
                column_cnt_d1   <=  column_cnt;
                for(i = 0; i < 32; i = i + 1)begin
                    temp_coef_abs_d2[i]     <=  temp_coef_abs_d1[i];
                end
            end
        end


//calculate scan position

    //scan position shift
        always@(*)begin
            case(i_height_log2_d[0])
                3'd2    : begin    
                        for(j = 0; j < 8; j = j + 1)begin
                            for(i = 1 ; i < 4; i = i + 1)begin
                                left_pos_tem[i - 1 + j * 4]     <=  left_pos[i];
                            end
                            left_pos_tem[3 + j * 4]    <=  left_pos_tem[3 ];
                        end
                    end
                3'd3    : begin
                        for(j = 0; j < 4; j = j + 1)begin
                            for(i = 1 ; i < 8; i = i + 1)begin
                                left_pos_tem[i - 1 + j * 8]     <=  left_pos[i];
                            end
                            left_pos_tem[7 + j * 8]    <=  left_pos_tem[7 ];
                        end
                    end
                3'd4    : begin
                        for(j = 0; j < 2; j = j + 1)begin
                            for(i = 1 ; i < 16; i = i + 1)begin
                                left_pos_tem[i - 1 + j * 16]     <=  left_pos[i];
                            end
                            left_pos_tem[15 + j * 16]    <=  left_pos_tem[15];
                        end
                    end
                3'd5    : begin
                        for(i = 1 ; i < 32; i = i + 1)begin
                            left_pos_tem[i - 1]     <=  left_pos[i];
                        end
                        left_pos_tem[31]    <=  left_pos_tem[31];
                    end
                default : begin
                        for(i = 0 ; i < 32; i = i + 1)begin
                            left_pos_tem[i]         <=  0;
                        end
                    end
            endcase 
        end
    
    //calculate scan position
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n) begin
                for(i = 0; i < 32; i = i + 1)begin
                    left_pos[i]        <=      0;
                end
            end
            else if(column_cnt[0]) begin
                for(i = 0; i < 32; i = i + 2)begin
                    left_pos[i]     <=  left_pos_tem[i] - 1;
                end
                
                for(i = 1; i < 3; i = i + 2)begin
                    left_pos[i]     <=  left_pos_tem[i] + 1;
                end
                for(i = 5; i < 7; i = i + 2)begin
                    left_pos[i]     <=  left_pos_tem[i] + 1;
                end
                for(i = 9; i < 15; i = i + 2)begin
                    left_pos[i]     <=  left_pos_tem[i] + 1;
                end            
                for(i = 17; i < 31; i = i + 2)begin
                    left_pos[i]     <=  left_pos_tem[i] + 1;
                end
                //determine the value of the last row 
                case(i_height_log2_d[0])
                    3'd2    : begin    
                            left_pos[3 ]    <=  i_bottom_pos_d1[column_cnt];
                            left_pos[7 ]    <=  0;//pending, not used
                            left_pos[15]    <=  0;//pending, not used
                            left_pos[31]    <=  0;//pending, not used
                        end
                    3'd3    : begin
                            left_pos[3 ]    <=  left_pos_tem[3 ] + 1;
                            left_pos[7 ]    <=  i_bottom_pos_d1[column_cnt];
                            left_pos[15]    <=  0;//pending, not used
                            left_pos[31]    <=  0;//pending, not used

                        end
                    3'd4    : begin
                            left_pos[3 ]    <=  left_pos_tem[3 ] + 1;
                            left_pos[7 ]    <=  left_pos_tem[7 ] + 1;
                            left_pos[15]    <=  i_bottom_pos_d1[column_cnt];
                            left_pos[31]    <=  0;//pending, not used

                        end
                    3'd5    : begin
                            left_pos[3 ]    <=  left_pos_tem[3 ] + 1;
                            left_pos[7 ]    <=  left_pos_tem[7 ] + 1;
                            left_pos[15]    <=  left_pos_tem[15] + 1;
                            left_pos[31]    <=  i_bottom_pos_d1[column_cnt];

                        end
                    default : begin
                            left_pos[3 ]    <=  0;
                            left_pos[7 ]    <=  0;
                            left_pos[15]    <=  0;
                            left_pos[31]    <=  0;
                        end
                endcase
            end
            else begin
                if(column_cnt == 0)begin
                    case(i_height_log2_d[0])
                        3'd2    : begin    
                                for(j = 0; j < 8; j = j + 1)begin
                                    for(i = 0; i < 16; i = i + 1)begin
                                        left_pos[i + j * 4]   <=  i_left_pos[i];
                                    end
                                end
                            end
                        3'd3    : begin
                                for(j = 0; j < 4; j = j + 1)begin
                                    for(i = 0; i < 8; i = i + 1)begin
                                        left_pos[i + j * 8]   <=  i_left_pos[i];
                                    end
                                end
                            end
                        3'd4    : begin
                                for(j = 0; j < 2; j = j + 1)begin
                                    for(i = 0; i < 16; i = i + 1)begin
                                        left_pos[i + j * 16]   <=  i_left_pos[i];
                                    end
                                end
                            end
                        3'd5    : begin
                                for(i = 0; i < 32; i = i + 1)begin
                                    left_pos[i]   <=  i_left_pos[i];
                                end
                            end
                        default : begin
                                for(i = 0; i < 32; i = i + 1)begin
                                    left_pos[i]   <=  0;
                                end
                            end
                    endcase
                end
                else begin
                    for(i = 0; i < 32; i = i + 2)begin
                        left_pos[i]     <=  left_pos_tem[i] + 1;
                    end

                    for(i = 1; i < 3; i = i + 2)begin
                        left_pos[i]     <=  left_pos_tem[i] - 1;
                    end
                    for(i = 5; i < 7; i = i + 2)begin
                        left_pos[i]     <=  left_pos_tem[i] - 1;
                    end
                    for(i = 9; i < 15; i = i + 2)begin
                        left_pos[i]     <=  left_pos_tem[i] - 1;
                    end            
                    for(i = 17; i < 31; i = i + 2)begin
                        left_pos[i]     <=  left_pos_tem[i] - 1;
                    end
                    //determine the value of the last row 
                    case(i_height_log2_d[0])
                        3'd2    : begin    
                                left_pos[3 ]    <=  i_bottom_pos_d1[column_cnt];
                                left_pos[7 ]    <=  0;//pending, not used
                                left_pos[15]    <=  0;//pending, not used
                                left_pos[31]    <=  0;//pending, not used
                            end
                        3'd3    : begin
                                left_pos[3 ]    <=  left_pos_tem[3 ] - 1;
                                left_pos[7 ]    <=  i_bottom_pos_d1[column_cnt];
                                left_pos[15]    <=  0;//pending, not used
                                left_pos[31]    <=  0;//pending, not used

                            end
                        3'd4    : begin
                                left_pos[3 ]    <=  left_pos_tem[3 ] - 1;
                                left_pos[7 ]    <=  left_pos_tem[7 ] - 1;
                                left_pos[15]    <=  i_bottom_pos_d1[column_cnt];
                                left_pos[31]    <=  0;//pending, not used

                            end
                        3'd5    : begin
                                left_pos[3 ]    <=  left_pos_tem[3 ] - 1;
                                left_pos[7 ]    <=  left_pos_tem[7 ] - 1;
                                left_pos[15]    <=  left_pos_tem[15] - 1;
                                left_pos[31]    <=  i_bottom_pos_d1[column_cnt];

                            end
                        default : begin
                                left_pos[3 ]    <=  0;
                                left_pos[7 ]    <=  0;
                                left_pos[15]    <=  0;
                                left_pos[31]    <=  0;
                            end
                    endcase

                end
            end
        end

    //assign scan position with zigzag order
        generate
            for(o = 0; o < 32; o = o + 1)begin
                assign  scan_pos[o]     =   left_pos[o];
            end
        endgenerate 


//calculate pre_level and run

    //calculate pre_level
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    pre_level[i]    <=  0;
                end
            end
            else if(column_cnt[0])begin
                for(i = 0 ; i < 32; i = i + 2)begin
                    pre_level[i]    <=  i_data_d1[i]        ?   temp_coef_abs_d1[i] : 1;
                end

                for(i = 1 ; i < 3 ; i = i + 4)begin//1
                    pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
                end
                for(i = 5 ; i < 7 ; i = i + 4)begin//5
                    pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
                end
                for(i = 9 ; i < 15; i = i + 4)begin//9  13
                    pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
                end            
                for(i = 17; i < 31; i = i + 4)begin//17  21  25  29 
                    pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
                end

                //determine the value of the last row 
                case(i_height_log2_d[0])
                    3'd2    : begin    
                            pre_level[3 ]       <=  i_data_d1[3 ]   ?   temp_coef_abs_d1[3 ] : 1;
                            pre_level[7 ]       <=  i_data_d1[7 ]   ?   temp_coef_abs_d1[7 ] : 1;
                            pre_level[11]       <=  i_data_d1[11]   ?   temp_coef_abs_d1[11] : 1;
                            pre_level[15]       <=  i_data_d1[15]   ?   temp_coef_abs_d1[15] : 1;
                            pre_level[19]       <=  i_data_d1[19]   ?   temp_coef_abs_d1[19] : 1;
                            pre_level[23]       <=  i_data_d1[23]   ?   temp_coef_abs_d1[23] : 1;
                            pre_level[27]       <=  i_data_d1[27]   ?   temp_coef_abs_d1[27] : 1;
                            pre_level[31]       <=  i_data_d1[31]   ?   temp_coef_abs_d1[31] : 1;
                        end
                    3'd3    : begin
                            pre_level[3 ]       <=  level_opt[3   + 1]   ?   level_opt[3   + 1]     : 1 ;
                            pre_level[7 ]       <=  i_data_d1[7      ]   ?   temp_coef_abs_d1[7 ]   : 1 ;

                            pre_level[11]       <=  level_opt[11  + 1]   ?   level_opt[11  + 1]     : 1 ;
                            pre_level[15]       <=  i_data_d1[15     ]   ?   temp_coef_abs_d1[15]   : 1 ;
                            
                            pre_level[19]       <=  level_opt[19  + 1]   ?   level_opt[19  + 1]     : 1 ;
                            pre_level[23]       <=  i_data_d1[23     ]   ?   temp_coef_abs_d1[23]   : 1 ;
                            
                            pre_level[27]       <=  level_opt[27  + 1]   ?   level_opt[27  + 1]     : 1 ;
                            pre_level[31]       <=  i_data_d1[31     ]   ?   temp_coef_abs_d1[31]   : 1 ;
                        end
                    3'd4    : begin
                            pre_level[3 ]       <=  level_opt[3   + 1]   ?   level_opt[3  + 1]      : 1 ;
                            pre_level[7 ]       <=  level_opt[7   + 1]   ?   level_opt[7  + 1]      : 1 ;
                            pre_level[11]       <=  level_opt[11  + 1]   ?   level_opt[11 + 1]      : 1 ;
                            pre_level[15]       <=  i_data_d1[15     ]   ?   temp_coef_abs_d1[15]   : 1 ;

                            pre_level[19]       <=  level_opt[19  + 1]   ?   level_opt[19 + 1]      : 1 ;
                            pre_level[23]       <=  level_opt[23  + 1]   ?   level_opt[23 + 1]      : 1 ;
                            pre_level[27]       <=  level_opt[27  + 1]   ?   level_opt[27 + 1]      : 1 ;
                            pre_level[31]       <=  i_data_d1[31     ]   ?   temp_coef_abs_d1[31]   : 1 ;
                        end 
                    3'd5    : begin 
                            pre_level[3 ]       <=  level_opt[3   + 1]   ?   level_opt[3  + 1]      : 1 ;
                            pre_level[7 ]       <=  level_opt[7   + 1]   ?   level_opt[7  + 1]      : 1 ;
                            pre_level[11]       <=  level_opt[11  + 1]   ?   level_opt[11 + 1]      : 1 ;
                            pre_level[15]       <=  level_opt[15  + 1]   ?   level_opt[15 + 1]      : 1 ;
                            pre_level[19]       <=  level_opt[19  + 1]   ?   level_opt[19 + 1]      : 1 ;
                            pre_level[23]       <=  level_opt[23  + 1]   ?   level_opt[23 + 1]      : 1 ;
                            pre_level[27]       <=  level_opt[27  + 1]   ?   level_opt[27 + 1]      : 1 ;
                            pre_level[31]       <=  i_data_d1[31     ]   ?   temp_coef_abs_d1[31]   : 1 ;
                        end
                    default : begin
                            pre_level[3 ]       <=  0;
                            pre_level[7 ]       <=  0;
                            pre_level[11]       <=  0;
                            pre_level[15]       <=  0;
                            pre_level[19]       <=  0;
                            pre_level[23]       <=  0;
                            pre_level[27]       <=  0;
                            pre_level[31]       <=  0;
                        end
                endcase
            end
            else begin
                for(i = 1; i < 32; i = i + 2)begin
                    pre_level[i]    <=  i_data_d1[i]        ?   temp_coef_abs_d1[i] : 1;
                end

                if(column_cnt == 0)begin
                    for(i = 0; i < 32; i = i + 2)begin
                        pre_level[i]    <=  i_data_d1[i]        ?   temp_coef_abs_d1[i] : 1;
                    end
                end
                else begin
                    for(i = 0; i < 32; i = i + 2)begin
                        pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
                    end
                end
            end
        end

    //do shift operation to run_tem
        // generate
        //     for(o = 1; o < 32; o = o + 1)begin
        //         assign  run_tem[o - 1]    =       run[o];
        //     end
        //     assign  run_tem[31]     =       run[31];
        // endgenerate
        always@(*)begin
            case(i_height_log2_d[0])
                3'd2    : begin    
                        for(j = 0; j < 8; j = j + 1)begin
                            for(i = 1 ; i < 4; i = i + 1)begin
                                run_tem[i - 1 + j * 4]     <=  run[i + j * 4];
                            end
                            run_tem[3 + j * 4]    <=  run_tem[3 + j * 4];
                        end
                    end
                3'd3    : begin
                        for(j = 0; j < 4; j = j + 1)begin
                            for(i = 1 ; i < 8; i = i + 1)begin
                                run_tem[i - 1 + j * 8]     <=  run[i + j * 8];
                            end
                            run_tem[7 + j * 8]    <=  run_tem[7 + j * 8];
                        end
                    end
                3'd4    : begin
                        for(j = 0; j < 2; j = j + 1)begin
                            for(i = 1 ; i < 16; i = i + 1)begin
                                run_tem[i - 1 + j * 16]     <=  run[i + j * 16];
                            end
                            run_tem[15 + j * 16]    <=  run_tem[15 + j * 16];
                        end
                    end
                3'd5    : begin
                        for(i = 1 ; i < 32; i = i + 1)begin
                            run_tem[i - 1]     <=  run[i];
                        end
                        run_tem[31]    <=  run_tem[31];
                    end
                default : begin
                        for(i = 0 ; i < 32; i = i + 1)begin
                            run_tem[i]         <=  0;
                        end
                    end
            endcase 
        end

    //calculate run
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    run[i]          <=  0;
                end
            end
            else if(column_cnt[0])begin
            //even rows
                for(i = 0; i < 32; i = i + 2)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                end

            //odd rows
                for(i = 1 ; i < 3 ; i = i + 4)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                end
                for(i = 5 ; i < 7 ; i = i + 4)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                end
                for(i = 9 ; i < 15; i = i + 4)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                end            
                for(i = 17; i < 31; i = i + 4)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                end
                //determine the value of the last row 
                case(i_height_log2_d[0])
                    3'd2    : begin    
                            run[3 ]             <=  i_data_d1[3 ]   ?   0 : 1;
                            run[7 ]             <=  i_data_d1[7 ]   ?   0 : 1;
                            run[11]             <=  i_data_d1[11]   ?   0 : 1;
                            run[15]             <=  i_data_d1[15]   ?   0 : 1;
                            run[19]             <=  i_data_d1[19]   ?   0 : 1;
                            run[23]             <=  i_data_d1[23]   ?   0 : 1;
                            run[27]             <=  i_data_d1[27]   ?   0 : 1;
                            run[31]             <=  i_data_d1[31]   ?   0 : 1;
                        end
                    3'd3    : begin
                            run[3 ]             <=  level_opt[3  + 1]   ?   0 : run_tem[3 ] + 1;
                            run[7 ]             <=  i_data_d1[7     ]   ?   0 : 1;

                            run[11]             <=  level_opt[11 + 1]   ?   0 : run_tem[11] + 1;
                            run[15]             <=  i_data_d1[15    ]   ?   0 : 1;

                            run[19]             <=  level_opt[19 + 1]   ?   0 : run_tem[19] + 1;
                            run[23]             <=  i_data_d1[23    ]   ?   0 : 1;

                            run[27]             <=  level_opt[27 + 1]   ?   0 : run_tem[27] + 1;
                            run[31]             <=  i_data_d1[31    ]   ?   0 : 1;

                        end
                    3'd4    : begin
                            run[3 ]             <=  level_opt[3  + 1]   ?   0 : run_tem[3 ] + 1;
                            run[7 ]             <=  level_opt[7  + 1]   ?   0 : run_tem[7 ] + 1;
                            run[11]             <=  level_opt[11 + 1]   ?   0 : run_tem[11] + 1;
                            run[15]             <=  i_data_d1[15    ]   ?   0 : 1;
                            
                            run[19]             <=  level_opt[19 + 1]   ?   0 : run_tem[19] + 1;
                            run[23]             <=  level_opt[23 + 1]   ?   0 : run_tem[23] + 1;
                            run[27]             <=  level_opt[27 + 1]   ?   0 : run_tem[27] + 1;
                            run[31]             <=  i_data_d1[31    ]   ?   0 : 1;
                        end
                    3'd5    : begin
                            run[3 ]             <=  level_opt[3  + 1]   ?   0 : run_tem[3 ] + 1;
                            run[7 ]             <=  level_opt[7  + 1]   ?   0 : run_tem[7 ] + 1;
                            run[11]             <=  level_opt[11 + 1]   ?   0 : run_tem[11] + 1;
                            run[15]             <=  level_opt[15 + 1]   ?   0 : run_tem[15] + 1;
                            run[19]             <=  level_opt[19 + 1]   ?   0 : run_tem[19] + 1;
                            run[23]             <=  level_opt[23 + 1]   ?   0 : run_tem[23] + 1;
                            run[27]             <=  level_opt[27 + 1]   ?   0 : run_tem[27] + 1;
                            run[31]             <=  i_data_d1[31    ]   ?   0 : 1;
                        end
                    default : begin
                            run[3 ]             <=  0;
                            run[7 ]             <=  0;
                            run[11]             <=  0;
                            run[15]             <=  0;
                            run[19]             <=  0;
                            run[23]             <=  0;
                            run[27]             <=  0;
                            run[31]             <=  0;
                        end
                endcase
            end
            else begin
            //odd rows
                if(column_cnt == 0)begin
                    for(i = 1; i < 32; i = i + 2)begin
                        run[i]          <=  i_data_d1[i]        ?   0 : 1;
                    end
                end
                else begin
                    for(i = 1 ; i < 3 ; i = i + 4)begin
                        run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                    end
                    for(i = 5 ; i < 7 ; i = i + 4)begin
                        run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                    end
                    for(i = 9 ; i < 15; i = i + 4)begin
                        run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                    end            
                    for(i = 17; i < 31; i = i + 4)begin
                        run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                    end
                    //determine the value of the last row 
                    case(i_height_log2_d[0])
                        3'd2    : begin    
                                run[3 ]             <=  i_data_d1[3 ]   ?   0 : 1;
                                run[7 ]             <=  i_data_d1[7 ]   ?   0 : 1;
                                run[11]             <=  i_data_d1[11]   ?   0 : 1;
                                run[15]             <=  i_data_d1[15]   ?   0 : 1;
                                run[19]             <=  i_data_d1[19]   ?   0 : 1;
                                run[23]             <=  i_data_d1[23]   ?   0 : 1;
                                run[27]             <=  i_data_d1[27]   ?   0 : 1;
                                run[31]             <=  i_data_d1[31]   ?   0 : 1;
                            end
                        3'd3    : begin
                                run[3 ]             <=  level_opt[3  + 1]   ?   0 : run_tem[3 ] + 1;
                                run[7 ]             <=  i_data_d1[7     ]   ?   0 : 1;
                                run[11]             <=  level_opt[11 + 1]   ?   0 : run_tem[11] + 1;
                                run[15]             <=  i_data_d1[15    ]   ?   0 : 1;
                                run[19]             <=  level_opt[19 + 1]   ?   0 : run_tem[19] + 1;
                                run[23]             <=  i_data_d1[23    ]   ?   0 : 1;
                                run[27]             <=  level_opt[27 + 1]   ?   0 : run_tem[27] + 1;
                                run[31]             <=  i_data_d1[31    ]   ?   0 : 1;
                            end
                        3'd4    : begin
                                run[3 ]             <=  level_opt[3  + 1]   ?   0 : run_tem[3 ] + 1;
                                run[7 ]             <=  level_opt[7  + 1]   ?   0 : run_tem[7 ] + 1;
                                run[11]             <=  level_opt[11 + 1]   ?   0 : run_tem[11] + 1;
                                run[15]             <=  i_data_d1[15    ]   ?   0 : 1;

                                run[19]             <=  level_opt[19 + 1]   ?   0 : run_tem[19] + 1;
                                run[23]             <=  level_opt[23 + 1]   ?   0 : run_tem[23] + 1;
                                run[27]             <=  level_opt[27 + 1]   ?   0 : run_tem[27] + 1;
                                run[31]             <=  i_data_d1[31    ]   ?   0 : 1;
                            end
                        3'd5    : begin
                                run[3 ]             <=  level_opt[3  + 1]   ?   0 : run_tem[3 ] + 1;
                                run[7 ]             <=  level_opt[7  + 1]   ?   0 : run_tem[7 ] + 1;
                                run[11]             <=  level_opt[11 + 1]   ?   0 : run_tem[11] + 1;
                                run[15]             <=  level_opt[15 + 1]   ?   0 : run_tem[15] + 1;
                                run[19]             <=  level_opt[19 + 1]   ?   0 : run_tem[19] + 1;
                                run[23]             <=  level_opt[23 + 1]   ?   0 : run_tem[23] + 1;
                                run[27]             <=  level_opt[27 + 1]   ?   0 : run_tem[27] + 1;
                                run[31]             <=  i_data_d1[31    ]   ?   0 : 1;
                            end
                        default : begin
                                run[3 ]             <=  0;
                                run[7 ]             <=  0;
                                run[11]             <=  0;
                                run[15]             <=  0;
                                run[19]             <=  0;
                                run[23]             <=  0;
                                run[27]             <=  0;
                                run[31]             <=  0;
                            end
                    endcase
                end

            //even rows
                if(column_cnt == 0)begin
                    for(i = 0; i < 32; i = i + 2)begin
                        run[i]          <=  i_data_d1[i]        ?   0 : 1;
                    end
                end
                else begin
                    for(i = 0; i < 32; i = i + 2)begin
                        run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                    end
                end

            end
        end

//calculate cost

    //calculate ctx_run and ctx_level
        generate
            for(o = 0; o < 32; o = o + 1)begin
                assign  ctx_run[o]          =   ( ( (pre_level[o] - 1) > 5 ? 5 : (pre_level[o] - 1) ) << 1 );
                assign  ctx_level[o]        =   ( ( (pre_level[o] - 1) > 5 ? 5 : (pre_level[o] - 1) ) << 1 );
            end
        endgenerate

    //calculate uncoded_cost_tem
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    uncoded_cost_tem[i]     <=      0;
                end
            end
            else begin
                for(i = 0; i < 32; i = i + 1)begin
                    uncoded_cost_tem[i]     <=      err1[i] * err1[i];
                end
            end
        end

    //calculate err_x_err
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 2; i = i + 1)begin
                    for(j = 0; j < 32; j = j + 1)begin
                        err_x_err[i][j]     <=  0;
                    end
                end
            end
            else begin
                for(i = 0; i < 2; i = i + 1)begin
                    for(j = 0; j < 32; j = j + 1)begin
                        err_x_err[i][j]     <=  err[i][j] * err[i][j];
                    end
                end
            end
        end


    //calculate coded_cost_tem
        generate            
            for(o = 0; o < 32; o = o + 1)begin
                assign  coded_cost_tem_all[o]   =   ( run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][0] : i_rdoq_est_run_d[1][(ctx_run[o] + 1)][0] ) + uncoded_cost_tem[o];
            end
        endgenerate

        generate            
            for(o = 0; o < 32; o = o + 1)begin
                assign  dCurrCost_extra[o]      =   GET_IEP_RATE + (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]);//may have some trouble with the last value 1, may 0
            end
        endgenerate

        generate            
            for(o = 0; o < 32; o = o + 1)begin
                assign  coded_cost_tem[o]       =   coded_cost_tem_all[o] - dCurrCost_extra[o];
            end
        endgenerate


    //calculate dCurrCost[0]
        generate            
            for(o = 0; o < 32; o = o + 1)begin
                assign  dCurrCost_tem[0][0][o]   =  err_x_err[0][o] +
                                                    i_rdoq_est_level_d[1][ctx_level[o]][1];
            end    
            for(o = 0; o < 32; o = o + 1)begin
                assign  dCurrCost_tem[1][0][o]   =  err_x_err[0][o] +
                                                    i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
                                                    i_rdoq_est_level_d[1][ctx_level[o] + 1][0] << 3 - i_rdoq_est_level_d[1][ctx_level[o] + 1][0] +
                                                    ((funclog2(temp_coef_abs_d2[o] - 7) < 12 ? (funclog2(temp_coef_abs_d2[o] - 7) << 1 ) + 1 : 25) << 16);
            end    
            for(o = 0; o < 32; o = o + 1)begin
                assign  dCurrCost_tem[2][0][o]   =  err_x_err[0][o] +
                                                    i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
                                                    i_rdoq_est_level_d[1][ctx_level[o] + 1][1];
            end
        endgenerate

        always@(*)begin
            for(i = 0; i < 32; i = i + 1) begin
                case(temp_coef_abs_d2[i])
                    0 : begin
                        dCurrCost[0][i]     <=  24'h7f_ffff;
                    end
                    1 : begin
                        dCurrCost[0][i]     <=  dCurrCost_tem[0][0][i];
                    end
                    2 : begin
                        dCurrCost[0][i]     <=  dCurrCost_tem[2][0][i];
                    end
                    3 : begin
                        dCurrCost[0][i]     <=  dCurrCost_tem[2][0][i] + i_rdoq_est_level_d[1][ctx_level[i] + 1][0];
                    end
                    4 : begin
                        dCurrCost[0][i]     <=  dCurrCost_tem[2][0][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 1);
                    end
                    5 : begin
                        dCurrCost[0][i]     <=  dCurrCost_tem[2][0][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 1) + i_rdoq_est_level_d[1][ctx_level[i] + 1][0];
                    end
                    6 : begin
                        dCurrCost[0][i]     <=  dCurrCost_tem[2][0][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 2);
                    end
                    7 : begin
                        dCurrCost[0][i]     <=  dCurrCost_tem[2][0][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 2) + i_rdoq_est_level_d[1][ctx_level[i] + 1][0];
                    end
                    8 : begin
                        dCurrCost[0][i]     <=  dCurrCost_tem[2][0][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 2) + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 1);
                    end
                    default: begin 
                        dCurrCost[0][i]     <=  dCurrCost_tem[1][0][i];
                    end
                endcase 
            end
        end

    //calculate dCurrCost[1]
        generate          
            for(o = 0; o < 32; o = o + 1)begin
                assign  dCurrCost_tem[0][1][o]   =  err_x_err[1][o] +
                                                    i_rdoq_est_level_d[1][ctx_level[o]][1];
            end    
            for(o = 0; o < 32; o = o + 1)begin
                assign  dCurrCost_tem[1][1][o]   =  err_x_err[1][o] +
                                                    i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
                                                    i_rdoq_est_level_d[1][ctx_level[o] + 1][0] << 3 - i_rdoq_est_level_d[1][ctx_level[o] + 1][0] + 
                                                    ((funclog2(temp_coef_abs_d2[o] - 1 - 7) < 12 ? (funclog2(temp_coef_abs_d2[o] - 1 - 7) << 1 ) + 1 : 25) << 16);
            end    
            for(o = 0; o < 32; o = o + 1)begin
                assign  dCurrCost_tem[2][1][o]   =  err_x_err[1][o] +
                                                    i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
                                                    i_rdoq_est_level_d[1][ctx_level[o] + 1][1];
            end
        endgenerate

        always@(*)begin
            for(i = 0; i < 32; i = i + 1) begin
                case(temp_coef_abs_d2[i])
                    0,1: begin
                        dCurrCost[1][i]     <=  24'h7f_ffff;
                    end
                    2 : begin
                        dCurrCost[1][i]     <=  dCurrCost_tem[0][1][i];
                    end
                    3 : begin
                        dCurrCost[1][i]     <=  dCurrCost_tem[2][1][i];
                    end
                    4 : begin
                        dCurrCost[1][i]     <=  dCurrCost_tem[2][1][i] + i_rdoq_est_level_d[1][ctx_level[i] + 1][0];
                    end
                    5 : begin
                        dCurrCost[1][i]     <=  dCurrCost_tem[2][1][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 1);
                    end
                    6 : begin
                        dCurrCost[1][i]     <=  dCurrCost_tem[2][1][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 1) + i_rdoq_est_level_d[1][ctx_level[i] + 1][0];
                    end
                    7 : begin
                        dCurrCost[1][i]     <=  dCurrCost_tem[2][1][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 2);
                    end
                    8 : begin
                        dCurrCost[1][i]     <=  dCurrCost_tem[2][1][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 2) + i_rdoq_est_level_d[1][ctx_level[i] + 1][0];
                    end
                    9 : begin
                        dCurrCost[1][i]     <=  dCurrCost_tem[2][1][i] + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 2) + (i_rdoq_est_level_d[1][ctx_level[i] + 1][0] << 1);
                    end
                    default: begin 
                        dCurrCost[1][i]     <=  dCurrCost_tem[1][1][i];
                    end
                endcase 
            end
        end

    //calculate level_opt
        generate 
            for(o = 0; o < 32; o = o + 1)begin
                assign      level_opt   [o]     =   coded_cost_tem[o] < (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o]) ? 
                                                    0 : (dCurrCost[0][o] < dCurrCost[1][o] ? temp_coef_abs_d2[o] : (temp_coef_abs_d2[o] - 1 ) ) ;
            end
        endgenerate

//pipe 3

    //delay one cycle
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    level_opt_d1[i]     <=  0;
                end
            end
            else begin
                for(i = 0; i < 32; i = i + 1)begin
                    level_opt_d1[i]     <=  level_opt[i];
                end
            end
        end

        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    temp_coef_sign_d3[i]    <=  0;
                end
            end
            else begin
                for(i = 0; i < 32; i = i + 1)begin
                    temp_coef_sign_d3[i]    <=  temp_coef_sign_d2[i];
                end
            end
        end

    //calculate d64_cost_last_zero and d64_cost_last_one
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    d64_cost_last_zero[i]       <=  0;
                    d64_cost_last_one[i]        <=  0;
                end
            end
            else begin
                for(i = 0; i < 32; i = i + 1)begin
                    d64_cost_last_zero[i]       <=  i_rdoq_est_last_d[1] [((pre_level[i] - 1) > 5 ? 5 : (pre_level[i] - 1))] [funclog2(scan_pos[i] + 1)] [0];
                    d64_cost_last_one[i]        <=  i_rdoq_est_last_d[1] [((pre_level[i] - 1) > 5 ? 5 : (pre_level[i] - 1))] [funclog2(scan_pos[i] + 1)] [1];
                end
            end
        end

    //calculate base_cost_buffer_tmp
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)begin
                for(i = 0; i < 32; i = i + 1)begin
                    base_cost_buffer_tmp[i]     <=  0;
                end
            end
            else begin
                for(i = 0; i < 32; i = i + 1)begin
                    base_cost_buffer_tmp[i]     <=  ((coded_cost_tem[i] < (dCurrCost[0][i] < dCurrCost[1][i] ? dCurrCost[0][i] : dCurrCost[1][i])) ? 
                                                    coded_cost_tem[i] : (dCurrCost[0][i] < dCurrCost[1][i] ? dCurrCost[0][i] : dCurrCost[1][i]))
                                                    - uncoded_cost_tem[i] +  dCurrCost_extra[i];
                end
            end
        end


//output assignment
    generate 
        for(o = 0; o < 32; o = o + 1)begin
            assign      o_d64_cost_last_zero[o]     =   d64_cost_last_zero[o];
            assign      o_d64_cost_last_one[o]      =   d64_cost_last_one[o];

            assign      o_level_opt[o]              =   level_opt_d1[o];
            assign      o_base_cost_buffer_tmp[o]   =   level_opt_d1[o] ? (base_cost_buffer_tmp[o] + o_d64_cost_last_zero[o]) : base_cost_buffer_tmp[o];
            assign      o_tmp_dst_coef_sign[o]      =   temp_coef_sign_d3[o];
        end
            assign      o_valid                     =   i_valid_d[2];
            assign      o_width_log2                =   i_width_log2_d[2];
            assign      o_height_log2               =   i_height_log2_d[2];
    endgenerate



//function definition
    function [3 : 0] funclog2;
        input [9 : 0]  value;
        begin
            if(value[9])
                funclog2    =   9;
            else if(value[8])
                funclog2    =   8;
            else if(value[7])
                funclog2    =   7;
            else if(value[6])
                funclog2    =   6;
            else if(value[5])
                funclog2    =   5;
            else if(value[4])
                funclog2    =   4;
            else if(value[3])
                funclog2    =   3;
            else if(value[2])
                funclog2    =   2;
            else if(value[1])
                funclog2    =   1;
            else if(value[0])
                funclog2    =   0;
        end
    endfunction



`ifdef file_write //test bench


    wire    signed  [63 : 0]    uncoded_cost        [0 : 31]                                ;
    wire    signed  [63 : 0]    coded_cost          [0 : 31]                                ;

    generate 
        for(o = 0; o < 32; o = o + 1)begin
            assign      uncoded_cost[o]     =   uncoded_cost_tem[o] ;
            assign      coded_cost[o]       =   (coded_cost_tem[o] < (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o]) ? 
                                                coded_cost_tem[o] : (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o])) + dCurrCost_extra[o] ;
        end
    endgenerate

//16*16
    initial begin 
    integer fp_base_cost_buffer_w0,fp_base_cost_buffer_w1;
    integer wr_base_cost_buffer_j,wr_base_cost_buffer_k;
    reg     signed  [63: 0]     base_cost_buffer_data        [0 : 63]    ;
        #16;
        fp_base_cost_buffer_w0 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_16x16_0.txt", "w");
        fp_base_cost_buffer_w1 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_16x16_1.txt", "w");
        for (wr_base_cost_buffer_j = 0; wr_base_cost_buffer_j < 16; wr_base_cost_buffer_j = wr_base_cost_buffer_j + 1) begin
            for (wr_base_cost_buffer_k = 0; wr_base_cost_buffer_k < 32; wr_base_cost_buffer_k = wr_base_cost_buffer_k + 1) begin
                base_cost_buffer_data[wr_base_cost_buffer_k] = o_base_cost_buffer_tmp[wr_base_cost_buffer_k];
            end
            #2;
            $fwrite(fp_base_cost_buffer_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                base_cost_buffer_data[0 ], base_cost_buffer_data[1 ], base_cost_buffer_data[2 ], base_cost_buffer_data[3 ], base_cost_buffer_data[4 ], base_cost_buffer_data[5 ], base_cost_buffer_data[6 ], base_cost_buffer_data[7 ], 
                base_cost_buffer_data[8 ], base_cost_buffer_data[9 ], base_cost_buffer_data[10], base_cost_buffer_data[11], base_cost_buffer_data[12], base_cost_buffer_data[13], base_cost_buffer_data[14], base_cost_buffer_data[15]);
            $fwrite(fp_base_cost_buffer_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                base_cost_buffer_data[16], base_cost_buffer_data[17], base_cost_buffer_data[18], base_cost_buffer_data[19], base_cost_buffer_data[20], base_cost_buffer_data[21], base_cost_buffer_data[22], base_cost_buffer_data[23], 
                base_cost_buffer_data[24], base_cost_buffer_data[25], base_cost_buffer_data[26], base_cost_buffer_data[27], base_cost_buffer_data[28], base_cost_buffer_data[29], base_cost_buffer_data[30], base_cost_buffer_data[31]);
        end
        $fclose(fp_base_cost_buffer_w0);
        $fclose(fp_base_cost_buffer_w1);
    end


    initial begin 
    integer fp_pre_level_w0,fp_pre_level_w1;
    integer wr_pre_level_j,wr_pre_level_k;
    reg     signed  [63: 0]     pre_level_data        [0 : 63]    ;
        #14;
        fp_pre_level_w0 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_16x16_0.txt", "w");
        fp_pre_level_w1 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_16x16_1.txt", "w");
        for (wr_pre_level_j = 0; wr_pre_level_j < 16; wr_pre_level_j = wr_pre_level_j + 1) begin
            for (wr_pre_level_k = 0; wr_pre_level_k < 32; wr_pre_level_k = wr_pre_level_k + 1) begin
                pre_level_data[wr_pre_level_k] = pre_level[wr_pre_level_k];
            end
            #2;
            $fwrite(fp_pre_level_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pre_level_data[0 ], pre_level_data[1 ], pre_level_data[2 ], pre_level_data[3 ], pre_level_data[4 ], pre_level_data[5 ], pre_level_data[6 ], pre_level_data[7 ], 
                pre_level_data[8 ], pre_level_data[9 ], pre_level_data[10], pre_level_data[11], pre_level_data[12], pre_level_data[13], pre_level_data[14], pre_level_data[15]);
            $fwrite(fp_pre_level_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pre_level_data[16], pre_level_data[17], pre_level_data[18], pre_level_data[19], pre_level_data[20], pre_level_data[21], pre_level_data[22], pre_level_data[23], 
                pre_level_data[24], pre_level_data[25], pre_level_data[26], pre_level_data[27], pre_level_data[28], pre_level_data[29], pre_level_data[30], pre_level_data[31]);
        end
        $fclose(fp_pre_level_w0);
        $fclose(fp_pre_level_w1);
    end

    initial begin 
    integer fp_run_w0,fp_run_w1;
    integer wr_run_j,wr_run_k;
    reg     signed  [63: 0]     run_data        [0 : 63]    ;
        #14;
        fp_run_w0 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_16x16_0.txt", "w");
        fp_run_w1 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_16x16_1.txt", "w");
        for (wr_run_j = 0; wr_run_j < 16; wr_run_j = wr_run_j + 1) begin
            for (wr_run_k = 0; wr_run_k < 32; wr_run_k = wr_run_k + 1) begin
                run_data[wr_run_k] = run[wr_run_k];
            end
            #2;
            $fwrite(fp_run_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                run_data[0 ], run_data[1 ], run_data[2 ], run_data[3 ], run_data[4 ], run_data[5 ], run_data[6 ], run_data[7 ], 
                run_data[8 ], run_data[9 ], run_data[10], run_data[11], run_data[12], run_data[13], run_data[14], run_data[15]);
            $fwrite(fp_run_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                run_data[16], run_data[17], run_data[18], run_data[19], run_data[20], run_data[21], run_data[22], run_data[23], 
                run_data[24], run_data[25], run_data[26], run_data[27], run_data[28], run_data[29], run_data[30], run_data[31]);
        end
        $fclose(fp_run_w0);
        $fclose(fp_run_w1);
    end

    initial begin 
    integer fp_opt_w0,fp_opt_w1;
    integer wr_opt_j,wr_opt_k;
    reg     signed  [63: 0]     level_opt_data  [0 : 63]    ;
        #14;
        fp_opt_w0 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_16x16_0.txt", "w");
        fp_opt_w1 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_16x16_1.txt", "w");
        for (wr_opt_j = 0; wr_opt_j < 16; wr_opt_j = wr_opt_j + 1) begin
            for (wr_opt_k = 0; wr_opt_k < 32; wr_opt_k = wr_opt_k + 1) begin
                level_opt_data[wr_opt_k] = level_opt[wr_opt_k];
            end
            #2;
            $fwrite(fp_opt_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                level_opt_data[0 ], level_opt_data[1 ], level_opt_data[2 ], level_opt_data[3 ], level_opt_data[4 ], level_opt_data[5 ], level_opt_data[6 ], level_opt_data[7 ], 
                level_opt_data[8 ], level_opt_data[9 ], level_opt_data[10], level_opt_data[11], level_opt_data[12], level_opt_data[13], level_opt_data[14], level_opt_data[15]);
            $fwrite(fp_opt_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                level_opt_data[16], level_opt_data[17], level_opt_data[18], level_opt_data[19], level_opt_data[20], level_opt_data[21], level_opt_data[22], level_opt_data[23], 
                level_opt_data[24], level_opt_data[25], level_opt_data[26], level_opt_data[27], level_opt_data[28], level_opt_data[29], level_opt_data[30], level_opt_data[31]);
        end
        $fclose(fp_opt_w0);
        $fclose(fp_opt_w1);
    end


    initial begin 
    integer fp_coded_cost_w0,fp_coded_cost_w1;
    integer wr_coded_cost_j,wr_coded_cost_k;
    reg     signed  [63: 0]     coded_cost_data  [0 : 63]    ;
        #14;
        fp_coded_cost_w0 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_16x16_0.txt", "w");
        fp_coded_cost_w1 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_16x16_1.txt", "w");
        for (wr_coded_cost_j = 0; wr_coded_cost_j < 16; wr_coded_cost_j = wr_coded_cost_j + 1) begin
            for (wr_coded_cost_k = 0; wr_coded_cost_k < 32; wr_coded_cost_k = wr_coded_cost_k + 1) begin
                coded_cost_data[wr_coded_cost_k] = coded_cost[wr_coded_cost_k];
            end
            #2;
            $fwrite(fp_coded_cost_w0, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n",  
                coded_cost_data[0 ], coded_cost_data[1 ], coded_cost_data[2 ], coded_cost_data[3 ], coded_cost_data[4 ], coded_cost_data[5 ], coded_cost_data[6 ], coded_cost_data[7 ], 
                coded_cost_data[8 ], coded_cost_data[9 ], coded_cost_data[10], coded_cost_data[11], coded_cost_data[12], coded_cost_data[13], coded_cost_data[14], coded_cost_data[15]);
            $fwrite(fp_coded_cost_w1, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n",  
                coded_cost_data[16], coded_cost_data[17], coded_cost_data[18], coded_cost_data[19], coded_cost_data[20], coded_cost_data[21], coded_cost_data[22], coded_cost_data[23], 
                coded_cost_data[24], coded_cost_data[25], coded_cost_data[26], coded_cost_data[27], coded_cost_data[28], coded_cost_data[29], coded_cost_data[30], coded_cost_data[31]);
        end
        $fclose(fp_coded_cost_w0);
        $fclose(fp_coded_cost_w1);
    end



    initial begin 
    integer fp_uncoded_cost_w0,fp_uncoded_cost_w1;
    integer wr_uncoded_cost_j,wr_uncoded_cost_k;
    reg     signed  [63: 0]     uncoded_cost_data  [0 : 63]    ;
        #14;
        fp_uncoded_cost_w0 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_16x16_0.txt", "w");
        fp_uncoded_cost_w1 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_16x16_1.txt", "w");
        for (wr_uncoded_cost_j = 0; wr_uncoded_cost_j < 16; wr_uncoded_cost_j = wr_uncoded_cost_j + 1) begin
            for (wr_uncoded_cost_k = 0; wr_uncoded_cost_k < 32; wr_uncoded_cost_k = wr_uncoded_cost_k + 1) begin
                uncoded_cost_data[wr_uncoded_cost_k] = uncoded_cost[wr_uncoded_cost_k];
            end
            #2;
            $fwrite(fp_uncoded_cost_w0, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n",  
                uncoded_cost_data[0 ], uncoded_cost_data[1 ], uncoded_cost_data[2 ], uncoded_cost_data[3 ], uncoded_cost_data[4 ], uncoded_cost_data[5 ], uncoded_cost_data[6 ], uncoded_cost_data[7 ], 
                uncoded_cost_data[8 ], uncoded_cost_data[9 ], uncoded_cost_data[10], uncoded_cost_data[11], uncoded_cost_data[12], uncoded_cost_data[13], uncoded_cost_data[14], uncoded_cost_data[15]);
            $fwrite(fp_uncoded_cost_w1, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n",  
                uncoded_cost_data[16], uncoded_cost_data[17], uncoded_cost_data[18], uncoded_cost_data[19], uncoded_cost_data[20], uncoded_cost_data[21], uncoded_cost_data[22], uncoded_cost_data[23], 
                uncoded_cost_data[24], uncoded_cost_data[25], uncoded_cost_data[26], uncoded_cost_data[27], uncoded_cost_data[28], uncoded_cost_data[29], uncoded_cost_data[30], uncoded_cost_data[31]);
        end
        $fclose(fp_uncoded_cost_w0);
        $fclose(fp_uncoded_cost_w1);
    end

//32*32
    initial begin 
    integer fp_pre_level_w1;
    integer wr_pre_level_j,wr_pre_level_k;
    reg     signed  [63: 0]     pre_level_data        [0 : 63]    ;
        #46;
        fp_pre_level_w1 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_32x32.txt", "w");
        for (wr_pre_level_j = 0; wr_pre_level_j < 32; wr_pre_level_j = wr_pre_level_j + 1) begin
            for (wr_pre_level_k = 0; wr_pre_level_k < 32; wr_pre_level_k = wr_pre_level_k + 1) begin
                pre_level_data[wr_pre_level_k] = pre_level[wr_pre_level_k];
            end
            #2;
            $fwrite(fp_pre_level_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            pre_level_data[0 ], pre_level_data[1 ], pre_level_data[2 ], pre_level_data[3 ], pre_level_data[4 ], pre_level_data[5 ], pre_level_data[6 ], pre_level_data[7 ],
            pre_level_data[8 ], pre_level_data[9 ], pre_level_data[10], pre_level_data[11], pre_level_data[12], pre_level_data[13], pre_level_data[14], pre_level_data[15], 
            pre_level_data[16], pre_level_data[17], pre_level_data[18], pre_level_data[19], pre_level_data[20], pre_level_data[21], pre_level_data[22], pre_level_data[23], 
            pre_level_data[24], pre_level_data[25], pre_level_data[26], pre_level_data[27], pre_level_data[28], pre_level_data[29], pre_level_data[30], pre_level_data[31]);
        end
        $fclose(fp_pre_level_w1);
    end

    initial begin 
    integer fp_run_w1;
    integer wr_run_j,wr_run_k;
    reg     signed  [63: 0]     run_data        [0 : 63]    ;
        #46;
        fp_run_w1 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_32x32.txt", "w");
        for (wr_run_j = 0; wr_run_j < 32; wr_run_j = wr_run_j + 1) begin
            for (wr_run_k = 0; wr_run_k < 32; wr_run_k = wr_run_k + 1) begin
                run_data[wr_run_k] = run[wr_run_k];
            end
            #2;
            $fwrite(fp_run_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            run_data[0 ], run_data[1 ], run_data[2 ], run_data[3 ], run_data[4 ], run_data[5 ], run_data[6 ], run_data[7 ],
            run_data[8 ], run_data[9 ], run_data[10], run_data[11], run_data[12], run_data[13], run_data[14], run_data[15], 
            run_data[16], run_data[17], run_data[18], run_data[19], run_data[20], run_data[21], run_data[22], run_data[23], 
            run_data[24], run_data[25], run_data[26], run_data[27], run_data[28], run_data[29], run_data[30], run_data[31]);
        end
        $fclose(fp_run_w1);
    end

    initial begin 
    integer fp_opt_w2;
    integer wr_opt_j,wr_opt_k;
    reg     signed  [63: 0]     level_opt_data  [0 : 63]    ;
        #46;
        fp_opt_w2 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_32x32.txt", "w");
        for (wr_opt_j = 0; wr_opt_j < 32; wr_opt_j = wr_opt_j + 1) begin
            for (wr_opt_k = 0; wr_opt_k < 32; wr_opt_k = wr_opt_k + 1) begin
                level_opt_data[wr_opt_k] = level_opt[wr_opt_k];
            end
            #2;
            $fwrite(fp_opt_w2, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            level_opt_data[0 ], level_opt_data[1 ], level_opt_data[2 ], level_opt_data[3 ], level_opt_data[4 ], level_opt_data[5 ], level_opt_data[6 ], level_opt_data[7 ],
            level_opt_data[8 ], level_opt_data[9 ], level_opt_data[10], level_opt_data[11], level_opt_data[12], level_opt_data[13], level_opt_data[14], level_opt_data[15], 
            level_opt_data[16], level_opt_data[17], level_opt_data[18], level_opt_data[19], level_opt_data[20], level_opt_data[21], level_opt_data[22], level_opt_data[23], 
            level_opt_data[24], level_opt_data[25], level_opt_data[26], level_opt_data[27], level_opt_data[28], level_opt_data[29], level_opt_data[30], level_opt_data[31]);
        end
        $fclose(fp_opt_w2);
    end


    initial begin 
    integer fp_coded_cost_w;
    integer wr_coded_cost_j,wr_coded_cost_k;
    reg     signed  [63: 0]     coded_cost_data  [0 : 63]    ;
        #46;
        fp_coded_cost_w = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_32x32.txt", "w");
        for (wr_coded_cost_j = 0; wr_coded_cost_j < 32; wr_coded_cost_j = wr_coded_cost_j + 1) begin
            for (wr_coded_cost_k = 0; wr_coded_cost_k < 32; wr_coded_cost_k = wr_coded_cost_k + 1) begin
                coded_cost_data[wr_coded_cost_k] = coded_cost[wr_coded_cost_k];
            end
            #2;
            $fwrite(fp_coded_cost_w, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n",  
            coded_cost_data[0 ], coded_cost_data[1 ], coded_cost_data[2 ], coded_cost_data[3 ], coded_cost_data[4 ], coded_cost_data[5 ], coded_cost_data[6 ], coded_cost_data[7 ],
            coded_cost_data[8 ], coded_cost_data[9 ], coded_cost_data[10], coded_cost_data[11], coded_cost_data[12], coded_cost_data[13], coded_cost_data[14], coded_cost_data[15], 
            coded_cost_data[16], coded_cost_data[17], coded_cost_data[18], coded_cost_data[19], coded_cost_data[20], coded_cost_data[21], coded_cost_data[22], coded_cost_data[23], 
            coded_cost_data[24], coded_cost_data[25], coded_cost_data[26], coded_cost_data[27], coded_cost_data[28], coded_cost_data[29], coded_cost_data[30], coded_cost_data[31]);
        end
        $fclose(fp_coded_cost_w);
    end



    initial begin 
    integer fp_uncoded_cost_w;
    integer wr_uncoded_cost_j,wr_uncoded_cost_k;
    reg     signed  [63: 0]     uncoded_cost_data  [0 : 63]    ;
        #46;
        fp_uncoded_cost_w = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_32x32.txt", "w");
        for (wr_uncoded_cost_j = 0; wr_uncoded_cost_j < 32; wr_uncoded_cost_j = wr_uncoded_cost_j + 1) begin
            for (wr_uncoded_cost_k = 0; wr_uncoded_cost_k < 32; wr_uncoded_cost_k = wr_uncoded_cost_k + 1) begin
                uncoded_cost_data[wr_uncoded_cost_k] = uncoded_cost[wr_uncoded_cost_k];
            end
            #2;
            $fwrite(fp_uncoded_cost_w, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n",  
            uncoded_cost_data[0 ], uncoded_cost_data[1 ], uncoded_cost_data[2 ], uncoded_cost_data[3 ], uncoded_cost_data[4 ], uncoded_cost_data[5 ], uncoded_cost_data[6 ], uncoded_cost_data[7 ],
            uncoded_cost_data[8 ], uncoded_cost_data[9 ], uncoded_cost_data[10], uncoded_cost_data[11], uncoded_cost_data[12], uncoded_cost_data[13], uncoded_cost_data[14], uncoded_cost_data[15], 
            uncoded_cost_data[16], uncoded_cost_data[17], uncoded_cost_data[18], uncoded_cost_data[19], uncoded_cost_data[20], uncoded_cost_data[21], uncoded_cost_data[22], uncoded_cost_data[23], 
            uncoded_cost_data[24], uncoded_cost_data[25], uncoded_cost_data[26], uncoded_cost_data[27], uncoded_cost_data[28], uncoded_cost_data[29], uncoded_cost_data[30], uncoded_cost_data[31]);
        end
        $fclose(fp_uncoded_cost_w);
    end

    initial begin 
    integer fp_base_cost_buffer_w1;
    integer wr_base_cost_buffer_j,wr_base_cost_buffer_k;
    reg     signed  [63: 0]     base_cost_buffer_data        [0 : 63]    ;
        #48;
        fp_base_cost_buffer_w1 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_32x32.txt", "w");
        for (wr_base_cost_buffer_j = 0; wr_base_cost_buffer_j < 32; wr_base_cost_buffer_j = wr_base_cost_buffer_j + 1) begin
            for (wr_base_cost_buffer_k = 0; wr_base_cost_buffer_k < 32; wr_base_cost_buffer_k = wr_base_cost_buffer_k + 1) begin
                base_cost_buffer_data[wr_base_cost_buffer_k] = o_base_cost_buffer_tmp[wr_base_cost_buffer_k];
            end
            #2;
            $fwrite(fp_base_cost_buffer_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            base_cost_buffer_data[0 ], base_cost_buffer_data[1 ], base_cost_buffer_data[2 ], base_cost_buffer_data[3 ], base_cost_buffer_data[4 ], base_cost_buffer_data[5 ], base_cost_buffer_data[6 ], base_cost_buffer_data[7 ],
            base_cost_buffer_data[8 ], base_cost_buffer_data[9 ], base_cost_buffer_data[10], base_cost_buffer_data[11], base_cost_buffer_data[12], base_cost_buffer_data[13], base_cost_buffer_data[14], base_cost_buffer_data[15], 
            base_cost_buffer_data[16], base_cost_buffer_data[17], base_cost_buffer_data[18], base_cost_buffer_data[19], base_cost_buffer_data[20], base_cost_buffer_data[21], base_cost_buffer_data[22], base_cost_buffer_data[23], 
            base_cost_buffer_data[24], base_cost_buffer_data[25], base_cost_buffer_data[26], base_cost_buffer_data[27], base_cost_buffer_data[28], base_cost_buffer_data[29], base_cost_buffer_data[30], base_cost_buffer_data[31]);
        end
        $fclose(fp_base_cost_buffer_w1);
    end

//8x8
    initial begin 
    integer fp_pre_level_w0,fp_pre_level_w1,fp_pre_level_w2,fp_pre_level_w3;
    integer wr_pre_level_j,wr_pre_level_k;
    reg     signed  [63: 0]     pre_level_data        [0 : 63]    ;
        #110;
        fp_pre_level_w0 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_8x8_0.txt", "w");
        fp_pre_level_w1 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_8x8_1.txt", "w");
        fp_pre_level_w2 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_8x8_2.txt", "w");
        fp_pre_level_w3 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_8x8_3.txt", "w");
        for (wr_pre_level_j = 0; wr_pre_level_j < 8; wr_pre_level_j = wr_pre_level_j + 1) begin
            for (wr_pre_level_k = 0; wr_pre_level_k < 32; wr_pre_level_k = wr_pre_level_k + 1) begin
                pre_level_data[wr_pre_level_k] = pre_level[wr_pre_level_k];
            end
            #2;
            $fwrite(fp_pre_level_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pre_level_data[0 ], pre_level_data[1 ], pre_level_data[2 ], pre_level_data[3 ], pre_level_data[4 ], pre_level_data[5 ], pre_level_data[6 ], pre_level_data[7 ]);
            $fwrite(fp_pre_level_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pre_level_data[8 ], pre_level_data[9 ], pre_level_data[10], pre_level_data[11], pre_level_data[12], pre_level_data[13], pre_level_data[14], pre_level_data[15]);
            $fwrite(fp_pre_level_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pre_level_data[16], pre_level_data[17], pre_level_data[18], pre_level_data[19], pre_level_data[20], pre_level_data[21], pre_level_data[22], pre_level_data[23]);
            $fwrite(fp_pre_level_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                pre_level_data[24], pre_level_data[25], pre_level_data[26], pre_level_data[27], pre_level_data[28], pre_level_data[29], pre_level_data[30], pre_level_data[31]);
        end
        $fclose(fp_pre_level_w0);
        $fclose(fp_pre_level_w1);
        $fclose(fp_pre_level_w2);
        $fclose(fp_pre_level_w3);
    end

    initial begin 
    integer fp_run_w0,fp_run_w1,fp_run_w2,fp_run_w3;
    integer wr_run_j,wr_run_k;
    reg     signed  [63: 0]     run_data        [0 : 63]    ;
        #110;
        fp_run_w0 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_8x8_0.txt", "w");
        fp_run_w1 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_8x8_1.txt", "w");
        fp_run_w2 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_8x8_2.txt", "w");
        fp_run_w3 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_8x8_3.txt", "w");
        for (wr_run_j = 0; wr_run_j < 8; wr_run_j = wr_run_j + 1) begin
            for (wr_run_k = 0; wr_run_k < 32; wr_run_k = wr_run_k + 1) begin
                run_data[wr_run_k] = run[wr_run_k];
            end
            #2;
            $fwrite(fp_run_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                run_data[0 ], run_data[1 ], run_data[2 ], run_data[3 ], run_data[4 ], run_data[5 ], run_data[6 ], run_data[7 ]);
            $fwrite(fp_run_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                run_data[8 ], run_data[9 ], run_data[10], run_data[11], run_data[12], run_data[13], run_data[14], run_data[15]);
            $fwrite(fp_run_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                run_data[16], run_data[17], run_data[18], run_data[19], run_data[20], run_data[21], run_data[22], run_data[23]);
            $fwrite(fp_run_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                run_data[24], run_data[25], run_data[26], run_data[27], run_data[28], run_data[29], run_data[30], run_data[31]);
        end
        $fclose(fp_run_w0);
        $fclose(fp_run_w1);
        $fclose(fp_run_w2);
        $fclose(fp_run_w3);
    end

    initial begin 
    integer fp_level_opt_w0,fp_level_opt_w1,fp_level_opt_w2,fp_level_opt_w3,fp_level_opt_w4,fp_level_opt_w5,fp_level_opt_w6,fp_level_opt_w7;
    integer wr_level_opt_j,wr_level_opt_k;
    reg     signed  [63: 0]     level_opt_data        [0 : 63]    ;
        #126;
        fp_level_opt_w0 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_4x4_0.txt", "w");
        fp_level_opt_w1 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_4x4_1.txt", "w");
        fp_level_opt_w2 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_4x4_2.txt", "w");
        fp_level_opt_w3 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_4x4_3.txt", "w");
        fp_level_opt_w4 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_4x4_4.txt", "w");
        fp_level_opt_w5 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_4x4_5.txt", "w");
        fp_level_opt_w6 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_4x4_6.txt", "w");
        fp_level_opt_w7 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_4x4_7.txt", "w");
        for (wr_level_opt_j = 0; wr_level_opt_j < 4; wr_level_opt_j = wr_level_opt_j + 1) begin
            for (wr_level_opt_k = 0; wr_level_opt_k < 32; wr_level_opt_k = wr_level_opt_k + 1) begin
                level_opt_data[wr_level_opt_k] = level_opt[wr_level_opt_k];
            end
            #2;
            $fwrite(fp_level_opt_w0, "%6d %6d %6d %6d \n", 
                level_opt_data[0 ], level_opt_data[1 ], level_opt_data[2 ], level_opt_data[3 ]);
            $fwrite(fp_level_opt_w1, "%6d %6d %6d %6d \n", 
                level_opt_data[4 ], level_opt_data[5 ], level_opt_data[6 ], level_opt_data[7 ]);
            $fwrite(fp_level_opt_w2, "%6d %6d %6d %6d \n", 
                level_opt_data[8 ], level_opt_data[9 ], level_opt_data[10], level_opt_data[11]);
            $fwrite(fp_level_opt_w3, "%6d %6d %6d %6d \n", 
                level_opt_data[12], level_opt_data[13], level_opt_data[14], level_opt_data[15]);
            $fwrite(fp_level_opt_w4, "%6d %6d %6d %6d \n", 
                level_opt_data[16], level_opt_data[17], level_opt_data[18], level_opt_data[19]);
            $fwrite(fp_level_opt_w5, "%6d %6d %6d %6d \n", 
                level_opt_data[20], level_opt_data[21], level_opt_data[22], level_opt_data[23]);
            $fwrite(fp_level_opt_w6, "%6d %6d %6d %6d \n", 
                level_opt_data[24], level_opt_data[25], level_opt_data[26], level_opt_data[27]);
            $fwrite(fp_level_opt_w7, "%6d %6d %6d %6d \n", 
                level_opt_data[28], level_opt_data[29], level_opt_data[30], level_opt_data[31]);
        end
        $fclose(fp_level_opt_w0);
        $fclose(fp_level_opt_w1);
        $fclose(fp_level_opt_w2);
        $fclose(fp_level_opt_w3);
        $fclose(fp_level_opt_w4);
        $fclose(fp_level_opt_w5);
        $fclose(fp_level_opt_w6);
        $fclose(fp_level_opt_w7);
    end

    initial begin 
    integer fp_coded_cost_w0,fp_coded_cost_w1,fp_coded_cost_w2,fp_coded_cost_w3;
    integer wr_coded_cost_j,wr_coded_cost_k;
    reg     signed  [63: 0]     coded_cost_data  [0 : 63]    ;
        #110;
        fp_coded_cost_w0 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_8x8_0.txt", "w");
        fp_coded_cost_w1 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_8x8_1.txt", "w");
        fp_coded_cost_w2 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_8x8_2.txt", "w");
        fp_coded_cost_w3 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_8x8_3.txt", "w");
        for (wr_coded_cost_j = 0; wr_coded_cost_j < 8; wr_coded_cost_j = wr_coded_cost_j + 1) begin
            for (wr_coded_cost_k = 0; wr_coded_cost_k < 32; wr_coded_cost_k = wr_coded_cost_k + 1) begin
                coded_cost_data[wr_coded_cost_k] = coded_cost[wr_coded_cost_k];
            end
            #2;
            $fwrite(fp_coded_cost_w0, "%16d %16d %16d %16d %16d %16d %16d %16d \n", 
                coded_cost_data[0 ], coded_cost_data[1 ], coded_cost_data[2 ], coded_cost_data[3 ], coded_cost_data[4 ], coded_cost_data[5 ], coded_cost_data[6 ], coded_cost_data[7 ]);
            $fwrite(fp_coded_cost_w1, "%16d %16d %16d %16d %16d %16d %16d %16d \n", 
                coded_cost_data[8 ], coded_cost_data[9 ], coded_cost_data[10], coded_cost_data[11], coded_cost_data[12], coded_cost_data[13], coded_cost_data[14], coded_cost_data[15]);
            $fwrite(fp_coded_cost_w2, "%16d %16d %16d %16d %16d %16d %16d %16d \n", 
                coded_cost_data[16], coded_cost_data[17], coded_cost_data[18], coded_cost_data[19], coded_cost_data[20], coded_cost_data[21], coded_cost_data[22], coded_cost_data[23]);
            $fwrite(fp_coded_cost_w3, "%16d %16d %16d %16d %16d %16d %16d %16d \n", 
                coded_cost_data[24], coded_cost_data[25], coded_cost_data[26], coded_cost_data[27], coded_cost_data[28], coded_cost_data[29], coded_cost_data[30], coded_cost_data[31]);
        end
        $fclose(fp_coded_cost_w0);
        $fclose(fp_coded_cost_w1);
        $fclose(fp_coded_cost_w2);
        $fclose(fp_coded_cost_w3);
    end



    initial begin 
    integer fp_uncoded_cost_w0,fp_uncoded_cost_w1,fp_uncoded_cost_w2,fp_uncoded_cost_w3;
    integer wr_uncoded_cost_j,wr_uncoded_cost_k;
    reg     signed  [63: 0]     uncoded_cost_data  [0 : 63]    ;
        #110;
        fp_uncoded_cost_w0 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_8x8_0.txt", "w");
        fp_uncoded_cost_w1 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_8x8_1.txt", "w");
        fp_uncoded_cost_w2 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_8x8_2.txt", "w");
        fp_uncoded_cost_w3 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_8x8_3.txt", "w");
        for (wr_uncoded_cost_j = 0; wr_uncoded_cost_j < 8; wr_uncoded_cost_j = wr_uncoded_cost_j + 1) begin
            for (wr_uncoded_cost_k = 0; wr_uncoded_cost_k < 32; wr_uncoded_cost_k = wr_uncoded_cost_k + 1) begin
                uncoded_cost_data[wr_uncoded_cost_k] = uncoded_cost[wr_uncoded_cost_k];
            end
            #2;
            $fwrite(fp_uncoded_cost_w0, "%16d %16d %16d %16d %16d %16d %16d %16d \n", 
                uncoded_cost_data[0 ], uncoded_cost_data[1 ], uncoded_cost_data[2 ], uncoded_cost_data[3 ], uncoded_cost_data[4 ], uncoded_cost_data[5 ], uncoded_cost_data[6 ], uncoded_cost_data[7 ]);
            $fwrite(fp_uncoded_cost_w1, "%16d %16d %16d %16d %16d %16d %16d %16d \n", 
                uncoded_cost_data[8 ], uncoded_cost_data[9 ], uncoded_cost_data[10], uncoded_cost_data[11], uncoded_cost_data[12], uncoded_cost_data[13], uncoded_cost_data[14], uncoded_cost_data[15]);
            $fwrite(fp_uncoded_cost_w2, "%16d %16d %16d %16d %16d %16d %16d %16d \n", 
                uncoded_cost_data[16], uncoded_cost_data[17], uncoded_cost_data[18], uncoded_cost_data[19], uncoded_cost_data[20], uncoded_cost_data[21], uncoded_cost_data[22], uncoded_cost_data[23]);
            $fwrite(fp_uncoded_cost_w3, "%16d %16d %16d %16d %16d %16d %16d %16d \n", 
                uncoded_cost_data[24], uncoded_cost_data[25], uncoded_cost_data[26], uncoded_cost_data[27], uncoded_cost_data[28], uncoded_cost_data[29], uncoded_cost_data[30], uncoded_cost_data[31]);
        end
        $fclose(fp_uncoded_cost_w0);
        $fclose(fp_uncoded_cost_w1);
        $fclose(fp_uncoded_cost_w2);
        $fclose(fp_uncoded_cost_w3);
    end

    initial begin 
    integer fp_base_cost_buffer_w0,fp_base_cost_buffer_w1,fp_base_cost_buffer_w2,fp_base_cost_buffer_w3;
    integer wr_base_cost_buffer_j,wr_base_cost_buffer_k;
    reg     signed  [63: 0]     base_cost_buffer_data        [0 : 63]    ;
        #112;
        fp_base_cost_buffer_w0 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_8x8_0.txt", "w");
        fp_base_cost_buffer_w1 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_8x8_1.txt", "w");
        fp_base_cost_buffer_w2 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_8x8_2.txt", "w");
        fp_base_cost_buffer_w3 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_8x8_3.txt", "w");
        for (wr_base_cost_buffer_j = 0; wr_base_cost_buffer_j < 8; wr_base_cost_buffer_j = wr_base_cost_buffer_j + 1) begin
            for (wr_base_cost_buffer_k = 0; wr_base_cost_buffer_k < 32; wr_base_cost_buffer_k = wr_base_cost_buffer_k + 1) begin
                base_cost_buffer_data[wr_base_cost_buffer_k] = o_base_cost_buffer_tmp[wr_base_cost_buffer_k];
            end
            #2;
            $fwrite(fp_base_cost_buffer_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                base_cost_buffer_data[0 ], base_cost_buffer_data[1 ], base_cost_buffer_data[2 ], base_cost_buffer_data[3 ], base_cost_buffer_data[4 ], base_cost_buffer_data[5 ], base_cost_buffer_data[6 ], base_cost_buffer_data[7 ]);
            $fwrite(fp_base_cost_buffer_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                base_cost_buffer_data[8 ], base_cost_buffer_data[9 ], base_cost_buffer_data[10], base_cost_buffer_data[11], base_cost_buffer_data[12], base_cost_buffer_data[13], base_cost_buffer_data[14], base_cost_buffer_data[15]);
            $fwrite(fp_base_cost_buffer_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                base_cost_buffer_data[16], base_cost_buffer_data[17], base_cost_buffer_data[18], base_cost_buffer_data[19], base_cost_buffer_data[20], base_cost_buffer_data[21], base_cost_buffer_data[22], base_cost_buffer_data[23]);
            $fwrite(fp_base_cost_buffer_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                base_cost_buffer_data[24], base_cost_buffer_data[25], base_cost_buffer_data[26], base_cost_buffer_data[27], base_cost_buffer_data[28], base_cost_buffer_data[29], base_cost_buffer_data[30], base_cost_buffer_data[31]);
        end
        $fclose(fp_base_cost_buffer_w0);
        $fclose(fp_base_cost_buffer_w1);
        $fclose(fp_base_cost_buffer_w2);
        $fclose(fp_base_cost_buffer_w3);
    end

//4x4
    initial begin 
    integer fp_pre_level_w0,fp_pre_level_w1,fp_pre_level_w2,fp_pre_level_w3,fp_pre_level_w4,fp_pre_level_w5,fp_pre_level_w6,fp_pre_level_w7;
    integer wr_pre_level_j,wr_pre_level_k;
    reg     signed  [63: 0]     pre_level_data        [0 : 63]    ;
        #126;
        fp_pre_level_w0 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_4x4_0.txt", "w");
        fp_pre_level_w1 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_4x4_1.txt", "w");
        fp_pre_level_w2 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_4x4_2.txt", "w");
        fp_pre_level_w3 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_4x4_3.txt", "w");
        fp_pre_level_w4 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_4x4_4.txt", "w");
        fp_pre_level_w5 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_4x4_5.txt", "w");
        fp_pre_level_w6 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_4x4_6.txt", "w");
        fp_pre_level_w7 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_4x4_7.txt", "w");
        for (wr_pre_level_j = 0; wr_pre_level_j < 4; wr_pre_level_j = wr_pre_level_j + 1) begin
            for (wr_pre_level_k = 0; wr_pre_level_k < 32; wr_pre_level_k = wr_pre_level_k + 1) begin
                pre_level_data[wr_pre_level_k] = pre_level[wr_pre_level_k];
            end
            #2;
            $fwrite(fp_pre_level_w0, "%6d %6d %6d %6d \n", 
                pre_level_data[0 ], pre_level_data[1 ], pre_level_data[2 ], pre_level_data[3 ]);
            $fwrite(fp_pre_level_w1, "%6d %6d %6d %6d \n", 
                pre_level_data[4 ], pre_level_data[5 ], pre_level_data[6 ], pre_level_data[7 ]);
            $fwrite(fp_pre_level_w2, "%6d %6d %6d %6d \n", 
                pre_level_data[8 ], pre_level_data[9 ], pre_level_data[10], pre_level_data[11]);
            $fwrite(fp_pre_level_w3, "%6d %6d %6d %6d \n", 
                pre_level_data[12], pre_level_data[13], pre_level_data[14], pre_level_data[15]);
            $fwrite(fp_pre_level_w4, "%6d %6d %6d %6d \n", 
                pre_level_data[16], pre_level_data[17], pre_level_data[18], pre_level_data[19]);
            $fwrite(fp_pre_level_w5, "%6d %6d %6d %6d \n", 
                pre_level_data[20], pre_level_data[21], pre_level_data[22], pre_level_data[23]);
            $fwrite(fp_pre_level_w6, "%6d %6d %6d %6d \n", 
                pre_level_data[24], pre_level_data[25], pre_level_data[26], pre_level_data[27]);
            $fwrite(fp_pre_level_w7, "%6d %6d %6d %6d \n", 
                pre_level_data[28], pre_level_data[29], pre_level_data[30], pre_level_data[31]);
        end
        $fclose(fp_pre_level_w0);
        $fclose(fp_pre_level_w1);
        $fclose(fp_pre_level_w2);
        $fclose(fp_pre_level_w3);
        $fclose(fp_pre_level_w4);
        $fclose(fp_pre_level_w5);
        $fclose(fp_pre_level_w6);
        $fclose(fp_pre_level_w7);
    end


    initial begin 
    integer fp_run_w0,fp_run_w1,fp_run_w2,fp_run_w3,fp_run_w4,fp_run_w5,fp_run_w6,fp_run_w7;
    integer wr_run_j,wr_run_k;
    reg     signed  [63: 0]     run_data        [0 : 63]    ;
        #126;
        fp_run_w0 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_4x4_0.txt", "w");
        fp_run_w1 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_4x4_1.txt", "w");
        fp_run_w2 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_4x4_2.txt", "w");
        fp_run_w3 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_4x4_3.txt", "w");
        fp_run_w4 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_4x4_4.txt", "w");
        fp_run_w5 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_4x4_5.txt", "w");
        fp_run_w6 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_4x4_6.txt", "w");
        fp_run_w7 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_4x4_7.txt", "w");
        for (wr_run_j = 0; wr_run_j < 4; wr_run_j = wr_run_j + 1) begin
            for (wr_run_k = 0; wr_run_k < 32; wr_run_k = wr_run_k + 1) begin
                run_data[wr_run_k] = run[wr_run_k];
            end
            #2;
            $fwrite(fp_run_w0, "%6d %6d %6d %6d \n", 
                run_data[0 ], run_data[1 ], run_data[2 ], run_data[3 ]);
            $fwrite(fp_run_w1, "%6d %6d %6d %6d \n", 
                run_data[4 ], run_data[5 ], run_data[6 ], run_data[7 ]);
            $fwrite(fp_run_w2, "%6d %6d %6d %6d \n", 
                run_data[8 ], run_data[9 ], run_data[10], run_data[11]);
            $fwrite(fp_run_w3, "%6d %6d %6d %6d \n", 
                run_data[12], run_data[13], run_data[14], run_data[15]);
            $fwrite(fp_run_w4, "%6d %6d %6d %6d \n", 
                run_data[16], run_data[17], run_data[18], run_data[19]);
            $fwrite(fp_run_w5, "%6d %6d %6d %6d \n", 
                run_data[20], run_data[21], run_data[22], run_data[23]);
            $fwrite(fp_run_w6, "%6d %6d %6d %6d \n", 
                run_data[24], run_data[25], run_data[26], run_data[27]);
            $fwrite(fp_run_w7, "%6d %6d %6d %6d \n", 
                run_data[28], run_data[29], run_data[30], run_data[31]);
        end
        $fclose(fp_run_w0);
        $fclose(fp_run_w1);
        $fclose(fp_run_w2);
        $fclose(fp_run_w3);
        $fclose(fp_run_w4);
        $fclose(fp_run_w5);
        $fclose(fp_run_w6);
        $fclose(fp_run_w7);
    end


    initial begin 
    integer fp_opt_w0,fp_opt_w1,fp_opt_w2,fp_opt_w3,fp_opt_w4,fp_opt_w5,fp_opt_w6,fp_opt_w7;
    integer wr_opt_j,wr_opt_k;
    reg     signed  [63: 0]     opt_data        [0 : 63]    ;
        #126;
        fp_opt_w0 = $fopen("../../../../../result/ocd/fpga_opt/fpga_opt_4x4_0.txt", "w");
        fp_opt_w1 = $fopen("../../../../../result/ocd/fpga_opt/fpga_opt_4x4_1.txt", "w");
        fp_opt_w2 = $fopen("../../../../../result/ocd/fpga_opt/fpga_opt_4x4_2.txt", "w");
        fp_opt_w3 = $fopen("../../../../../result/ocd/fpga_opt/fpga_opt_4x4_3.txt", "w");
        fp_opt_w4 = $fopen("../../../../../result/ocd/fpga_opt/fpga_opt_4x4_4.txt", "w");
        fp_opt_w5 = $fopen("../../../../../result/ocd/fpga_opt/fpga_opt_4x4_5.txt", "w");
        fp_opt_w6 = $fopen("../../../../../result/ocd/fpga_opt/fpga_opt_4x4_6.txt", "w");
        fp_opt_w7 = $fopen("../../../../../result/ocd/fpga_opt/fpga_opt_4x4_7.txt", "w");
        for (wr_opt_j = 0; wr_opt_j < 4; wr_opt_j = wr_opt_j + 1) begin
            for (wr_opt_k = 0; wr_opt_k < 32; wr_opt_k = wr_opt_k + 1) begin
                opt_data[wr_opt_k] = level_opt[wr_opt_k];
            end
            #2;
            $fwrite(fp_opt_w0, "%6d %6d %6d %6d \n", 
                opt_data[0 ], opt_data[1 ], opt_data[2 ], opt_data[3 ]);
            $fwrite(fp_opt_w1, "%6d %6d %6d %6d \n", 
                opt_data[4 ], opt_data[5 ], opt_data[6 ], opt_data[7 ]);
            $fwrite(fp_opt_w2, "%6d %6d %6d %6d \n", 
                opt_data[8 ], opt_data[9 ], opt_data[10], opt_data[11]);
            $fwrite(fp_opt_w3, "%6d %6d %6d %6d \n", 
                opt_data[12], opt_data[13], opt_data[14], opt_data[15]);
            $fwrite(fp_opt_w4, "%6d %6d %6d %6d \n", 
                opt_data[16], opt_data[17], opt_data[18], opt_data[19]);
            $fwrite(fp_opt_w5, "%6d %6d %6d %6d \n", 
                opt_data[20], opt_data[21], opt_data[22], opt_data[23]);
            $fwrite(fp_opt_w6, "%6d %6d %6d %6d \n", 
                opt_data[24], opt_data[25], opt_data[26], opt_data[27]);
            $fwrite(fp_opt_w7, "%6d %6d %6d %6d \n", 
                opt_data[28], opt_data[29], opt_data[30], opt_data[31]);
        end
        $fclose(fp_opt_w0);
        $fclose(fp_opt_w1);
        $fclose(fp_opt_w2);
        $fclose(fp_opt_w3);
        $fclose(fp_opt_w4);
        $fclose(fp_opt_w5);
        $fclose(fp_opt_w6);
        $fclose(fp_opt_w7);
    end


    initial begin 
    integer fp_coded_cost_w0,fp_coded_cost_w1,fp_coded_cost_w2,fp_coded_cost_w3,fp_coded_cost_w4,fp_coded_cost_w5,fp_coded_cost_w6,fp_coded_cost_w7;
    integer wr_coded_cost_j,wr_coded_cost_k;
    reg     signed  [63: 0]     coded_cost_data        [0 : 63]    ;
        #126;
        fp_coded_cost_w0 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_0.txt", "w");
        fp_coded_cost_w1 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_1.txt", "w");
        fp_coded_cost_w2 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_2.txt", "w");
        fp_coded_cost_w3 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_3.txt", "w");
        fp_coded_cost_w4 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_4.txt", "w");
        fp_coded_cost_w5 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_5.txt", "w");
        fp_coded_cost_w6 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_6.txt", "w");
        fp_coded_cost_w7 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_7.txt", "w");
        for (wr_coded_cost_j = 0; wr_coded_cost_j < 4; wr_coded_cost_j = wr_coded_cost_j + 1) begin
            for (wr_coded_cost_k = 0; wr_coded_cost_k < 32; wr_coded_cost_k = wr_coded_cost_k + 1) begin
                coded_cost_data[wr_coded_cost_k] = coded_cost[wr_coded_cost_k];
            end
            #2;
            $fwrite(fp_coded_cost_w0, "%16d %16d %16d %16d \n", 
                coded_cost_data[0 ], coded_cost_data[1 ], coded_cost_data[2 ], coded_cost_data[3 ]);
            $fwrite(fp_coded_cost_w1, "%16d %16d %16d %16d \n", 
                coded_cost_data[4 ], coded_cost_data[5 ], coded_cost_data[6 ], coded_cost_data[7 ]);
            $fwrite(fp_coded_cost_w2, "%16d %16d %16d %16d \n", 
                coded_cost_data[8 ], coded_cost_data[9 ], coded_cost_data[10], coded_cost_data[11]);
            $fwrite(fp_coded_cost_w3, "%16d %16d %16d %16d \n", 
                coded_cost_data[12], coded_cost_data[13], coded_cost_data[14], coded_cost_data[15]);
            $fwrite(fp_coded_cost_w4, "%16d %16d %16d %16d \n", 
                coded_cost_data[16], coded_cost_data[17], coded_cost_data[18], coded_cost_data[19]);
            $fwrite(fp_coded_cost_w5, "%16d %16d %16d %16d \n", 
                coded_cost_data[20], coded_cost_data[21], coded_cost_data[22], coded_cost_data[23]);
            $fwrite(fp_coded_cost_w6, "%16d %16d %16d %16d \n", 
                coded_cost_data[24], coded_cost_data[25], coded_cost_data[26], coded_cost_data[27]);
            $fwrite(fp_coded_cost_w7, "%16d %16d %16d %16d \n", 
                coded_cost_data[28], coded_cost_data[29], coded_cost_data[30], coded_cost_data[31]);
        end
        $fclose(fp_coded_cost_w0);
        $fclose(fp_coded_cost_w1);
        $fclose(fp_coded_cost_w2);
        $fclose(fp_coded_cost_w3);
        $fclose(fp_coded_cost_w4);
        $fclose(fp_coded_cost_w5);
        $fclose(fp_coded_cost_w6);
        $fclose(fp_coded_cost_w7);
    end


    initial begin 
    integer fp_uncoded_cost_w0,fp_uncoded_cost_w1,fp_uncoded_cost_w2,fp_uncoded_cost_w3,fp_uncoded_cost_w4,fp_uncoded_cost_w5,fp_uncoded_cost_w6,fp_uncoded_cost_w7;
    integer wr_uncoded_cost_j,wr_uncoded_cost_k;
    reg     signed  [63: 0]     uncoded_cost_data        [0 : 63]    ;
        #126;
        fp_uncoded_cost_w0 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_0.txt", "w");
        fp_uncoded_cost_w1 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_1.txt", "w");
        fp_uncoded_cost_w2 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_2.txt", "w");
        fp_uncoded_cost_w3 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_3.txt", "w");
        fp_uncoded_cost_w4 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_4.txt", "w");
        fp_uncoded_cost_w5 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_5.txt", "w");
        fp_uncoded_cost_w6 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_6.txt", "w");
        fp_uncoded_cost_w7 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_7.txt", "w");
        for (wr_uncoded_cost_j = 0; wr_uncoded_cost_j < 4; wr_uncoded_cost_j = wr_uncoded_cost_j + 1) begin
            for (wr_uncoded_cost_k = 0; wr_uncoded_cost_k < 32; wr_uncoded_cost_k = wr_uncoded_cost_k + 1) begin
                uncoded_cost_data[wr_uncoded_cost_k] = uncoded_cost[wr_uncoded_cost_k];
            end
            #2;
            $fwrite(fp_uncoded_cost_w0, "%16d %16d %16d %16d \n", 
                uncoded_cost_data[0 ], uncoded_cost_data[1 ], uncoded_cost_data[2 ], uncoded_cost_data[3 ]);
            $fwrite(fp_uncoded_cost_w1, "%16d %16d %16d %16d \n", 
                uncoded_cost_data[4 ], uncoded_cost_data[5 ], uncoded_cost_data[6 ], uncoded_cost_data[7 ]);
            $fwrite(fp_uncoded_cost_w2, "%16d %16d %16d %16d \n", 
                uncoded_cost_data[8 ], uncoded_cost_data[9 ], uncoded_cost_data[10], uncoded_cost_data[11]);
            $fwrite(fp_uncoded_cost_w3, "%16d %16d %16d %16d \n", 
                uncoded_cost_data[12], uncoded_cost_data[13], uncoded_cost_data[14], uncoded_cost_data[15]);
            $fwrite(fp_uncoded_cost_w4, "%16d %16d %16d %16d \n", 
                uncoded_cost_data[16], uncoded_cost_data[17], uncoded_cost_data[18], uncoded_cost_data[19]);
            $fwrite(fp_uncoded_cost_w5, "%16d %16d %16d %16d \n", 
                uncoded_cost_data[20], uncoded_cost_data[21], uncoded_cost_data[22], uncoded_cost_data[23]);
            $fwrite(fp_uncoded_cost_w6, "%16d %16d %16d %16d \n", 
                uncoded_cost_data[24], uncoded_cost_data[25], uncoded_cost_data[26], uncoded_cost_data[27]);
            $fwrite(fp_uncoded_cost_w7, "%16d %16d %16d %16d \n", 
                uncoded_cost_data[28], uncoded_cost_data[29], uncoded_cost_data[30], uncoded_cost_data[31]);
        end
        $fclose(fp_uncoded_cost_w0);
        $fclose(fp_uncoded_cost_w1);
        $fclose(fp_uncoded_cost_w2);
        $fclose(fp_uncoded_cost_w3);
        $fclose(fp_uncoded_cost_w4);
        $fclose(fp_uncoded_cost_w5);
        $fclose(fp_uncoded_cost_w6);
        $fclose(fp_uncoded_cost_w7);
    end

    initial begin 
    integer fp_base_cost_buffer_w0,fp_base_cost_buffer_w1,fp_base_cost_buffer_w2,fp_base_cost_buffer_w3,fp_base_cost_buffer_w4,fp_base_cost_buffer_w5,fp_base_cost_buffer_w6,fp_base_cost_buffer_w7;
    integer wr_base_cost_buffer_j,wr_base_cost_buffer_k;
    reg     signed  [63: 0]     base_cost_buffer_data        [0 : 63]    ;
        #128;
        fp_base_cost_buffer_w0 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_0.txt", "w");
        fp_base_cost_buffer_w1 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_1.txt", "w");
        fp_base_cost_buffer_w2 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_2.txt", "w");
        fp_base_cost_buffer_w3 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_3.txt", "w");
        fp_base_cost_buffer_w4 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_4.txt", "w");
        fp_base_cost_buffer_w5 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_5.txt", "w");
        fp_base_cost_buffer_w6 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_6.txt", "w");
        fp_base_cost_buffer_w7 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_7.txt", "w");
        for (wr_base_cost_buffer_j = 0; wr_base_cost_buffer_j < 4; wr_base_cost_buffer_j = wr_base_cost_buffer_j + 1) begin
            for (wr_base_cost_buffer_k = 0; wr_base_cost_buffer_k < 32; wr_base_cost_buffer_k = wr_base_cost_buffer_k + 1) begin
                base_cost_buffer_data[wr_base_cost_buffer_k] = o_base_cost_buffer_tmp[wr_base_cost_buffer_k];
            end
            #2;
            $fwrite(fp_base_cost_buffer_w0, "%6d %6d %6d %6d \n", 
                base_cost_buffer_data[0 ], base_cost_buffer_data[1 ], base_cost_buffer_data[2 ], base_cost_buffer_data[3 ]);
            $fwrite(fp_base_cost_buffer_w1, "%6d %6d %6d %6d \n", 
                base_cost_buffer_data[4 ], base_cost_buffer_data[5 ], base_cost_buffer_data[6 ], base_cost_buffer_data[7 ]);
            $fwrite(fp_base_cost_buffer_w2, "%6d %6d %6d %6d \n", 
                base_cost_buffer_data[8 ], base_cost_buffer_data[9 ], base_cost_buffer_data[10], base_cost_buffer_data[11]);
            $fwrite(fp_base_cost_buffer_w3, "%6d %6d %6d %6d \n", 
                base_cost_buffer_data[12], base_cost_buffer_data[13], base_cost_buffer_data[14], base_cost_buffer_data[15]);
            $fwrite(fp_base_cost_buffer_w4, "%6d %6d %6d %6d \n", 
                base_cost_buffer_data[16], base_cost_buffer_data[17], base_cost_buffer_data[18], base_cost_buffer_data[19]);
            $fwrite(fp_base_cost_buffer_w5, "%6d %6d %6d %6d \n", 
                base_cost_buffer_data[20], base_cost_buffer_data[21], base_cost_buffer_data[22], base_cost_buffer_data[23]);
            $fwrite(fp_base_cost_buffer_w6, "%6d %6d %6d %6d \n", 
                base_cost_buffer_data[24], base_cost_buffer_data[25], base_cost_buffer_data[26], base_cost_buffer_data[27]);
            $fwrite(fp_base_cost_buffer_w7, "%6d %6d %6d %6d \n", 
                base_cost_buffer_data[28], base_cost_buffer_data[29], base_cost_buffer_data[30], base_cost_buffer_data[31]);
        end
        $fclose(fp_base_cost_buffer_w0);
        $fclose(fp_base_cost_buffer_w1);
        $fclose(fp_base_cost_buffer_w2);
        $fclose(fp_base_cost_buffer_w3);
        $fclose(fp_base_cost_buffer_w4);
        $fclose(fp_base_cost_buffer_w5);
        $fclose(fp_base_cost_buffer_w6);
        $fclose(fp_base_cost_buffer_w7);
    end


`endif










endmodule


