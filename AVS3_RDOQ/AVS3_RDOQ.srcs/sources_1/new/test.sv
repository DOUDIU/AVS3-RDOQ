module test(      
//system clk and rest       
    input                       clk                                                     ,
    input                       rst_n                                                   ,

//input parameter                                   
    input           [2 : 0]     i_width_log2                                            ,//the value is between 2 and 6
    input           [2 : 0]     i_height_log2                                           ,//the value is between 2 and 6
    input           [2 : 0]     i_ch_type                                               ,//Y_C 0; U_C 1; V_C 2;
    input           [4 : 0]     i_q_bits                                                ,
    input   signed  [27: 0]     i_err_scale                                             ,
    input   signed  [23: 0]     i_lambda                                                ,
    input   signed  [19: 0]     i_diff_scale                                            ,
    
    input           [31: 0]     i_rdoq_est_last         [0 :  1][0 :  5][0 : 11][0 : 1] ,//pending
    input           [31: 0]     i_rdoq_est_level        [0 : 23][0 :  1]                ,//pending
    input           [31: 0]     i_rdoq_est_run          [0 : 23][0 :  1]                ,//pending
    input           [9 : 0]     i_left_pos              [0 : 31]                        ,//the max value is 1023
    input           [9 : 0]     i_bottom_pos            [0 : 31]                        ,//the max value is 1023

//input data                        
    input                       i_valid                                                 ,
    input   signed  [23: 0]     i_level_double          [0 : 31]                        ,
    input   signed  [15: 0]     i_data                  [0 : 31]                        ,
                        
//output parameter                      
    output          [2 : 0]     o_width_log2                                            ,//the value is between 2 and 6
    output          [2 : 0]     o_height_log2                                           ,//the value is between 2 and 6
                        
//output data                       
    output                      o_valid                                                 ,
    output          [15 : 0]    o_level_opt             [0 : 31]                        ,
    output                      o_tmp_dst_coef_sign     [0 : 31]                        ,//the sign of tmp_dst_coef 1- 0+
    output  signed  [63 : 0]    o_d64_cost_last_zero    [0 : 31]                        ,
    output  signed  [63 : 0]    o_d64_cost_last_one     [0 : 31]                        , 
    output  signed  [63 : 0]    o_base_cost_buffer_tmp  [0 : 31]                        ,
    
    output  reg     signed  [63 : 0]    coded_cost_tem      [0 : 31]                        ,
    output  reg     signed  [23 : 0]    err_x_err           [0 :  1][0 : 31]              
    
//output reg     signed  [63 : 0]    dCurrCost           [0 :  1][0 : 31]                        

);

parameter delay_period                  =   3;

//local parameter definition
localparam  Y_C                         =   2'd0    ,
            U_C                         =   2'd1    ,
            V_C                         =   2'd2    ;
localparam  ERR_SCALE_PRECISION_BITS    =   20      ;
localparam  GET_IEP_RATE                =   32768   ;



//integer definition
integer i,j,k,l,m   ;
genvar  o,p,q,r     ;


//reg definition
reg     signed  [15 : 0]    i_data_d1           [0 : 31]                                ;
reg     signed  [23 : 0]    i_level_double_d1   [0 : 31]                                ;
reg     signed  [23 : 0]    i_level_double_d2   [0 : 31]                                ;
reg             [15 : 0]    temp_coef_abs_d1    [0 : 31]                                ;
reg             [15 : 0]    temp_coef_abs_d2    [0 : 31]                                ;
reg             [15 : 0]    temp_coef_abs_d3    [0 : 31]                                ;
reg                         temp_coef_sign_d1   [0 : 31]                                ;
reg                         temp_coef_sign_d2   [0 : 31]                                ;
reg                         temp_coef_sign_d3   [0 : 31]                                ;


reg             [9 : 0]     left_pos            [0 : 31]                                ;//the max value is 1023
reg             [9 : 0]     i_bottom_pos_d1     [0 : 31]                                ;//the max value is 1023
reg             [9 : 0]     left_pos_tem        [0 : 31]                                ;//shift operation after the calculation of scan position

reg             [31 : 0]    pre_level           [0 : 31]                                ;
reg             [15 : 0]    run                 [0 : 31]                                ;
reg             [15 : 0]    run_tem             [0 : 31]                                ;

reg     signed  [39 : 0]    uncoded_cost_tem    [0 : 31]                                ;
reg     signed  [39 : 0]    uncoded_cost_tem_d1 [0 : 31]                                ;
//reg     signed  [63 : 0]    coded_cost_tem      [0 : 31]                                ;
reg             [31 : 0]    level_opt           [0 : 31]                                ;
reg             [31 : 0]    level_opt_d1        [0 : 31]                                ;
//reg     signed  [63 : 0]    dCurrCost           [0 :  1][0 : 31]                        ;
reg     signed  [63 : 0]    dCurrCost_tem       [0 :  3][0 :  1][0 : 31]                ;
reg     signed  [31 : 0]    err1                [0 : 31]                                ;
reg     signed  [11 : 0]    err                 [0 :  1][0 : 31]                        ;
//reg     signed  [23 : 0]    err_x_err           [0 :  1][0 : 31]                        ;


reg             [6  : 0]    column_cnt                                                  ;
reg             [6  : 0]    column_cnt_d1                                               ;

reg                         i_valid_d           [0 :  delay_period - 1]                                ;
reg             [2  : 0]    i_width_log2_d      [0 :  delay_period - 1]                                ;
reg             [2  : 0]    i_height_log2_d     [0 :  delay_period - 1]                                ;
reg             [2  : 0]    i_ch_type_d         [0 :  delay_period - 1]                                ;
reg             [4  : 0]    i_q_bits_d          [0 :  delay_period - 1]                                ;
reg     signed  [27 : 0]    i_err_scale_d       [0 :  delay_period - 1]                                ;
reg     signed  [19 : 0]    i_diff_scale_d      [0 :  delay_period - 1]                                ;
reg     signed  [23 : 0]    i_lambda_d          [0 :  delay_period - 1]                                ;
reg             [31 : 0]    i_rdoq_est_last_d   [0 :  delay_period - 1][0 :  1][0 :  5][0 : 11][0 : 1] ;//pending
reg             [31 : 0]    i_rdoq_est_level_d  [0 :  delay_period - 1][0 : 23][0 :  1]                ;//pending
reg             [31 : 0]    i_rdoq_est_run_d    [0 :  delay_period - 1][0 : 23][0 :  1]                ;//pending



//wire definition   
wire            [15 : 0]    temp_coef_abs       [0 : 31]                                ;
wire            [4  : 0]    ctx_run             [0 : 31]                                ;
wire            [4  : 0]    ctx_level           [0 : 31]                                ;
wire    signed  [31 : 0]    i64Delta            [0 :  1][0 : 31]                        ;
wire            [9  : 0]    scan_pos            [0 : 31]                                ;//zigzag scan position of each row


wire    signed  [39 : 0]    uncoded_cost        [0 : 31]                                ;
wire    signed  [63 : 0]    coded_cost          [0 : 31]                                ;

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
                i_ch_type_d[i]          <=  0;
                i_q_bits_d[i]           <=  0;
                i_err_scale_d[i]        <=  0;
                i_diff_scale_d[i]       <=  0;
                i_lambda_d[i]           <=  0;
            end

            for(m = 0; m < delay_period; m = m + 1)begin
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
            i_valid_d[0]                <=      i_valid;
            i_width_log2_d[0]           <=      i_width_log2;
            i_height_log2_d[0]          <=      i_height_log2;
            i_ch_type_d[0]              <=      i_ch_type;
            i_q_bits_d[0]               <=      i_q_bits;
            i_err_scale_d[0]            <=      i_err_scale;
            i_diff_scale_d[0]           <=      i_diff_scale;
            i_lambda_d[0]               <=      i_lambda;

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

            for(i = 1; i < delay_period; i = i + 1)begin
                i_valid_d[i]            <=      i_valid_d[i-1];
            end
            for(i = 1; i < delay_period; i = i + 1)begin
                i_width_log2_d[i]       <=      i_width_log2_d[i-1];
                i_height_log2_d[i]      <=      i_height_log2_d[i-1];
                i_ch_type_d[i]          <=      i_ch_type_d[i-1];
                i_q_bits_d[i]           <=      i_q_bits_d[i-1];
                i_err_scale_d[i]        <=      i_err_scale_d[i-1];
                i_diff_scale_d[i]       <=      i_diff_scale_d[i-1];
                i_lambda_d[i]           <=      i_lambda_d[i-1];
            end
            
            for(m = 1; m < delay_period; m = m + 1)begin
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

//pipe 0
    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  temp_coef_abs[o]     =   i_data[o][15] ? (~i_data[o] + 1) : i_data[o];
        end
    endgenerate

    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  i64Delta[0][o]      =   i_level_double[o] - (temp_coef_abs[o] << i_q_bits);
            assign  i64Delta[1][o]      =   i_level_double[o] - ((temp_coef_abs[o] - 1) << i_q_bits);
        end
    endgenerate

//pipe 1

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
                temp_coef_sign_d1[i]    <=  i_data[i][15];
            end
        end
    end

    //calculate err
    generate
        for(o = 0; o < 32; o = o + 1)begin
            always@(posedge clk or negedge rst_n)begin
                if(!rst_n)begin
                    for(j = 0; j < 2; j = j + 1)begin
                        err[j][o]     <=      0;
                    end
                end
                else if(temp_coef_abs[o] == 0) begin 
                    for(j = 0; j < 2; j = j + 1)begin
                        err[j][o]     <=      0;
                    end
                end
                else if(temp_coef_abs[o] == 1) begin 
                    err[0][o]   <=  (i64Delta[0][o] * i_diff_scale) >>> ERR_SCALE_PRECISION_BITS;

                    err[1][o]   <=  0;
                end
                else begin
                    err[0][o]   <=  (i64Delta[0][o] * i_diff_scale) >>> ERR_SCALE_PRECISION_BITS;
                    err[1][o]   <=  (i64Delta[1][o] * i_diff_scale) >>> ERR_SCALE_PRECISION_BITS;
                end
            end
        end
    endgenerate



    //calculate err1
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                err1[i]     <=  0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                err1[i]     <=  (i_level_double[i] * i_diff_scale) >>> ERR_SCALE_PRECISION_BITS;
            end
        end
    end


//pipe 2 pre_level 需与 level_opt 同时算出

//delaay one cycle
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
    generate
        for(o = 1; o < 32; o = o + 1)begin
            assign  left_pos_tem[o - 1]    =    left_pos[o];
        end
        assign  left_pos_tem[31]     =  left_pos[31];
    endgenerate

    /*
        always@(*)begin
            for(i = 2; i < 32; i = i + 2)begin
                left_pos_tem[i - 1]     <=  left_pos[i];
            end
            
            for(i = 1 ; i < 3; i = i + 2)begin
                left_pos_tem[i - 1]     <=  left_pos[i];
            end
            for(i = 5 ; i < 7; i = i + 2)begin
                left_pos_tem[i - 1]     <=  left_pos[i];
            end
            for(i = 9 ; i < 15; i = i + 2)begin
                left_pos_tem[i - 1]     <=  left_pos[i];
            end            
            for(i = 17; i < 31; i = i + 2)begin
                left_pos_tem[i - 1]     <=  left_pos[i];
            end
            case(i_height_log2_d[0])
                3'd2    : begin    
                        for(i = 1 ; i < 4; i = i + 1)begin
                            left_pos_tem[i - 1]     <=  left_pos[i];
                        end
                        left_pos_tem[3 ]    <=  left_pos_tem[3 ];
                        for(i = 4 ; i < 32; i = i + 1)begin
                            left_pos_tem[i]         <=  0;
                        end
                    end
                3'd3    : begin
                        for(i = 1 ; i < 8; i = i + 1)begin
                            left_pos_tem[i - 1]     <=  left_pos[i];
                        end
                        left_pos_tem[7 ]    <=  left_pos_tem[7 ];
                        for(i = 8 ; i < 32; i = i + 1)begin
                            left_pos_tem[i]         <=  0;
                        end
                    end
                3'd4    : begin
                        for(i = 1 ; i < 16; i = i + 1)begin
                            left_pos_tem[i - 1]     <=  left_pos[i];
                        end
                        left_pos_tem[15]    <=  left_pos_tem[15];
                        for(i = 16 ; i < 32; i = i + 1)begin
                            left_pos_tem[i]         <=  0;
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
    */
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
                for(i = 0; i < 32; i = i + 1)begin
                    left_pos[i]     <=  i_left_pos[i];
                end
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
            for(i = 0; i < 32; i = i + 2)begin
                pre_level[i]    <=  i_data_d1[i]        ?   temp_coef_abs_d1[i] : 1;
            end

            for(i = 1; i < 3; i = i + 2)begin
                pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
            end
            for(i = 5; i < 7; i = i + 2)begin
                pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
            end
            for(i = 9; i < 15; i = i + 2)begin
                pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
            end            
            for(i = 17; i < 31; i = i + 2)begin
                pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
            end
            
            //determine the value of the last row 
            case(i_height_log2_d[0])
                3'd2    : begin    
                        pre_level[3]        <=  i_data_d1[3     ]   ?   temp_coef_abs_d1[3] : 1;
                        pre_level[7]        <=  0   ;//pending, not used
                        pre_level[15]       <=  0   ;//pending, not used
                        pre_level[31]       <=  0   ;//pending, not used
                    end
                3'd3    : begin
                        pre_level[3]        <=  level_opt[3  + 1]   ?   level_opt[3 + 1] : 1;
                        pre_level[7]        <=  i_data_d1[7     ]   ?   temp_coef_abs_d1[7] : 1;
                        pre_level[15]       <=  0   ;//pending, not used
                        pre_level[31]       <=  0   ;//pending, not used

                    end
                3'd4    : begin
                        pre_level[3]        <=  level_opt[3  + 1]   ?   level_opt[3 + 1] : 1;
                        pre_level[7]        <=  level_opt[7  + 1]   ?   level_opt[7 + 1] : 1;
                        pre_level[15]       <=  i_data_d1[15    ]   ?   temp_coef_abs_d1[15] : 1;
                        pre_level[31]       <=  0   ;//pending, not used

                    end
                3'd5    : begin
                        pre_level[3]        <=  level_opt[3  + 1]   ?   level_opt[3  + 1] : 1;
                        pre_level[7]        <=  level_opt[7  + 1]   ?   level_opt[7  + 1] : 1;
                        pre_level[15]       <=  level_opt[15 + 1]   ?   level_opt[15 + 1] : 1;
                        pre_level[31]       <=  i_data_d1[31    ]   ?   temp_coef_abs_d1[31] : 1;

                    end
                default : begin
                        pre_level[3]        <=  0 ;
                        pre_level[7]        <=  0 ;
                        pre_level[15]       <=  0 ;
                        pre_level[31]       <=  0 ;
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
    generate
        for(o = 1; o < 32; o = o + 1)begin
            assign  run_tem[o - 1]    =       run[o];
        end
        assign  run_tem[31]     =       run[31];
    endgenerate

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
            for(i = 1; i < 3; i = i + 2)begin
                run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
            end
            for(i = 5; i < 7; i = i + 2)begin
                run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
            end
            for(i = 9; i < 15; i = i + 2)begin
                run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
            end            
            for(i = 17; i < 31; i = i + 2)begin
                run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
            end
            //determine the value of the last row 
            case(i_height_log2_d[0])
                3'd2    : begin    
                        run[3]              <=  i_data_d1[3     ]   ?   0 : 1;
                        run[7]              <=  0   ;//pending, not used
                        run[15]             <=  0   ;//pending, not used
                        run[31]             <=  0   ;//pending, not used
                    end
                3'd3    : begin
                        run[3]              <=  level_opt[3  + 1]   ?   0 : run_tem[3] + 1;
                        run[7]              <=  i_data_d1[7     ]   ?   0 : 1;
                        run[15]             <=  0   ;//pending, not used
                        run[31]             <=  0   ;//pending, not used

                    end
                3'd4    : begin
                        run[3]              <=  level_opt[3  + 1]   ?   0 : run_tem[3] + 1;
                        run[7]              <=  level_opt[7  + 1]   ?   0 : run_tem[7] + 1;
                        run[15]             <=  i_data_d1[15    ]   ?   0 : 1;
                        run[31]             <=  0   ;//pending, not used

                    end
                3'd5    : begin
                        run[3]              <=  level_opt[3  + 1]   ?   0 : run_tem[3] + 1;
                        run[7]              <=  level_opt[7  + 1]   ?   0 : run_tem[7] + 1;
                        run[15]             <=  level_opt[15 + 1]   ?   0 : run_tem[15] + 1;
                        run[31]             <=  i_data_d1[31    ]   ?   0 : 1;

                    end
                default : begin
                        run[3]              <=  0 ;
                        run[7]              <=  0 ;
                        run[15]             <=  0 ;
                        run[31]             <=  0 ;
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
                for(i = 1; i < 3; i = i + 2)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                end
                for(i = 5; i < 7; i = i + 2)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                end
                for(i = 9; i < 15; i = i + 2)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                end            
                for(i = 17; i < 31; i = i + 2)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run_tem[i] + 1;
                end
                //determine the value of the last row 
                case(i_height_log2_d[0])
                    3'd2    : begin    
                            run[3]              <=  i_data_d1[3     ]   ?   0 : 1;
                            run[7]              <=  0   ;//pending, not used
                            run[15]             <=  0   ;//pending, not used
                            run[31]             <=  0   ;//pending, not used
                        end
                    3'd3    : begin
                            run[3]              <=  level_opt[3  + 1]   ?   0 : run_tem[3] + 1;
                            run[7]              <=  i_data_d1[7     ]   ?   0 : 1;
                            run[15]             <=  0   ;//pending, not used
                            run[31]             <=  0   ;//pending, not used

                        end
                    3'd4    : begin
                            run[3]              <=  level_opt[3  + 1]   ?   0 : run_tem[3] + 1;
                            run[7]              <=  level_opt[7  + 1]   ?   0 : run_tem[7] + 1;
                            run[15]             <=  i_data_d1[15    ]   ?   0 : 1;
                            run[31]             <=  0   ;//pending, not used

                        end
                    3'd5    : begin
                            run[3]              <=  level_opt[3  + 1]   ?   0 : run_tem[3] + 1;
                            run[7]              <=  level_opt[7  + 1]   ?   0 : run_tem[7] + 1;
                            run[15]             <=  level_opt[15 + 1]   ?   0 : run_tem[15] + 1;
                            run[31]             <=  i_data_d1[31    ]   ?   0 : 1;

                        end
                    default : begin
                            run[3]              <=  0 ;
                            run[7]              <=  0 ;
                            run[15]             <=  0 ;
                            run[31]             <=  0 ;
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
            assign  ctx_run[o]          =   ( ( (pre_level[o] - 1) > 5 ? 5 : (pre_level[o] - 1) ) << 1 ) + ( i_ch_type_d[1] == Y_C ? 0 : 12 );
            assign  ctx_level[o]        =   ( ( (pre_level[o] - 1) > 5 ? 5 : (pre_level[o] - 1) ) << 1 ) + ( i_ch_type_d[1] == Y_C ? 0 : 12 );
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
//err_x_err

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


    //new revise
    generate            
        for(o = 0; o < 32; o = o + 1)begin
            assign  coded_cost_tem[o]   =   ( run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][0] : i_rdoq_est_run_d[1][(ctx_run[o] + 1)][0] ) + uncoded_cost_tem[o];
        end
    endgenerate


    // //calculate dCurrCost[0]
    // generate            
    //     for(o = 0; o < 32; o = o + 1)begin
    //         assign  dCurrCost_tem[0][0][o]   =  64'h7FFFFFFFFFFFFFFF;
    //     end
    //     for(o = 0; o < 32; o = o + 1)begin
    //         assign  dCurrCost_tem[1][0][o]   =  err_x_err[0][o] +
    //                                             GET_IEP_RATE + 
    //                                             (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
    //                                             i_rdoq_est_level_d[1][ctx_level[o]][1];
    //     end    
    //     for(o = 0; o < 32; o = o + 1)begin
    //         assign  dCurrCost_tem[2][0][o]   =  err_x_err[0][o] +
    //                                             GET_IEP_RATE + 
    //                                             (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
    //                                             i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
    //                                             i_rdoq_est_level_d[1][ctx_level[o] + 1][0] << 3 - i_rdoq_est_level_d[1][ctx_level[o] + 1][0] +
    //                                             GET_IEP_RATE * (funclog2(temp_coef_abs_d2[o] - 7) < 12 ? funclog2(temp_coef_abs_d2[o] - 7) * 2 + 1 : 25);
    //     end    
    //     for(o = 0; o < 32; o = o + 1)begin
    //         assign  dCurrCost_tem[3][0][o]   =  err_x_err[0][o] +
    //                                             GET_IEP_RATE + 
    //                                             (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
    //                                             i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
    //                                             i_rdoq_est_level_d[1][ctx_level[o] + 1][0] * (temp_coef_abs_d2[o] - 2) + 
    //                                             i_rdoq_est_level_d[1][ctx_level[o] + 1][1];
    //     end
    // endgenerate


    
    // always@(*)begin
    //     for(i = 0; i < 32; i = i + 1) begin
    //         case(temp_coef_abs_d2[i])
    //             0 : begin
    //                 dCurrCost[0][i]     <=  dCurrCost_tem[0][0][i];
    //             end
    //             1 : begin
    //                 dCurrCost[0][i]     <=  dCurrCost_tem[1][0][i];
    //             end
    //             2,3,4,5,6,7,8 : begin
    //                 dCurrCost[0][i]     <=  dCurrCost_tem[3][0][i];
    //             end
    //             default: begin 
    //                 dCurrCost[0][i]     <=  dCurrCost_tem[2][0][i];
    //             end
    //         endcase 
    //     end
    // end

    // //calculate dCurrCost[1]
    // generate            
    //     for(o = 0; o < 32; o = o + 1)begin
    //         assign  dCurrCost_tem[0][1][o]   =  64'h7FFFFFFFFFFFFFFF;
    //     end
    //     for(o = 0; o < 32; o = o + 1)begin
    //         assign  dCurrCost_tem[1][1][o]   =  err_x_err[1][o] +
    //                                             GET_IEP_RATE + 
    //                                             (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
    //                                             i_rdoq_est_level_d[1][ctx_level[o]][1];
    //     end    
    //     for(o = 0; o < 32; o = o + 1)begin
    //         assign  dCurrCost_tem[2][1][o]   =  err_x_err[1][o] +
    //                                             GET_IEP_RATE + 
    //                                             (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
    //                                             i_rdoq_est_run_d[1][ctx_level[o]    ][0] + 
    //                                             i_rdoq_est_run_d[1][ctx_level[o] + 1][0] << 3 - i_rdoq_est_run_d[1][ctx_level[o] + 1][0] + 
    //                                             GET_IEP_RATE * (funclog2(temp_coef_abs_d2[o] - 1 - 7) < 12 ? funclog2(temp_coef_abs_d2[o] - 1 - 7) * 2 + 1 : 25);
    //     end    
    //     for(o = 0; o < 32; o = o + 1)begin
    //         assign  dCurrCost_tem[3][1][o]   =  err_x_err[1][o] +
    //                                             GET_IEP_RATE + 
    //                                             (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
    //                                             i_rdoq_est_run_d[1][ctx_level[o]    ][0] + 
    //                                             i_rdoq_est_run_d[1][ctx_level[o] + 1][0] * (temp_coef_abs_d2[o] - 1 - 2) + 
    //                                             i_rdoq_est_run_d[1][ctx_level[o] + 1][1];
    //     end
    // endgenerate

    // always@(*)begin
    //     for(i = 0; i < 32; i = i + 1) begin
    //         case(temp_coef_abs_d2[i])
    //             0,1: begin
    //                 dCurrCost[1][i]     <=  dCurrCost_tem[0][1][i];
    //             end
    //             2 : begin
    //                 dCurrCost[1][i]     <=  dCurrCost_tem[1][1][i];
    //             end
    //             3,4,5,6,7,8,9 : begin
    //                 dCurrCost[1][i]     <=  dCurrCost_tem[3][1][i];
    //             end
    //             default: begin 
    //                 dCurrCost[1][i]     <=  dCurrCost_tem[2][1][i];
    //             end
    //         endcase 
    //     end
    // end

























    function [3 : 0] funclog2;
        input [15 : 0]  value;
        begin
            if(value[15])
                funclog2    =   15;
            else if(value[14])
                funclog2    =   14;
            else if(value[13])
                funclog2    =   13;
            else if(value[12])
                funclog2    =   12;
            else if(value[11])
                funclog2    =   11;
            else if(value[10])
                funclog2    =   10;
            else if(value[9])
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


    endmodule