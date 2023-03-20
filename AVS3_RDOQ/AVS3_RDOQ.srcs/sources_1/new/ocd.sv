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
    output  signed  [15 : 0]    o_data              [0 : 31]                        
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
reg     signed  [15 : 0]     i_data_d1           [0 : 31]                                ;
reg     signed  [63 : 0]     i_level_double_d1   [0 : 31]                                ;
reg     signed  [63 : 0]     i_level_double_d2   [0 : 31]                                ;
reg             [15 : 0]     temp_coef_abs_d2    [0 : 31]                                ;
reg             [15 : 0]     temp_coef_abs_d3    [0 : 31]                                ;

reg             [31 : 0]     pre_level           [0 : 31]                                ;
reg             [15 : 0]     run                 [0 : 31]                                ;
reg     signed  [63 : 0]     uncoded_cost        [0 : 31]                                ;
reg     signed  [63 : 0]     coded_cost_tem      [0 : 31]                                ;
reg     signed  [63 : 0]     coded_cost          [0 : 31]                                ;
reg             [31 : 0]     level_opt           [0 : 31]                                ;
reg     signed  [63 : 0]     dCurrCost           [0 :  1][0 : 31]                        ;
reg     signed  [63 : 0]     err                 [0 :  1][0 : 31]                        ;

reg             [6  : 0]     column_cnt                                                  ;
reg             [6  : 0]     column_cnt_d1                                               ;

reg                          i_valid_d           [0 :  3]                                ;
reg             [2  : 0]     i_width_log2_d      [0 :  3]                                ;
reg             [2  : 0]     i_height_log2_d     [0 :  3]                                ;
reg             [2  : 0]     i_ch_type_d         [0 :  3]                                ;
reg             [4  : 0]     i_q_bits_d          [0 :  3]                                ;
reg     signed  [29 : 0]     i_err_scale_d       [0 :  3]                                ;
reg     signed  [63 : 0]     i_lambda_d          [0 :  3]                                ;

reg             [31 : 0]     i_rdoq_est_cbf_d    [0 :  3][0 :  2][0 :  1]                ;//pending
reg             [31 : 0]     i_rdoq_est_last_d   [0 :  3][0 :  1][0 :  5][0 : 11][0 : 1] ;//pending
reg             [31 : 0]     i_rdoq_est_level_d  [0 :  3][0 : 23][0 :  1]                ;//pending
reg             [31 : 0]     i_rdoq_est_run_d    [0 :  3][0 : 23][0 :  1]                ;//pending



//wire definition   
wire            [15 : 0]    temp_coef_abs_d1    [0 : 31]                                ;
wire            [4  : 0]    ctx_run             [0 : 31]                                ;
wire            [4  : 0]    ctx_level           [0 : 31]                                ;
wire    signed  [63 : 0]    i64Delta            [0 :  1][0 : 31]                        ;


//assignment



//tem
    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign o_data[o]   =  pre_level[o];
        end
    endgenerate


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
            assign  i64Delta[0][o]      =   ( i_level_double_d1[o] - (  temp_coef_abs_d1[o]         << i_q_bits_d[0])       );
            assign  i64Delta[1][o]      =   ( i_level_double_d1[o] - (  (temp_coef_abs_d1[o] - 1)   << i_q_bits_d[0])       );
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


    //calculate pre_level and run
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                pre_level[i]    <=  0;
                run[i]          <=  0;
            end
        end
        else if(column_cnt[0])begin
            for(i = 0; i < 32; i = i + 2)begin
                pre_level[i]    <=  i_data_d1[i]    ?   temp_coef_abs_d1[i] : 1;
                run[i]          <=  i_data_d1[i]    ?   0 : 1;
            end

            for(i = 1; i < 31; i = i + 2)begin
                pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
                run[i]          <=  level_opt[i + 1]    ?   0 : 1;
            end
            
            pre_level[31]       <=  i_data_d1[31]   ?   temp_coef_abs_d1[31] : 1;
            run[31]             <=  i_data_d1[31]   ?   0 : 1;

        end
        else begin
            for(i = 1; i < 32; i = i + 2)begin
                pre_level[i]    <=  i_data_d1[i]    ?   temp_coef_abs_d1[i] : 1;
                run[i]          <=  i_data_d1[i]    ?   0 : 1;
            end

            if(column_cnt == 0)begin
                for(i = 0; i < 32; i = i + 2)begin
                    pre_level[i]    <=  i_data_d1[i]    ?   temp_coef_abs_d1[i] : 1;
                    run[i]          <=  i_data_d1[i]    ?   0 : 1;
                end
            end
            else begin
                for(i = 0; i < 32; i = i + 2)begin
                    pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
                    run[i]          <=  level_opt[i + 1]    ?   0 : 1;
                end
            end

        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                uncoded_cost[i]     <=      0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                uncoded_cost[i]     <=      ((i_level_double_d1[i] * i_err_scale_d[0]) >>> ERR_SCALE_PRECISION_BITS) * ((i_level_double_d1[i] * i_err_scale_d[0]) >>> ERR_SCALE_PRECISION_BITS);
            end
        end
    end

    generate
        for(o = 0; o < 32; o = o + 1)begin
            assign  ctx_run[o]          =   ( (pre_level[o] - 1 > 5 ? 5 : pre_level[o] - 1) << 1 ) + ( i_ch_type_d[1] == Y_C ? 0 : 12 );
            assign  ctx_level[o]        =   ( (pre_level[o] - 1 > 5 ? 5 : pre_level[o] - 1) << 1 ) + ( i_ch_type_d[1] == Y_C ? 0 : 12 );
        end
    endgenerate
   
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
                    err[0][o]   <=  ( i_level_double_d1[o] - (1 << i_q_bits_d[0]) ) * i_err_scale_d[0] >>> ERR_SCALE_PRECISION_BITS;

                    err[1][o]   <=  0;
                end
                else begin
                    err[0][o]   <=  (i64Delta[0][o] * i_err_scale_d[0]) >>> ERR_SCALE_PRECISION_BITS;
                    err[1][o]   <=  (i64Delta[1][o] * i_err_scale_d[0]) >>> ERR_SCALE_PRECISION_BITS;
                end
            end
        end
    endgenerate

//pipe 3

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            column_cnt_d1   <=  0;
            for(i = 0; i < 32; i = i + 1)begin
                temp_coef_abs_d3[i]     <=  0;
            end
        end
        else begin
            column_cnt_d1   <=  column_cnt;
            for(i = 0; i < 32; i = i + 1)begin
                temp_coef_abs_d3[i]     <=  temp_coef_abs_d2[i];
            end
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                coded_cost_tem[i]   =   0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                coded_cost_tem[i]   =   ( run[i] == 0 ? i_rdoq_est_run_d[1][ctx_run[i]][0] : i_rdoq_est_run_d[1][(ctx_run[i] + 1)][0] ) * i_lambda_d[1] +  uncoded_cost[i];
            end
        end
    end

    //dCurrCost[0]
    generate
        for(o = 0; o < 32; o = o + 1)begin
            always@(posedge clk or negedge rst_n)begin
                if(!rst_n)begin
                    dCurrCost[0][o]     <=      64'h7FFFFFFFFFFFFFFF;
                end
                else if(temp_coef_abs_d2[o] == 0) begin 
                    dCurrCost[0][o]     <=      64'h7FFFFFFFFFFFFFFF;
                end
                else if(temp_coef_abs_d2[o] == 1) begin 
                    dCurrCost[0][o]     <=      err[0][o] * err[0][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_level_d[1][ctx_level[o]][1] 
                                                ) * i_lambda_d[1];
                    
                end
                else if(temp_coef_abs_d2[o] >= 9)begin
                    dCurrCost[0][o]     <=      err[0][o] * err[0][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
                                                i_rdoq_est_level_d[1][ctx_level[o] + 1][0] * 7 + 
                                                GET_IEP_RATE * (funclog2(temp_coef_abs_d2[o] - 7) < 12 ? funclog2(temp_coef_abs_d2[o] - 7) * 2 + 1 : 25)
                                                ) * i_lambda_d[1];
                end
                else begin
                    dCurrCost[0][o]     <=      err[0][o] * err[0][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_level_d[1][ctx_level[o]    ][0] + 
                                                i_rdoq_est_level_d[1][ctx_level[o] + 1][0] * (temp_coef_abs_d2[o] - 2) + 
                                                i_rdoq_est_level_d[1][ctx_level[o] + 1][1]
                                                ) * i_lambda_d[1];
                end
            end
        end
    endgenerate

    //dCurrCost[1]
    generate
        for(o = 0; o < 32; o = o + 1)begin
            always@(posedge clk or negedge rst_n)begin
                if(!rst_n)begin
                    dCurrCost[1][o]     <=      64'h7FFFFFFFFFFFFFFF;
                end
                else if(temp_coef_abs_d2[o] == 0) begin 
                    dCurrCost[1][o]     <=      64'h7FFFFFFFFFFFFFFF;
                end
                else if(temp_coef_abs_d2[o] == 1) begin                     
                    dCurrCost[1][o]     <=      64'h7FFFFFFFFFFFFFFF;
                end
                else if(temp_coef_abs_d2[o] == 2) begin       
                    dCurrCost[1][o]     <=      err[1][o] * err[1][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_level_d[1][ctx_level[o]][1] 
                                                ) * i_lambda_d[1];
                end
                else if(temp_coef_abs_d2[o] >= 10)begin
                    dCurrCost[1][o]     <=      err[1][o] * err[1][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_run_d[1][ctx_level[o]    ][0] + 
                                                i_rdoq_est_run_d[1][ctx_level[o] + 1][0] * 7 + 
                                                GET_IEP_RATE * (funclog2(temp_coef_abs_d2[o] - 1 - 7) < 12 ? funclog2(temp_coef_abs_d2[o] - 1 - 7) * 2 + 1 : 25)
                                                ) * i_lambda_d[1];
                end
                else begin
                    dCurrCost[1][o]     <=      err[1][o] * err[1][o] + 
                                                (GET_IEP_RATE + 
                                                (run[o] == 0 ? i_rdoq_est_run_d[1][ctx_run[o]][1] : i_rdoq_est_run_d[1][ctx_run[o] + 1][1]) + 
                                                i_rdoq_est_run_d[1][ctx_level[o]    ][0] + 
                                                i_rdoq_est_run_d[1][ctx_level[o] + 1][0] * (temp_coef_abs_d2[o] - 1 - 2) + 
                                                i_rdoq_est_run_d[1][ctx_level[o] + 1][1]
                                                ) * i_lambda_d[1];
                end
            end
        end
    endgenerate

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
            assign      level_opt[o]    =   coded_cost_tem[o] < (dCurrCost[0][o] < dCurrCost[1][o] ? dCurrCost[0][o] : dCurrCost[1][o]) ? 0 : (dCurrCost[0][o] < dCurrCost[1][o] ? temp_coef_abs_d3[o] : (temp_coef_abs_d3[o] - 1 ) ) ;
        end
    endgenerate













//function log2
    function integer funclog2;
    input integer value;
    begin
        value = value - 1;
        for (funclog2 = 0; value > 0; funclog2 = funclog2 + 1)begin
        value = value >> 1;
        end
    end
    endfunction


//test bench
integer fp_r, fp_w1, fp_w2, rd_i, rd_j, rd_k, rd_l, wr_i, wr_j, wr_k;
reg     signed  [63: 0]     wr_data [0 : 63]    ;

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

// initial begin 
//     #14;
//     fp_w2 = $fopen("../../../../../result/ocd/fpga_run/fpga_run_16x16.txt", "w");
//     for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
//         for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
//             wr_data[wr_k] = run[wr_k];
//         end
//         #2;
//         $fwrite(fp_w2, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
//             wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
//             wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
//     end
//     $fclose(fp_w2);
// end

initial begin 
    #16;
    fp_w2 = $fopen("../../../../../result/ocd/fpga_level_opt/fpga_level_opt_16x16.txt", "w");
    for (wr_j = 0; wr_j < 16; wr_j = wr_j + 1) begin
        for (wr_k = 0; wr_k < 16; wr_k = wr_k + 1) begin
            wr_data[wr_k] = level_opt[wr_k];
        end
        #2;
        $fwrite(fp_w2, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            wr_data[0 ], wr_data[1 ], wr_data[2 ], wr_data[3 ], wr_data[4 ], wr_data[5 ], wr_data[6 ], wr_data[7 ], 
            wr_data[8 ], wr_data[9 ], wr_data[10], wr_data[11], wr_data[12], wr_data[13], wr_data[14], wr_data[15]);
    end
    $fclose(fp_w2);
end
























endmodule


