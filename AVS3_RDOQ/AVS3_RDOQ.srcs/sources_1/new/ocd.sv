module ocd(      
//system clk and rest       
    input                               clk                         ,
    input                               rst_n                       ,

//input parameter       
    input           [2 : 0]             i_width_log2                ,//the value is between 2 and 6
    input           [2 : 0]             i_height_log2               ,//the value is between 2 and 6
    input           [2 : 0]             i_ch_type                   ,//Y_C 0; U_C 1; V_C 2;
    input           [4 : 0]             i_q_bits                    ,
    input   signed  [29: 0]             i_err_scale                 ,
    input   signed  [63: 0]             i_lambda                    ,
    
    input           [31: 0]             i_rdoq_est_cbf    [0 :  2][0 :  1],//pending
    input           [31: 0]             i_rdoq_est_last   [0 :  1][0 :  5][0 : 11][0 : 1],//pending
    input           [31: 0]             i_rdoq_est_level  [0 : 23][0 :  1],//pending

//input data                
    input                               i_valid                     ,
    input   signed  [63 : 0]            i_level_double  [0 : 31]    ,
    input   signed  [15 : 0]            i_data          [0 : 31]    ,

//output parameter

//output data
    output                              o_valid                     ,
    output  signed  [15 : 0]            o_data          [0 : 31]    
);

//parameter definition
localparam  Y_C                         =   2'd0,
            U_C                         =   2'd1,
            V_C                         =   2'd2;
localparam  ERR_SCALE_PRECISION_BITS    =   20;


//integer definition
integer i,j;
genvar  l;


//reg definition
reg     signed  [15 : 0]    i_data_d1           [0 : 31]        ;
reg     signed  [63 : 0]    i_level_double_d1   [0 : 31]        ;
reg     signed  [63 : 0]    i_level_double_d2   [0 : 31]        ;

reg             [31 : 0]    pre_level           [0 : 31]        ;
reg             [15 : 0]    run                 [0 : 31]        ;
reg     signed  [63 : 0]    uncoded_cost        [0 : 31]        ;
reg     signed  [63 : 0]    coded_cost          [0 : 31]        ;
reg             [31 : 0]    level_opt           [0 : 31]        ;

reg             [6  : 0]    column_cnt                          ;

reg                         i_valid_d           [0 :  3]        ;
reg             [2  : 0]    i_width_log2_d      [0 :  3]        ;
reg             [2  : 0]    i_height_log2_d     [0 :  3]        ;
reg             [2  : 0]    i_ch_type_d         [0 :  3]        ;
reg             [4 : 0]     i_q_bits_d          [0 :  3]        ;
reg     signed  [29: 0]     i_err_scale_d       [0 :  3]        ;
reg     signed  [63: 0]     i_lambda_d          [0 :  3]        ;

//wire definition   
wire            [15 : 0]    i_data_d1_abs       [0 : 31]        ;
wire            [4  : 0]    ctx_run             [0 : 31]        ;
wire            [4  : 0]    ctx_level           [0 : 31]        ;


//assignment



//tem
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                level_opt[i]    <=  0;
            end
        end
    end

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
    end
    else begin
        i_valid_d[0]                <=      i_valid;
        i_width_log2_d[0]           <=      i_width_log2;
        i_height_log2_d[0]          <=      i_height_log2;
        i_ch_type_d[0]              <=      i_ch_type;
        i_q_bits_d[0]               <=      i_q_bits;
        i_err_scale_d[0]            <=      i_err_scale;
        i_lambda_d[0]               <=      i_lambda;
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
    end
end



//pipe 1

    generate
        for(l = 0; l < 32; l = l + 1)begin
            assign  i_data_d1_abs[l]    =   i_data_d1[l] > 0 ? i_data_d1[l] : (~i_data_d1[l] + 1) ;
        end
    endgenerate

    //delay one cycle
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



//pipe 2

    // always@(posedge clk or negedge rst_n)begin
    //    if(!rst_n) begin
    //         for(i = 0; i < 32; i = i + 1)begin
    //             i_level_double_d2[i]    <=  0;
    //         end
    //    end
    //    else begin
    //         for(i = 0; i < 32; i = i + 1)begin
    //             i_level_double_d2[i]    <=  i_level_double_d1[i];
    //         end
    //    end
    // end

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
                pre_level[i]    <=  i_data_d1[i]    ?   i_data_d1_abs[i] : 1;
                run[i]          <=  i_data_d1[i]    ?   0 : 1;
            end

            for(i = 1; i < 31; i = i + 2)begin
                pre_level[i]    <=  level_opt[i + 1]    ?   level_opt[i + 1] : 1;
                run[i]          <=  level_opt[i + 1]    ?   0 : 1;
            end
            
            pre_level[31]       <=  i_data_d1[31]   ?   i_data_d1_abs[31] : 1;
            run[31]             <=  i_data_d1[31]   ?   0 : 1;

        end
        else begin
            for(i = 1; i < 32; i = i + 2)begin
                pre_level[i]    <=  i_data_d1[i]    ?   i_data_d1_abs[i] : 1;
                run[i]          <=  i_data_d1[i]    ?   0 : 1;
            end

            if(column_cnt == 0)begin
                for(i = 0; i < 32; i = i + 2)begin
                    pre_level[i]    <=  i_data_d1[i]    ?   i_data_d1_abs[i] : 1;
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
                uncoded_cost[i]     <=      ((i_level_double_d1[i] * i_err_scale_d[0]) >> ERR_SCALE_PRECISION_BITS) * ((i_level_double_d1[i] * i_err_scale_d[0]) >> ERR_SCALE_PRECISION_BITS);
            end
        end
    end

    generate
        for(l = 0; l < 32; l = l + 1)begin
            assign  ctx_run[l]          =   (pre_level[l] - 1 > 5 ? 5 : pre_level[l] - 1) << 1 + i_ch_type_d[1] == Y_C ? 0 : 12 ;
            assign  ctx_level[l]        =   (pre_level[l] - 1 > 5 ? 5 : pre_level[l] - 1) << 1 + i_ch_type_d[1] == Y_C ? 0 : 12 ;
        end
    endgenerate

//pipe 3

    // always@(posedge clk or negedge rst_n)begin
    //     if(!rst_n)begin
    //         for(i = 0; i < 32; i = i + 1)begin
    //             coded_cost[i]     <=      0;
    //         end
    //     end
    //     else begin
    //         for(i = 0; i < 32; i = i + 1)begin
    //             coded_cost[i]     <=      uncoded_cost[i] + ;
    //         end
    //     end
    // end


































endmodule