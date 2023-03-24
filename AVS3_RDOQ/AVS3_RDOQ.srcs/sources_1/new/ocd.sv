module ocd(      
//system clk and rest       
    input                       clk                                                 ,
    input                       rst_n                                               ,

//input parameter                               
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

//input data                    
    input                       i_valid                                             ,
    input   signed  [63: 0]     i_level_double      [0 : 31]                        ,
    input   signed  [15: 0]     i_data              [0 : 31]                        ,
                        
//output parameter                      
                        
//output data                       
    output                      o_valid                                             ,
    output  signed  [15 : 0]    tmp_dst_coef        [0 : 31]                        ,
    output  signed  [63 : 0]    coded_cost          [0 : 31]                        ,
    output  signed  [63 : 0]    uncoded_cost        [0 : 31]                        
);

//parameter definition
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
reg                         temp_coef_sign_d3   [0 : 31]                                ;

reg             [31 : 0]    pre_level           [0 : 31]                                ;
reg             [15 : 0]    run                 [0 : 31]                                ;

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


//assignment



//tem



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

    always@(posedge clk or negedge rst_n)begin
       if(!rst_n) begin
            for(i = 0; i < 32; i = i + 1)begin
                i_data_d1[i]            <=  0;
                i_level_double_d1[i]    <=  0;
            end
       end
       else begin
            for(i = 0; i < 32; i = i + 1)begin
                i_data_d1[i]            <=  i_data[i];
                i_level_double_d1[i]    <=  i_level_double[i];
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

//pipe 2

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
                run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
            end

        //odd rows
            for(i = 1; i < 3; i = i + 2)begin
                run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
            end
            for(i = 5; i < 7; i = i + 2)begin
                run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
            end
            for(i = 9; i < 15; i = i + 2)begin
                run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
            end            
            for(i = 17; i < 31; i = i + 2)begin
                run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
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
                        run[3]              <=  level_opt[3  + 1]   ?   0 : run[i] + 1;
                        run[7]              <=  i_data_d1[7     ]   ?   0 : 1;
                        run[15]             <=  0   ;//pending, not used
                        run[31]             <=  0   ;//pending, not used

                    end
                3'd4    : begin
                        run[3]              <=  level_opt[3  + 1]   ?   0 : run[i] + 1;
                        run[7]              <=  level_opt[7  + 1]   ?   0 : run[i] + 1;
                        run[15]             <=  i_data_d1[15    ]   ?   0 : 1;
                        run[31]             <=  0   ;//pending, not used

                    end
                3'd5    : begin
                        run[3]              <=  level_opt[3  + 1]   ?   0 : run[i] + 1;
                        run[7]              <=  level_opt[7  + 1]   ?   0 : run[i] + 1;
                        run[15]             <=  level_opt[15 + 1]   ?   0 : run[i] + 1;
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
                    run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
                end
                for(i = 5; i < 7; i = i + 2)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
                end
                for(i = 9; i < 15; i = i + 2)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
                end            
                for(i = 17; i < 31; i = i + 2)begin
                    run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
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
                            run[3]              <=  level_opt[3  + 1]   ?   0 : run[i] + 1;
                            run[7]              <=  i_data_d1[7     ]   ?   0 : 1;
                            run[15]             <=  0   ;//pending, not used
                            run[31]             <=  0   ;//pending, not used

                        end
                    3'd4    : begin
                            run[3]              <=  level_opt[3  + 1]   ?   0 : run[i] + 1;
                            run[7]              <=  level_opt[7  + 1]   ?   0 : run[i] + 1;
                            run[15]             <=  i_data_d1[15    ]   ?   0 : 1;
                            run[31]             <=  0   ;//pending, not used

                        end
                    3'd5    : begin
                            run[3]              <=  level_opt[3  + 1]   ?   0 : run[i] + 1;
                            run[7]              <=  level_opt[7  + 1]   ?   0 : run[i] + 1;
                            run[15]             <=  level_opt[15 + 1]   ?   0 : run[i] + 1;
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
                    run[i]          <=  level_opt[i + 1]    ?   0 : run[i] + 1;
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




    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                level_opt[i]    <=  0;
            end
        end
    end


    generate 
        for(o = 0; o < 32; o = o + 1)begin
            assign      coded_cost[o]   =   coded_cost_tem[o] < (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o]) ? coded_cost_tem[o] : (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o]) ;
            assign      level_opt[o]    =   coded_cost_tem[o] < (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o]) ? 0 : (dCurrCost[0][o] < dCurrCost[1][o] ? temp_coef_abs_d2[o] : (temp_coef_abs_d2[o] - 1 ) ) ;
        end
    endgenerate



    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  tmp_dst_coef[o]     =   temp_coef_sign_d2[o] ? -level_opt[o] : level_opt[o];
            assign  uncoded_cost[o]     =   uncoded_cost_tem[o];
            assign  o_valid             =   i_valid_d[1]    ;
        end
    endgenerate



//function log2
    function integer funclog2;
    input integer value;
    begin
        value = value - 1;
        funclog2 = 0;
        if(value > 0)begin
            funclog2 = funclog2 + 1;
            value = value >> 1;
        end
    end
    endfunction


//test bench
integer fp_r, fp_w1, fp_w2, rd_i, rd_j, rd_k, rd_l, wr_i, wr_j, wr_k;
reg     signed  [63: 0]     wr_data [0 : 63]    ;

// initial begin 
//     #14;
//     fp_w2 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_16x16.txt", "w");
//     for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
//         for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
//             wr_data[wr_k] = level_opt[wr_k];
//         end
//         #2;
//         $fwrite(fp_w2, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
//             wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
//             wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
//     end
//     $fclose(fp_w2);
// end



// initial begin 
//     #16;
//     fp_w2 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_tem_16x16.txt", "w");
//     for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
//         for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
//             wr_data[wr_k] = coded_cost_tem[wr_k];
//         end
//         #2;
//         $fwrite(fp_w2, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n",  
//             wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
//             wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
//     end
//     $fclose(fp_w2);
// end

// initial begin 
//     #16;
//     fp_w2 = $fopen("../../../../../result/ocd/fpga_dst_coef/fpga_dst_coef_16x16.txt", "w");
//     for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
//         for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
//             wr_data[wr_k] = tmp_dst_coef[wr_k];
//         end
//         #2;
//         $fwrite(fp_w2, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
//             wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
//             wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
//     end
//     $fclose(fp_w2);
// end


// initial begin 
//     #14;
//     fp_w2 = $fopen("../../../../../result/ocd/fpga_coded_cost/fpga_coded_cost_16x16.txt", "w");
//     for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
//         for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
//             wr_data[wr_k] = coded_cost[wr_k];
//         end
//         #2;
//         $fwrite(fp_w2, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n", 
//             wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
//             wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
//     end
//     $fclose(fp_w2);
// end


// initial begin 
//     #14;
//     fp_w2 = $fopen("../../../../../result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_16x16.txt", "w");
//     for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
//         for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
//             wr_data[wr_k] = uncoded_cost[wr_k];
//         end
//         #2;
//         $fwrite(fp_w2, "%16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d %16d \n", 
//             wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
//             wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
//     end
//     $fclose(fp_w2);
// end


// initial begin 
//     #14;
//     //16x16
//     fp_w1 = $fopen("../../../../../result/ocd/fpga_prevel/fpga_prevel_16x16.txt", "w");
//     for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
//         for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
//             wr_data[wr_k] = pre_level[wr_k];
//         end
//         #2;
//         $fwrite(fp_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
//             wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
//             wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
//     end
//     $fclose(fp_w1);
// end

initial begin 
    #14;
    fp_w2 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_16x16.txt", "w");
    for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
        for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
            wr_data[wr_k] = run[wr_k];
        end
        #2;
        $fwrite(fp_w2, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w2);
end









endmodule


