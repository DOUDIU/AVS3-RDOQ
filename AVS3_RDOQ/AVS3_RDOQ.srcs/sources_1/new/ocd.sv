module ocd(      
//system clk and rest       
    input                       clk                                                     ,
    input                       rst_n                                                   ,

//input parameter                                   
    input           [2 : 0]     i_width_log2                                            ,//the value is between 2 and 6
    input           [2 : 0]     i_height_log2                                           ,//the value is between 2 and 6
    input           [2 : 0]     i_ch_type                                               ,//Y_C 0; U_C 1; V_C 2;
    input           [4 : 0]     i_q_bits                                                ,
    input   signed  [29: 0]     i_err_scale                                             ,
    input   signed  [63: 0]     i_lambda                                                ,
    
    input           [31: 0]     i_rdoq_est_cbf          [0 :  2][0 :  1]                ,//pending
    input           [31: 0]     i_rdoq_est_last         [0 :  1][0 :  5][0 : 11][0 : 1] ,//pending
    input           [31: 0]     i_rdoq_est_level        [0 : 23][0 :  1]                ,//pending
    input           [31: 0]     i_rdoq_est_run          [0 : 23][0 :  1]                ,//pending
    input           [9 : 0]     i_left_pos              [0 : 31]                        ,//the max value is 1023
    input           [9 : 0]     i_bottom_pos            [0 : 31]                        ,//the max value is 1023

//input data                        
    input                       i_valid                                                 ,
    input   signed  [63: 0]     i_level_double          [0 : 31]                        ,
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
    output  signed  [63 : 0]    o_base_cost_buffer_tmp  [0 : 31]                        
);

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
reg     signed  [63 : 0]    i_level_double_d1   [0 : 31]                                ;
reg     signed  [63 : 0]    i_level_double_d2   [0 : 31]                                ;
reg             [15 : 0]    temp_coef_abs_d2    [0 : 31]                                ;
reg             [15 : 0]    temp_coef_abs_d3    [0 : 31]                                ;
reg                         temp_coef_sign_d2   [0 : 31]                                ;


reg             [9 : 0]     left_pos            [0 : 31]                                ;//the max value is 1023
reg             [9 : 0]     i_bottom_pos_d1     [0 : 31]                                ;//the max value is 1023
reg             [9 : 0]     left_pos_tem        [0 : 31]                                ;//shift operation after the calculation of scan position

reg             [31 : 0]    pre_level           [0 : 31]                                ;
reg             [15 : 0]    run                 [0 : 31]                                ;
reg             [15 : 0]    run_tem             [0 : 31]                                ;

reg     signed  [63 : 0]    uncoded_cost_tem    [0 : 31]                                ;
reg     signed  [63 : 0]    uncoded_cost_tem_d1 [0 : 31]                                ;
reg     signed  [63 : 0]    coded_cost_tem      [0 : 31]                                ;
reg             [31 : 0]    level_opt           [0 : 31]                                ;
reg     signed  [63 : 0]    dCurrCost           [0 :  1][0 : 31]                        ;
reg     signed  [63 : 0]    dCurrCost_tem       [0 :  3][0 :  1][0 : 31]                ;
reg     signed  [63 : 0]    err                 [0 :  1][0 : 31]                        ;


reg             [6  : 0]    column_cnt                                                  ;
reg             [6  : 0]    column_cnt_d1                                               ;

reg                         i_valid_d           [0 :  3]                                ;
reg             [2  : 0]    i_width_log2_d      [0 :  3]                                ;
reg             [2  : 0]    i_height_log2_d     [0 :  3]                                ;
reg             [2  : 0]    i_ch_type_d         [0 :  3]                                ;
reg             [4  : 0]    i_q_bits_d          [0 :  3]                                ;
reg     signed  [29 : 0]    i_err_scale_d       [0 :  3]                                ;
reg     signed  [63 : 0]    i_lambda_d          [0 :  3]                                ;

reg             [31 : 0]    i_rdoq_est_cbf_d    [0 :  3][0 :  2][0 :  1]                ;//pending
reg             [31 : 0]    i_rdoq_est_last_d   [0 :  3][0 :  1][0 :  5][0 : 11][0 : 1] ;//pending
reg             [31 : 0]    i_rdoq_est_level_d  [0 :  3][0 : 23][0 :  1]                ;//pending
reg             [31 : 0]    i_rdoq_est_run_d    [0 :  3][0 : 23][0 :  1]                ;//pending



//wire definition   
wire            [15 : 0]    temp_coef_abs_d1    [0 : 31]                                ;
wire                        temp_coef_sign_d1   [0 : 31]                                ;
wire            [4  : 0]    ctx_run             [0 : 31]                                ;
wire            [4  : 0]    ctx_level           [0 : 31]                                ;
wire    signed  [63 : 0]    i64Delta            [0 :  1][0 : 31]                        ;
wire            [9 : 0]     scan_pos            [0 : 31]                                ;//zigzag scan position of each row


wire    signed  [63 : 0]    uncoded_cost        [0 : 31]                                ;
wire    signed  [63 : 0]    coded_cost          [0 : 31]                                ;

//assignment





//delay operation
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 4; i = i + 1)begin
                i_valid_d[i]            <=  0;
            end

            for(i = 0; i < 4; i = i + 1)begin
                i_width_log2_d[i]       <=  0;
                i_height_log2_d[i]      <=  0;
                i_ch_type_d[i]          <=  0;
                i_q_bits_d[i]           <=  0;
                i_err_scale_d[i]        <=  0;
                i_lambda_d[i]           <=  0;
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
            i_valid_d[0]                <=      i_valid;
            i_width_log2_d[0]           <=      i_width_log2;
            i_height_log2_d[0]          <=      i_height_log2;
            i_ch_type_d[0]              <=      i_ch_type;
            i_q_bits_d[0]               <=      i_q_bits;
            i_err_scale_d[0]            <=      i_err_scale;
            i_lambda_d[0]               <=      i_lambda;

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
                i_valid_d[i]            <=      i_valid_d[i-1];
            end
            for(i = 1; i < 4; i = i + 1)begin
                i_width_log2_d[i]       <=      i_width_log2_d[i-1];
                i_height_log2_d[i]      <=      i_height_log2_d[i-1];
                i_ch_type_d[i]          <=      i_ch_type_d[i-1];
                i_q_bits_d[i]           <=      i_q_bits_d[i-1];
                i_err_scale_d[i]        <=      i_err_scale_d[i-1];
                i_lambda_d[i]           <=      i_lambda_d[i-1];
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
            end
       end
       else begin
            for(i = 0; i < 32; i = i + 1)begin
                i_data_d1[i]            <=      i_data[i]           ;
                i_level_double_d1[i]    <=      i_level_double[i]   ;
                i_bottom_pos_d1[i]      <=      i_bottom_pos[i]     ;
            end
       end
    end

    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  temp_coef_abs_d1[o]     =   i_data_d1[o] > 0 ? i_data_d1[o] : (~i_data_d1[o] + 1) ;
        end
    endgenerate

    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  temp_coef_sign_d1[o]    =   i_data_d1[o][15];
        end
    endgenerate

    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  i64Delta[0][o]      =   ( i_level_double_d1[o] - ( temp_coef_abs_d1[o] << i_q_bits_d[0] ) );
            assign  i64Delta[1][o]      =   temp_coef_abs_d1[o] > 0 ? ( i_level_double_d1[o] - ( (temp_coef_abs_d1[o] - 1)   << i_q_bits_d[0] ) ) : 0 ;
        end
    endgenerate



//pipe 2 pre_level 需与 level_opt 同时算出

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

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            for(i = 0; i < 32; i = i + 1)begin
                left_pos[i]        <=      0;
            end
        end
        if(column_cnt[0]) begin
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

//run_tem shift
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



//calculate ctx_run and ctx_level
    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  ctx_run[o]          =   ( ( (pre_level[o] - 1) > 5 ? 5 : (pre_level[o] - 1) ) << 1 ) + ( i_ch_type_d[1] == Y_C ? 0 : 12 );
            assign  ctx_level[o]        =   ( ( (pre_level[o] - 1) > 5 ? 5 : (pre_level[o] - 1) ) << 1 ) + ( i_ch_type_d[1] == Y_C ? 0 : 12 );
        end
    endgenerate

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                uncoded_cost_tem[i]     <=      0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                uncoded_cost_tem[i]     <=      ((i_level_double_d1[i] * i_err_scale_d[0]) >>> ERR_SCALE_PRECISION_BITS) * ((i_level_double_d1[i] * i_err_scale_d[0]) >>> ERR_SCALE_PRECISION_BITS);
            end
        end
    end

    generate
        for(o = 0; o < 32; o = o + 1)begin
            always@(posedge clk or negedge rst_n)begin
                if(!rst_n)begin
                    for(j = 0; j < 2; j = j + 1)begin
                        err[j][o]     <=      0;
                    end
                end
                else if(temp_coef_abs_d1[o] == 0) begin 
                    for(j = 0; j < 2; j = j + 1)begin
                        err[j][o]     <=      0;
                    end
                end
                else if(temp_coef_abs_d1[o] == 1) begin 
                    err[0][o]   <=  (i64Delta[0][o] * i_err_scale_d[0]) >>> ERR_SCALE_PRECISION_BITS;

                    err[1][o]   <=  0;
                end
                else begin
                    err[0][o]   <=  (i64Delta[0][o] * i_err_scale_d[0]) >>> ERR_SCALE_PRECISION_BITS;
                    err[1][o]   <=  (i64Delta[1][o] * i_err_scale_d[0]) >>> ERR_SCALE_PRECISION_BITS;
                end
            end
        end
    endgenerate


//new revise
    generate            
        for(o = 0; o < 32; o = o + 1)begin
            assign  coded_cost_tem[o]   =   ( run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][0] : i_rdoq_est_run_d[1][(ctx_run[o] + 1)][0] ) * i_lambda_d[1]  +  uncoded_cost_tem[o];
        end
    endgenerate

//dCurrCost[0]
    generate            
        for(o = 0; o < 32; o = o + 1)begin
            assign  dCurrCost_tem[0][0][o]   =  64'h7FFFFFFFFFFFFFFF;
        end
        for(o = 0; o < 32; o = o + 1)begin
            assign  dCurrCost_tem[1][0][o]   =  err[0][o] * err[0][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_level_d[1][ctx_level[o]][1] 
                                                ) * i_lambda_d[1];;
        end    
        for(o = 0; o < 32; o = o + 1)begin
            assign  dCurrCost_tem[2][0][o]   =  err[0][o] * err[0][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
                                                i_rdoq_est_level_d[1][ctx_level[o] + 1][0] * 7 + 
                                                GET_IEP_RATE * (funclog2(temp_coef_abs_d2[o] - 7) < 12 ? funclog2(temp_coef_abs_d2[o] - 7) * 2 + 1 : 25)
                                                ) * i_lambda_d[1];
        end    
        for(o = 0; o < 32; o = o + 1)begin
            assign  dCurrCost_tem[3][0][o]   =   err[0][o] * err[0][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
                                                i_rdoq_est_level_d[1][ctx_level[o] + 1][0] * (temp_coef_abs_d2[o] - 2) + 
                                                i_rdoq_est_level_d[1][ctx_level[o] + 1][1]
                                                ) * i_lambda_d[1];;
        end
    endgenerate

    always@(*)begin
        for(i = 0; i < 32; i = i + 1) begin
            case(temp_coef_abs_d2[i])
                0 : begin
                    dCurrCost[0][i]     <=  dCurrCost_tem[0][0][i];
                end
                1 : begin
                    dCurrCost[0][i]     <=  dCurrCost_tem[1][0][i];
                end
                2,3,4,5,6,7,8 : begin
                    dCurrCost[0][i]     <=  dCurrCost_tem[3][0][i];
                end
                default: begin 
                    dCurrCost[0][i]     <=  dCurrCost_tem[2][0][i];
                end
            endcase 
        end
    end

//dCurrCost[1]
    generate            
        for(o = 0; o < 32; o = o + 1)begin
            assign  dCurrCost_tem[0][1][o]   =  64'h7FFFFFFFFFFFFFFF;
        end
        for(o = 0; o < 32; o = o + 1)begin
            assign  dCurrCost_tem[1][1][o]   =  err[1][o] * err[1][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_level_d[1][ctx_level[o]][1] 
                                                ) * i_lambda_d[1];
        end    
        for(o = 0; o < 32; o = o + 1)begin
            assign  dCurrCost_tem[2][1][o]   =  err[1][o] * err[1][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_run_d[1][ctx_level[o]    ][0] + 
                                                i_rdoq_est_run_d[1][ctx_level[o] + 1][0] * 7 + 
                                                GET_IEP_RATE * (funclog2(temp_coef_abs_d2[o] - 1 - 7) < 12 ? funclog2(temp_coef_abs_d2[o] - 1 - 7) * 2 + 1 : 25)
                                                ) * i_lambda_d[1];
        end    
        for(o = 0; o < 32; o = o + 1)begin
            assign  dCurrCost_tem[3][1][o]   =  err[1][o] * err[1][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_run_d[1][ctx_level[o]    ][0] + 
                                                i_rdoq_est_run_d[1][ctx_level[o] + 1][0] * (temp_coef_abs_d2[o] - 1 - 2) + 
                                                i_rdoq_est_run_d[1][ctx_level[o] + 1][1]
                                                ) * i_lambda_d[1];
        end
    endgenerate

    always@(*)begin
        for(i = 0; i < 32; i = i + 1) begin
            case(temp_coef_abs_d2[i])
                0,1: begin
                    dCurrCost[1][i]     <=  dCurrCost_tem[0][1][i];
                end
                2 : begin
                    dCurrCost[1][i]     <=  dCurrCost_tem[1][1][i];
                end
                3,4,5,6,7,8,9 : begin
                    dCurrCost[1][i]     <=  dCurrCost_tem[3][1][i];
                end
                default: begin 
                    dCurrCost[1][i]     <=  dCurrCost_tem[2][1][i];
                end
            endcase 
        end
    end

    generate 
        for(o = 0; o < 32; o = o + 1)begin
            assign      uncoded_cost[o]     =   uncoded_cost_tem[o] ;
            assign      coded_cost[o]       =   coded_cost_tem[o] < (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o]) ? coded_cost_tem[o] : (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o]) ;
            assign      level_opt[o]        =   coded_cost_tem[o] < (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o]) ? 0 : (dCurrCost[0][o] < dCurrCost[1][o] ? temp_coef_abs_d2[o] : (temp_coef_abs_d2[o] - 1 ) ) ;
        end
    endgenerate

//output assignment
    generate 
        for(o = 0; o < 32; o = o + 1)begin
            assign      o_d64_cost_last_zero[o]     =   i_lambda_d[1] * i_rdoq_est_last_d[1] [i_ch_type_d[1] != Y_C] [((pre_level[o] - 1) > 5 ? 5 : (pre_level[o] - 1))] [funclog2(scan_pos[o] + 1)] [0];
            assign      o_d64_cost_last_one[o]      =   i_lambda_d[1] * i_rdoq_est_last_d[1] [i_ch_type_d[1] != Y_C] [((pre_level[o] - 1) > 5 ? 5 : (pre_level[o] - 1))] [funclog2(scan_pos[o] + 1)] [1];

            assign      o_base_cost_buffer_tmp[o]   =   level_opt[o] ? (coded_cost[o] - uncoded_cost[o] + o_d64_cost_last_zero[o]) : (coded_cost[o] - uncoded_cost[o]);
            assign      o_tmp_dst_coef_sign[o]      =   temp_coef_sign_d2[o];
            assign      o_level_opt[o]              =   level_opt[o];
        end
            assign      o_valid                     =   i_valid_d[1];
            assign      o_width_log2                =   i_width_log2_d[1];
            assign      o_height_log2               =   i_height_log2_d[1];
    endgenerate












//function log2
function integer funclog2; 
    input integer value; 
    begin 
    for(funclog2 = 0; value > 1; funclog2 = funclog2 + 1) 
        value = value >> 1; 
    end 
endfunction 

//test bench

integer fp_base_cost_buffer_w1;
integer wr_base_cost_buffer_j,wr_base_cost_buffer_k;
reg     signed  [63: 0]     base_cost_buffer_data        [0 : 63]    ;
initial begin 
    #14;
    fp_base_cost_buffer_w1 = $fopen("../../../../../result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_16x16.txt", "w");
    for (wr_base_cost_buffer_j = 0; wr_base_cost_buffer_j < 16; wr_base_cost_buffer_j = wr_base_cost_buffer_j + 1) begin
        for (wr_base_cost_buffer_k = 0; wr_base_cost_buffer_k < 16; wr_base_cost_buffer_k = wr_base_cost_buffer_k + 1) begin
            base_cost_buffer_data[wr_base_cost_buffer_k] = o_base_cost_buffer_tmp[wr_base_cost_buffer_k];
        end
        #2;
        $fwrite(fp_base_cost_buffer_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            base_cost_buffer_data[0 ], base_cost_buffer_data[1 ], base_cost_buffer_data[2 ], base_cost_buffer_data[3 ], base_cost_buffer_data[4 ], base_cost_buffer_data[5 ], base_cost_buffer_data[6 ], base_cost_buffer_data[7 ], 
            base_cost_buffer_data[8 ], base_cost_buffer_data[9 ], base_cost_buffer_data[10], base_cost_buffer_data[11], base_cost_buffer_data[12], base_cost_buffer_data[13], base_cost_buffer_data[14], base_cost_buffer_data[15]);
    end
    $fclose(fp_base_cost_buffer_w1);
end


integer fp_pre_level_w1;
integer wr_pre_level_j,wr_pre_level_k;
reg     signed  [63: 0]     pre_level_data        [0 : 63]    ;
initial begin 
    #14;
    fp_pre_level_w1 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_16x16.txt", "w");
    for (wr_pre_level_j = 0; wr_pre_level_j < 16; wr_pre_level_j = wr_pre_level_j + 1) begin
        for (wr_pre_level_k = 0; wr_pre_level_k < 16; wr_pre_level_k = wr_pre_level_k + 1) begin
            pre_level_data[wr_pre_level_k] = pre_level[wr_pre_level_k];
        end
        #2;
        $fwrite(fp_pre_level_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            pre_level_data[0 ], pre_level_data[1 ], pre_level_data[2 ], pre_level_data[3 ], pre_level_data[4 ], pre_level_data[5 ], pre_level_data[6 ], pre_level_data[7 ], 
            pre_level_data[8 ], pre_level_data[9 ], pre_level_data[10], pre_level_data[11], pre_level_data[12], pre_level_data[13], pre_level_data[14], pre_level_data[15]);
    end
    $fclose(fp_pre_level_w1);
end

integer fp_run_w1;
integer wr_run_j,wr_run_k;
reg     signed  [63: 0]     run_data        [0 : 63]    ;
initial begin 
    #14;
    fp_run_w1 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_16x16.txt", "w");
    for (wr_run_j = 0; wr_run_j < 16; wr_run_j = wr_run_j + 1) begin
        for (wr_run_k = 0; wr_run_k < 16; wr_run_k = wr_run_k + 1) begin
            run_data[wr_run_k] = run[wr_run_k];
        end
        #2;
        $fwrite(fp_run_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            run_data[0 ], run_data[1 ], run_data[2 ], run_data[3 ], run_data[4 ], run_data[5 ], run_data[6 ], run_data[7 ], 
            run_data[8 ], run_data[9 ], run_data[10], run_data[11], run_data[12], run_data[13], run_data[14], run_data[15]);
    end
    $fclose(fp_run_w1);
end

integer fp_opt_w2;
integer wr_opt_j,wr_opt_k;
reg     signed  [63: 0]     level_opt_data  [0 : 63]    ;
initial begin 
    #14;
    fp_opt_w2 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_16x16.txt", "w");
    for (wr_opt_j = 0; wr_opt_j < 16; wr_opt_j = wr_opt_j + 1) begin
        for (wr_opt_k = 0; wr_opt_k < 16; wr_opt_k = wr_opt_k + 1) begin
            level_opt_data[wr_opt_k] = level_opt[wr_opt_k];
        end
        #2;
        $fwrite(fp_opt_w2, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            level_opt_data[0 ], level_opt_data[1 ], level_opt_data[2 ], level_opt_data[3 ], level_opt_data[4 ], level_opt_data[5 ], level_opt_data[6 ], level_opt_data[7 ], 
            level_opt_data[8 ], level_opt_data[9 ], level_opt_data[10], level_opt_data[11], level_opt_data[12], level_opt_data[13], level_opt_data[14], level_opt_data[15]);
    end
    $fclose(fp_opt_w2);
end


integer fp_coded_cost_w;
integer wr_coded_cost_j,wr_coded_cost_k;
reg     signed  [63: 0]     coded_cost_data  [0 : 63]    ;
initial begin 
    #14;
    fp_coded_cost_w = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_16x16.txt", "w");
    for (wr_coded_cost_j = 0; wr_coded_cost_j < 16; wr_coded_cost_j = wr_coded_cost_j + 1) begin
        for (wr_coded_cost_k = 0; wr_coded_cost_k < 16; wr_coded_cost_k = wr_coded_cost_k + 1) begin
            coded_cost_data[wr_coded_cost_k] = coded_cost[wr_coded_cost_k];
        end
        #2;
        $fwrite(fp_coded_cost_w, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n",  
            coded_cost_data[0 ], coded_cost_data[1 ], coded_cost_data[2 ], coded_cost_data[3 ], coded_cost_data[4 ], coded_cost_data[5 ], coded_cost_data[6 ], coded_cost_data[7 ], 
            coded_cost_data[8 ], coded_cost_data[9 ], coded_cost_data[10], coded_cost_data[11], coded_cost_data[12], coded_cost_data[13], coded_cost_data[14], coded_cost_data[15]);
    end
    $fclose(fp_coded_cost_w);
end



integer fp_uncoded_cost_w;
integer wr_uncoded_cost_j,wr_uncoded_cost_k;
reg     signed  [63: 0]     uncoded_cost_data  [0 : 63]    ;
initial begin 
    #14;
    fp_uncoded_cost_w = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_16x16.txt", "w");
    for (wr_uncoded_cost_j = 0; wr_uncoded_cost_j < 16; wr_uncoded_cost_j = wr_uncoded_cost_j + 1) begin
        for (wr_uncoded_cost_k = 0; wr_uncoded_cost_k < 16; wr_uncoded_cost_k = wr_uncoded_cost_k + 1) begin
            uncoded_cost_data[wr_uncoded_cost_k] = uncoded_cost[wr_uncoded_cost_k];
        end
        #2;
        $fwrite(fp_uncoded_cost_w, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n",  
            uncoded_cost_data[0 ], uncoded_cost_data[1 ], uncoded_cost_data[2 ], uncoded_cost_data[3 ], uncoded_cost_data[4 ], uncoded_cost_data[5 ], uncoded_cost_data[6 ], uncoded_cost_data[7 ], 
            uncoded_cost_data[8 ], uncoded_cost_data[9 ], uncoded_cost_data[10], uncoded_cost_data[11], uncoded_cost_data[12], uncoded_cost_data[13], uncoded_cost_data[14], uncoded_cost_data[15]);
    end
    $fclose(fp_uncoded_cost_w);
end

// integer fp_dst_coef_w1;
// integer wr_dst_coef_j,wr_dst_coef_k;
// reg     signed  [63: 0]     dst_coef_data        [0 : 63]    ;
// initial begin 
//     #14;
//     fp_dst_coef_w1 = $fopen("../../../../../result/ocd/fpga_dst_coef/fpga_dst_coef_16x16.txt", "w");
//     for (wr_dst_coef_j = 0; wr_dst_coef_j < 16; wr_dst_coef_j = wr_dst_coef_j + 1) begin
//         for (wr_dst_coef_k = 0; wr_dst_coef_k < 16; wr_dst_coef_k = wr_dst_coef_k + 1) begin
//             dst_coef_data[wr_dst_coef_k] = o_tmp_dst_coef[wr_dst_coef_k];
//         end
//         #2;
//         $fwrite(fp_dst_coef_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
//             dst_coef_data[0 ], dst_coef_data[1 ], dst_coef_data[2 ], dst_coef_data[3 ], dst_coef_data[4 ], dst_coef_data[5 ], dst_coef_data[6 ], dst_coef_data[7 ], 
//             dst_coef_data[8 ], dst_coef_data[9 ], dst_coef_data[10], dst_coef_data[11], dst_coef_data[12], dst_coef_data[13], dst_coef_data[14], dst_coef_data[15]);
//     end
//     $fclose(fp_dst_coef_w1);
// end











endmodule


