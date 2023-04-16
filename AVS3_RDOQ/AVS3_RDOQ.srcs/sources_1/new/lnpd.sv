`include "rdoq_header.vh"

module lnpd(      
//system clk and rest       
    input                                           clk                                 ,
    input                                           rst_n                               ,

//input parameter           
    input           [`w_size            - 1 : 0]    i_width_log2                        ,//the value is between 2 and 6
    input           [`w_size            - 1 : 0]    i_height_log2                       ,//the value is between 2 and 6            

//input data 
    input                                           i_valid                             ,
    input           [15 : 0]                        i_level_opt             [0 : 31]    ,
    input                                           i_tmp_dst_coef_sign     [0 : 31]    ,//the sign of tmp_dst_coef 1- 0+
    input   signed  [`w_rdoq_est_last   - 1 : 0]    i_d64_cost_last_zero    [0 : 31]    ,
    input   signed  [`w_rdoq_est_last   - 1 : 0]    i_d64_cost_last_one     [0 : 31]    , 
    input   signed  [33                     : 0]    i_base_cost_buffer_tmp  [0 : 31]    ,

//output parameter                      

//output data                 

    output  signed  [15                     : 0]    o_tmp_dst_coef          [0 : 31]    ,
    output                                          o_valid                             ,
    output  signed  [6                      : 0]    o_rdoq_last_x                       ,
    output  signed  [6                      : 0]    o_rdoq_last_y                       ,
    output  signed  [63                     : 0]    o_final_rdoq_cost                   ,
    output  signed  [63                     : 0]    o_d64_best_cost_tmp                 
);


//local parameter definition

//integer definition
integer i,j,k,l,m   ;
genvar  o,p,q,r     ;

//reg definition
reg                                     i_valid_d1                              ;
reg                                     i_valid_d2                              ;
reg             [`w_size - 1 : 0]       i_width_log2_d1                         ;
reg             [`w_size - 1 : 0]       i_height_log2_d1                        ;
reg             [`w_size - 1 : 0]       i_width_log2_d2                         ;
reg             [`w_size - 1 : 0]       i_height_log2_d2                        ;
reg             [`w_size - 1 : 0]       i_width_log2_d3                         ;
reg             [`w_size - 1 : 0]       i_height_log2_d3                        ;
reg             [15 : 0]    i_level_opt_d1              [0 : 31]                ;
reg     signed  [63 : 0]    i_d64_cost_last_zero_d1     [0 : 31]                ;
reg     signed  [63 : 0]    i_d64_cost_last_one_d1      [0 : 31]                ; 
reg     signed  [63 : 0]    i_base_cost_buffer_tmp_d1   [0 : 31]                ;

reg     signed  [63 : 0]    tempCost                    [0 : 31]                ;
reg     signed  [63 : 0]    endPosCost                  [0 : 31]                ;

reg     signed  [63 : 0]    rdoqD64LastZero             [0 : 31]                ;
reg     signed  [63 : 0]    rdoqD64LastOne              [0 : 31]                ;

reg             [6  : 0]    column_cnt                                          ;
reg             [6  : 0]    column_cnt_d1                                       ;
reg             [6  : 0]    column_cnt_d2                                       ;

reg     signed  [6  : 0]    rdoq_last_x                 [0 : 31]                ;
reg     signed  [6  : 0]    rdoq_last_y                 [0 : 31]                ;

reg     signed  [63 : 0]    d64_best_cost_tmp_top                               ;
reg     signed  [63 : 0]    final_rdoq_cost_top                                 ;
reg     signed  [63 : 0]    temp_RdoqCost_top                                   ;
reg     signed  [6  : 0]    final_rdoq_last_x_top                               ;
reg     signed  [6  : 0]    final_rdoq_last_y_top                               ;

reg     signed  [63 : 0]    d64_best_cost_tmp_left                              ;
reg     signed  [63 : 0]    final_rdoq_cost_left                                ;
reg     signed  [6  : 0]    final_rdoq_last_x_left                              ;
reg     signed  [6  : 0]    final_rdoq_last_y_left                              ;

reg     signed  [63 : 0]    tempCost_left               [0 : 31]                ;
reg     signed  [63 : 0]    endPosCost_left             [0 : 31]                ;
reg     signed  [63 : 0]    rdoqD64LastZero_left        [0 : 31]                ;
reg     signed  [63 : 0]    rdoqD64LastOne_left         [0 : 31]                ;
reg     signed  [6  : 0]    rdoq_last_x_left            [0 : 31]                ;
reg     signed  [6  : 0]    rdoq_last_y_left            [0 : 31]                ;

reg     signed  [63 : 0]    tempCost_tem                [0 : 31]                ;
reg     signed  [63 : 0]    rdoqD64LastZero_tem         [0 : 31]                ;
reg     signed  [63 : 0]    rdoqD64LastOne_tem          [0 : 31]                ;
reg     signed  [6  : 0]    rdoq_last_x_tem             [0 : 31]                ;
reg     signed  [6  : 0]    rdoq_last_y_tem             [0 : 31]                ;
reg     signed  [63 : 0]    endPosCost_tem              [0 : 31]                ;



reg     signed  [63 : 0]    temp_RdoqCost_except_final_cost_left_d      [0 : 31][0 : 31]    ;
reg     signed  [6  : 0]    rdoq_last_x_left_d                          [0 : 31][0 : 31]    ;
reg     signed  [6  : 0]    rdoq_last_y_left_d                          [0 : 31][0 : 31]    ;
reg     signed  [63 : 0]    rdoqD64LastOne_left_d                       [0 : 31][0 : 31]    ;
reg     signed  [63 : 0]    tempCost_left_d                             [0 : 31][0 : 31]    ;



//wire definition   
wire    signed  [63 : 0]    temp_RdoqCost_except_final_cost_left    [0 : 31]    ;
wire    signed  [63 : 0]    d64_best_cost_tmp_left_d                [0 : 31]    ;
wire    signed  [63 : 0]    final_rdoq_cost_left_d                  [0 : 31]    ;
wire    signed  [6  : 0]    final_rdoq_last_x_left_d                [0 : 31]    ;
wire    signed  [6  : 0]    final_rdoq_last_y_left_d                [0 : 31]    ;

//assignment
assign  o_valid     =   i_valid_d2;
generate 
    for(o = 0; o < 32; o = o + 1)begin
        assign  o_tmp_dst_coef[o]   =   i_tmp_dst_coef_sign[o] ? -i_level_opt[o] : i_level_opt[o];
    end
endgenerate
assign  o_rdoq_last_x           =       final_rdoq_last_x_left_d[31];
assign  o_rdoq_last_y           =       final_rdoq_last_y_left_d[31];
assign  o_final_rdoq_cost       =       final_rdoq_cost_left_d[31];
assign  o_d64_best_cost_tmp     =       d64_best_cost_tmp_left_d[31];

//pipe 1

    //counter of the input data(as same sa column)
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

    //delay one cycle to the input data
    always@(posedge clk or negedge rst_n)begin
       if(!rst_n) begin
                i_valid_d1                      <=      0;
                i_valid_d2                      <=      0;
                i_width_log2_d1                 <=      0;
                i_height_log2_d1                <=      0;
            for(i = 0; i < 32; i = i + 1)begin
                i_level_opt_d1[i]               <=      0;
                i_d64_cost_last_zero_d1[i]      <=      0;
                i_d64_cost_last_one_d1[i]       <=      0;
                i_base_cost_buffer_tmp_d1[i]    <=      0;
            end
       end
       else begin
                i_valid_d1                      <=      i_valid;
                i_valid_d2                      <=      i_valid_d1;
                i_width_log2_d1                 <=      i_width_log2    ;
                i_height_log2_d1                <=      i_height_log2   ;
            for(i = 0; i < 32; i = i + 1)begin
                i_level_opt_d1[i]               <=      i_level_opt[i]              ;
                i_d64_cost_last_zero_d1[i]      <=      i_d64_cost_last_zero[i]     ;
                i_d64_cost_last_one_d1[i]       <=      i_d64_cost_last_one[i]      ;
                i_base_cost_buffer_tmp_d1[i]    <=      i_base_cost_buffer_tmp[i]   ;
            end
       end
    end


//pipe 2

    //delay one cycle
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            column_cnt_d1       <=      0;
            i_width_log2_d2     <=      0;
            i_height_log2_d2    <=      0;
        end
        else begin
            column_cnt_d1       <=      column_cnt          ;
            i_width_log2_d2     <=      i_width_log2_d1     ;
            i_height_log2_d2    <=      i_height_log2_d1    ;
        end
    end

    //do shift operation to the former temCost  
    always@(*)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                tempCost_tem[i]     <=   0;   
            end
        end
        else begin
            for(i = 0 ; i < 3 ; i = i + 1)begin
                tempCost_tem[i]     <=   tempCost[i + 1];   
            end
            for(i = 4 ; i < 7 ; i = i + 1)begin
                tempCost_tem[i]     <=   tempCost[i + 1];   
            end
            for(i = 8 ; i < 11; i = i + 1)begin
                tempCost_tem[i]     <=   tempCost[i + 1];   
            end
            for(i = 12 ; i < 15 ; i = i + 1)begin
                tempCost_tem[i]     <=   tempCost[i + 1];   
            end
            for(i = 16; i < 19; i = i + 1)begin
                tempCost_tem[i]     <=   tempCost[i + 1];   
            end
            for(i = 20; i < 23; i = i + 1)begin
                tempCost_tem[i]     <=   tempCost[i + 1];   
            end
            for(i = 24; i < 27; i = i + 1)begin
                tempCost_tem[i]     <=   tempCost[i + 1];   
            end
            for(i = 28; i < 31; i = i + 1)begin
                tempCost_tem[i]     <=   tempCost[i + 1];   
            end

            case(i_height_log2_d2)
                3'd2    : begin    
                        tempCost_tem[3 ]    <=  tempCost[3 ];
                        tempCost_tem[7 ]    <=  tempCost[7 ];
                        tempCost_tem[11]    <=  tempCost[11];
                        tempCost_tem[15]    <=  tempCost[15];
                        tempCost_tem[19]    <=  tempCost[19];
                        tempCost_tem[23]    <=  tempCost[23];
                        tempCost_tem[27]    <=  tempCost[27];
                        tempCost_tem[31]    <=  tempCost[31];
                    end
                3'd3    : begin
                        tempCost_tem[3 ]    <=  tempCost[4 ];
                        tempCost_tem[7 ]    <=  tempCost[7 ];

                        tempCost_tem[11]    <=  tempCost[12];
                        tempCost_tem[15]    <=  tempCost[15];

                        tempCost_tem[19]    <=  tempCost[20];
                        tempCost_tem[23]    <=  tempCost[23];

                        tempCost_tem[27]    <=  tempCost[28];
                        tempCost_tem[31]    <=  tempCost[31];
                    end
                3'd4    : begin
                        tempCost_tem[3 ]    <=  tempCost[4 ];
                        tempCost_tem[7 ]    <=  tempCost[8 ];
                        tempCost_tem[11]    <=  tempCost[12];
                        tempCost_tem[15]    <=  tempCost[15];
                        
                        tempCost_tem[19]    <=  tempCost[20];
                        tempCost_tem[23]    <=  tempCost[24];
                        tempCost_tem[27]    <=  tempCost[28];
                        tempCost_tem[31]    <=  tempCost[31];
                    end
                3'd5    : begin
                        tempCost_tem[3 ]    <=  tempCost[4 ];
                        tempCost_tem[7 ]    <=  tempCost[8 ];
                        tempCost_tem[11]    <=  tempCost[12];
                        tempCost_tem[15]    <=  tempCost[16];
                        tempCost_tem[19]    <=  tempCost[20];
                        tempCost_tem[23]    <=  tempCost[24];
                        tempCost_tem[27]    <=  tempCost[28];
                        tempCost_tem[31]    <=  tempCost[31];
                    end
                default : begin
                        tempCost_tem[3 ]    <=  0;
                        tempCost_tem[7 ]    <=  0;
                        tempCost_tem[11]    <=  0;
                        tempCost_tem[15]    <=  0;
                        tempCost_tem[19]    <=  0;
                        tempCost_tem[23]    <=  0;
                        tempCost_tem[27]    <=  0;
                        tempCost_tem[31]    <=  0;
                    end
            endcase
        end
    end
   
    //calculate tempCost
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                tempCost[i]     <=  0;
            end
        end
        else if(column_cnt == 0)begin
            for(i = 0 ; i < 32; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i];
            end
        end
        else begin
            for(i = 0 ; i < 3 ; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end
            for(i = 4 ; i < 7 ; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end
            for(i = 8 ; i < 11; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end         
            for(i = 12; i < 15; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end        
            for(i = 16; i < 19; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end
            for(i = 20; i < 23; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end
            for(i = 24; i < 27; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end
            for(i = 28; i < 31; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end
            //determine the value of the last row 
            case(i_height_log2_d1)
                3'd2: begin    
                        tempCost[3 ]    <=  i_base_cost_buffer_tmp_d1[3 ];
                        tempCost[7 ]    <=  i_base_cost_buffer_tmp_d1[7 ];
                        tempCost[11]    <=  i_base_cost_buffer_tmp_d1[11];
                        tempCost[15]    <=  i_base_cost_buffer_tmp_d1[15];
                        tempCost[19]    <=  i_base_cost_buffer_tmp_d1[19];
                        tempCost[23]    <=  i_base_cost_buffer_tmp_d1[23];
                        tempCost[27]    <=  i_base_cost_buffer_tmp_d1[27];
                        tempCost[31]    <=  i_base_cost_buffer_tmp_d1[31];
                    end
                3'd3: begin
                        tempCost[3 ]    <=  i_base_cost_buffer_tmp_d1[3 ] + tempCost_tem[3 ];
                        tempCost[7 ]    <=  i_base_cost_buffer_tmp_d1[7 ];

                        tempCost[11]    <=  i_base_cost_buffer_tmp_d1[11] + tempCost_tem[11];
                        tempCost[15]    <=  i_base_cost_buffer_tmp_d1[15];

                        tempCost[19]    <=  i_base_cost_buffer_tmp_d1[19] + tempCost_tem[19];
                        tempCost[23]    <=  i_base_cost_buffer_tmp_d1[23];

                        tempCost[27]    <=  i_base_cost_buffer_tmp_d1[27] + tempCost_tem[27];
                        tempCost[31]    <=  i_base_cost_buffer_tmp_d1[31];
                    end
                3'd4: begin
                        tempCost[3 ]    <=  i_base_cost_buffer_tmp_d1[3 ] + tempCost_tem[3 ];
                        tempCost[7 ]    <=  i_base_cost_buffer_tmp_d1[7 ] + tempCost_tem[7 ];
                        tempCost[11]    <=  i_base_cost_buffer_tmp_d1[11] + tempCost_tem[11];
                        tempCost[15]    <=  i_base_cost_buffer_tmp_d1[15];

                        tempCost[19]    <=  i_base_cost_buffer_tmp_d1[19] + tempCost_tem[19];
                        tempCost[23]    <=  i_base_cost_buffer_tmp_d1[23] + tempCost_tem[23];
                        tempCost[27]    <=  i_base_cost_buffer_tmp_d1[27] + tempCost_tem[27];
                        tempCost[31]    <=  i_base_cost_buffer_tmp_d1[31];
                    end
                3'd5: begin
                        tempCost[3 ]    <=  i_base_cost_buffer_tmp_d1[3 ] + tempCost_tem[3 ];
                        tempCost[7 ]    <=  i_base_cost_buffer_tmp_d1[7 ] + tempCost_tem[7 ];
                        tempCost[11]    <=  i_base_cost_buffer_tmp_d1[11] + tempCost_tem[11];
                        tempCost[15]    <=  i_base_cost_buffer_tmp_d1[15] + tempCost_tem[15];
                        tempCost[19]    <=  i_base_cost_buffer_tmp_d1[19] + tempCost_tem[19];
                        tempCost[23]    <=  i_base_cost_buffer_tmp_d1[23] + tempCost_tem[23];
                        tempCost[27]    <=  i_base_cost_buffer_tmp_d1[27] + tempCost_tem[27];
                        tempCost[31]    <=  i_base_cost_buffer_tmp_d1[31];
                    end
                default : begin
                        tempCost[3 ]    <=  0;
                        tempCost[7 ]    <=  0;
                        tempCost[11]    <=  0;
                        tempCost[15]    <=  0;
                        tempCost[19]    <=  0;
                        tempCost[23]    <=  0;
                        tempCost[27]    <=  0;
                        tempCost[31]    <=  0;
                    end
            endcase
        end
    end


    //do shift operation to the former rdoqD64LastOne and rdoqD64LastZero
    always@(*)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                rdoqD64LastOne_tem[i]     <=   0;   
            end
        end
        else begin
            for(i = 0 ; i < 3 ; i = i + 1)begin
                rdoqD64LastOne_tem[i]     <=   rdoqD64LastOne[i + 1];   
            end
            for(i = 4 ; i < 7 ; i = i + 1)begin
                rdoqD64LastOne_tem[i]     <=   rdoqD64LastOne[i + 1];   
            end
            for(i = 8 ; i < 11 ; i = i + 1)begin
                rdoqD64LastOne_tem[i]     <=   rdoqD64LastOne[i + 1];   
            end
            for(i = 12; i < 15 ; i = i + 1)begin
                rdoqD64LastOne_tem[i]     <=   rdoqD64LastOne[i + 1];   
            end
            for(i = 16; i < 19; i = i + 1)begin
                rdoqD64LastOne_tem[i]     <=   rdoqD64LastOne[i + 1];   
            end
            for(i = 20; i < 23; i = i + 1)begin
                rdoqD64LastOne_tem[i]     <=   rdoqD64LastOne[i + 1];   
            end
            for(i = 24; i < 27; i = i + 1)begin
                rdoqD64LastOne_tem[i]     <=   rdoqD64LastOne[i + 1];   
            end
            for(i = 28; i < 31; i = i + 1)begin
                rdoqD64LastOne_tem[i]     <=   rdoqD64LastOne[i + 1];   
            end

            case(i_height_log2_d2)
                3'd2    : begin    
                        rdoqD64LastOne_tem[3 ]    <=  rdoqD64LastOne[3 ];
                        rdoqD64LastOne_tem[7 ]    <=  rdoqD64LastOne[7 ];
                        rdoqD64LastOne_tem[11]    <=  rdoqD64LastOne[11];
                        rdoqD64LastOne_tem[15]    <=  rdoqD64LastOne[15];
                        rdoqD64LastOne_tem[19]    <=  rdoqD64LastOne[19];
                        rdoqD64LastOne_tem[23]    <=  rdoqD64LastOne[23];
                        rdoqD64LastOne_tem[27]    <=  rdoqD64LastOne[27];
                        rdoqD64LastOne_tem[31]    <=  rdoqD64LastOne[31];
                    end
                3'd3    : begin
                        rdoqD64LastOne_tem[3 ]    <=  rdoqD64LastOne[4 ];
                        rdoqD64LastOne_tem[7 ]    <=  rdoqD64LastOne[7 ];

                        rdoqD64LastOne_tem[11]    <=  rdoqD64LastOne[12];
                        rdoqD64LastOne_tem[15]    <=  rdoqD64LastOne[15];

                        rdoqD64LastOne_tem[19]    <=  rdoqD64LastOne[20];
                        rdoqD64LastOne_tem[23]    <=  rdoqD64LastOne[23];

                        rdoqD64LastOne_tem[27]    <=  rdoqD64LastOne[28];
                        rdoqD64LastOne_tem[31]    <=  rdoqD64LastOne[31];
                    end
                3'd4    : begin
                        rdoqD64LastOne_tem[3 ]    <=  rdoqD64LastOne[4 ];
                        rdoqD64LastOne_tem[7 ]    <=  rdoqD64LastOne[8 ];
                        rdoqD64LastOne_tem[11]    <=  rdoqD64LastOne[12];
                        rdoqD64LastOne_tem[15]    <=  rdoqD64LastOne[15];

                        rdoqD64LastOne_tem[19]    <=  rdoqD64LastOne[20];
                        rdoqD64LastOne_tem[23]    <=  rdoqD64LastOne[24];
                        rdoqD64LastOne_tem[27]    <=  rdoqD64LastOne[28];
                        rdoqD64LastOne_tem[31]    <=  rdoqD64LastOne[31];
                    end
                3'd5    : begin
                        rdoqD64LastOne_tem[3 ]    <=  rdoqD64LastOne[4 ];
                        rdoqD64LastOne_tem[7 ]    <=  rdoqD64LastOne[8 ];
                        rdoqD64LastOne_tem[11]    <=  rdoqD64LastOne[12];
                        rdoqD64LastOne_tem[15]    <=  rdoqD64LastOne[16];
                        rdoqD64LastOne_tem[19]    <=  rdoqD64LastOne[20];
                        rdoqD64LastOne_tem[23]    <=  rdoqD64LastOne[24];
                        rdoqD64LastOne_tem[27]    <=  rdoqD64LastOne[28];
                        rdoqD64LastOne_tem[31]    <=  rdoqD64LastOne[31];
                    end
                default : begin
                        rdoqD64LastOne_tem[3 ]    <=  0;
                        rdoqD64LastOne_tem[7 ]    <=  0;
                        rdoqD64LastOne_tem[11]    <=  0;
                        rdoqD64LastOne_tem[15]    <=  0;
                        rdoqD64LastOne_tem[19]    <=  0;
                        rdoqD64LastOne_tem[23]    <=  0;
                        rdoqD64LastOne_tem[27]    <=  0;
                        rdoqD64LastOne_tem[31]    <=  0;
                    end
            endcase
        end
    end

    always@(*)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                rdoqD64LastZero_tem[i]     <=   0;   
            end
        end
        else begin
            for(i = 0 ; i < 3 ; i = i + 1)begin
                rdoqD64LastZero_tem[i]     <=   rdoqD64LastZero[i + 1];   
            end
            for(i = 4 ; i < 7 ; i = i + 1)begin
                rdoqD64LastZero_tem[i]     <=   rdoqD64LastZero[i + 1];   
            end
            for(i = 8 ; i < 11 ; i = i + 1)begin
                rdoqD64LastZero_tem[i]     <=   rdoqD64LastZero[i + 1];   
            end
            for(i = 12; i < 15 ; i = i + 1)begin
                rdoqD64LastZero_tem[i]     <=   rdoqD64LastZero[i + 1];   
            end
            for(i = 16; i < 19; i = i + 1)begin
                rdoqD64LastZero_tem[i]     <=   rdoqD64LastZero[i + 1];   
            end
            for(i = 20; i < 23; i = i + 1)begin
                rdoqD64LastZero_tem[i]     <=   rdoqD64LastZero[i + 1];   
            end
            for(i = 24; i < 27; i = i + 1)begin
                rdoqD64LastZero_tem[i]     <=   rdoqD64LastZero[i + 1];   
            end
            for(i = 28; i < 31; i = i + 1)begin
                rdoqD64LastZero_tem[i]     <=   rdoqD64LastZero[i + 1];   
            end

            case(i_height_log2_d2)
                3'd2    : begin    
                        rdoqD64LastZero_tem[3 ]    <=  rdoqD64LastZero[3 ];
                        rdoqD64LastZero_tem[7 ]    <=  rdoqD64LastZero[7 ];
                        rdoqD64LastZero_tem[11]    <=  rdoqD64LastZero[11];
                        rdoqD64LastZero_tem[15]    <=  rdoqD64LastZero[15];
                        rdoqD64LastZero_tem[19]    <=  rdoqD64LastZero[19];
                        rdoqD64LastZero_tem[23]    <=  rdoqD64LastZero[23];
                        rdoqD64LastZero_tem[27]    <=  rdoqD64LastZero[27];
                        rdoqD64LastZero_tem[31]    <=  rdoqD64LastZero[31];
                    end
                3'd3    : begin
                        rdoqD64LastZero_tem[3 ]    <=  rdoqD64LastZero[4 ];
                        rdoqD64LastZero_tem[7 ]    <=  rdoqD64LastZero[7 ];

                        rdoqD64LastZero_tem[11]    <=  rdoqD64LastZero[12];
                        rdoqD64LastZero_tem[15]    <=  rdoqD64LastZero[15];

                        rdoqD64LastZero_tem[19]    <=  rdoqD64LastZero[20];
                        rdoqD64LastZero_tem[23]    <=  rdoqD64LastZero[23];

                        rdoqD64LastZero_tem[27]    <=  rdoqD64LastZero[28];
                        rdoqD64LastZero_tem[31]    <=  rdoqD64LastZero[31];
                    end
                3'd4    : begin
                        rdoqD64LastZero_tem[3 ]    <=  rdoqD64LastZero[4 ];
                        rdoqD64LastZero_tem[7 ]    <=  rdoqD64LastZero[8 ];
                        rdoqD64LastZero_tem[11]    <=  rdoqD64LastZero[12];
                        rdoqD64LastZero_tem[15]    <=  rdoqD64LastZero[15];

                        rdoqD64LastZero_tem[19]    <=  rdoqD64LastZero[20];
                        rdoqD64LastZero_tem[23]    <=  rdoqD64LastZero[24];
                        rdoqD64LastZero_tem[27]    <=  rdoqD64LastZero[28];
                        rdoqD64LastZero_tem[31]    <=  rdoqD64LastZero[31];
                    end
                3'd5    : begin
                        rdoqD64LastZero_tem[3 ]    <=  rdoqD64LastZero[4 ];
                        rdoqD64LastZero_tem[7 ]    <=  rdoqD64LastZero[8 ];
                        rdoqD64LastZero_tem[11]    <=  rdoqD64LastZero[12];
                        rdoqD64LastZero_tem[15]    <=  rdoqD64LastZero[16];
                        rdoqD64LastZero_tem[19]    <=  rdoqD64LastZero[20];
                        rdoqD64LastZero_tem[23]    <=  rdoqD64LastZero[24];
                        rdoqD64LastZero_tem[27]    <=  rdoqD64LastZero[28];
                        rdoqD64LastZero_tem[31]    <=  rdoqD64LastZero[31];
                    end
                default : begin
                        rdoqD64LastZero_tem[3 ]    <=  0;
                        rdoqD64LastZero_tem[7 ]    <=  0;
                        rdoqD64LastZero_tem[11]    <=  0;
                        rdoqD64LastZero_tem[15]    <=  0;
                        rdoqD64LastZero_tem[19]    <=  0;
                        rdoqD64LastZero_tem[23]    <=  0;
                        rdoqD64LastZero_tem[27]    <=  0;
                        rdoqD64LastZero_tem[31]    <=  0;
                    end
            endcase
        end
    end
    //calculate rdoqD64LastOne and rdoqD64LastZero
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                rdoqD64LastOne[i]       <=      0;
                rdoqD64LastZero[i]      <=      0;
            end
        end
        else if(column_cnt[0])begin//odd column
            for(i = 0; i < 32; i = i + 2)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                            rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                        rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                    end
                end
                else begin
                    rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                    rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                end
            end

            //odd rows except the last row of each matrix
            for(i = 1; i < 3; i = i + 4)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                            rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                        rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                    end
                end
                else begin
                    rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                    rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                end
            end
            for(i = 5; i < 7; i = i + 4)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                            rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                        rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                    end
                end
                else begin
                    rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                    rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                end
            end
            for(i = 9; i < 15; i = i + 4)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                            rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                        rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                    end
                end
                else begin
                    rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                    rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                end
            end            
            for(i = 17; i < 31; i = i + 4)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                            rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                        rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                    end
                end
                else begin
                    rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem[i]   ;
                    rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem[i]  ;
                end
            end
            //determine the value of the last row 
            case(i_height_log2_d1)
                3'd2    : begin    
                        if(i_level_opt_d1[ 3])begin
                            rdoqD64LastOne  [ 3]    <=  i_d64_cost_last_one_d1 [ 3] ;
                            rdoqD64LastZero [ 3]    <=  i_d64_cost_last_zero_d1[ 3] ;
                        end
                        else begin
                            rdoqD64LastOne  [ 3]    <=  rdoqD64LastOne_tem [ 3]     ;
                            rdoqD64LastZero [ 3]    <=  rdoqD64LastZero_tem[ 3]     ;
                        end

                        if(i_level_opt_d1[ 7])begin
                            rdoqD64LastOne  [ 7]    <=  i_d64_cost_last_one_d1 [ 7] ;
                            rdoqD64LastZero [ 7]    <=  i_d64_cost_last_zero_d1[ 7] ;
                        end
                        else begin
                            rdoqD64LastOne  [ 7]    <=  rdoqD64LastOne_tem [ 7]     ;
                            rdoqD64LastZero [ 7]    <=  rdoqD64LastZero_tem[ 7]     ;
                        end
                        
                        if(i_level_opt_d1[11])begin
                            rdoqD64LastOne  [11]    <=  i_d64_cost_last_one_d1 [11] ;
                            rdoqD64LastZero [11]    <=  i_d64_cost_last_zero_d1[11] ;
                        end
                        else begin
                            rdoqD64LastOne  [11]    <=  rdoqD64LastOne_tem [11]     ;
                            rdoqD64LastZero [11]    <=  rdoqD64LastZero_tem[11]     ;
                        end
                        
                        if(i_level_opt_d1[15])begin
                            rdoqD64LastOne  [15]    <=  i_d64_cost_last_one_d1 [15] ;
                            rdoqD64LastZero [15]    <=  i_d64_cost_last_zero_d1[15] ;
                        end
                        else begin
                            rdoqD64LastOne  [15]    <=  rdoqD64LastOne_tem [15]     ;
                            rdoqD64LastZero [15]    <=  rdoqD64LastZero_tem[15]     ;
                        end
                        
                        if(i_level_opt_d1[19])begin
                            rdoqD64LastOne  [19]    <=  i_d64_cost_last_one_d1 [19] ;
                            rdoqD64LastZero [19]    <=  i_d64_cost_last_zero_d1[19] ;
                        end
                        else begin
                            rdoqD64LastOne  [19]    <=  rdoqD64LastOne_tem [19]     ;
                            rdoqD64LastZero [19]    <=  rdoqD64LastZero_tem[19]     ;
                        end

                        if(i_level_opt_d1[23])begin
                            rdoqD64LastOne  [23]    <=  i_d64_cost_last_one_d1 [23] ;
                            rdoqD64LastZero [23]    <=  i_d64_cost_last_zero_d1[23] ;
                        end
                        else begin
                            rdoqD64LastOne  [23]    <=  rdoqD64LastOne_tem [23]     ;
                            rdoqD64LastZero [23]    <=  rdoqD64LastZero_tem[23]     ;
                        end

                        if(i_level_opt_d1[27])begin
                            rdoqD64LastOne  [27]    <=  i_d64_cost_last_one_d1 [27] ;
                            rdoqD64LastZero [27]    <=  i_d64_cost_last_zero_d1[27] ;
                        end
                        else begin
                            rdoqD64LastOne  [27]    <=  rdoqD64LastOne_tem [27]     ;
                            rdoqD64LastZero [27]    <=  rdoqD64LastZero_tem[27]     ;
                        end

                        if(i_level_opt_d1[31])begin
                            rdoqD64LastOne  [31]    <=  i_d64_cost_last_one_d1 [31] ;
                            rdoqD64LastZero [31]    <=  i_d64_cost_last_zero_d1[31] ;
                        end
                        else begin
                            rdoqD64LastOne  [31]    <=  rdoqD64LastOne_tem [31]     ;
                            rdoqD64LastZero [31]    <=  rdoqD64LastZero_tem[31]     ;
                        end
                    end
                3'd3    : begin
                        if(i_level_opt_d1[ 3])begin
                            if(rdoq_last_y_tem[ 3] != -1)begin
                                if( (tempCost_tem[ 3] + i_base_cost_buffer_tmp_d1[ 3] + i_d64_cost_last_one_d1[ 3] - i_d64_cost_last_zero_d1[ 3]) < (endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - rdoqD64LastZero_tem[ 3]) )begin
                                    rdoqD64LastOne [ 3]     <=      i_d64_cost_last_one_d1 [ 3] ;
                                    rdoqD64LastZero[ 3]     <=      i_d64_cost_last_zero_d1[ 3] ;
                                end
                                else begin
                                    rdoqD64LastOne  [ 3]    <=  rdoqD64LastOne_tem[ 3]       ;
                                    rdoqD64LastZero [ 3]    <=  rdoqD64LastZero_tem[ 3]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [ 3]     <=      i_d64_cost_last_one_d1 [ 3] ;
                                rdoqD64LastZero[ 3]     <=      i_d64_cost_last_zero_d1[ 3] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [ 3]    <=  rdoqD64LastOne_tem [ 3]      ;
                            rdoqD64LastZero [ 3]    <=  rdoqD64LastZero_tem[ 3]      ;
                        end

                        if(i_level_opt_d1[ 7])begin
                            rdoqD64LastOne  [ 7]    <=  i_d64_cost_last_one_d1 [ 7]  ;
                            rdoqD64LastZero [ 7]    <=  i_d64_cost_last_zero_d1[ 7]  ;
                        end
                        else begin
                            rdoqD64LastOne  [ 7]    <=  rdoqD64LastOne_tem [ 7]      ;
                            rdoqD64LastZero [ 7]    <=  rdoqD64LastZero_tem[ 7]      ;
                        end

                        if(i_level_opt_d1[11])begin
                            if(rdoq_last_y_tem[11] != -1)begin
                                if( (tempCost_tem[11] + i_base_cost_buffer_tmp_d1[11] + i_d64_cost_last_one_d1[11] - i_d64_cost_last_zero_d1[11]) < (endPosCost_tem[11] + rdoqD64LastOne_tem[11] - rdoqD64LastZero_tem[11]) )begin
                                    rdoqD64LastOne [11]     <=      i_d64_cost_last_one_d1 [11] ;
                                    rdoqD64LastZero[11]     <=      i_d64_cost_last_zero_d1[11] ;
                                end
                                else begin
                                    rdoqD64LastOne  [11]    <=  rdoqD64LastOne_tem[11]       ;
                                    rdoqD64LastZero [11]    <=  rdoqD64LastZero_tem[11]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [11]     <=      i_d64_cost_last_one_d1 [11] ;
                                rdoqD64LastZero[11]     <=      i_d64_cost_last_zero_d1[11] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [11]    <=  rdoqD64LastOne_tem [11]      ;
                            rdoqD64LastZero [11]    <=  rdoqD64LastZero_tem[11]      ;
                        end

                        if(i_level_opt_d1[15])begin
                            rdoqD64LastOne  [15]    <=  i_d64_cost_last_one_d1 [15]  ;
                            rdoqD64LastZero [15]    <=  i_d64_cost_last_zero_d1[15]  ;
                        end
                        else begin
                            rdoqD64LastOne  [15]    <=  rdoqD64LastOne_tem [15]      ;
                            rdoqD64LastZero [15]    <=  rdoqD64LastZero_tem[15]      ;
                        end

                        if(i_level_opt_d1[19])begin
                            if(rdoq_last_y_tem[19] != -1)begin
                                if( (tempCost_tem[19] + i_base_cost_buffer_tmp_d1[19] + i_d64_cost_last_one_d1[19] - i_d64_cost_last_zero_d1[19]) < (endPosCost_tem[19] + rdoqD64LastOne_tem[19] - rdoqD64LastZero_tem[19]) )begin
                                    rdoqD64LastOne [19]     <=      i_d64_cost_last_one_d1 [19] ;
                                    rdoqD64LastZero[19]     <=      i_d64_cost_last_zero_d1[19] ;
                                end
                                else begin
                                    rdoqD64LastOne  [19]    <=  rdoqD64LastOne_tem[19]       ;
                                    rdoqD64LastZero [19]    <=  rdoqD64LastZero_tem[19]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [19]     <=      i_d64_cost_last_one_d1 [19] ;
                                rdoqD64LastZero[19]     <=      i_d64_cost_last_zero_d1[19] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [19]    <=  rdoqD64LastOne_tem [19]      ;
                            rdoqD64LastZero [19]    <=  rdoqD64LastZero_tem[19]      ;
                        end

                        if(i_level_opt_d1[23])begin
                            rdoqD64LastOne  [23]    <=  i_d64_cost_last_one_d1 [23]  ;
                            rdoqD64LastZero [23]    <=  i_d64_cost_last_zero_d1[23]  ;
                        end
                        else begin
                            rdoqD64LastOne  [23]    <=  rdoqD64LastOne_tem [23]      ;
                            rdoqD64LastZero [23]    <=  rdoqD64LastZero_tem[23]      ;
                        end

                        if(i_level_opt_d1[27])begin
                            if(rdoq_last_y_tem[27] != -1)begin
                                if( (tempCost_tem[27] + i_base_cost_buffer_tmp_d1[27] + i_d64_cost_last_one_d1[27] - i_d64_cost_last_zero_d1[27]) < (endPosCost_tem[27] + rdoqD64LastOne_tem[27] - rdoqD64LastZero_tem[27]) )begin
                                    rdoqD64LastOne [27]     <=      i_d64_cost_last_one_d1 [27] ;
                                    rdoqD64LastZero[27]     <=      i_d64_cost_last_zero_d1[27] ;
                                end
                                else begin
                                    rdoqD64LastOne  [27]    <=  rdoqD64LastOne_tem[27]       ;
                                    rdoqD64LastZero [27]    <=  rdoqD64LastZero_tem[27]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [27]     <=      i_d64_cost_last_one_d1 [27] ;
                                rdoqD64LastZero[27]     <=      i_d64_cost_last_zero_d1[27] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [27]    <=  rdoqD64LastOne_tem [27]      ;
                            rdoqD64LastZero [27]    <=  rdoqD64LastZero_tem[27]      ;
                        end

                        if(i_level_opt_d1[31])begin
                            rdoqD64LastOne  [31]    <=  i_d64_cost_last_one_d1 [31]  ;
                            rdoqD64LastZero [31]    <=  i_d64_cost_last_zero_d1[31]  ;
                        end
                        else begin
                            rdoqD64LastOne  [31]    <=  rdoqD64LastOne_tem [31]      ;
                            rdoqD64LastZero [31]    <=  rdoqD64LastZero_tem[31]      ;
                        end
                        
                    end
                3'd4    : begin
                        if(i_level_opt_d1[ 3])begin
                            if(rdoq_last_y_tem[ 3] != -1)begin
                                if( (tempCost_tem[ 3] + i_base_cost_buffer_tmp_d1[ 3] + i_d64_cost_last_one_d1[ 3] - i_d64_cost_last_zero_d1[ 3]) < (endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - rdoqD64LastZero_tem[ 3]) )begin
                                    rdoqD64LastOne [ 3]     <=      i_d64_cost_last_one_d1 [ 3] ;
                                    rdoqD64LastZero[ 3]     <=      i_d64_cost_last_zero_d1[ 3] ;
                                end
                                else begin
                                    rdoqD64LastOne  [ 3]    <=  rdoqD64LastOne_tem[ 3]       ;
                                    rdoqD64LastZero [ 3]    <=  rdoqD64LastZero_tem[ 3]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [ 3]     <=      i_d64_cost_last_one_d1 [ 3] ;
                                rdoqD64LastZero[ 3]     <=      i_d64_cost_last_zero_d1[ 3] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [ 3]    <=  rdoqD64LastOne_tem [ 3]      ;
                            rdoqD64LastZero [ 3]    <=  rdoqD64LastZero_tem[ 3]      ;
                        end

                        if(i_level_opt_d1[ 7])begin
                            if(rdoq_last_y_tem[ 7] != -1)begin
                                if( (tempCost_tem[ 7] + i_base_cost_buffer_tmp_d1[ 7] + i_d64_cost_last_one_d1[ 7] - i_d64_cost_last_zero_d1[ 7]) < (endPosCost_tem[ 7] + rdoqD64LastOne_tem[ 7] - rdoqD64LastZero_tem[ 7]) )begin
                                    rdoqD64LastOne [ 7]     <=      i_d64_cost_last_one_d1 [ 7] ;
                                    rdoqD64LastZero[ 7]     <=      i_d64_cost_last_zero_d1[ 7] ;
                                end
                                else begin
                                    rdoqD64LastOne  [ 7]    <=  rdoqD64LastOne_tem[ 7]       ;
                                    rdoqD64LastZero [ 7]    <=  rdoqD64LastZero_tem[ 7]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [ 7]     <=      i_d64_cost_last_one_d1 [ 7] ;
                                rdoqD64LastZero[ 7]     <=      i_d64_cost_last_zero_d1[ 7] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [ 7]    <=  rdoqD64LastOne_tem[ 7]       ;
                            rdoqD64LastZero [ 7]    <=  rdoqD64LastZero_tem[ 7]      ;
                        end

                        if(i_level_opt_d1[11])begin
                            if(rdoq_last_y_tem[11] != -1)begin
                                if( (tempCost_tem[11] + i_base_cost_buffer_tmp_d1[11] + i_d64_cost_last_one_d1[11] - i_d64_cost_last_zero_d1[11]) < (endPosCost_tem[11] + rdoqD64LastOne_tem[11] - rdoqD64LastZero_tem[11]) )begin
                                    rdoqD64LastOne [11]     <=      i_d64_cost_last_one_d1 [11] ;
                                    rdoqD64LastZero[11]     <=      i_d64_cost_last_zero_d1[11] ;
                                end
                                else begin
                                    rdoqD64LastOne  [11]    <=  rdoqD64LastOne_tem[11]       ;
                                    rdoqD64LastZero [11]    <=  rdoqD64LastZero_tem[11]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [11]     <=      i_d64_cost_last_one_d1 [11] ;
                                rdoqD64LastZero[11]     <=      i_d64_cost_last_zero_d1[11] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [11]    <=  rdoqD64LastOne_tem [11]      ;
                            rdoqD64LastZero [11]    <=  rdoqD64LastZero_tem[11]      ;
                        end

                        if(i_level_opt_d1[15])begin
                            rdoqD64LastOne  [15]    <=  i_d64_cost_last_one_d1 [15]  ;
                            rdoqD64LastZero [15]    <=  i_d64_cost_last_zero_d1[15]  ;
                        end
                        else begin
                            rdoqD64LastOne  [15]    <=  rdoqD64LastOne_tem [15]      ;
                            rdoqD64LastZero [15]    <=  rdoqD64LastZero_tem[15]      ;
                        end


                        if(i_level_opt_d1[19])begin
                            if(rdoq_last_y_tem[19] != -1)begin
                                if( (tempCost_tem[19] + i_base_cost_buffer_tmp_d1[19] + i_d64_cost_last_one_d1[19] - i_d64_cost_last_zero_d1[19]) < (endPosCost_tem[19] + rdoqD64LastOne_tem[19] - rdoqD64LastZero_tem[19]) )begin
                                    rdoqD64LastOne [19]     <=      i_d64_cost_last_one_d1 [19] ;
                                    rdoqD64LastZero[19]     <=      i_d64_cost_last_zero_d1[19] ;
                                end
                                else begin
                                    rdoqD64LastOne  [19]    <=  rdoqD64LastOne_tem[19]       ;
                                    rdoqD64LastZero [19]    <=  rdoqD64LastZero_tem[19]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [19]     <=      i_d64_cost_last_one_d1 [19] ;
                                rdoqD64LastZero[19]     <=      i_d64_cost_last_zero_d1[19] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [19]    <=  rdoqD64LastOne_tem [19]      ;
                            rdoqD64LastZero [19]    <=  rdoqD64LastZero_tem[19]      ;
                        end

                        if(i_level_opt_d1[23])begin
                            if(rdoq_last_y_tem[23] != -1)begin
                                if( (tempCost_tem[23] + i_base_cost_buffer_tmp_d1[23] + i_d64_cost_last_one_d1[23] - i_d64_cost_last_zero_d1[23]) < (endPosCost_tem[23] + rdoqD64LastOne_tem[23] - rdoqD64LastZero_tem[23]) )begin
                                    rdoqD64LastOne [23]     <=      i_d64_cost_last_one_d1 [23] ;
                                    rdoqD64LastZero[23]     <=      i_d64_cost_last_zero_d1[23] ;
                                end
                                else begin
                                    rdoqD64LastOne  [23]    <=  rdoqD64LastOne_tem[23]       ;
                                    rdoqD64LastZero [23]    <=  rdoqD64LastZero_tem[23]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [23]     <=      i_d64_cost_last_one_d1 [23] ;
                                rdoqD64LastZero[23]     <=      i_d64_cost_last_zero_d1[23] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [23]    <=  rdoqD64LastOne_tem[23]       ;
                            rdoqD64LastZero [23]    <=  rdoqD64LastZero_tem[23]      ;
                        end

                        if(i_level_opt_d1[27])begin
                            if(rdoq_last_y_tem[27] != -1)begin
                                if( (tempCost_tem[27] + i_base_cost_buffer_tmp_d1[27] + i_d64_cost_last_one_d1[27] - i_d64_cost_last_zero_d1[27]) < (endPosCost_tem[27] + rdoqD64LastOne_tem[27] - rdoqD64LastZero_tem[27]) )begin
                                    rdoqD64LastOne [27]     <=      i_d64_cost_last_one_d1 [27] ;
                                    rdoqD64LastZero[27]     <=      i_d64_cost_last_zero_d1[27] ;
                                end
                                else begin
                                    rdoqD64LastOne  [27]    <=  rdoqD64LastOne_tem[27]       ;
                                    rdoqD64LastZero [27]    <=  rdoqD64LastZero_tem[27]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [27]     <=      i_d64_cost_last_one_d1 [27] ;
                                rdoqD64LastZero[27]     <=      i_d64_cost_last_zero_d1[27] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [27]    <=  rdoqD64LastOne_tem [27]      ;
                            rdoqD64LastZero [27]    <=  rdoqD64LastZero_tem[27]      ;
                        end

                        if(i_level_opt_d1[31])begin
                            rdoqD64LastOne  [31]    <=  i_d64_cost_last_one_d1 [31]  ;
                            rdoqD64LastZero [31]    <=  i_d64_cost_last_zero_d1[31]  ;
                        end
                        else begin
                            rdoqD64LastOne  [31]    <=  rdoqD64LastOne_tem [31]      ;
                            rdoqD64LastZero [31]    <=  rdoqD64LastZero_tem[31]      ;
                        end
                    end
                3'd5    : begin
                        if(i_level_opt_d1[ 3])begin
                            if(rdoq_last_y_tem[ 3] != -1)begin
                                if( (tempCost_tem[ 3] + i_base_cost_buffer_tmp_d1[ 3] + i_d64_cost_last_one_d1[ 3] - i_d64_cost_last_zero_d1[ 3]) < (endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - rdoqD64LastZero_tem[ 3]) )begin
                                    rdoqD64LastOne [ 3]     <=      i_d64_cost_last_one_d1 [ 3] ;
                                    rdoqD64LastZero[ 3]     <=      i_d64_cost_last_zero_d1[ 3] ;
                                end
                                else begin
                                    rdoqD64LastOne  [ 3]    <=  rdoqD64LastOne_tem[ 3]       ;
                                    rdoqD64LastZero [ 3]    <=  rdoqD64LastZero_tem[ 3]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [ 3]     <=      i_d64_cost_last_one_d1 [ 3] ;
                                rdoqD64LastZero[ 3]     <=      i_d64_cost_last_zero_d1[ 3] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [ 3]    <=  rdoqD64LastOne_tem [ 3]      ;
                            rdoqD64LastZero [ 3]    <=  rdoqD64LastZero_tem[ 3]      ;
                        end

                        if(i_level_opt_d1[ 7])begin
                            if(rdoq_last_y_tem[ 7] != -1)begin
                                if( (tempCost_tem[ 7] + i_base_cost_buffer_tmp_d1[ 7] + i_d64_cost_last_one_d1[ 7] - i_d64_cost_last_zero_d1[ 7]) < (endPosCost_tem[ 7] + rdoqD64LastOne_tem[ 7] - rdoqD64LastZero_tem[ 7]) )begin
                                    rdoqD64LastOne [ 7]     <=      i_d64_cost_last_one_d1 [ 7] ;
                                    rdoqD64LastZero[ 7]     <=      i_d64_cost_last_zero_d1[ 7] ;
                                end
                                else begin
                                    rdoqD64LastOne  [ 7]    <=  rdoqD64LastOne_tem[ 7]       ;
                                    rdoqD64LastZero [ 7]    <=  rdoqD64LastZero_tem[ 7]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [ 7]     <=      i_d64_cost_last_one_d1 [ 7] ;
                                rdoqD64LastZero[ 7]     <=      i_d64_cost_last_zero_d1[ 7] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [ 7]    <=  rdoqD64LastOne_tem[ 7]       ;
                            rdoqD64LastZero [ 7]    <=  rdoqD64LastZero_tem[ 7]      ;
                        end

                        if(i_level_opt_d1[11])begin
                            if(rdoq_last_y_tem[11] != -1)begin
                                if( (tempCost_tem[11] + i_base_cost_buffer_tmp_d1[11] + i_d64_cost_last_one_d1[11] - i_d64_cost_last_zero_d1[11]) < (endPosCost_tem[11] + rdoqD64LastOne_tem[11] - rdoqD64LastZero_tem[11]) )begin
                                    rdoqD64LastOne [11]     <=      i_d64_cost_last_one_d1 [11] ;
                                    rdoqD64LastZero[11]     <=      i_d64_cost_last_zero_d1[11] ;
                                end
                                else begin
                                    rdoqD64LastOne  [11]    <=  rdoqD64LastOne_tem[11]       ;
                                    rdoqD64LastZero [11]    <=  rdoqD64LastZero_tem[11]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [11]     <=      i_d64_cost_last_one_d1 [11] ;
                                rdoqD64LastZero[11]     <=      i_d64_cost_last_zero_d1[11] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [11]    <=  rdoqD64LastOne_tem [11]      ;
                            rdoqD64LastZero [11]    <=  rdoqD64LastZero_tem[11]      ;
                        end

                        if(i_level_opt_d1[15])begin
                            if(rdoq_last_y_tem[15] != -1)begin
                                if( (tempCost_tem[15] + i_base_cost_buffer_tmp_d1[15] + i_d64_cost_last_one_d1[15] - i_d64_cost_last_zero_d1[15]) < (endPosCost_tem[15] + rdoqD64LastOne_tem[15] - rdoqD64LastZero_tem[15]) )begin
                                    rdoqD64LastOne [15]     <=      i_d64_cost_last_one_d1 [15] ;
                                    rdoqD64LastZero[15]     <=      i_d64_cost_last_zero_d1[15] ;
                                end
                                else begin
                                    rdoqD64LastOne  [15]    <=  rdoqD64LastOne_tem[15]       ;
                                    rdoqD64LastZero [15]    <=  rdoqD64LastZero_tem[15]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [15]     <=      i_d64_cost_last_one_d1 [15] ;
                                rdoqD64LastZero[15]     <=      i_d64_cost_last_zero_d1[15] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [15]    <=  rdoqD64LastOne_tem[15]       ;
                            rdoqD64LastZero [15]    <=  rdoqD64LastZero_tem[15]      ;
                        end

                        if(i_level_opt_d1[19])begin
                            if(rdoq_last_y_tem[19] != -1)begin
                                if( (tempCost_tem[19] + i_base_cost_buffer_tmp_d1[19] + i_d64_cost_last_one_d1[19] - i_d64_cost_last_zero_d1[19]) < (endPosCost_tem[19] + rdoqD64LastOne_tem[19] - rdoqD64LastZero_tem[19]) )begin
                                    rdoqD64LastOne [19]     <=      i_d64_cost_last_one_d1 [19] ;
                                    rdoqD64LastZero[19]     <=      i_d64_cost_last_zero_d1[19] ;
                                end
                                else begin
                                    rdoqD64LastOne  [19]    <=  rdoqD64LastOne_tem[19]       ;
                                    rdoqD64LastZero [19]    <=  rdoqD64LastZero_tem[19]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [19]     <=      i_d64_cost_last_one_d1 [19] ;
                                rdoqD64LastZero[19]     <=      i_d64_cost_last_zero_d1[19] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [19]    <=  rdoqD64LastOne_tem [19]      ;
                            rdoqD64LastZero [19]    <=  rdoqD64LastZero_tem[19]      ;
                        end

                        if(i_level_opt_d1[23])begin
                            if(rdoq_last_y_tem[23] != -1)begin
                                if( (tempCost_tem[23] + i_base_cost_buffer_tmp_d1[23] + i_d64_cost_last_one_d1[23] - i_d64_cost_last_zero_d1[23]) < (endPosCost_tem[23] + rdoqD64LastOne_tem[23] - rdoqD64LastZero_tem[23]) )begin
                                    rdoqD64LastOne [23]     <=      i_d64_cost_last_one_d1 [23] ;
                                    rdoqD64LastZero[23]     <=      i_d64_cost_last_zero_d1[23] ;
                                end
                                else begin
                                    rdoqD64LastOne  [23]    <=  rdoqD64LastOne_tem[23]       ;
                                    rdoqD64LastZero [23]    <=  rdoqD64LastZero_tem[23]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [23]     <=      i_d64_cost_last_one_d1 [23] ;
                                rdoqD64LastZero[23]     <=      i_d64_cost_last_zero_d1[23] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [23]    <=  rdoqD64LastOne_tem[23]       ;
                            rdoqD64LastZero [23]    <=  rdoqD64LastZero_tem[23]      ;
                        end

                        if(i_level_opt_d1[27])begin
                            if(rdoq_last_y_tem[27] != -1)begin
                                if( (tempCost_tem[27] + i_base_cost_buffer_tmp_d1[27] + i_d64_cost_last_one_d1[27] - i_d64_cost_last_zero_d1[27]) < (endPosCost_tem[27] + rdoqD64LastOne_tem[27] - rdoqD64LastZero_tem[27]) )begin
                                    rdoqD64LastOne [27]     <=      i_d64_cost_last_one_d1 [27] ;
                                    rdoqD64LastZero[27]     <=      i_d64_cost_last_zero_d1[27] ;
                                end
                                else begin
                                    rdoqD64LastOne  [27]    <=  rdoqD64LastOne_tem[27]       ;
                                    rdoqD64LastZero [27]    <=  rdoqD64LastZero_tem[27]      ;
                                end
                            end
                            else begin
                                rdoqD64LastOne [27]     <=      i_d64_cost_last_one_d1 [27] ;
                                rdoqD64LastZero[27]     <=      i_d64_cost_last_zero_d1[27] ;
                            end
                        end
                        else begin
                            rdoqD64LastOne  [27]    <=  rdoqD64LastOne_tem [27]      ;
                            rdoqD64LastZero [27]    <=  rdoqD64LastZero_tem[27]      ;
                        end

                        if(i_level_opt_d1[31])begin
                            rdoqD64LastOne  [31]    <=  i_d64_cost_last_one_d1 [31]  ;
                            rdoqD64LastZero [31]    <=  i_d64_cost_last_zero_d1[31]  ;
                        end
                    end
                default : begin
                        rdoqD64LastOne  [ 3]    <=  0;
                        rdoqD64LastZero [ 3]    <=  0;
                        rdoqD64LastOne  [ 7]    <=  0;
                        rdoqD64LastZero [ 7]    <=  0;
                        rdoqD64LastOne  [11]    <=  0;
                        rdoqD64LastZero [11]    <=  0;
                        rdoqD64LastOne  [15]    <=  0;
                        rdoqD64LastOne  [15]    <=  0;
                        rdoqD64LastZero [19]    <=  0;
                        rdoqD64LastZero [19]    <=  0;
                        rdoqD64LastOne  [23]    <=  0;
                        rdoqD64LastOne  [23]    <=  0;
                        rdoqD64LastZero [27]    <=  0;
                        rdoqD64LastZero [27]    <=  0;
                        rdoqD64LastOne  [31]    <=  0;
                        rdoqD64LastZero [31]    <=  0;
                    end
            endcase
        end
        else begin//even column
            if(column_cnt == 0)begin
                for(i = 0; i < 32; i = i + 1)begin
                    if(i_level_opt_d1[i])begin
                        rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                        rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                        rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                    end
                end
            end
            else begin
                //even rows
                for(i = 0; i < 32; i = i + 2)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                                rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                                rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                            end
                            else begin
                                rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                                rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                            end
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                        rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                    end
                end

                //odd rows except the last row of each matrix
                for(i = 1; i < 3; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                                rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                            end
                            else begin
                                rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                                rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                            end
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                        rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                    end
                end
                for(i = 5; i < 7; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                                rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                            end
                            else begin
                                rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                                rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                            end
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                        rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                    end
                end
                for(i = 9; i < 15; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                                rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                            end
                            else begin
                                rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                                rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                            end
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                        rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                    end
                end            
                for(i = 17; i < 31; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                                rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                            end
                            else begin
                                rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                                rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                            end
                        end
                        else begin
                            rdoqD64LastOne[i]       <=      i_d64_cost_last_one_d1[i]   ;
                            rdoqD64LastZero[i]      <=      i_d64_cost_last_zero_d1[i]  ;
                        end
                    end
                    else begin
                        rdoqD64LastOne[i]       <=      rdoqD64LastOne_tem  [i];
                        rdoqD64LastZero[i]      <=      rdoqD64LastZero_tem [i];
                    end
                end
                //determine the value of the last row 
                case(i_height_log2_d1)
                    3'd2    : begin                                
                            for(i = 0; i < 8; i = i + 1)begin
                                if(i_level_opt_d1[ 3 + i * 4])begin
                                    rdoqD64LastOne  [ 3 + i * 4]    <=  i_d64_cost_last_one_d1 [ 3 + i * 4]  ;
                                    rdoqD64LastZero [ 3 + i * 4]    <=  i_d64_cost_last_zero_d1[ 3 + i * 4]  ;
                                end
                            end
                        end
                    3'd3    : begin
                            for(i = 0; i < 4; i = i + 1)begin
                                if(i_level_opt_d1[ 3 + i * 8])begin
                                    if(rdoq_last_y_tem[ 3 + i * 8] != -1)begin
                                        if(tempCost_tem[ 3 + i * 8] - endPosCost_tem[ 3 + i * 8] + rdoqD64LastOne_tem[ 3 + i * 8] - i_d64_cost_last_one_d1[ 3 + i * 8] + i_d64_cost_last_zero_d1[ 3 + i * 8] - rdoqD64LastZero_tem[ 3 + i * 8] > 0)begin
                                            rdoqD64LastOne [ 3 + i * 8]     <=      i_d64_cost_last_one_d1 [ 3 + i * 8] ;
                                            rdoqD64LastZero[ 3 + i * 8]     <=      i_d64_cost_last_zero_d1[ 3 + i * 8] ;
                                        end
                                        else begin 
                                            rdoqD64LastOne [ 3 + i * 8]     <=      rdoqD64LastOne_tem  [ 3 + i * 8]    ;
                                            rdoqD64LastZero[ 3 + i * 8]     <=      rdoqD64LastZero_tem [ 3 + i * 8]    ;
                                        end
                                    end
                                    else begin
                                        rdoqD64LastOne [ 3 + i * 8]     <=      i_d64_cost_last_one_d1 [ 3 + i * 8] ;
                                        rdoqD64LastZero[ 3 + i * 8]     <=      i_d64_cost_last_zero_d1[ 3 + i * 8] ;
                                    end
                                end
                                else begin 
                                    rdoqD64LastOne [ 3 + i * 8]     <=      rdoqD64LastOne_tem [ 3 + i * 8]    ;
                                    rdoqD64LastZero[ 3 + i * 8]     <=      rdoqD64LastZero_tem[ 3 + i * 8]    ;
                                end

                                if(i_level_opt_d1[ 7 + i * 8])begin
                                    rdoqD64LastOne  [ 7 + i * 8]    <=  i_d64_cost_last_one_d1 [ 7 + i * 8]  ;
                                    rdoqD64LastZero [ 7 + i * 8]    <=  i_d64_cost_last_zero_d1[ 7 + i * 8]  ;
                                end
                                else begin
                                    rdoqD64LastOne  [ 7 + i * 8]    <=  rdoqD64LastOne_tem [ 7 + i * 8]  ;
                                    rdoqD64LastZero [ 7 + i * 8]    <=  rdoqD64LastZero_tem[ 7 + i * 8]  ;
                                end
                            end
                        end
                    3'd4    : begin                            
                            for(i = 0; i < 2; i = i + 1)begin
                                if(i_level_opt_d1[ 3 + i * 16])begin
                                    if(rdoq_last_y_tem[ 3 + i * 16] != -1)begin
                                        if(tempCost_tem[ 3 + i * 16] - endPosCost_tem[ 3 + i * 16] + rdoqD64LastOne_tem[ 3 + i * 16] - i_d64_cost_last_one_d1[ 3 + i * 16] + i_d64_cost_last_zero_d1[ 3 + i * 16] - rdoqD64LastZero_tem[ 3 + i * 16] > 0)begin
                                            rdoqD64LastOne [ 3 + i * 16]     <=      i_d64_cost_last_one_d1 [ 3 + i * 16] ;
                                            rdoqD64LastZero[ 3 + i * 16]     <=      i_d64_cost_last_zero_d1[ 3 + i * 16] ;
                                        end
                                        else begin 
                                            rdoqD64LastOne [ 3 + i * 16]     <=      rdoqD64LastOne_tem  [ 3 + i * 16]    ;
                                            rdoqD64LastZero[ 3 + i * 16]     <=      rdoqD64LastZero_tem [ 3 + i * 16]    ;
                                        end
                                    end
                                    else begin
                                        rdoqD64LastOne [ 3 + i * 16]     <=      i_d64_cost_last_one_d1 [ 3 + i * 16] ;
                                        rdoqD64LastZero[ 3 + i * 16]     <=      i_d64_cost_last_zero_d1[ 3 + i * 16] ;
                                    end
                                end
                                else begin 
                                    rdoqD64LastOne [ 3 + i * 16]     <=      rdoqD64LastOne_tem [ 3 + i * 16]    ;
                                    rdoqD64LastZero[ 3 + i * 16]     <=      rdoqD64LastZero_tem[ 3 + i * 16]    ;
                                end

                                if(i_level_opt_d1[ 7 + i * 16])begin
                                    if(rdoq_last_y_tem[ 7 + i * 16] != -1)begin
                                        if(tempCost_tem[ 7 + i * 16] - endPosCost_tem[ 7 + i * 16] + rdoqD64LastOne_tem[ 7 + i * 16] - i_d64_cost_last_one_d1[ 7 + i * 16] + i_d64_cost_last_zero_d1[ 7 + i * 16] - rdoqD64LastZero_tem[ 7 + i * 16] > 0)begin
                                            rdoqD64LastOne [ 7 + i * 16]     <=      i_d64_cost_last_one_d1 [ 7 + i * 16] ;
                                            rdoqD64LastZero[ 7 + i * 16]     <=      i_d64_cost_last_zero_d1[ 7 + i * 16] ;
                                        end
                                        else begin 
                                            rdoqD64LastOne [ 7 + i * 16]     <=      rdoqD64LastOne_tem  [ 7 + i * 16]    ;
                                            rdoqD64LastZero[ 7 + i * 16]     <=      rdoqD64LastZero_tem [ 7 + i * 16]    ;
                                        end
                                    end
                                    else begin
                                        rdoqD64LastOne [ 7 + i * 16]     <=      i_d64_cost_last_one_d1 [ 7 + i * 16] ;
                                        rdoqD64LastZero[ 7 + i * 16]     <=      i_d64_cost_last_zero_d1[ 7 + i * 16] ;
                                    end
                                end
                                else begin 
                                    rdoqD64LastOne [ 7 + i * 16]     <=      rdoqD64LastOne_tem [ 7 + i * 16]    ;
                                    rdoqD64LastZero[ 7 + i * 16]     <=      rdoqD64LastZero_tem[ 7 + i * 16]    ;
                                end
                                
                                if(i_level_opt_d1[11 + i * 16])begin
                                    if(rdoq_last_y_tem[11 + i * 16] != -1)begin
                                        if(tempCost_tem[11 + i * 16] - endPosCost_tem[11 + i * 16] + rdoqD64LastOne_tem[11 + i * 16] - i_d64_cost_last_one_d1[11 + i * 16] + i_d64_cost_last_zero_d1[11 + i * 16] - rdoqD64LastZero_tem[11 + i * 16] > 0)begin
                                            rdoqD64LastOne [11 + i * 16]     <=      i_d64_cost_last_one_d1 [11 + i * 16] ;
                                            rdoqD64LastZero[11 + i * 16]     <=      i_d64_cost_last_zero_d1[11 + i * 16] ;
                                        end
                                        else begin 
                                            rdoqD64LastOne [11 + i * 16]     <=      rdoqD64LastOne_tem  [11 + i * 16]    ;
                                            rdoqD64LastZero[11 + i * 16]     <=      rdoqD64LastZero_tem [11 + i * 16]    ;
                                        end
                                    end
                                    else begin
                                        rdoqD64LastOne [11 + i * 16]     <=      i_d64_cost_last_one_d1 [11 + i * 16] ;
                                        rdoqD64LastZero[11 + i * 16]     <=      i_d64_cost_last_zero_d1[11 + i * 16] ;
                                    end
                                end
                                else begin 
                                    rdoqD64LastOne [11 + i * 16]     <=      rdoqD64LastOne_tem [11 + i * 16]    ;
                                    rdoqD64LastZero[11 + i * 16]     <=      rdoqD64LastZero_tem[11 + i * 16]    ;
                                end

                                if(i_level_opt_d1[15])begin
                                    rdoqD64LastOne  [15]    <=  i_d64_cost_last_one_d1 [15]  ;
                                    rdoqD64LastZero [15]    <=  i_d64_cost_last_zero_d1[15]  ;
                                end
                                else begin
                                    rdoqD64LastOne  [15]    <=  rdoqD64LastOne_tem [15]  ;
                                    rdoqD64LastZero [15]    <=  rdoqD64LastZero_tem[15]  ;
                                end
                            end
                        end
                    3'd5    : begin
                            if(i_level_opt_d1[ 3])begin
                                if(rdoq_last_y_tem[ 3] != -1)begin
                                    if(tempCost_tem[ 3] - endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - i_d64_cost_last_one_d1[ 3] + i_d64_cost_last_zero_d1[ 3] - rdoqD64LastZero_tem[ 3] > 0)begin
                                        rdoqD64LastOne [ 3]     <=      i_d64_cost_last_one_d1 [ 3] ;
                                        rdoqD64LastZero[ 3]     <=      i_d64_cost_last_zero_d1[ 3] ;
                                    end
                                    else begin 
                                        rdoqD64LastOne [ 3]     <=      rdoqD64LastOne_tem  [ 3]    ;
                                        rdoqD64LastZero[ 3]     <=      rdoqD64LastZero_tem [ 3]    ;
                                    end
                                end
                                else begin
                                    rdoqD64LastOne [ 3]     <=      i_d64_cost_last_one_d1 [ 3] ;
                                    rdoqD64LastZero[ 3]     <=      i_d64_cost_last_zero_d1[ 3] ;
                                end
                            end
                            else begin 
                                rdoqD64LastOne [ 3]     <=      rdoqD64LastOne_tem [ 3]    ;
                                rdoqD64LastZero[ 3]     <=      rdoqD64LastZero_tem[ 3]    ;
                            end

                            if(i_level_opt_d1[ 7])begin
                                if(rdoq_last_y_tem[ 7] != -1)begin
                                    if(tempCost_tem[ 7] - endPosCost_tem[ 7] + rdoqD64LastOne_tem[ 7] - i_d64_cost_last_one_d1[ 7] + i_d64_cost_last_zero_d1[ 7] - rdoqD64LastZero_tem[ 7] > 0)begin
                                        rdoqD64LastOne [ 7]     <=      i_d64_cost_last_one_d1 [ 7] ;
                                        rdoqD64LastZero[ 7]     <=      i_d64_cost_last_zero_d1[ 7] ;
                                    end
                                    else begin 
                                        rdoqD64LastOne [ 7]     <=      rdoqD64LastOne_tem  [ 7]    ;
                                        rdoqD64LastZero[ 7]     <=      rdoqD64LastZero_tem [ 7]    ;
                                    end
                                end
                                else begin
                                    rdoqD64LastOne [ 7]     <=      i_d64_cost_last_one_d1 [ 7] ;
                                    rdoqD64LastZero[ 7]     <=      i_d64_cost_last_zero_d1[ 7] ;
                                end
                            end
                            else begin 
                                rdoqD64LastOne [ 7]     <=      rdoqD64LastOne_tem [ 7]    ;
                                rdoqD64LastZero[ 7]     <=      rdoqD64LastZero_tem[ 7]    ;
                            end

                            if(i_level_opt_d1[11])begin
                                if(rdoq_last_y_tem[11] != -1)begin
                                    if(tempCost_tem[11] - endPosCost_tem[11] + rdoqD64LastOne_tem[11] - i_d64_cost_last_one_d1[11] + i_d64_cost_last_zero_d1[11] - rdoqD64LastZero_tem[11] > 0)begin
                                        rdoqD64LastOne [11]     <=      i_d64_cost_last_one_d1 [11] ;
                                        rdoqD64LastZero[11]     <=      i_d64_cost_last_zero_d1[11] ;
                                    end
                                    else begin 
                                        rdoqD64LastOne [11]     <=      rdoqD64LastOne_tem  [11]    ;
                                        rdoqD64LastZero[11]     <=      rdoqD64LastZero_tem [11]    ;
                                    end
                                end
                                else begin
                                    rdoqD64LastOne [11]     <=      i_d64_cost_last_one_d1 [11] ;
                                    rdoqD64LastZero[11]     <=      i_d64_cost_last_zero_d1[11] ;
                                end
                            end
                            else begin 
                                rdoqD64LastOne [11]     <=      rdoqD64LastOne_tem [11]    ;
                                rdoqD64LastZero[11]     <=      rdoqD64LastZero_tem[11]    ;
                            end

                            if(i_level_opt_d1[15])begin
                                if(rdoq_last_y_tem[15] != -1)begin
                                    if(tempCost_tem[15] - endPosCost_tem[15] + rdoqD64LastOne_tem[15] - i_d64_cost_last_one_d1[15] + i_d64_cost_last_zero_d1[15] - rdoqD64LastZero_tem[15] > 0)begin
                                        rdoqD64LastOne [15]     <=      i_d64_cost_last_one_d1 [15] ;
                                        rdoqD64LastZero[15]     <=      i_d64_cost_last_zero_d1[15] ;
                                    end
                                    else begin 
                                        rdoqD64LastOne [15]     <=      rdoqD64LastOne_tem  [15]    ;
                                        rdoqD64LastZero[15]     <=      rdoqD64LastZero_tem [15]    ;
                                    end
                                end
                                else begin
                                    rdoqD64LastOne [15]     <=      i_d64_cost_last_one_d1 [15] ;
                                    rdoqD64LastZero[15]     <=      i_d64_cost_last_zero_d1[15] ;
                                end
                            end
                            else begin 
                                rdoqD64LastOne [15]     <=      rdoqD64LastOne_tem [15]    ;
                                rdoqD64LastZero[15]     <=      rdoqD64LastZero_tem[15]    ;
                            end

                            if(i_level_opt_d1[19])begin
                                if(rdoq_last_y_tem[19] != -1)begin
                                    if(tempCost_tem[19] - endPosCost_tem[19] + rdoqD64LastOne_tem[19] - i_d64_cost_last_one_d1[19] + i_d64_cost_last_zero_d1[19] - rdoqD64LastZero_tem[19] > 0)begin
                                        rdoqD64LastOne [19]     <=      i_d64_cost_last_one_d1 [19] ;
                                        rdoqD64LastZero[19]     <=      i_d64_cost_last_zero_d1[19] ;
                                    end
                                    else begin 
                                        rdoqD64LastOne [19]     <=      rdoqD64LastOne_tem  [19]    ;
                                        rdoqD64LastZero[19]     <=      rdoqD64LastZero_tem [19]    ;
                                    end
                                end
                                else begin
                                    rdoqD64LastOne [19]     <=      i_d64_cost_last_one_d1 [19] ;
                                    rdoqD64LastZero[19]     <=      i_d64_cost_last_zero_d1[19] ;
                                end
                            end
                            else begin 
                                rdoqD64LastOne [19]     <=      rdoqD64LastOne_tem [19]    ;
                                rdoqD64LastZero[19]     <=      rdoqD64LastZero_tem[19]    ;
                            end

                            if(i_level_opt_d1[23])begin
                                if(rdoq_last_y_tem[23] != -1)begin
                                    if(tempCost_tem[23] - endPosCost_tem[23] + rdoqD64LastOne_tem[23] - i_d64_cost_last_one_d1[23] + i_d64_cost_last_zero_d1[23] - rdoqD64LastZero_tem[23] > 0)begin
                                        rdoqD64LastOne [23]     <=      i_d64_cost_last_one_d1 [23] ;
                                        rdoqD64LastZero[23]     <=      i_d64_cost_last_zero_d1[23] ;
                                    end
                                    else begin 
                                        rdoqD64LastOne [23]     <=      rdoqD64LastOne_tem  [23]    ;
                                        rdoqD64LastZero[23]     <=      rdoqD64LastZero_tem [23]    ;
                                    end
                                end
                                else begin
                                    rdoqD64LastOne [23]     <=      i_d64_cost_last_one_d1 [23] ;
                                    rdoqD64LastZero[23]     <=      i_d64_cost_last_zero_d1[23] ;
                                end
                            end
                            else begin 
                                rdoqD64LastOne [23]     <=      rdoqD64LastOne_tem [23]    ;
                                rdoqD64LastZero[23]     <=      rdoqD64LastZero_tem[23]    ;
                            end

                            if(i_level_opt_d1[27])begin
                                if(rdoq_last_y_tem[27] != -1)begin
                                    if(tempCost_tem[27] - endPosCost_tem[27] + rdoqD64LastOne_tem[27] - i_d64_cost_last_one_d1[27] + i_d64_cost_last_zero_d1[27] - rdoqD64LastZero_tem[27] > 0)begin
                                        rdoqD64LastOne [27]     <=      i_d64_cost_last_one_d1 [27] ;
                                        rdoqD64LastZero[27]     <=      i_d64_cost_last_zero_d1[27] ;
                                    end
                                    else begin 
                                        rdoqD64LastOne [27]     <=      rdoqD64LastOne_tem  [27]    ;
                                        rdoqD64LastZero[27]     <=      rdoqD64LastZero_tem [27]    ;
                                    end
                                end
                                else begin
                                    rdoqD64LastOne [27]     <=      i_d64_cost_last_one_d1 [27] ;
                                    rdoqD64LastZero[27]     <=      i_d64_cost_last_zero_d1[27] ;
                                end
                            end
                            else begin 
                                rdoqD64LastOne [27]     <=      rdoqD64LastOne_tem [27]    ;
                                rdoqD64LastZero[27]     <=      rdoqD64LastZero_tem[27]    ;
                            end

                            if(i_level_opt_d1[31])begin
                                rdoqD64LastOne  [31]    <=  i_d64_cost_last_one_d1 [31]  ;
                                rdoqD64LastZero [31]    <=  i_d64_cost_last_zero_d1[31]  ;
                            end
                            else begin
                                rdoqD64LastOne  [31]    <=  rdoqD64LastOne_tem [31] ;
                                rdoqD64LastZero [31]    <=  rdoqD64LastZero_tem[31] ;
                            end
                        end
                    default : begin
                            rdoqD64LastOne  [ 3]    <=  0;
                            rdoqD64LastZero [ 3]    <=  0;
                            rdoqD64LastOne  [ 7]    <=  0;
                            rdoqD64LastZero [ 7]    <=  0;
                            rdoqD64LastOne  [11]    <=  0;
                            rdoqD64LastZero [11]    <=  0;
                            rdoqD64LastOne  [15]    <=  0;
                            rdoqD64LastOne  [15]    <=  0;
                            rdoqD64LastZero [19]    <=  0;
                            rdoqD64LastZero [19]    <=  0;
                            rdoqD64LastOne  [23]    <=  0;
                            rdoqD64LastOne  [23]    <=  0;
                            rdoqD64LastZero [27]    <=  0;
                            rdoqD64LastZero [27]    <=  0;
                            rdoqD64LastOne  [31]    <=  0;
                            rdoqD64LastZero [31]    <=  0;
                        end
                endcase
            end
        end
    end

    //do shift operation to the former rdoq_last_x and rdoq_last_y
    always@(*)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                rdoq_last_x_tem[i]     <=   0;   
            end
        end
        else begin
            for(j = 0; j < 8; j = j + 1)begin
                for(i = 0 ; i < 3 ; i = i + 1)begin
                    rdoq_last_x_tem[i + j * 4]     <=   rdoq_last_x[i + 1 + j * 4];   
                end
            end
            case(i_height_log2_d2)
                3'd2    : begin    
                        for(i = 0; i < 8; i = i + 1)begin
                            rdoq_last_x_tem[3 + i * 4]    <=  rdoq_last_x[3 + i * 4];
                        end
                    end
                3'd3    : begin
                        for(i = 0; i < 4; i = i + 1)begin
                            rdoq_last_x_tem[3 + i * 8]    <=  rdoq_last_x[4 + i * 8];
                        end
                        for(i = 0; i < 4; i = i + 1)begin
                            rdoq_last_x_tem[7 + i * 8]    <=  rdoq_last_x[7 + i * 8];
                        end
                    end
                3'd4    : begin
                        for(i = 0; i < 2; i = i + 1)begin
                            rdoq_last_x_tem[3  + i * 16]    <=  rdoq_last_x[4  + i * 16];
                            rdoq_last_x_tem[7  + i * 16]    <=  rdoq_last_x[8  + i * 16];
                            rdoq_last_x_tem[11 + i * 16]    <=  rdoq_last_x[12 + i * 16];
                            rdoq_last_x_tem[15 + i * 16]    <=  rdoq_last_x[15 + i * 16];
                        end
                    end
                3'd5    : begin
                        rdoq_last_x_tem[3 ]    <=  rdoq_last_x[4 ];
                        rdoq_last_x_tem[7 ]    <=  rdoq_last_x[8 ];
                        rdoq_last_x_tem[11]    <=  rdoq_last_x[12];
                        rdoq_last_x_tem[15]    <=  rdoq_last_x[16];
                        rdoq_last_x_tem[19]    <=  rdoq_last_x[20];
                        rdoq_last_x_tem[23]    <=  rdoq_last_x[24];
                        rdoq_last_x_tem[27]    <=  rdoq_last_x[28];
                        rdoq_last_x_tem[31]    <=  rdoq_last_x[31];
                    end
                default : begin
                        rdoq_last_x_tem[3 ]    <=  0;
                        rdoq_last_x_tem[7 ]    <=  0;
                        rdoq_last_x_tem[11]    <=  0;
                        rdoq_last_x_tem[15]    <=  0;
                        rdoq_last_x_tem[19]    <=  0;
                        rdoq_last_x_tem[23]    <=  0;
                        rdoq_last_x_tem[27]    <=  0;
                        rdoq_last_x_tem[31]    <=  0;
                    end
            endcase
        end
    end

    always@(*)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                rdoq_last_y_tem[i]     <=   0;   
            end
        end
        else begin
            for(j = 0; j < 8; j = j + 1)begin
                for(i = 0 ; i < 3 ; i = i + 1)begin
                    rdoq_last_y_tem[i + j * 4]     <=   rdoq_last_y[i + 1 + j * 4];   
                end
            end
            case(i_height_log2_d2)
                3'd2    : begin    
                        for(i = 0; i < 8; i = i + 1)begin
                            rdoq_last_y_tem[3 + i * 4]    <=  rdoq_last_y[3 + i * 4];
                        end
                    end
                3'd3    : begin
                        for(i = 0; i < 4; i = i + 1)begin
                            rdoq_last_y_tem[3 + i * 8]    <=  rdoq_last_y[4 + i * 8];
                        end
                        for(i = 0; i < 4; i = i + 1)begin
                            rdoq_last_y_tem[7 + i * 8]    <=  rdoq_last_y[7 + i * 8];
                        end
                    end
                3'd4    : begin
                        for(i = 0; i < 2; i = i + 1)begin
                            rdoq_last_y_tem[3  + i * 16]    <=  rdoq_last_y[4  + i * 16];
                            rdoq_last_y_tem[7  + i * 16]    <=  rdoq_last_y[8  + i * 16];
                            rdoq_last_y_tem[11 + i * 16]    <=  rdoq_last_y[12 + i * 16];
                            rdoq_last_y_tem[15 + i * 16]    <=  rdoq_last_y[15 + i * 16];
                        end
                    end
                3'd5    : begin
                        rdoq_last_y_tem[3 ]    <=  rdoq_last_y[4 ];
                        rdoq_last_y_tem[7 ]    <=  rdoq_last_y[8 ];
                        rdoq_last_y_tem[11]    <=  rdoq_last_y[12];
                        rdoq_last_y_tem[15]    <=  rdoq_last_y[16];
                        rdoq_last_y_tem[19]    <=  rdoq_last_y[20];
                        rdoq_last_y_tem[23]    <=  rdoq_last_y[24];
                        rdoq_last_y_tem[27]    <=  rdoq_last_y[28];
                        rdoq_last_y_tem[31]    <=  rdoq_last_y[31];
                    end
                default : begin
                        rdoq_last_y_tem[3 ]    <=  0;
                        rdoq_last_y_tem[7 ]    <=  0;
                        rdoq_last_y_tem[11]    <=  0;
                        rdoq_last_y_tem[15]    <=  0;
                        rdoq_last_y_tem[19]    <=  0;
                        rdoq_last_y_tem[23]    <=  0;
                        rdoq_last_y_tem[27]    <=  0;
                        rdoq_last_y_tem[31]    <=  0;
                    end
            endcase
        end
    end

    //calculate rdoq_last_x and rdoq_last_y
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                rdoq_last_x [i] <= -1;
                rdoq_last_y [i] <= -1;
            end
        end
        else if(column_cnt[0])begin
            for(i = 0; i < 32; i = i + 2)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                            rdoq_last_y[i]      <=      column_cnt          ;
                        end
                        else begin
                            rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                            rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                        end
                    end
                    else begin
                        case(i_height_log2_d1)
                            3'd2: begin
                                rdoq_last_x[i]  <=  i % 4;
                            end
                            3'd3: begin
                                rdoq_last_x[i]  <=  i % 8;
                            end
                            3'd4: begin
                                rdoq_last_x[i]  <=  i % 16;
                            end
                            3'd5: begin
                                rdoq_last_x[i]  <=  i;
                            end
                            default : begin
                                rdoq_last_x[i]  <=  0;
                            end
                        endcase
                        rdoq_last_y[i]      <=      column_cnt  ;
                    end
                end
                else begin
                    rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                    rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                end
            end
            
            //odd rows except the last row of each matrix
            for(j = 0; j < 8; j = j + 1)begin
                for(i = 1; i < 3; i = i + 2)begin
                    if(i_level_opt_d1[i + j * 4])begin
                        if(rdoq_last_y_tem[i + j * 4] != -1)begin
                            if( (tempCost_tem[i + j * 4] + i_base_cost_buffer_tmp_d1[i + j * 4] + i_d64_cost_last_one_d1[i + j * 4] - i_d64_cost_last_zero_d1[i + j * 4]) < (endPosCost_tem[i + j * 4] + rdoqD64LastOne_tem[i + j * 4] - rdoqD64LastZero_tem[i + j * 4]) )begin
                                case(i_height_log2_d1)
                                    3'd2: begin
                                        rdoq_last_x[i + j * 4]      <=      i;
                                    end
                                    3'd3: begin
                                        rdoq_last_x[i + j * 4]      <=      (i + j * 4) % 8;
                                    end
                                    3'd4: begin
                                        rdoq_last_x[i + j * 4]      <=      (i + j * 4) % 16;
                                    end
                                    3'd5: begin
                                        rdoq_last_x[i + j * 4]      <=      i + j * 4;
                                    end
                                    default : begin
                                        rdoq_last_x[i + j * 4]      <=      0;
                                    end
                                endcase
                                rdoq_last_y[i + j * 4]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i + j * 4]      <=      rdoq_last_x_tem[i + j * 4]  ;
                                rdoq_last_y[i + j * 4]      <=      rdoq_last_y_tem[i + j * 4]  ;
                            end
                        end
                        else begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i + j * 4]      <=      i;
                                end
                                3'd3: begin
                                    rdoq_last_x[i + j * 4]      <=      (i + j * 4) % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i + j * 4]      <=      (i + j * 4) % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i + j * 4]      <=      i + j * 4;
                                end
                                default : begin
                                    rdoq_last_x[i + j * 4]      <=      0;
                                end
                            endcase
                            rdoq_last_y[i + j * 4]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i + j * 4]      <=      rdoq_last_x_tem[i + j * 4]  ;
                        rdoq_last_y[i + j * 4]      <=      rdoq_last_y_tem[i + j * 4]  ;
                    end
                end
            end
            //determine the value of the last row 
            case(i_height_log2_d1)
                3'd2    : begin    
                        for(i = 0; i < 8; i = i + 1)begin
                            if(i_level_opt_d1[ 3 + i * 4])begin
                                rdoq_last_x[ 3 + i * 4]    <=  3            ;
                                rdoq_last_y[ 3 + i * 4]    <=  column_cnt   ;
                            end
                            else begin
                                rdoq_last_x[ 3 + i * 4]    <=  -1   ;
                                rdoq_last_y[ 3 + i * 4]    <=  -1   ;
                            end
                        end
                    end
                3'd3    : begin                        
                        for(i = 0; i < 4; i = i + 1)begin
                            if(i_level_opt_d1[ 3 + i * 8])begin
                                if(rdoq_last_y_tem[ 3 + i * 8] != -1)begin
                                    if( (tempCost_tem[ 3 + i * 8] + i_base_cost_buffer_tmp_d1[ 3 + i * 8] + i_d64_cost_last_one_d1[ 3 + i * 8] - i_d64_cost_last_zero_d1[ 3 + i * 8]) < (endPosCost_tem[ 3 + i * 8] + rdoqD64LastOne_tem[ 3 + i * 8] - rdoqD64LastZero_tem[ 3 + i * 8]) )begin
                                        rdoq_last_x[ 3 + i * 8]      <=      3          ;
                                        rdoq_last_y[ 3 + i * 8]      <=      column_cnt ;
                                    end
                                    else begin
                                        rdoq_last_x[ 3 + i * 8]      <=      rdoq_last_x_tem[ 3 + i * 8]  ;
                                        rdoq_last_y[ 3 + i * 8]      <=      rdoq_last_y_tem[ 3 + i * 8]  ;
                                    end
                                end
                                else begin
                                    rdoq_last_x[ 3 + i * 8]      <=      3          ;
                                    rdoq_last_y[ 3 + i * 8]      <=      column_cnt ;
                                end
                            end
                            else begin
                                rdoq_last_x[ 3 + i * 8]      <=      rdoq_last_x_tem[ 3 + i * 8]  ;
                                rdoq_last_y[ 3 + i * 8]      <=      rdoq_last_y_tem[ 3 + i * 8]  ;
                            end

                            if(i_level_opt_d1[ 7 + i * 8])begin
                                rdoq_last_x[ 7 + i * 8]    <=  7            ;
                                rdoq_last_y[ 7 + i * 8]    <=  column_cnt   ;
                            end
                            else begin
                                rdoq_last_x[ 7 + i * 8]    <=  -1   ;
                                rdoq_last_y[ 7 + i * 8]    <=  -1   ;
                            end
                        end
                    end
                3'd4    : begin                        
                    for(i = 0; i < 2; i = i + 1)begin
                            if(i_level_opt_d1[ 3 + 16 * i])begin
                                if(rdoq_last_y_tem[ 3 + 16 * i] != -1)begin
                                    if( (tempCost_tem[ 3 + 16 * i] + i_base_cost_buffer_tmp_d1[ 3 + 16 * i] + i_d64_cost_last_one_d1[ 3 + 16 * i] - i_d64_cost_last_zero_d1[ 3 + 16 * i]) < (endPosCost_tem[ 3 + 16 * i] + rdoqD64LastOne_tem[ 3 + 16 * i] - rdoqD64LastZero_tem[ 3 + 16 * i]) )begin
                                        rdoq_last_x[ 3 + 16 * i]      <=      3             ;
                                        rdoq_last_y[ 3 + 16 * i]      <=      column_cnt    ;
                                    end
                                    else begin
                                        rdoq_last_x[ 3 + 16 * i]      <=      rdoq_last_x_tem[ 3 + 16 * i]  ;
                                        rdoq_last_y[ 3 + 16 * i]      <=      rdoq_last_y_tem[ 3 + 16 * i]  ;
                                    end
                                end
                                else begin
                                    rdoq_last_x[ 3 + 16 * i]      <=      3             ;
                                    rdoq_last_y[ 3 + 16 * i]      <=      column_cnt    ;
                                end
                            end
                            else begin
                                rdoq_last_x[ 3 + 16 * i]      <=      rdoq_last_x_tem[ 3 + 16 * i]  ;
                                rdoq_last_y[ 3 + 16 * i]      <=      rdoq_last_y_tem[ 3 + 16 * i]  ;
                            end

                            if(i_level_opt_d1[ 7 + 16 * i])begin
                                if(rdoq_last_y_tem[ 7 + 16 * i] != -1)begin
                                    if( (tempCost_tem[ 7 + 16 * i] + i_base_cost_buffer_tmp_d1[ 7 + 16 * i] + i_d64_cost_last_one_d1[ 7 + 16 * i] - i_d64_cost_last_zero_d1[ 7 + 16 * i]) < (endPosCost_tem[ 7 + 16 * i] + rdoqD64LastOne_tem[ 7 + 16 * i] - rdoqD64LastZero_tem[ 7 + 16 * i]) )begin
                                        rdoq_last_x[ 7 + 16 * i]      <=      7             ;
                                        rdoq_last_y[ 7 + 16 * i]      <=      column_cnt    ;
                                    end
                                    else begin
                                        rdoq_last_x[ 7 + 16 * i]      <=      rdoq_last_x_tem[ 7 + 16 * i]  ;
                                        rdoq_last_y[ 7 + 16 * i]      <=      rdoq_last_y_tem[ 7 + 16 * i]  ;
                                    end
                                end
                                else begin
                                    rdoq_last_x[ 7 + 16 * i]      <=      7             ;
                                    rdoq_last_y[ 7 + 16 * i]      <=      column_cnt    ;
                                end
                            end
                            else begin
                                rdoq_last_x[ 7 + 16 * i]      <=      rdoq_last_x_tem[ 7 + 16 * i]  ;
                                rdoq_last_y[ 7 + 16 * i]      <=      rdoq_last_y_tem[ 7 + 16 * i]  ;
                            end

                            if(i_level_opt_d1[11 + 16 * i])begin
                                if(rdoq_last_y_tem[11 + 16 * i] != -1)begin
                                    if( (tempCost_tem[11 + 16 * i] + i_base_cost_buffer_tmp_d1[11 + 16 * i] + i_d64_cost_last_one_d1[11 + 16 * i] - i_d64_cost_last_zero_d1[11 + 16 * i]) < (endPosCost_tem[11 + 16 * i] + rdoqD64LastOne_tem[11 + 16 * i] - rdoqD64LastZero_tem[11 + 16 * i]) )begin
                                        rdoq_last_x[11 + 16 * i]      <=    11          ;
                                        rdoq_last_y[11 + 16 * i]      <=    column_cnt  ;
                                    end
                                    else begin
                                        rdoq_last_x[11 + 16 * i]      <=      rdoq_last_x_tem[11 + 16 * i]  ;
                                        rdoq_last_y[11 + 16 * i]      <=      rdoq_last_y_tem[11 + 16 * i]  ;
                                    end
                                end
                                else begin
                                    rdoq_last_x[11 + 16 * i]      <=    11          ;
                                    rdoq_last_y[11 + 16 * i]      <=    column_cnt  ;
                                end
                            end
                            else begin
                                rdoq_last_x[11 + 16 * i]      <=      rdoq_last_x_tem[11 + 16 * i]  ;
                                rdoq_last_y[11 + 16 * i]      <=      rdoq_last_y_tem[11 + 16 * i]  ;
                            end

                            if(i_level_opt_d1[15 + 16 * i])begin
                                rdoq_last_x[15 + 16 * i]    <=  15          ;
                                rdoq_last_y[15 + 16 * i]    <=  column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[15 + 16 * i]    <=  -1   ;
                                rdoq_last_y[15 + 16 * i]    <=  -1   ;
                            end
                        end
                    end
                3'd5    : begin                        
                        if(i_level_opt_d1[ 3])begin
                            if(rdoq_last_y_tem[ 3] != -1)begin
                                if( (tempCost_tem[ 3] + i_base_cost_buffer_tmp_d1[ 3] + i_d64_cost_last_one_d1[ 3] - i_d64_cost_last_zero_d1[ 3]) < (endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - rdoqD64LastZero_tem[ 3]) )begin
                                    rdoq_last_x[ 3]      <=      3           ;
                                    rdoq_last_y[ 3]      <=      column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[ 3]      <=      rdoq_last_x_tem[ 3]  ;
                                    rdoq_last_y[ 3]      <=      rdoq_last_y_tem[ 3]  ;
                                end
                            end
                            else begin
                                rdoq_last_x[ 3]      <=      3           ;
                                rdoq_last_y[ 3]      <=      column_cnt  ;
                            end
                        end
                        else begin
                            rdoq_last_x[ 3]      <=      rdoq_last_x_tem[ 3]  ;
                            rdoq_last_y[ 3]      <=      rdoq_last_y_tem[ 3]  ;
                        end

                        if(i_level_opt_d1[ 7])begin
                            if(rdoq_last_y_tem[ 7] != -1)begin
                                if( (tempCost_tem[ 7] + i_base_cost_buffer_tmp_d1[ 7] + i_d64_cost_last_one_d1[ 7] - i_d64_cost_last_zero_d1[ 7]) < (endPosCost_tem[ 7] + rdoqD64LastOne_tem[ 7] - rdoqD64LastZero_tem[ 7]) )begin
                                    rdoq_last_x[ 7]      <=      7           ;
                                    rdoq_last_y[ 7]      <=      column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[ 7]      <=      rdoq_last_x_tem[ 7]  ;
                                    rdoq_last_y[ 7]      <=      rdoq_last_y_tem[ 7]  ;
                                end
                            end
                            else begin
                                rdoq_last_x[ 7]      <=      7           ;
                                rdoq_last_y[ 7]      <=      column_cnt  ;
                            end
                        end
                        else begin
                            rdoq_last_x[ 7]      <=      rdoq_last_x_tem[ 7]  ;
                            rdoq_last_y[ 7]      <=      rdoq_last_y_tem[ 7]  ;
                        end

                        if(i_level_opt_d1[11])begin
                            if(rdoq_last_y_tem[11] != -1)begin
                                if( (tempCost_tem[11] + i_base_cost_buffer_tmp_d1[11] + i_d64_cost_last_one_d1[11] - i_d64_cost_last_zero_d1[11]) < (endPosCost_tem[11] + rdoqD64LastOne_tem[11] - rdoqD64LastZero_tem[11]) )begin
                                    rdoq_last_x[11]      <=     11          ;
                                    rdoq_last_y[11]      <=     column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[11]      <=      rdoq_last_x_tem[11]  ;
                                    rdoq_last_y[11]      <=      rdoq_last_y_tem[11]  ;
                                end
                            end
                            else begin
                                rdoq_last_x[11]      <=     11          ;
                                rdoq_last_y[11]      <=     column_cnt  ;
                            end
                        end
                        else begin
                            rdoq_last_x[11]      <=      rdoq_last_x_tem[11]  ;
                            rdoq_last_y[11]      <=      rdoq_last_y_tem[11]  ;
                        end

                        if(i_level_opt_d1[15])begin
                            if(rdoq_last_y_tem[15] != -1)begin
                                if( (tempCost_tem[15] + i_base_cost_buffer_tmp_d1[15] + i_d64_cost_last_one_d1[15] - i_d64_cost_last_zero_d1[15]) < (endPosCost_tem[15] + rdoqD64LastOne_tem[15] - rdoqD64LastZero_tem[15]) )begin
                                    rdoq_last_x[15]      <=     15          ;
                                    rdoq_last_y[15]      <=     column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[15]      <=      rdoq_last_x_tem[15]  ;
                                    rdoq_last_y[15]      <=      rdoq_last_y_tem[15]  ;
                                end
                            end
                            else begin
                                rdoq_last_x[15]      <=     15          ;
                                rdoq_last_y[15]      <=     column_cnt  ;
                            end
                        end
                        else begin
                            rdoq_last_x[15]      <=      rdoq_last_x_tem[15]  ;
                            rdoq_last_y[15]      <=      rdoq_last_y_tem[15]  ;
                        end
                        
                        if(i_level_opt_d1[19])begin
                            if(rdoq_last_y_tem[19] != -1)begin
                                if( (tempCost_tem[19] + i_base_cost_buffer_tmp_d1[19] + i_d64_cost_last_one_d1[19] - i_d64_cost_last_zero_d1[19]) < (endPosCost_tem[19] + rdoqD64LastOne_tem[19] - rdoqD64LastZero_tem[19]) )begin
                                    rdoq_last_x[19]      <=     19          ;
                                    rdoq_last_y[19]      <=     column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[19]      <=     rdoq_last_x_tem[19]  ;
                                    rdoq_last_y[19]      <=     rdoq_last_y_tem[19]  ;
                                end
                            end
                            else begin
                                rdoq_last_x[19]      <=     19          ;
                                rdoq_last_y[19]      <=     column_cnt  ;
                            end
                        end
                        else begin
                            rdoq_last_x[19]      <=      rdoq_last_x_tem[19]  ;
                            rdoq_last_y[19]      <=      rdoq_last_y_tem[19]  ;
                        end
                        
                        if(i_level_opt_d1[23])begin
                            if(rdoq_last_y_tem[23] != -1)begin
                                if( (tempCost_tem[23] + i_base_cost_buffer_tmp_d1[23] + i_d64_cost_last_one_d1[23] - i_d64_cost_last_zero_d1[23]) < (endPosCost_tem[23] + rdoqD64LastOne_tem[23] - rdoqD64LastZero_tem[23]) )begin
                                    rdoq_last_x[23]      <=     23          ;
                                    rdoq_last_y[23]      <=     column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[23]      <=      rdoq_last_x_tem[23]  ;
                                    rdoq_last_y[23]      <=      rdoq_last_y_tem[23]  ;
                                end
                            end
                            else begin
                                rdoq_last_x[23]      <=     23          ;
                                rdoq_last_y[23]      <=     column_cnt  ;
                            end
                        end
                        else begin
                            rdoq_last_x[23]      <=      rdoq_last_x_tem[23]  ;
                            rdoq_last_y[23]      <=      rdoq_last_y_tem[23]  ;
                        end
                        
                        if(i_level_opt_d1[27])begin
                            if(rdoq_last_y_tem[27] != -1)begin
                                if( (tempCost_tem[27] + i_base_cost_buffer_tmp_d1[27] + i_d64_cost_last_one_d1[27] - i_d64_cost_last_zero_d1[27]) < (endPosCost_tem[27] + rdoqD64LastOne_tem[27] - rdoqD64LastZero_tem[27]) )begin
                                    rdoq_last_x[27]      <=     27          ;
                                    rdoq_last_y[27]      <=     column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[27]      <=      rdoq_last_x_tem[27]  ;
                                    rdoq_last_y[27]      <=      rdoq_last_y_tem[27]  ;
                                end
                            end
                            else begin
                                rdoq_last_x[27]      <=     27          ;
                                rdoq_last_y[27]      <=     column_cnt  ;
                            end
                        end
                        else begin
                            rdoq_last_x[27]      <=      rdoq_last_x_tem[27]  ;
                            rdoq_last_y[27]      <=      rdoq_last_y_tem[27]  ;
                        end

                        if(i_level_opt_d1[31])begin
                            rdoq_last_x[31]    <=  31           ;
                            rdoq_last_y[31]    <=  column_cnt   ;
                        end
                        else begin
                            rdoq_last_x[31]    <=  -1   ;
                            rdoq_last_y[31]    <=  -1   ;
                        end
                    end
                default : begin
                        rdoq_last_x[ 3]    <=  0;
                        rdoq_last_y[ 3]    <=  0;
                        rdoq_last_x[ 7]    <=  0;
                        rdoq_last_y[ 7]    <=  0;
                        rdoq_last_x[11]    <=  0;
                        rdoq_last_y[11]    <=  0;
                        rdoq_last_x[15]    <=  0;
                        rdoq_last_y[15]    <=  0;
                        rdoq_last_x[19]    <=  0;
                        rdoq_last_y[19]    <=  0;
                        rdoq_last_x[23]    <=  0;
                        rdoq_last_y[23]    <=  0;
                        rdoq_last_x[27]    <=  0;
                        rdoq_last_y[27]    <=  0;
                        rdoq_last_x[31]    <=  0;
                        rdoq_last_y[31]    <=  0;
                    end
            endcase
        end
        else begin
            //the first column
            if(column_cnt == 0)begin
                for(i = 0; i < 32; i = i + 1)begin
                    if(i_level_opt_d1[i])begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                            rdoq_last_y[i]      <=      column_cnt  ;
                    end
                    else begin
                        rdoq_last_x[i]      <=      -1  ;
                        rdoq_last_y[i]      <=      -1  ;
                    end
                end
            end
            else begin
                //even rows
                for(i = 0; i < 32; i = i + 2)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                                case(i_height_log2_d1)
                                    3'd2: begin
                                        rdoq_last_x[i]  <=  i % 4;
                                    end
                                    3'd3: begin
                                        rdoq_last_x[i]  <=  i % 8;
                                    end
                                    3'd4: begin
                                        rdoq_last_x[i]  <=  i % 16;
                                    end
                                    3'd5: begin
                                        rdoq_last_x[i]  <=  i;
                                    end
                                    default : begin
                                        rdoq_last_x[i]  <=  0;
                                    end
                                endcase
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                        rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                    end
                end

                //odd rows except the last row of each matrix
                for(i = 1; i < 3; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                        rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                    end
                end
                for(i = 5; i < 7; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                        rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                    end
                end
                for(i = 9; i < 15; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                        rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                    end
                end            
                for(i = 17; i < 31; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            case(i_height_log2_d1)
                                3'd2: begin
                                    rdoq_last_x[i]  <=  i % 4;
                                end
                                3'd3: begin
                                    rdoq_last_x[i]  <=  i % 8;
                                end
                                3'd4: begin
                                    rdoq_last_x[i]  <=  i % 16;
                                end
                                3'd5: begin
                                    rdoq_last_x[i]  <=  i;
                                end
                                default : begin
                                    rdoq_last_x[i]  <=  0;
                                end
                            endcase
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                        rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                    end
                end
                //determine the value of the last row 
                case(i_height_log2_d1)
                    3'd2    : begin    
                            for(i = 0; i < 8; i = i + 1)begin
                                if(i_level_opt_d1[ 3 + 4 * i])begin
                                    rdoq_last_x[ 3 + 4 * i]    <=  3            ;
                                    rdoq_last_y[ 3 + 4 * i]    <=  column_cnt   ;
                                end
                                else begin
                                    rdoq_last_x[ 3 + 4 * i]    <=  -1   ;
                                    rdoq_last_y[ 3 + 4 * i]    <=  -1   ;
                                end
                            end
                        end
                    3'd3    : begin                            
                            for(i = 0; i < 4; i = i + 1) begin
                                if(i_level_opt_d1[ 3 + 8 * i])begin
                                    if(rdoq_last_y_tem[ 3 + 8 * i] != -1)begin
                                        if(tempCost_tem[ 3 + 8 * i] - endPosCost_tem[ 3 + 8 * i] + rdoqD64LastOne_tem[ 3 + 8 * i] - i_d64_cost_last_one_d1[ 3 + 8 * i] + i_d64_cost_last_zero_d1[ 3 + 8 * i] - rdoqD64LastZero_tem[ 3 + 8 * i] > 0)begin
                                            rdoq_last_x[ 3 + 8 * i]      <=      3              ;
                                            rdoq_last_y[ 3 + 8 * i]      <=      column_cnt     ;
                                        end
                                        else begin
                                            rdoq_last_x[ 3 + 8 * i]      <=      rdoq_last_x_tem[ 3 + 8 * i];
                                            rdoq_last_y[ 3 + 8 * i]      <=      rdoq_last_y_tem[ 3 + 8 * i];
                                        end
                                    end
                                    else begin
                                        rdoq_last_x[ 3 + 8 * i]      <=      3              ;
                                        rdoq_last_y[ 3 + 8 * i]      <=      column_cnt     ;
                                    end
                                end
                                else begin
                                    rdoq_last_x[ 3 + 8 * i]      <=      rdoq_last_x_tem[ 3 + 8 * i];
                                    rdoq_last_y[ 3 + 8 * i]      <=      rdoq_last_y_tem[ 3 + 8 * i];
                                end

                                if(i_level_opt_d1[ 7 + 8 * i])begin
                                    rdoq_last_x[ 7 + 8 * i]    <=  7            ;
                                    rdoq_last_y[ 7 + 8 * i]    <=  column_cnt   ;
                                end
                                else begin
                                    rdoq_last_x[ 7 + 8 * i]    <=  -1   ;
                                    rdoq_last_y[ 7 + 8 * i]    <=  -1   ;
                                end
                            end
                        end
                    3'd4    : begin                            
                            for(i = 0; i < 2; i = i + 1)begin
                                if(i_level_opt_d1[ 3 + i * 16])begin
                                    if(rdoq_last_y_tem[ 3 + i * 16] != -1)begin
                                        if(tempCost_tem[ 3 + i * 16] - endPosCost_tem[ 3 + i * 16] + rdoqD64LastOne_tem[ 3 + i * 16] - i_d64_cost_last_one_d1[ 3 + i * 16] + i_d64_cost_last_zero_d1[ 3 + i * 16] - rdoqD64LastZero_tem[ 3 + i * 16] > 0)begin
                                            rdoq_last_x[ 3 + i * 16]      <=      3             ;
                                            rdoq_last_y[ 3 + i * 16]      <=      column_cnt    ;
                                        end
                                        else begin
                                            rdoq_last_x[ 3 + i * 16]      <=      rdoq_last_x_tem[ 3 + i * 16];
                                            rdoq_last_y[ 3 + i * 16]      <=      rdoq_last_y_tem[ 3 + i * 16];
                                        end
                                    end
                                    else begin
                                        rdoq_last_x[ 3 + i * 16]      <=      3             ;
                                        rdoq_last_y[ 3 + i * 16]      <=      column_cnt    ;
                                    end
                                end
                                else begin
                                    rdoq_last_x[ 3 + i * 16]      <=      rdoq_last_x_tem[ 3 + i * 16];
                                    rdoq_last_y[ 3 + i * 16]      <=      rdoq_last_y_tem[ 3 + i * 16];
                                end
                                
                                if(i_level_opt_d1[ 7 + i * 16])begin
                                    if(rdoq_last_y_tem[ 7 + i * 16] != -1)begin
                                        if(tempCost_tem[ 7 + i * 16] - endPosCost_tem[ 7 + i * 16] + rdoqD64LastOne_tem[ 7 + i * 16] - i_d64_cost_last_one_d1[ 7 + i * 16] + i_d64_cost_last_zero_d1[ 7 + i * 16] - rdoqD64LastZero_tem[ 7 + i * 16] > 0)begin
                                            rdoq_last_x[ 7 + i * 16]      <=      7             ;
                                            rdoq_last_y[ 7 + i * 16]      <=      column_cnt    ;
                                        end
                                        else begin
                                            rdoq_last_x[ 7 + i * 16]      <=      rdoq_last_x_tem[ 7 + i * 16];
                                            rdoq_last_y[ 7 + i * 16]      <=      rdoq_last_y_tem[ 7 + i * 16];
                                        end
                                    end
                                    else begin
                                        rdoq_last_x[ 7 + i * 16]      <=      7             ;
                                        rdoq_last_y[ 7 + i * 16]      <=      column_cnt    ;
                                    end
                                end
                                else begin
                                    rdoq_last_x[ 7 + i * 16]      <=      rdoq_last_x_tem[ 7 + i * 16];
                                    rdoq_last_y[ 7 + i * 16]      <=      rdoq_last_y_tem[ 7 + i * 16];
                                end
                                
                                if(i_level_opt_d1[11 + i * 16])begin
                                    if(rdoq_last_y_tem[11 + i * 16] != -1)begin
                                        if(tempCost_tem[11 + i * 16] - endPosCost_tem[11 + i * 16] + rdoqD64LastOne_tem[11 + i * 16] - i_d64_cost_last_one_d1[11 + i * 16] + i_d64_cost_last_zero_d1[11 + i * 16] - rdoqD64LastZero_tem[11 + i * 16] > 0)begin
                                            rdoq_last_x[11 + i * 16]      <=     11             ;
                                            rdoq_last_y[11 + i * 16]      <=     column_cnt     ;
                                        end
                                        else begin
                                            rdoq_last_x[11 + i * 16]      <=      rdoq_last_x_tem[11 + i * 16];
                                            rdoq_last_y[11 + i * 16]      <=      rdoq_last_y_tem[11 + i * 16];
                                        end
                                    end
                                    else begin
                                        rdoq_last_x[11 + i * 16]      <=     11             ;
                                        rdoq_last_y[11 + i * 16]      <=     column_cnt     ;
                                    end
                                end
                                else begin
                                    rdoq_last_x[11 + i * 16]      <=      rdoq_last_x_tem[11 + i * 16];
                                    rdoq_last_y[11 + i * 16]      <=      rdoq_last_y_tem[11 + i * 16];
                                end

                                if(i_level_opt_d1[15 + i * 16])begin
                                    rdoq_last_x[15 + i * 16]    <=  15              ;
                                    rdoq_last_y[15 + i * 16]    <=  column_cnt      ;
                                end
                                else begin
                                    rdoq_last_x[15 + i * 16]    <=  -1   ;
                                    rdoq_last_y[15 + i * 16]    <=  -1   ;
                                end
                            end
                        end
                    3'd5    : begin
                            if(i_level_opt_d1[ 3])begin
                                if(rdoq_last_y_tem[ 3] != -1)begin
                                    if(tempCost_tem[ 3] - endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - i_d64_cost_last_one_d1[ 3] + i_d64_cost_last_zero_d1[ 3] - rdoqD64LastZero_tem[ 3] > 0)begin
                                        rdoq_last_x[ 3]      <=      3           ;
                                        rdoq_last_y[ 3]      <=      column_cnt  ;
                                    end
                                    else begin
                                        rdoq_last_x[ 3]      <=      rdoq_last_x_tem[ 3];
                                        rdoq_last_y[ 3]      <=      rdoq_last_y_tem[ 3];
                                    end
                                end
                                else begin
                                    rdoq_last_x[ 3]      <=      3           ;
                                    rdoq_last_y[ 3]      <=      column_cnt  ;
                                end
                            end
                            else begin
                                rdoq_last_x[ 3]      <=      rdoq_last_x_tem[ 3];
                                rdoq_last_y[ 3]      <=      rdoq_last_y_tem[ 3];
                            end

                            if(i_level_opt_d1[ 7])begin
                                if(rdoq_last_y_tem[ 7] != -1)begin
                                    if(tempCost_tem[ 7] - endPosCost_tem[ 7] + rdoqD64LastOne_tem[ 7] - i_d64_cost_last_one_d1[ 7] + i_d64_cost_last_zero_d1[ 7] - rdoqD64LastZero_tem[ 7] > 0)begin
                                        rdoq_last_x[ 7]      <=      7           ;
                                        rdoq_last_y[ 7]      <=      column_cnt  ;
                                    end
                                    else begin
                                        rdoq_last_x[ 7]      <=      rdoq_last_x_tem[ 7];
                                        rdoq_last_y[ 7]      <=      rdoq_last_y_tem[ 7];
                                    end
                                end
                                else begin
                                    rdoq_last_x[ 7]      <=      7           ;
                                    rdoq_last_y[ 7]      <=      column_cnt  ;
                                end
                            end
                            else begin
                                rdoq_last_x[ 7]      <=      rdoq_last_x_tem[ 7];
                                rdoq_last_y[ 7]      <=      rdoq_last_y_tem[ 7];
                            end
                            
                            if(i_level_opt_d1[11])begin
                                if(rdoq_last_y_tem[11] != -1)begin
                                    if(tempCost_tem[11] - endPosCost_tem[11] + rdoqD64LastOne_tem[11] - i_d64_cost_last_one_d1[11] + i_d64_cost_last_zero_d1[11] - rdoqD64LastZero_tem[11] > 0)begin
                                        rdoq_last_x[11]      <=     11          ;
                                        rdoq_last_y[11]      <=     column_cnt  ;
                                    end
                                    else begin
                                        rdoq_last_x[11]      <=      rdoq_last_x_tem[11];
                                        rdoq_last_y[11]      <=      rdoq_last_y_tem[11];
                                    end
                                end
                                else begin
                                    rdoq_last_x[11]      <=     11          ;
                                    rdoq_last_y[11]      <=     column_cnt  ;
                                end
                            end
                            else begin
                                rdoq_last_x[11]      <=      rdoq_last_x_tem[11];
                                rdoq_last_y[11]      <=      rdoq_last_y_tem[11];
                            end

                            if(i_level_opt_d1[15])begin
                                if(rdoq_last_y_tem[15] != -1)begin
                                    if(tempCost_tem[15] - endPosCost_tem[15] + rdoqD64LastOne_tem[15] - i_d64_cost_last_one_d1[15] + i_d64_cost_last_zero_d1[15] - rdoqD64LastZero_tem[15] > 0)begin
                                        rdoq_last_x[15]      <=     15           ;
                                        rdoq_last_y[15]      <=      column_cnt  ;
                                    end
                                    else begin
                                        rdoq_last_x[15]      <=      rdoq_last_x_tem[15];
                                        rdoq_last_y[15]      <=      rdoq_last_y_tem[15];
                                    end
                                end
                                else begin
                                    rdoq_last_x[15]      <=     15           ;
                                    rdoq_last_y[15]      <=      column_cnt  ;
                                end
                            end
                            else begin
                                rdoq_last_x[15]      <=      rdoq_last_x_tem[15];
                                rdoq_last_y[15]      <=      rdoq_last_y_tem[15];
                            end

                            if(i_level_opt_d1[19])begin
                                if(rdoq_last_y_tem[19] != -1)begin
                                    if(tempCost_tem[19] - endPosCost_tem[19] + rdoqD64LastOne_tem[19] - i_d64_cost_last_one_d1[19] + i_d64_cost_last_zero_d1[19] - rdoqD64LastZero_tem[19] > 0)begin
                                        rdoq_last_x[19]      <=     19           ;
                                        rdoq_last_y[19]      <=      column_cnt  ;
                                    end
                                    else begin
                                        rdoq_last_x[19]      <=      rdoq_last_x_tem[19];
                                        rdoq_last_y[19]      <=      rdoq_last_y_tem[19];
                                    end
                                end
                                else begin
                                    rdoq_last_x[19]      <=     19           ;
                                    rdoq_last_y[19]      <=      column_cnt  ;
                                end
                            end
                            else begin
                                rdoq_last_x[19]      <=      rdoq_last_x_tem[19];
                                rdoq_last_y[19]      <=      rdoq_last_y_tem[19];
                            end

                            if(i_level_opt_d1[23])begin
                                if(rdoq_last_y_tem[23] != -1)begin
                                    if(tempCost_tem[23] - endPosCost_tem[23] + rdoqD64LastOne_tem[23] - i_d64_cost_last_one_d1[23] + i_d64_cost_last_zero_d1[23] - rdoqD64LastZero_tem[23] > 0)begin
                                        rdoq_last_x[23]      <=     23           ;
                                        rdoq_last_y[23]      <=      column_cnt  ;
                                    end
                                    else begin
                                        rdoq_last_x[23]      <=      rdoq_last_x_tem[23];
                                        rdoq_last_y[23]      <=      rdoq_last_y_tem[23];
                                    end
                                end
                                else begin
                                    rdoq_last_x[23]      <=     23           ;
                                    rdoq_last_y[23]      <=      column_cnt  ;
                                end
                            end
                            else begin
                                rdoq_last_x[23]      <=      rdoq_last_x_tem[23];
                                rdoq_last_y[23]      <=      rdoq_last_y_tem[23];
                            end

                            if(i_level_opt_d1[27])begin
                                if(rdoq_last_y_tem[27] != -1)begin
                                    if(tempCost_tem[27] - endPosCost_tem[27] + rdoqD64LastOne_tem[27] - i_d64_cost_last_one_d1[27] + i_d64_cost_last_zero_d1[27] - rdoqD64LastZero_tem[27] > 0)begin
                                        rdoq_last_x[27]      <=     27           ;
                                        rdoq_last_y[27]      <=      column_cnt  ;
                                    end
                                    else begin
                                        rdoq_last_x[27]      <=      rdoq_last_x_tem[27];
                                        rdoq_last_y[27]      <=      rdoq_last_y_tem[27];
                                    end
                                end
                                else begin
                                    rdoq_last_x[27]      <=     27           ;
                                    rdoq_last_y[27]      <=      column_cnt  ;
                                end
                            end
                            else begin
                                rdoq_last_x[27]      <=      rdoq_last_x_tem[27];
                                rdoq_last_y[27]      <=      rdoq_last_y_tem[27];
                            end

                            if(i_level_opt_d1[31])begin
                                rdoq_last_x[31]    <=  31           ;
                                rdoq_last_y[31]    <=  column_cnt   ;
                            end
                            else begin
                                rdoq_last_x[31]    <=  -1   ;
                                rdoq_last_y[31]    <=  -1   ;
                            end
                        end
                    default : begin
                            rdoq_last_x[ 3]    <=  0;
                            rdoq_last_y[ 3]    <=  0;
                            rdoq_last_x[ 7]    <=  0;
                            rdoq_last_y[ 7]    <=  0;
                            rdoq_last_x[11]    <=  0;
                            rdoq_last_y[11]    <=  0;
                            rdoq_last_x[15]    <=  0;
                            rdoq_last_y[15]    <=  0;
                            rdoq_last_x[19]    <=  0;
                            rdoq_last_y[19]    <=  0;
                            rdoq_last_x[23]    <=  0;
                            rdoq_last_y[23]    <=  0;
                            rdoq_last_x[27]    <=  0;
                            rdoq_last_y[27]    <=  0;
                            rdoq_last_x[31]    <=  0;
                            rdoq_last_y[31]    <=  0;
                        end
                endcase
            end
        end
    end


    //do shift operation to the former endPosCost
    always@(*)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                endPosCost_tem[i]     <=   0;   
            end
        end
        else begin
            for(j = 0; j < 8; j = j + 1)begin
                for(i = 0 ; i < 3 ; i = i + 1)begin
                    endPosCost_tem[i + j * 4]     <=   endPosCost[i + 1 + j * 4];   
                end
            end

            case(i_height_log2_d2)
                3'd2    : begin    
                        for(i = 0; i < 8; i = i + 1)begin
                            endPosCost_tem[3 + i * 4]    <=  endPosCost[3 + i * 4];
                        end
                    end
                    3'd3    : begin
                        for(i = 0; i < 4; i = i + 1)begin
                            endPosCost_tem[3 + i * 8]    <=  endPosCost[4 + i * 8];
                            endPosCost_tem[7 + i * 8]    <=  endPosCost[7 + i * 8];
                        end
                    end
                3'd4    : begin
                        for(i = 0; i < 2; i = i + 1)begin
                            endPosCost_tem[3  + i * 16]    <=  endPosCost[4  + i * 16];
                            endPosCost_tem[7  + i * 16]    <=  endPosCost[8  + i * 16];
                            endPosCost_tem[11 + i * 16]    <=  endPosCost[12 + i * 16];
                            endPosCost_tem[15 + i * 16]    <=  endPosCost[15 + i * 16];
                        end
                    end
                3'd5    : begin
                        endPosCost_tem[3 ]    <=  endPosCost[4 ];
                        endPosCost_tem[7 ]    <=  endPosCost[8 ];
                        endPosCost_tem[11]    <=  endPosCost[12];
                        endPosCost_tem[15]    <=  endPosCost[16];
                        endPosCost_tem[19]    <=  endPosCost[20];
                        endPosCost_tem[23]    <=  endPosCost[24];
                        endPosCost_tem[27]    <=  endPosCost[28];
                        endPosCost_tem[31]    <=  endPosCost[31];
                    end
                default : begin
                        endPosCost_tem[3 ]    <=  0;
                        endPosCost_tem[7 ]    <=  0;
                        endPosCost_tem[11]    <=  0;
                        endPosCost_tem[15]    <=  0;
                        endPosCost_tem[19]    <=  0;
                        endPosCost_tem[23]    <=  0;
                        endPosCost_tem[27]    <=  0;
                        endPosCost_tem[31]    <=  0;
                    end
            endcase
        end
    end


    //calculate endPosCost
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin 
                endPosCost[i]   <=  0;
            end
        end
        else if(column_cnt[0])begin//odd columns
            for(i = 0; i < 32; i = i + 2)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                            endPosCost[i]       <=      tempCost_tem[i];
                        end
                        else begin
                            endPosCost[i]       <=      endPosCost_tem[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      tempCost_tem[i];
                    end
                end
                else begin
                    endPosCost[i]       <=      endPosCost_tem[i];
                end
            end

            //odd rows except the last row of each matrix
            for(i = 1; i < 3; i = i + 4)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                        end
                        else begin
                            endPosCost[i]       <=      endPosCost_tem[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                    end
                end
                else begin
                    endPosCost[i]       <=      endPosCost_tem[i];
                end
            end
            for(i = 5; i < 7; i = i + 4)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                        end
                        else begin
                            endPosCost[i]       <=      endPosCost_tem[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                    end
                end
                else begin
                    endPosCost[i]       <=      endPosCost_tem[i];
                end
            end
            for(i = 9; i < 15; i = i + 4)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                        end
                        else begin
                            endPosCost[i]       <=      endPosCost_tem[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                    end
                end
                else begin
                    endPosCost[i]       <=      endPosCost_tem[i];
                end
            end            
            for(i = 17; i < 31; i = i + 4)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                        end
                        else begin
                            endPosCost[i]       <=      endPosCost_tem[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                    end
                end
                else begin
                    endPosCost[i]       <=      endPosCost_tem[i];
                end
            end
            //determine the value of the last row 
            case(i_height_log2_d1)
                3'd2    : begin    
                        for(i = 0; i < 8; i = i + 1)begin
                            endPosCost[ 3 + i * 4]      <=      i_level_opt_d1[ 3 + i * 4] != 0 ? i_base_cost_buffer_tmp_d1[ 3 + i * 4] : 0;
                        end
                    end
                3'd3    : begin
                        for(i = 0; i < 4; i = i + 1)begin
                            if(i_level_opt_d1[ 3 + i * 8])begin
                                if(rdoq_last_y_tem[ 3 + i * 8] != -1)begin
                                    if( (tempCost_tem[ 3 + i * 8] + i_base_cost_buffer_tmp_d1[ 3 + i * 8] + i_d64_cost_last_one_d1[ 3 + i * 8] - i_d64_cost_last_zero_d1[ 3 + i * 8]) < (endPosCost_tem[ 3 + i * 8] + rdoqD64LastOne_tem[ 3 + i * 8] - rdoqD64LastZero_tem[ 3 + i * 8]) )begin
                                        endPosCost[ 3 + i * 8]       <=      tempCost_tem[ 3 + i * 8] + i_base_cost_buffer_tmp_d1[ 3 + i * 8];
                                    end
                                    else begin
                                        endPosCost[ 3 + i * 8]       <=      endPosCost_tem[ 3 + i * 8];
                                    end
                                end
                                else begin
                                    endPosCost[ 3 + i * 8]       <=      tempCost_tem[ 3 + i * 8] + i_base_cost_buffer_tmp_d1[ 3 + i * 8];
                                end
                            end
                            else begin
                                endPosCost[ 3 + i * 8]       <=      endPosCost_tem[ 3 + i * 8];
                            end
                            endPosCost[ 7 + i * 8]      <=      i_level_opt_d1[ 7 + i * 8] != 0 ? i_base_cost_buffer_tmp_d1[ 7 + i * 8] : 0;
                        end
                    end
                3'd4    : begin                    
                        for(i = 0; i < 2; i = i + 1)begin
                            if(i_level_opt_d1[ 3 + i * 16])begin
                                if(rdoq_last_y_tem[ 3 + i * 16] != -1)begin
                                    if( (tempCost_tem[ 3 + i * 16] + i_base_cost_buffer_tmp_d1[ 3 + i * 16] + i_d64_cost_last_one_d1[ 3 + i * 16] - i_d64_cost_last_zero_d1[ 3 + i * 16]) < (endPosCost_tem[ 3 + i * 16] + rdoqD64LastOne_tem[ 3 + i * 16] - rdoqD64LastZero_tem[ 3 + i * 16]) )begin
                                        endPosCost[ 3 + i * 16]       <=      tempCost_tem[ 3 + i * 16] + i_base_cost_buffer_tmp_d1[ 3 + i * 16];
                                    end
                                    else begin
                                        endPosCost[ 3 + i * 16]       <=      endPosCost_tem[ 3 + i * 16];
                                    end
                                end
                                else begin
                                    endPosCost[ 3 + i * 16]       <=      tempCost_tem[ 3 + i * 16] + i_base_cost_buffer_tmp_d1[ 3 + i * 16];
                                end
                            end
                            else begin
                                endPosCost[ 3 + i * 16]       <=      endPosCost_tem[ 3 + i * 16];
                            end

                            if(i_level_opt_d1[ 7 + i * 16])begin
                                if(rdoq_last_y_tem[ 7 + i * 16] != -1)begin
                                    if( (tempCost_tem[ 7 + i * 16] + i_base_cost_buffer_tmp_d1[ 7 + i * 16] + i_d64_cost_last_one_d1[ 7 + i * 16] - i_d64_cost_last_zero_d1[ 7 + i * 16]) < (endPosCost_tem[ 7 + i * 16] + rdoqD64LastOne_tem[ 7 + i * 16] - rdoqD64LastZero_tem[ 7 + i * 16]) )begin
                                        endPosCost[ 7 + i * 16]       <=      tempCost_tem[ 7 + i * 16] + i_base_cost_buffer_tmp_d1[ 7 + i * 16];
                                    end
                                    else begin
                                        endPosCost[ 7 + i * 16]       <=      endPosCost_tem[ 7 + i * 16];
                                    end
                                end
                                else begin
                                    endPosCost[ 7 + i * 16]       <=      tempCost_tem[ 7 + i * 16] + i_base_cost_buffer_tmp_d1[ 7 + i * 16];
                                end
                            end
                            else begin
                                endPosCost[ 7 + i * 16]       <=      endPosCost_tem[ 7 + i * 16];
                            end
                            
                            if(i_level_opt_d1[11 + i * 16])begin
                                if(rdoq_last_y_tem[11 + i * 16] != -1)begin
                                    if( (tempCost_tem[11 + i * 16] + i_base_cost_buffer_tmp_d1[11 + i * 16] + i_d64_cost_last_one_d1[11 + i * 16] - i_d64_cost_last_zero_d1[11 + i * 16]) < (endPosCost_tem[11 + i * 16] + rdoqD64LastOne_tem[11 + i * 16] - rdoqD64LastZero_tem[11 + i * 16]) )begin
                                        endPosCost[11 + i * 16]       <=      tempCost_tem[11 + i * 16] + i_base_cost_buffer_tmp_d1[11 + i * 16];
                                    end
                                    else begin
                                        endPosCost[11 + i * 16]       <=      endPosCost_tem[11 + i * 16];
                                    end
                                end
                                else begin
                                    endPosCost[11 + i * 16]       <=      tempCost_tem[11 + i * 16] + i_base_cost_buffer_tmp_d1[11 + i * 16];
                                end
                            end
                            else begin
                                endPosCost[11 + i * 16]       <=      endPosCost_tem[11 + i * 16];
                            end

                            
                            endPosCost[15 + i * 16]      <=      i_level_opt_d1[15 + i * 16] != 0 ? i_base_cost_buffer_tmp_d1[15 + i * 16] : 0;
                        end
                    end
                3'd5    : begin
                        if(i_level_opt_d1[ 3])begin
                            if(rdoq_last_y_tem[ 3] != -1)begin
                                if( (tempCost_tem[ 3] + i_base_cost_buffer_tmp_d1[ 3] + i_d64_cost_last_one_d1[ 3] - i_d64_cost_last_zero_d1[ 3]) < (endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - rdoqD64LastZero_tem[ 3]) )begin
                                    endPosCost[ 3]       <=      tempCost_tem[ 3] + i_base_cost_buffer_tmp_d1[ 3];
                                end
                                else begin
                                    endPosCost[ 3]       <=      endPosCost_tem[ 3];
                                end
                            end
                            else begin
                                endPosCost[ 3]       <=      tempCost_tem[ 3] + i_base_cost_buffer_tmp_d1[ 3];
                            end
                        end
                        else begin
                            endPosCost[ 3]       <=      endPosCost_tem[ 3];
                        end

                        if(i_level_opt_d1[ 7])begin
                            if(rdoq_last_y_tem[ 7] != -1)begin
                                if( (tempCost_tem[ 7] + i_base_cost_buffer_tmp_d1[ 7] + i_d64_cost_last_one_d1[ 7] - i_d64_cost_last_zero_d1[ 7]) < (endPosCost_tem[ 7] + rdoqD64LastOne_tem[ 7] - rdoqD64LastZero_tem[ 7]) )begin
                                    endPosCost[ 7]       <=      tempCost_tem[ 7] + i_base_cost_buffer_tmp_d1[ 7];
                                end
                                else begin
                                    endPosCost[ 7]       <=      endPosCost_tem[ 7];
                                end
                            end
                            else begin
                                endPosCost[ 7]       <=      tempCost_tem[ 7] + i_base_cost_buffer_tmp_d1[ 7];
                            end
                        end
                        else begin
                            endPosCost[ 7]       <=      endPosCost_tem[ 7];
                        end
                        
                        if(i_level_opt_d1[11])begin
                            if(rdoq_last_y_tem[11] != -1)begin
                                if( (tempCost_tem[11] + i_base_cost_buffer_tmp_d1[11] + i_d64_cost_last_one_d1[11] - i_d64_cost_last_zero_d1[11]) < (endPosCost_tem[11] + rdoqD64LastOne_tem[11] - rdoqD64LastZero_tem[11]) )begin
                                    endPosCost[11]       <=      tempCost_tem[11] + i_base_cost_buffer_tmp_d1[11];
                                end
                                else begin
                                    endPosCost[11]       <=      endPosCost_tem[11];
                                end
                            end
                            else begin
                                endPosCost[11]       <=      tempCost_tem[11] + i_base_cost_buffer_tmp_d1[11];
                            end
                        end
                        else begin
                            endPosCost[11]       <=      endPosCost_tem[11];
                        end

                        if(i_level_opt_d1[15])begin
                            if(rdoq_last_y_tem[15] != -1)begin
                                if( (tempCost_tem[15] + i_base_cost_buffer_tmp_d1[15] + i_d64_cost_last_one_d1[15] - i_d64_cost_last_zero_d1[15]) < (endPosCost_tem[15] + rdoqD64LastOne_tem[15] - rdoqD64LastZero_tem[15]) )begin
                                    endPosCost[15]       <=      tempCost_tem[15] + i_base_cost_buffer_tmp_d1[15];
                                end
                                else begin
                                    endPosCost[15]       <=      endPosCost_tem[15];
                                end
                            end
                            else begin
                                endPosCost[15]       <=      tempCost_tem[15] + i_base_cost_buffer_tmp_d1[15];
                            end
                        end
                        else begin
                            endPosCost[15]       <=      endPosCost_tem[15];
                        end
                        
                        if(i_level_opt_d1[19])begin
                            if(rdoq_last_y_tem[19] != -1)begin
                                if( (tempCost_tem[19] + i_base_cost_buffer_tmp_d1[19] + i_d64_cost_last_one_d1[19] - i_d64_cost_last_zero_d1[19]) < (endPosCost_tem[19] + rdoqD64LastOne_tem[19] - rdoqD64LastZero_tem[19]) )begin
                                    endPosCost[19]       <=      tempCost_tem[19] + i_base_cost_buffer_tmp_d1[19];
                                end
                                else begin
                                    endPosCost[19]       <=      endPosCost_tem[19];
                                end
                            end
                            else begin
                                endPosCost[19]       <=      tempCost_tem[19] + i_base_cost_buffer_tmp_d1[19];
                            end
                        end
                        else begin
                            endPosCost[19]       <=      endPosCost_tem[19];
                        end
                        
                        if(i_level_opt_d1[23])begin
                            if(rdoq_last_y_tem[23] != -1)begin
                                if( (tempCost_tem[23] + i_base_cost_buffer_tmp_d1[23] + i_d64_cost_last_one_d1[23] - i_d64_cost_last_zero_d1[23]) < (endPosCost_tem[23] + rdoqD64LastOne_tem[23] - rdoqD64LastZero_tem[23]) )begin
                                    endPosCost[23]       <=      tempCost_tem[23] + i_base_cost_buffer_tmp_d1[23];
                                end
                                else begin
                                    endPosCost[23]       <=      endPosCost_tem[23];
                                end
                            end
                            else begin
                                endPosCost[23]       <=      tempCost_tem[23] + i_base_cost_buffer_tmp_d1[23];
                            end
                        end
                        else begin
                            endPosCost[23]       <=      endPosCost_tem[23];
                        end
                        
                        if(i_level_opt_d1[27])begin
                            if(rdoq_last_y_tem[27] != -1)begin
                                if( (tempCost_tem[27] + i_base_cost_buffer_tmp_d1[27] + i_d64_cost_last_one_d1[27] - i_d64_cost_last_zero_d1[27]) < (endPosCost_tem[27] + rdoqD64LastOne_tem[27] - rdoqD64LastZero_tem[27]) )begin
                                    endPosCost[27]       <=      tempCost_tem[27] + i_base_cost_buffer_tmp_d1[27];
                                end
                                else begin
                                    endPosCost[27]       <=      endPosCost_tem[27];
                                end
                            end
                            else begin
                                endPosCost[27]       <=      tempCost_tem[27] + i_base_cost_buffer_tmp_d1[27];
                            end
                        end
                        else begin
                            endPosCost[27]       <=      endPosCost_tem[27];
                        end

                        endPosCost[31]      <=      i_level_opt_d1[31] != 0 ? i_base_cost_buffer_tmp_d1[31] : 0;
                    end
                default : begin
                        endPosCost[ 3]      <=      0;
                        endPosCost[ 7]      <=      0;
                        endPosCost[11]      <=      0;
                        endPosCost[15]      <=      0;
                        endPosCost[19]      <=      0;
                        endPosCost[23]      <=      0;
                        endPosCost[27]      <=      0;
                        endPosCost[31]      <=      0;
                    end
            endcase
        end
        else begin//even columns
            //the first column
            if(column_cnt == 0)begin
                for(i = 0; i < 32; i = i + 2)begin
                    endPosCost[i]       <=      i_level_opt_d1[i] != 0 ? i_base_cost_buffer_tmp_d1[i] : 0;
                end
                for(i = 1; i < 32; i = i + 2)begin
                    endPosCost[i]       <=      i_level_opt_d1[i] == 0 ? i_base_cost_buffer_tmp_d1[i] : 0;
                end
            end
            else begin
                //even rows
                for(i = 0; i < 32; i = i + 2)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                                endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                            end
                            else begin
                                endPosCost[i]       <=      endPosCost_tem[i];
                            end
                        end
                        else begin
                            endPosCost[i]       <=      tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      endPosCost_tem[i];
                    end
                end

                //odd rows except the last row of each matrix
                for(i = 1; i < 3; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                endPosCost[i]       <=      tempCost_tem[i];
                            end
                            else begin
                                endPosCost[i]       <=      endPosCost_tem[i];
                            end
                        end
                        else begin
                            endPosCost[i]       <=      tempCost_tem[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      endPosCost_tem[i];
                    end
                end
                for(i = 5; i < 7; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                endPosCost[i]       <=      tempCost_tem[i];
                            end
                            else begin
                                endPosCost[i]       <=      endPosCost_tem[i];
                            end
                        end
                        else begin
                            endPosCost[i]       <=      tempCost_tem[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      endPosCost_tem[i];
                    end
                end
                for(i = 9; i < 15; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                endPosCost[i]       <=      tempCost_tem[i];
                            end
                            else begin
                                endPosCost[i]       <=      endPosCost_tem[i];
                            end
                        end
                        else begin
                            endPosCost[i]       <=      tempCost_tem[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      endPosCost_tem[i];
                    end
                end            
                for(i = 17; i < 31; i = i + 4)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                endPosCost[i]       <=      tempCost_tem[i];
                            end
                            else begin
                                endPosCost[i]       <=      endPosCost_tem[i];
                            end
                        end
                        else begin
                            endPosCost[i]       <=      tempCost_tem[i];
                        end
                    end
                    else begin
                        endPosCost[i]       <=      endPosCost_tem[i];
                    end
                end
                //determine the value of the last row 
                case(i_height_log2_d1)
                    3'd2    : begin    
                            for(i = 0; i < 8; i = i + 1)begin
                                endPosCost[ 3 + i * 4]      <=      i_level_opt_d1[ 3 + i * 4] == 0 ? i_base_cost_buffer_tmp_d1[ 3 + i * 4] : 0;
                            end
                        end
                    3'd3    : begin
                            for(i = 0; i < 4; i = i + 1)begin
                                if(i_level_opt_d1[ 3 + i * 8])begin
                                    if(rdoq_last_y_tem[ 3 + i * 8] != -1)begin
                                        if(tempCost_tem[ 3 + i * 8] - endPosCost_tem[ 3 + i * 8] + rdoqD64LastOne_tem[ 3 + i * 8] - i_d64_cost_last_one_d1[ 3 + i * 8] + i_d64_cost_last_zero_d1[ 3 + i * 8] - rdoqD64LastZero_tem[ 3 + i * 8] > 0)begin
                                            endPosCost[ 3 + i * 8]       <=      tempCost_tem[ 3 + i * 8];
                                        end
                                        else begin
                                            endPosCost[ 3 + i * 8]       <=      endPosCost_tem[ 3 + i * 8];
                                        end
                                    end
                                    else begin
                                        endPosCost[ 3 + i * 8]       <=      tempCost_tem[ 3 + i * 8];
                                    end
                                end
                                else begin
                                    endPosCost[ 3 + i * 8]       <=      endPosCost_tem[ 3 + i * 8];
                                end

                                endPosCost[ 7 + i * 8]      <=      i_level_opt_d1[ 7 + i * 8] == 0 ? i_base_cost_buffer_tmp_d1[ 7 + i * 8] : 0;
                            end
                        end
                    3'd4    : begin                            
                            for(i = 0; i < 2; i = i + 1)begin
                                if(i_level_opt_d1[ 3 + i * 16])begin
                                    if(rdoq_last_y_tem[ 3 + i * 16] != -1)begin
                                        if(tempCost_tem[ 3 + i * 16] - endPosCost_tem[ 3 + i * 16] + rdoqD64LastOne_tem[ 3 + i * 16] - i_d64_cost_last_one_d1[ 3 + i * 16] + i_d64_cost_last_zero_d1[ 3 + i * 16] - rdoqD64LastZero_tem[ 3 + i * 16] > 0)begin
                                            endPosCost[ 3 + i * 16]       <=      tempCost_tem[ 3 + i * 16];
                                        end
                                        else begin
                                            endPosCost[ 3 + i * 16]       <=      endPosCost_tem[ 3 + i * 16];
                                        end
                                    end
                                    else begin
                                        endPosCost[ 3 + i * 16]       <=      tempCost_tem[ 3 + i * 16];
                                    end
                                end
                                else begin
                                    endPosCost[ 3 + i * 16]       <=      endPosCost_tem[ 3 + i * 16];
                                end

                                if(i_level_opt_d1[ 7 + i * 16])begin
                                    if(rdoq_last_y_tem[ 7 + i * 16] != -1)begin
                                        if(tempCost_tem[ 7 + i * 16] - endPosCost_tem[ 7 + i * 16] + rdoqD64LastOne_tem[ 7 + i * 16] - i_d64_cost_last_one_d1[ 7 + i * 16] + i_d64_cost_last_zero_d1[ 7 + i * 16] - rdoqD64LastZero_tem[ 7 + i * 16] > 0)begin
                                            endPosCost[ 7 + i * 16]       <=      tempCost_tem[ 7 + i * 16];
                                        end
                                        else begin
                                            endPosCost[ 7 + i * 16]       <=      endPosCost_tem[ 7 + i * 16];
                                        end
                                    end
                                    else begin
                                        endPosCost[ 7 + i * 16]       <=      tempCost_tem[ 7 + i * 16];
                                    end
                                end
                                else begin
                                    endPosCost[ 7 + i * 16]       <=      endPosCost_tem[ 7 + i * 16];
                                end

                                if(i_level_opt_d1[11+ i * 16])begin
                                    if(rdoq_last_y_tem[11+ i * 16] != -1)begin
                                        if(tempCost_tem[11+ i * 16] - endPosCost_tem[11+ i * 16] + rdoqD64LastOne_tem[11+ i * 16] - i_d64_cost_last_one_d1[11+ i * 16] + i_d64_cost_last_zero_d1[11+ i * 16] - rdoqD64LastZero_tem[11+ i * 16] > 0)begin
                                            endPosCost[11+ i * 16]       <=      tempCost_tem[11+ i * 16];
                                        end
                                        else begin
                                            endPosCost[11+ i * 16]       <=      endPosCost_tem[11+ i * 16];
                                        end
                                    end
                                    else begin
                                        endPosCost[11+ i * 16]       <=      tempCost_tem[11+ i * 16];
                                    end
                                end
                                else begin
                                    endPosCost[11+ i * 16]       <=      endPosCost_tem[11+ i * 16];
                                end

                                endPosCost[15 + i * 16]      <=      i_level_opt_d1[15 + i * 16] == 0 ? i_base_cost_buffer_tmp_d1[15 + i * 16] : 0;
                            end
                        end
                    3'd5    : begin
                            if(i_level_opt_d1[ 3])begin
                                if(rdoq_last_y_tem[ 3] != -1)begin
                                    if(tempCost_tem[ 3] - endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - i_d64_cost_last_one_d1[ 3] + i_d64_cost_last_zero_d1[ 3] - rdoqD64LastZero_tem[ 3] > 0)begin
                                        endPosCost[ 3]       <=      tempCost_tem[ 3];
                                    end
                                    else begin
                                        endPosCost[ 3]       <=      endPosCost_tem[ 3];
                                    end
                                end
                                else begin
                                    endPosCost[ 3]       <=      tempCost_tem[ 3];
                                end
                            end
                            else begin
                                endPosCost[ 3]       <=      endPosCost_tem[ 3];
                            end

                            if(i_level_opt_d1[ 7])begin
                                if(rdoq_last_y_tem[ 7] != -1)begin
                                    if(tempCost_tem[ 7] - endPosCost_tem[ 7] + rdoqD64LastOne_tem[ 7] - i_d64_cost_last_one_d1[ 7] + i_d64_cost_last_zero_d1[ 7] - rdoqD64LastZero_tem[ 7] > 0)begin
                                        endPosCost[ 7]       <=      tempCost_tem[ 7];
                                    end
                                    else begin
                                        endPosCost[ 7]       <=      endPosCost_tem[ 7];
                                    end
                                end
                                else begin
                                    endPosCost[ 7]       <=      tempCost_tem[ 7];
                                end
                            end
                            else begin
                                endPosCost[ 7]       <=      endPosCost_tem[ 7];
                            end

                            if(i_level_opt_d1[11])begin
                                if(rdoq_last_y_tem[11] != -1)begin
                                    if(tempCost_tem[11] - endPosCost_tem[11] + rdoqD64LastOne_tem[11] - i_d64_cost_last_one_d1[11] + i_d64_cost_last_zero_d1[11] - rdoqD64LastZero_tem[11] > 0)begin
                                        endPosCost[11]       <=      tempCost_tem[11];
                                    end
                                    else begin
                                        endPosCost[11]       <=      endPosCost_tem[11];
                                    end
                                end
                                else begin
                                    endPosCost[11]       <=      tempCost_tem[11];
                                end
                            end
                            else begin
                                endPosCost[11]       <=      endPosCost_tem[11];
                            end

                            if(i_level_opt_d1[15])begin
                                if(rdoq_last_y_tem[15] != -1)begin
                                    if(tempCost_tem[15] - endPosCost_tem[15] + rdoqD64LastOne_tem[15] - i_d64_cost_last_one_d1[15] + i_d64_cost_last_zero_d1[15] - rdoqD64LastZero_tem[15] > 0)begin
                                        endPosCost[15]       <=      tempCost_tem[15];
                                    end
                                    else begin
                                        endPosCost[15]       <=      endPosCost_tem[15];
                                    end
                                end
                                else begin
                                    endPosCost[15]       <=      tempCost_tem[15];
                                end
                            end
                            else begin
                                endPosCost[15]       <=      endPosCost_tem[15];
                            end

                            if(i_level_opt_d1[19])begin
                                if(rdoq_last_y_tem[19] != -1)begin
                                    if(tempCost_tem[19] - endPosCost_tem[19] + rdoqD64LastOne_tem[19] - i_d64_cost_last_one_d1[19] + i_d64_cost_last_zero_d1[19] - rdoqD64LastZero_tem[19] > 0)begin
                                        endPosCost[19]       <=      tempCost_tem[19];
                                    end
                                    else begin
                                        endPosCost[19]       <=      endPosCost_tem[19];
                                    end
                                end
                                else begin
                                    endPosCost[19]       <=      tempCost_tem[19];
                                end
                            end
                            else begin
                                endPosCost[19]       <=      endPosCost_tem[19];
                            end

                            if(i_level_opt_d1[23])begin
                                if(rdoq_last_y_tem[23] != -1)begin
                                    if(tempCost_tem[23] - endPosCost_tem[23] + rdoqD64LastOne_tem[23] - i_d64_cost_last_one_d1[23] + i_d64_cost_last_zero_d1[23] - rdoqD64LastZero_tem[23] > 0)begin
                                        endPosCost[23]       <=      tempCost_tem[23];
                                    end
                                    else begin
                                        endPosCost[23]       <=      endPosCost_tem[23];
                                    end
                                end
                                else begin
                                    endPosCost[23]       <=      tempCost_tem[23];
                                end
                            end
                            else begin
                                endPosCost[23]       <=      endPosCost_tem[23];
                            end

                            if(i_level_opt_d1[27])begin
                                if(rdoq_last_y_tem[27] != -1)begin
                                    if(tempCost_tem[27] - endPosCost_tem[27] + rdoqD64LastOne_tem[27] - i_d64_cost_last_one_d1[27] + i_d64_cost_last_zero_d1[27] - rdoqD64LastZero_tem[27] > 0)begin
                                        endPosCost[27]       <=      tempCost_tem[27];
                                    end
                                    else begin
                                        endPosCost[27]       <=      endPosCost_tem[27];
                                    end
                                end
                                else begin
                                    endPosCost[27]       <=      tempCost_tem[27];
                                end
                            end
                            else begin
                                endPosCost[27]       <=      endPosCost_tem[27];
                            end

                            endPosCost[31]      <=      i_level_opt_d1[31] == 0 ? i_base_cost_buffer_tmp_d1[31] : 0;
                        end
                    default : begin
                            endPosCost[3 ]      <=      0;
                            endPosCost[7 ]      <=      0;
                            endPosCost[11]      <=      0;
                            endPosCost[15]      <=      0;
                            endPosCost[19]      <=      0;
                            endPosCost[23]      <=      0;
                            endPosCost[27]      <=      0;
                            endPosCost[31]      <=      0;
                        end
                endcase
            end
        end
    end

    assign  temp_RdoqCost_top   =   final_rdoq_cost_top + tempCost[0] - endPosCost[0] - rdoqD64LastZero[0];

//pipe 3
    //delay one cycle
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            column_cnt_d2       <=      0;
            i_width_log2_d3     <=      0;
            i_height_log2_d3    <=      0;
        end
        else begin
            column_cnt_d2       <=      column_cnt_d1       ;
            i_width_log2_d3     <=      i_width_log2_d2     ;
            i_height_log2_d3    <=      i_height_log2_d2    ;
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            final_rdoq_last_x_top   <=  -1;
            final_rdoq_last_y_top   <=  -1;
        end
        else if( (rdoq_last_y[0] != -1) && (temp_RdoqCost_top + rdoqD64LastOne[0]   <   d64_best_cost_tmp_top) )begin
            final_rdoq_last_x_top   <=  rdoq_last_x[0];
            final_rdoq_last_y_top   <=  rdoq_last_y[0];
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            d64_best_cost_tmp_top   <=  -(64'd21241079192053);
        end
        else if(column_cnt_d2 == (1 << i_width_log2_d3) - 1)begin
            if( (rdoq_last_y[0] != -1) && (temp_RdoqCost_top + rdoqD64LastOne[0]   <   -(64'd21241079192053)) )begin
                d64_best_cost_tmp_top   <=  temp_RdoqCost_top + rdoqD64LastOne[0];
            end
            else begin
                d64_best_cost_tmp_top   <=  -(64'd21241079192053);
            end
        end
        else begin
            if( (rdoq_last_y[0] != -1) && (temp_RdoqCost_top + rdoqD64LastOne[0]   <   d64_best_cost_tmp_top) )begin
                d64_best_cost_tmp_top   <=  temp_RdoqCost_top + rdoqD64LastOne[0];
            end
        end
    end


    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            final_rdoq_cost_top     <=  0;
        end
        else if(column_cnt_d2 == (1 << i_width_log2_d3) - 1)begin
            final_rdoq_cost_top     <=  tempCost[0];
        end
        else begin
            final_rdoq_cost_top     <=  final_rdoq_cost_top + tempCost[0];
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                tempCost_left[i]            <=      0;
                rdoqD64LastZero_left[i]     <=      0;
                rdoqD64LastOne_left[i]      <=      0;
                rdoq_last_x_left[i]         <=      0;
                rdoq_last_y_left[i]         <=      0;
            end
        end
        else if(column_cnt_d1 == (1 << i_width_log2_d2) - 1)begin
            for(i = 0; i < 32; i = i + 1)begin
                tempCost_left[i]            <=       tempCost_tem[i]       ;//value after shift operation
                rdoqD64LastZero_left[i]     <=       rdoqD64LastZero_tem[i];//value after shift operation
                rdoqD64LastOne_left[i]      <=       rdoqD64LastOne_tem[i] ;//value after shift operation
                rdoq_last_x_left[i]         <=       rdoq_last_x_tem[i]    ;//value after shift operation
                rdoq_last_y_left[i]         <=       rdoq_last_y_tem[i]    ;//value after shift operation
            end
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                endPosCost_left[i]          <=      0;
            end
        end
        else if(column_cnt_d1 == (1 << i_width_log2_d2) - 1)begin
            for(i = 0; i < 32; i = i + 2)begin
                endPosCost_left[i]          <=       endPosCost_tem[i]     ;//value after shift operation
            end
            for(i = 1; i < 32; i = i + 2)begin
                endPosCost_left[i]          <=       tempCost_tem[i] - endPosCost_tem[i]     ;//value after shift operation
            end
        end
    end

    generate 
        for(o = 0; o < 32; o = o + 1)begin
            assign  temp_RdoqCost_except_final_cost_left[o]     =   endPosCost_left[o] - rdoqD64LastZero_left[o];
        end
    endgenerate


//pipe 4

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            d64_best_cost_tmp_left      <=      0;
            final_rdoq_cost_left        <=      0;
            final_rdoq_last_x_left      <=      -1;
            final_rdoq_last_y_left      <=      -1;
        end
        else if(column_cnt_d2 == (1 << i_width_log2_d3) - 1)begin
            d64_best_cost_tmp_left      <=      d64_best_cost_tmp_top;
            final_rdoq_cost_left        <=      final_rdoq_cost_top;
            final_rdoq_last_x_left      <=      final_rdoq_last_x_top;
            final_rdoq_last_y_left      <=      final_rdoq_last_y_top;
        end
    end

    assign  d64_best_cost_tmp_left_d[0]     =   d64_best_cost_tmp_left;
    assign  final_rdoq_cost_left_d[0]       =   final_rdoq_cost_left;
    assign  final_rdoq_last_x_left_d[0]     =   final_rdoq_last_x_left;
    assign  final_rdoq_last_y_left_d[0]     =   final_rdoq_last_y_left;



//next 0-32 cycles
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                for(j = 0; j < 32; j = j + 1)begin
                    temp_RdoqCost_except_final_cost_left_d[i][j]    <=  0   ;
                    rdoq_last_x_left_d[i][j]                        <=  0   ;
                    rdoq_last_y_left_d[i][j]                        <=  0   ;
                    rdoqD64LastOne_left_d[i][j]                     <=  0   ;
                    tempCost_left_d[i][j]                           <=  0   ;
                end 
            end
        end 
        else begin
            for(j = 0; j < 32; j = j + 1)begin
                temp_RdoqCost_except_final_cost_left_d[0][j]    <=      temp_RdoqCost_except_final_cost_left[j]     ;
                rdoq_last_x_left_d[0][j]                        <=      rdoq_last_x_left[j]                         ;
                rdoq_last_y_left_d[0][j]                        <=      rdoq_last_y_left[j]                         ;
                rdoqD64LastOne_left_d[0][j]                     <=      rdoqD64LastOne_left[j]                      ;
                tempCost_left_d[0][j]                           <=      tempCost_left[j]                            ;
            end 

            for(i = 1; i < 32; i = i + 1)begin
                for(j = 0; j < 32; j = j + 1)begin
                    temp_RdoqCost_except_final_cost_left_d[i][j]    <=      temp_RdoqCost_except_final_cost_left_d[i-1][j]    ;
                    rdoq_last_x_left_d[i][j]                        <=      rdoq_last_x_left_d[i-1][j]                        ;
                    rdoq_last_y_left_d[i][j]                        <=      rdoq_last_y_left_d[i-1][j]                        ;
                    rdoqD64LastOne_left_d[i][j]                     <=      rdoqD64LastOne_left_d[i-1][j]                     ;
                    tempCost_left_d[i][j]                           <=      tempCost_left_d[i-1][j]                           ;
                end 
            end
        end
    end

    generate
        for(o = 0; o < 31; o = o + 1)begin
            position_cal u_position_cal(      
            //system clk and rest       
                .clk                     (clk                               ),
                .rst_n                   (rst_n                             ),

            //input data
                .rdoqD64LastOne          (rdoqD64LastOne_left_d[o][o]                                               ),  
                .temp_RdoqCost           (final_rdoq_cost_left[o] + temp_RdoqCost_except_final_cost_left_d[o][o]    ),  
                .tempCost                (tempCost_left_d   [o][o]                                                  ),  
                .rdoq_last_x             (rdoq_last_x_left_d[o][o]                                                  ),
                .rdoq_last_y             (rdoq_last_y_left_d[o][o]                                                  ),

                .final_rdoq_last_x_in    (final_rdoq_last_x_left_d[o]       ),
                .final_rdoq_last_y_in    (final_rdoq_last_y_left_d[o]       ), 
                .final_rdoq_cost_in      (final_rdoq_cost_left_d  [o]       ),
                .d64_best_cost_tmp_in    (d64_best_cost_tmp_left_d[o]       ),

            //output data
                .final_rdoq_last_x_out   (final_rdoq_last_x_left_d[o + 1]   ),
                .final_rdoq_last_y_out   (final_rdoq_last_y_left_d[o + 1]   ), 
                .final_rdoq_cost_out     (final_rdoq_cost_left_d  [o + 1]   ),
                .d64_best_cost_tmp_out   (d64_best_cost_tmp_left_d[o + 1]   )     
            );
        end
    endgenerate
















`ifdef file_write//test bench
    

//16x16
    initial begin 
    integer fp_endPosCost_w0,fp_endPosCost_w1;
    integer wr_endPosCost_j,wr_endPosCost_k;
    reg     signed  [63: 0]     endPosCost_data        [0 : 63]    ;
    integer fp_tempCost_w0,fp_tempCost_w1;
    integer wr_tempCost_j,wr_tempCost_k;
    reg     signed  [63: 0]     tempCost_data        [0 : 63]    ;
    reg     column_count;
        #20;
        fp_tempCost_w0 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_16x16_0.txt", "w");
        fp_tempCost_w1 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_16x16_1.txt", "w");
        fp_endPosCost_w0 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_16x16_0.txt", "w");
        fp_endPosCost_w1 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_16x16_1.txt", "w");
        column_count  <=  0;
        for (wr_tempCost_j = 0; wr_tempCost_j < 16; wr_tempCost_j = wr_tempCost_j + 1) begin
            for (wr_tempCost_k = 0; wr_tempCost_k < 32; wr_tempCost_k = wr_tempCost_k + 1) begin
                tempCost_data[wr_tempCost_k]    = tempCost[wr_tempCost_k];
                endPosCost_data[wr_tempCost_k]  = endPosCost[wr_tempCost_k];
            end
            #2;
            $fwrite(fp_tempCost_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                tempCost_data[0 ], tempCost_data[1 ], tempCost_data[2 ], tempCost_data[3 ], tempCost_data[4 ], tempCost_data[5 ], tempCost_data[6 ], tempCost_data[7 ], 
                tempCost_data[8 ], tempCost_data[9 ], tempCost_data[10], tempCost_data[11], tempCost_data[12], tempCost_data[13], tempCost_data[14], tempCost_data[15]);
            $fwrite(fp_tempCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                tempCost_data[16], tempCost_data[17], tempCost_data[18], tempCost_data[19], tempCost_data[20], tempCost_data[21], tempCost_data[22], tempCost_data[23], 
                tempCost_data[24], tempCost_data[25], tempCost_data[26], tempCost_data[27], tempCost_data[28], tempCost_data[29], tempCost_data[30], tempCost_data[31]);
            if(column_count % 2)begin
                $fwrite(fp_endPosCost_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    tempCost_data[0 ] - endPosCost_data[0 ], endPosCost_data[1 ], endPosCost_data[2 ], endPosCost_data[3 ], endPosCost_data[4 ], endPosCost_data[5 ], endPosCost_data[6 ], endPosCost_data[7 ], 
                    endPosCost_data[8 ], endPosCost_data[9 ], endPosCost_data[10], endPosCost_data[11], endPosCost_data[12], endPosCost_data[13], endPosCost_data[14], endPosCost_data[15]);
                $fwrite(fp_endPosCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    tempCost_data[16] - endPosCost_data[16], endPosCost_data[17], endPosCost_data[18], endPosCost_data[19], endPosCost_data[20], endPosCost_data[21], endPosCost_data[22], endPosCost_data[23], 
                    endPosCost_data[24], endPosCost_data[25], endPosCost_data[26], endPosCost_data[27], endPosCost_data[28], endPosCost_data[29], endPosCost_data[30], endPosCost_data[31]);
            end
            else begin
                $fwrite(fp_endPosCost_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    endPosCost_data[0 ], endPosCost_data[1 ], endPosCost_data[2 ], endPosCost_data[3 ], endPosCost_data[4 ], endPosCost_data[5 ], endPosCost_data[6 ], endPosCost_data[7 ], 
                    endPosCost_data[8 ], endPosCost_data[9 ], endPosCost_data[10], endPosCost_data[11], endPosCost_data[12], endPosCost_data[13], endPosCost_data[14], endPosCost_data[15]);
                $fwrite(fp_endPosCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    endPosCost_data[16], endPosCost_data[17], endPosCost_data[18], endPosCost_data[19], endPosCost_data[20], endPosCost_data[21], endPosCost_data[22], endPosCost_data[23], 
                    endPosCost_data[24], endPosCost_data[25], endPosCost_data[26], endPosCost_data[27], endPosCost_data[28], endPosCost_data[29], endPosCost_data[30], endPosCost_data[31]);
            end
            column_count  <=  column_count + 1;
        end
        $fclose(fp_tempCost_w0);
        $fclose(fp_tempCost_w1);
        $fclose(fp_endPosCost_w0);
        $fclose(fp_endPosCost_w1);
    end

    initial begin 
    integer fp_rdoqD64LastOne_w0,fp_rdoqD64LastOne_w1;
    integer wr_rdoqD64LastOne_j,wr_rdoqD64LastOne_k;
    reg     signed  [63: 0]     rdoqD64LastOne_data        [0 : 63]    ;
        #20;
        fp_rdoqD64LastOne_w0 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_16x16_0.txt", "w");
        fp_rdoqD64LastOne_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_16x16_1.txt", "w");
        for (wr_rdoqD64LastOne_j = 0; wr_rdoqD64LastOne_j < 16; wr_rdoqD64LastOne_j = wr_rdoqD64LastOne_j + 1) begin
            for (wr_rdoqD64LastOne_k = 0; wr_rdoqD64LastOne_k < 32; wr_rdoqD64LastOne_k = wr_rdoqD64LastOne_k + 1) begin
                rdoqD64LastOne_data[wr_rdoqD64LastOne_k] = rdoqD64LastOne[wr_rdoqD64LastOne_k];
            end
            #2;
            $fwrite(fp_rdoqD64LastOne_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[0 ], rdoqD64LastOne_data[1 ], rdoqD64LastOne_data[2 ], rdoqD64LastOne_data[3 ], rdoqD64LastOne_data[4 ], rdoqD64LastOne_data[5 ], rdoqD64LastOne_data[6 ], rdoqD64LastOne_data[7 ], 
                rdoqD64LastOne_data[8 ], rdoqD64LastOne_data[9 ], rdoqD64LastOne_data[10], rdoqD64LastOne_data[11], rdoqD64LastOne_data[12], rdoqD64LastOne_data[13], rdoqD64LastOne_data[14], rdoqD64LastOne_data[15]);
            $fwrite(fp_rdoqD64LastOne_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[16], rdoqD64LastOne_data[17], rdoqD64LastOne_data[18], rdoqD64LastOne_data[19], rdoqD64LastOne_data[20], rdoqD64LastOne_data[21], rdoqD64LastOne_data[22], rdoqD64LastOne_data[23], 
                rdoqD64LastOne_data[24], rdoqD64LastOne_data[25], rdoqD64LastOne_data[26], rdoqD64LastOne_data[27], rdoqD64LastOne_data[28], rdoqD64LastOne_data[29], rdoqD64LastOne_data[30], rdoqD64LastOne_data[31]);
        end
        $fclose(fp_rdoqD64LastOne_w0);
        $fclose(fp_rdoqD64LastOne_w1);
    end

    initial begin 
    integer fp_rdoqD64LastZero_w0,fp_rdoqD64LastZero_w1;
    integer wr_rdoqD64LastZero_j,wr_rdoqD64LastZero_k;
    reg     signed  [63: 0]     rdoqD64LastZero_data        [0 : 63]    ;
        #20;
        fp_rdoqD64LastZero_w0 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_16x16_0.txt", "w");
        fp_rdoqD64LastZero_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_16x16_1.txt", "w");
        for (wr_rdoqD64LastZero_j = 0; wr_rdoqD64LastZero_j < 16; wr_rdoqD64LastZero_j = wr_rdoqD64LastZero_j + 1) begin
            for (wr_rdoqD64LastZero_k = 0; wr_rdoqD64LastZero_k < 32; wr_rdoqD64LastZero_k = wr_rdoqD64LastZero_k + 1) begin
                rdoqD64LastZero_data[wr_rdoqD64LastZero_k] = rdoqD64LastZero[wr_rdoqD64LastZero_k];
            end
            #2;
            $fwrite(fp_rdoqD64LastZero_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[0 ], rdoqD64LastZero_data[1 ], rdoqD64LastZero_data[2 ], rdoqD64LastZero_data[3 ], rdoqD64LastZero_data[4 ], rdoqD64LastZero_data[5 ], rdoqD64LastZero_data[6 ], rdoqD64LastZero_data[7 ], 
                rdoqD64LastZero_data[8 ], rdoqD64LastZero_data[9 ], rdoqD64LastZero_data[10], rdoqD64LastZero_data[11], rdoqD64LastZero_data[12], rdoqD64LastZero_data[13], rdoqD64LastZero_data[14], rdoqD64LastZero_data[15]);
            $fwrite(fp_rdoqD64LastZero_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[16], rdoqD64LastZero_data[17], rdoqD64LastZero_data[18], rdoqD64LastZero_data[19], rdoqD64LastZero_data[20], rdoqD64LastZero_data[21], rdoqD64LastZero_data[22], rdoqD64LastZero_data[23], 
                rdoqD64LastZero_data[24], rdoqD64LastZero_data[25], rdoqD64LastZero_data[26], rdoqD64LastZero_data[27], rdoqD64LastZero_data[28], rdoqD64LastZero_data[29], rdoqD64LastZero_data[30], rdoqD64LastZero_data[31]);
        end
        $fclose(fp_rdoqD64LastZero_w0);
        $fclose(fp_rdoqD64LastZero_w1);
    end

    initial begin 
    integer fp_rdoq_last_x_w0,fp_rdoq_last_x_w1;
    integer wr_rdoq_last_x_j,wr_rdoq_last_x_k;
    reg     signed  [63: 0]     rdoq_last_x_data        [0 : 63]    ;
        #20;
        fp_rdoq_last_x_w0 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_16x16_0.txt", "w");
        fp_rdoq_last_x_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_16x16_1.txt", "w");
        for (wr_rdoq_last_x_j = 0; wr_rdoq_last_x_j < 16; wr_rdoq_last_x_j = wr_rdoq_last_x_j + 1) begin
            for (wr_rdoq_last_x_k = 0; wr_rdoq_last_x_k < 32; wr_rdoq_last_x_k = wr_rdoq_last_x_k + 1) begin
                rdoq_last_x_data[wr_rdoq_last_x_k] = rdoq_last_x[wr_rdoq_last_x_k];
            end
            #2;
            $fwrite(fp_rdoq_last_x_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_x_data[0 ], rdoq_last_x_data[1 ], rdoq_last_x_data[2 ], rdoq_last_x_data[3 ], rdoq_last_x_data[4 ], rdoq_last_x_data[5 ], rdoq_last_x_data[6 ], rdoq_last_x_data[7 ], 
                rdoq_last_x_data[8 ], rdoq_last_x_data[9 ], rdoq_last_x_data[10], rdoq_last_x_data[11], rdoq_last_x_data[12], rdoq_last_x_data[13], rdoq_last_x_data[14], rdoq_last_x_data[15]);
            $fwrite(fp_rdoq_last_x_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_x_data[16], rdoq_last_x_data[17], rdoq_last_x_data[18], rdoq_last_x_data[19], rdoq_last_x_data[20], rdoq_last_x_data[21], rdoq_last_x_data[22], rdoq_last_x_data[23], 
                rdoq_last_x_data[24], rdoq_last_x_data[25], rdoq_last_x_data[26], rdoq_last_x_data[27], rdoq_last_x_data[28], rdoq_last_x_data[29], rdoq_last_x_data[30], rdoq_last_x_data[31]);
        end
        $fclose(fp_rdoq_last_x_w0);
        $fclose(fp_rdoq_last_x_w1);
    end


    initial begin 
    integer fp_rdoq_last_y_w0,fp_rdoq_last_y_w1;
    integer wr_rdoq_last_y_j,wr_rdoq_last_y_k;
    reg     signed  [63: 0]     rdoq_last_y_data        [0 : 63]    ;
        #20;
        fp_rdoq_last_y_w0 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_16x16_0.txt", "w");
        fp_rdoq_last_y_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_16x16_1.txt", "w");
        for (wr_rdoq_last_y_j = 0; wr_rdoq_last_y_j < 16; wr_rdoq_last_y_j = wr_rdoq_last_y_j + 1) begin
            for (wr_rdoq_last_y_k = 0; wr_rdoq_last_y_k < 32; wr_rdoq_last_y_k = wr_rdoq_last_y_k + 1) begin
                rdoq_last_y_data[wr_rdoq_last_y_k] = rdoq_last_y[wr_rdoq_last_y_k];
            end
            #2;
            $fwrite(fp_rdoq_last_y_w0, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_y_data[0 ], rdoq_last_y_data[1 ], rdoq_last_y_data[2 ], rdoq_last_y_data[3 ], rdoq_last_y_data[4 ], rdoq_last_y_data[5 ], rdoq_last_y_data[6 ], rdoq_last_y_data[7 ], 
                rdoq_last_y_data[8 ], rdoq_last_y_data[9 ], rdoq_last_y_data[10], rdoq_last_y_data[11], rdoq_last_y_data[12], rdoq_last_y_data[13], rdoq_last_y_data[14], rdoq_last_y_data[15]);
            $fwrite(fp_rdoq_last_y_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_y_data[16], rdoq_last_y_data[17], rdoq_last_y_data[18], rdoq_last_y_data[19], rdoq_last_y_data[20], rdoq_last_y_data[21], rdoq_last_y_data[22], rdoq_last_y_data[23], 
                rdoq_last_y_data[24], rdoq_last_y_data[25], rdoq_last_y_data[26], rdoq_last_y_data[27], rdoq_last_y_data[28], rdoq_last_y_data[29], rdoq_last_y_data[30], rdoq_last_y_data[31]);
        end
        $fclose(fp_rdoq_last_y_w0);
        $fclose(fp_rdoq_last_y_w1);
    end

//32x32
    initial begin 
    integer fp_tempCost_w1;
    integer wr_tempCost_j,wr_tempCost_k;
    integer fp_endPosCost_w1;
    integer wr_endPosCost_j,wr_endPosCost_k;
    reg     signed  [63: 0]     tempCost_data       [0 : 63]    ;
    reg     signed  [63: 0]     endPosCost_data     [0 : 63]    ;
    reg             [5 : 0]     column_count                    ;
        #52;
        fp_tempCost_w1      = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_32x32.txt", "w");
        fp_endPosCost_w1    = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_32x32.txt", "w");
        column_count        <=  0;
        for (wr_tempCost_j = 0; wr_tempCost_j < 32; wr_tempCost_j = wr_tempCost_j + 1) begin
            for (wr_tempCost_k = 0; wr_tempCost_k < 32; wr_tempCost_k = wr_tempCost_k + 1) begin
                tempCost_data[wr_tempCost_k] = tempCost[wr_tempCost_k];
                endPosCost_data[wr_tempCost_k] = endPosCost[wr_tempCost_k];
            end
            #2;
            $fwrite(fp_tempCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            tempCost_data[0 ], tempCost_data[1 ], tempCost_data[2 ], tempCost_data[3 ], tempCost_data[4 ], tempCost_data[5 ], tempCost_data[6 ], tempCost_data[7 ],
            tempCost_data[8 ], tempCost_data[9 ], tempCost_data[10], tempCost_data[11], tempCost_data[12], tempCost_data[13], tempCost_data[14], tempCost_data[15], 
            tempCost_data[16], tempCost_data[17], tempCost_data[18], tempCost_data[19], tempCost_data[20], tempCost_data[21], tempCost_data[22], tempCost_data[23], 
            tempCost_data[24], tempCost_data[25], tempCost_data[26], tempCost_data[27], tempCost_data[28], tempCost_data[29], tempCost_data[30], tempCost_data[31]);
            if(column_count % 2)begin
                $fwrite(fp_endPosCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                tempCost_data[0 ] - endPosCost_data[0 ], endPosCost_data[1 ], endPosCost_data[2 ], endPosCost_data[3 ], endPosCost_data[4 ], endPosCost_data[5 ], endPosCost_data[6 ], endPosCost_data[7 ],
                endPosCost_data[8 ], endPosCost_data[9 ], endPosCost_data[10], endPosCost_data[11], endPosCost_data[12], endPosCost_data[13], endPosCost_data[14], endPosCost_data[15], 
                endPosCost_data[16], endPosCost_data[17], endPosCost_data[18], endPosCost_data[19], endPosCost_data[20], endPosCost_data[21], endPosCost_data[22], endPosCost_data[23], 
                endPosCost_data[24], endPosCost_data[25], endPosCost_data[26], endPosCost_data[27], endPosCost_data[28], endPosCost_data[29], endPosCost_data[30], endPosCost_data[31]);
            end
            else begin
                $fwrite(fp_endPosCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
                endPosCost_data[0 ], endPosCost_data[1 ], endPosCost_data[2 ], endPosCost_data[3 ], endPosCost_data[4 ], endPosCost_data[5 ], endPosCost_data[6 ], endPosCost_data[7 ],
                endPosCost_data[8 ], endPosCost_data[9 ], endPosCost_data[10], endPosCost_data[11], endPosCost_data[12], endPosCost_data[13], endPosCost_data[14], endPosCost_data[15], 
                endPosCost_data[16], endPosCost_data[17], endPosCost_data[18], endPosCost_data[19], endPosCost_data[20], endPosCost_data[21], endPosCost_data[22], endPosCost_data[23], 
                endPosCost_data[24], endPosCost_data[25], endPosCost_data[26], endPosCost_data[27], endPosCost_data[28], endPosCost_data[29], endPosCost_data[30], endPosCost_data[31]);
            end
            column_count        <=  column_count + 1;
        end
        $fclose(fp_tempCost_w1);
        $fclose(fp_endPosCost_w1);
    end


    initial begin 
    integer fp_rdoqD64LastOne_w1;
    integer wr_rdoqD64LastOne_j,wr_rdoqD64LastOne_k;
    reg     signed  [63: 0]     rdoqD64LastOne_data        [0 : 63]    ;
        #52;
        fp_rdoqD64LastOne_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_32x32.txt", "w");
        for (wr_rdoqD64LastOne_j = 0; wr_rdoqD64LastOne_j < 32; wr_rdoqD64LastOne_j = wr_rdoqD64LastOne_j + 1) begin
            for (wr_rdoqD64LastOne_k = 0; wr_rdoqD64LastOne_k < 32; wr_rdoqD64LastOne_k = wr_rdoqD64LastOne_k + 1) begin
                rdoqD64LastOne_data[wr_rdoqD64LastOne_k] = rdoqD64LastOne[wr_rdoqD64LastOne_k];
            end
            #2;
            $fwrite(fp_rdoqD64LastOne_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            rdoqD64LastOne_data[0 ], rdoqD64LastOne_data[1 ], rdoqD64LastOne_data[2 ], rdoqD64LastOne_data[3 ], rdoqD64LastOne_data[4 ], rdoqD64LastOne_data[5 ], rdoqD64LastOne_data[6 ], rdoqD64LastOne_data[7 ],
            rdoqD64LastOne_data[8 ], rdoqD64LastOne_data[9 ], rdoqD64LastOne_data[10], rdoqD64LastOne_data[11], rdoqD64LastOne_data[12], rdoqD64LastOne_data[13], rdoqD64LastOne_data[14], rdoqD64LastOne_data[15], 
            rdoqD64LastOne_data[16], rdoqD64LastOne_data[17], rdoqD64LastOne_data[18], rdoqD64LastOne_data[19], rdoqD64LastOne_data[20], rdoqD64LastOne_data[21], rdoqD64LastOne_data[22], rdoqD64LastOne_data[23], 
            rdoqD64LastOne_data[24], rdoqD64LastOne_data[25], rdoqD64LastOne_data[26], rdoqD64LastOne_data[27], rdoqD64LastOne_data[28], rdoqD64LastOne_data[29], rdoqD64LastOne_data[30], rdoqD64LastOne_data[31]);
        end
        $fclose(fp_rdoqD64LastOne_w1);
    end

    initial begin 
    integer fp_rdoqD64LastZero_w1;
    integer wr_rdoqD64LastZero_j,wr_rdoqD64LastZero_k;
    reg     signed  [63: 0]     rdoqD64LastZero_data        [0 : 63]    ;
        #52;
        fp_rdoqD64LastZero_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_32x32.txt", "w");
        for (wr_rdoqD64LastZero_j = 0; wr_rdoqD64LastZero_j < 32; wr_rdoqD64LastZero_j = wr_rdoqD64LastZero_j + 1) begin
            for (wr_rdoqD64LastZero_k = 0; wr_rdoqD64LastZero_k < 32; wr_rdoqD64LastZero_k = wr_rdoqD64LastZero_k + 1) begin
                rdoqD64LastZero_data[wr_rdoqD64LastZero_k] = rdoqD64LastZero[wr_rdoqD64LastZero_k];
            end
            #2;
            $fwrite(fp_rdoqD64LastZero_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            rdoqD64LastZero_data[0 ], rdoqD64LastZero_data[1 ], rdoqD64LastZero_data[2 ], rdoqD64LastZero_data[3 ], rdoqD64LastZero_data[4 ], rdoqD64LastZero_data[5 ], rdoqD64LastZero_data[6 ], rdoqD64LastZero_data[7 ],
            rdoqD64LastZero_data[8 ], rdoqD64LastZero_data[9 ], rdoqD64LastZero_data[10], rdoqD64LastZero_data[11], rdoqD64LastZero_data[12], rdoqD64LastZero_data[13], rdoqD64LastZero_data[14], rdoqD64LastZero_data[15], 
            rdoqD64LastZero_data[16], rdoqD64LastZero_data[17], rdoqD64LastZero_data[18], rdoqD64LastZero_data[19], rdoqD64LastZero_data[20], rdoqD64LastZero_data[21], rdoqD64LastZero_data[22], rdoqD64LastZero_data[23], 
            rdoqD64LastZero_data[24], rdoqD64LastZero_data[25], rdoqD64LastZero_data[26], rdoqD64LastZero_data[27], rdoqD64LastZero_data[28], rdoqD64LastZero_data[29], rdoqD64LastZero_data[30], rdoqD64LastZero_data[31]);
        end
        $fclose(fp_rdoqD64LastZero_w1);
    end


    initial begin 
    integer fp_rdoq_last_x_w1;
    integer wr_rdoq_last_x_j,wr_rdoq_last_x_k;
    reg     signed  [63: 0]     rdoq_last_x_data        [0 : 63]    ;
        #52;
        fp_rdoq_last_x_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_32x32.txt", "w");
        for (wr_rdoq_last_x_j = 0; wr_rdoq_last_x_j < 32; wr_rdoq_last_x_j = wr_rdoq_last_x_j + 1) begin
            for (wr_rdoq_last_x_k = 0; wr_rdoq_last_x_k < 32; wr_rdoq_last_x_k = wr_rdoq_last_x_k + 1) begin
                rdoq_last_x_data[wr_rdoq_last_x_k] = rdoq_last_x[wr_rdoq_last_x_k];
            end
            #2;
            $fwrite(fp_rdoq_last_x_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            rdoq_last_x_data[0 ], rdoq_last_x_data[1 ], rdoq_last_x_data[2 ], rdoq_last_x_data[3 ], rdoq_last_x_data[4 ], rdoq_last_x_data[5 ], rdoq_last_x_data[6 ], rdoq_last_x_data[7 ],
            rdoq_last_x_data[8 ], rdoq_last_x_data[9 ], rdoq_last_x_data[10], rdoq_last_x_data[11], rdoq_last_x_data[12], rdoq_last_x_data[13], rdoq_last_x_data[14], rdoq_last_x_data[15], 
            rdoq_last_x_data[16], rdoq_last_x_data[17], rdoq_last_x_data[18], rdoq_last_x_data[19], rdoq_last_x_data[20], rdoq_last_x_data[21], rdoq_last_x_data[22], rdoq_last_x_data[23], 
            rdoq_last_x_data[24], rdoq_last_x_data[25], rdoq_last_x_data[26], rdoq_last_x_data[27], rdoq_last_x_data[28], rdoq_last_x_data[29], rdoq_last_x_data[30], rdoq_last_x_data[31]);
        end
        $fclose(fp_rdoq_last_x_w1);
    end

    initial begin 
    integer fp_rdoq_last_y_w1;
    integer wr_rdoq_last_y_j,wr_rdoq_last_y_k;
    reg     signed  [63: 0]     rdoq_last_y_data        [0 : 63]    ;
        #52;
        fp_rdoq_last_y_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_32x32.txt", "w");
        for (wr_rdoq_last_y_j = 0; wr_rdoq_last_y_j < 32; wr_rdoq_last_y_j = wr_rdoq_last_y_j + 1) begin
            for (wr_rdoq_last_y_k = 0; wr_rdoq_last_y_k < 32; wr_rdoq_last_y_k = wr_rdoq_last_y_k + 1) begin
                rdoq_last_y_data[wr_rdoq_last_y_k] = rdoq_last_y[wr_rdoq_last_y_k];
            end
            #2;
            $fwrite(fp_rdoq_last_y_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            rdoq_last_y_data[0 ], rdoq_last_y_data[1 ], rdoq_last_y_data[2 ], rdoq_last_y_data[3 ], rdoq_last_y_data[4 ], rdoq_last_y_data[5 ], rdoq_last_y_data[6 ], rdoq_last_y_data[7 ],
            rdoq_last_y_data[8 ], rdoq_last_y_data[9 ], rdoq_last_y_data[10], rdoq_last_y_data[11], rdoq_last_y_data[12], rdoq_last_y_data[13], rdoq_last_y_data[14], rdoq_last_y_data[15], 
            rdoq_last_y_data[16], rdoq_last_y_data[17], rdoq_last_y_data[18], rdoq_last_y_data[19], rdoq_last_y_data[20], rdoq_last_y_data[21], rdoq_last_y_data[22], rdoq_last_y_data[23], 
            rdoq_last_y_data[24], rdoq_last_y_data[25], rdoq_last_y_data[26], rdoq_last_y_data[27], rdoq_last_y_data[28], rdoq_last_y_data[29], rdoq_last_y_data[30], rdoq_last_y_data[31]);
        end
        $fclose(fp_rdoq_last_y_w1);
    end

//8x8
    initial begin 
    integer fp_endPosCost_w0,fp_endPosCost_w1,fp_endPosCost_w2,fp_endPosCost_w3;
    integer wr_endPosCost_j,wr_endPosCost_k;
    reg     signed  [63: 0]     endPosCost_data        [0 : 63]    ;
    integer fp_tempCost_w0,fp_tempCost_w1,fp_tempCost_w2,fp_tempCost_w3;
    integer wr_tempCost_j,wr_tempCost_k;
    reg     signed  [63: 0]     tempCost_data        [0 : 63]    ;
    reg     column_count;
        #116;
        fp_tempCost_w0 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_8x8_0.txt", "w");
        fp_tempCost_w1 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_8x8_1.txt", "w");
        fp_tempCost_w2 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_8x8_2.txt", "w");
        fp_tempCost_w3 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_8x8_3.txt", "w");
        fp_endPosCost_w0 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_8x8_0.txt", "w");
        fp_endPosCost_w1 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_8x8_1.txt", "w");
        fp_endPosCost_w2 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_8x8_2.txt", "w");
        fp_endPosCost_w3 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_8x8_3.txt", "w");
        column_count    <=  0;
        for (wr_tempCost_j = 0; wr_tempCost_j < 8; wr_tempCost_j = wr_tempCost_j + 1) begin
            for (wr_tempCost_k = 0; wr_tempCost_k < 32; wr_tempCost_k = wr_tempCost_k + 1) begin
                tempCost_data[wr_tempCost_k] = tempCost[wr_tempCost_k];
                endPosCost_data[wr_tempCost_k] = endPosCost[wr_tempCost_k];
            end
            #2;
            $fwrite(fp_tempCost_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                tempCost_data[0 ], tempCost_data[1 ], tempCost_data[2 ], tempCost_data[3 ], tempCost_data[4 ], tempCost_data[5 ], tempCost_data[6 ], tempCost_data[7 ]);
            $fwrite(fp_tempCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                tempCost_data[8 ], tempCost_data[9 ], tempCost_data[10], tempCost_data[11], tempCost_data[12], tempCost_data[13], tempCost_data[14], tempCost_data[15]);
            $fwrite(fp_tempCost_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                tempCost_data[16], tempCost_data[17], tempCost_data[18], tempCost_data[19], tempCost_data[20], tempCost_data[21], tempCost_data[22], tempCost_data[23]); 
            $fwrite(fp_tempCost_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                tempCost_data[24], tempCost_data[25], tempCost_data[26], tempCost_data[27], tempCost_data[28], tempCost_data[29], tempCost_data[30], tempCost_data[31]);

            if(column_count % 2)begin                
                $fwrite(fp_endPosCost_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    tempCost_data[0 ] - endPosCost_data[0 ], endPosCost_data[1 ], endPosCost_data[2 ], endPosCost_data[3 ], endPosCost_data[4 ], endPosCost_data[5 ], endPosCost_data[6 ], endPosCost_data[7 ]);
                $fwrite(fp_endPosCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    tempCost_data[8 ] - endPosCost_data[8 ], endPosCost_data[9 ], endPosCost_data[10], endPosCost_data[11], endPosCost_data[12], endPosCost_data[13], endPosCost_data[14], endPosCost_data[15]);
                $fwrite(fp_endPosCost_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    tempCost_data[16] - endPosCost_data[16], endPosCost_data[17], endPosCost_data[18], endPosCost_data[19], endPosCost_data[20], endPosCost_data[21], endPosCost_data[22], endPosCost_data[23]); 
                $fwrite(fp_endPosCost_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    tempCost_data[24] - endPosCost_data[24], endPosCost_data[25], endPosCost_data[26], endPosCost_data[27], endPosCost_data[28], endPosCost_data[29], endPosCost_data[30], endPosCost_data[31]);
            end
            else begin
                $fwrite(fp_endPosCost_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    endPosCost_data[0 ], endPosCost_data[1 ], endPosCost_data[2 ], endPosCost_data[3 ], endPosCost_data[4 ], endPosCost_data[5 ], endPosCost_data[6 ], endPosCost_data[7 ]);
                $fwrite(fp_endPosCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    endPosCost_data[8 ], endPosCost_data[9 ], endPosCost_data[10], endPosCost_data[11], endPosCost_data[12], endPosCost_data[13], endPosCost_data[14], endPosCost_data[15]);
                $fwrite(fp_endPosCost_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    endPosCost_data[16], endPosCost_data[17], endPosCost_data[18], endPosCost_data[19], endPosCost_data[20], endPosCost_data[21], endPosCost_data[22], endPosCost_data[23]); 
                $fwrite(fp_endPosCost_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                    endPosCost_data[24], endPosCost_data[25], endPosCost_data[26], endPosCost_data[27], endPosCost_data[28], endPosCost_data[29], endPosCost_data[30], endPosCost_data[31]);
            end
            column_count    <=  column_count + 1;
        end
        $fclose(fp_tempCost_w0);
        $fclose(fp_tempCost_w1);
        $fclose(fp_tempCost_w2);
        $fclose(fp_tempCost_w3);
        $fclose(fp_endPosCost_w0);
        $fclose(fp_endPosCost_w1);
        $fclose(fp_endPosCost_w2);
        $fclose(fp_endPosCost_w3);
    end


    initial begin 
    integer fp_rdoqD64LastOne_w0,fp_rdoqD64LastOne_w1,fp_rdoqD64LastOne_w2,fp_rdoqD64LastOne_w3;
    integer wr_rdoqD64LastOne_j,wr_rdoqD64LastOne_k;
    reg     signed  [63: 0]     rdoqD64LastOne_data        [0 : 63]    ;
        #116;
        fp_rdoqD64LastOne_w0 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_8x8_0.txt", "w");
        fp_rdoqD64LastOne_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_8x8_1.txt", "w");
        fp_rdoqD64LastOne_w2 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_8x8_2.txt", "w");
        fp_rdoqD64LastOne_w3 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_8x8_3.txt", "w");
        for (wr_rdoqD64LastOne_j = 0; wr_rdoqD64LastOne_j < 8; wr_rdoqD64LastOne_j = wr_rdoqD64LastOne_j + 1) begin
            for (wr_rdoqD64LastOne_k = 0; wr_rdoqD64LastOne_k < 32; wr_rdoqD64LastOne_k = wr_rdoqD64LastOne_k + 1) begin
                rdoqD64LastOne_data[wr_rdoqD64LastOne_k] = rdoqD64LastOne[wr_rdoqD64LastOne_k];
            end
            #2;
            $fwrite(fp_rdoqD64LastOne_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[0 ], rdoqD64LastOne_data[1 ], rdoqD64LastOne_data[2 ], rdoqD64LastOne_data[3 ], rdoqD64LastOne_data[4 ], rdoqD64LastOne_data[5 ], rdoqD64LastOne_data[6 ], rdoqD64LastOne_data[7 ]);
            $fwrite(fp_rdoqD64LastOne_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[8 ], rdoqD64LastOne_data[9 ], rdoqD64LastOne_data[10], rdoqD64LastOne_data[11], rdoqD64LastOne_data[12], rdoqD64LastOne_data[13], rdoqD64LastOne_data[14], rdoqD64LastOne_data[15]);
            $fwrite(fp_rdoqD64LastOne_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[16], rdoqD64LastOne_data[17], rdoqD64LastOne_data[18], rdoqD64LastOne_data[19], rdoqD64LastOne_data[20], rdoqD64LastOne_data[21], rdoqD64LastOne_data[22], rdoqD64LastOne_data[23]); 
            $fwrite(fp_rdoqD64LastOne_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[24], rdoqD64LastOne_data[25], rdoqD64LastOne_data[26], rdoqD64LastOne_data[27], rdoqD64LastOne_data[28], rdoqD64LastOne_data[29], rdoqD64LastOne_data[30], rdoqD64LastOne_data[31]);
        end
        $fclose(fp_rdoqD64LastOne_w0);
        $fclose(fp_rdoqD64LastOne_w1);
        $fclose(fp_rdoqD64LastOne_w2);
        $fclose(fp_rdoqD64LastOne_w3);
    end


    initial begin 
    integer fp_rdoqD64LastZero_w0,fp_rdoqD64LastZero_w1,fp_rdoqD64LastZero_w2,fp_rdoqD64LastZero_w3;
    integer wr_rdoqD64LastZero_j,wr_rdoqD64LastZero_k;
    reg     signed  [63: 0]     rdoqD64LastZero_data        [0 : 63]    ;
        #116;
        fp_rdoqD64LastZero_w0 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_8x8_0.txt", "w");
        fp_rdoqD64LastZero_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_8x8_1.txt", "w");
        fp_rdoqD64LastZero_w2 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_8x8_2.txt", "w");
        fp_rdoqD64LastZero_w3 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_8x8_3.txt", "w");
        for (wr_rdoqD64LastZero_j = 0; wr_rdoqD64LastZero_j < 8; wr_rdoqD64LastZero_j = wr_rdoqD64LastZero_j + 1) begin
            for (wr_rdoqD64LastZero_k = 0; wr_rdoqD64LastZero_k < 32; wr_rdoqD64LastZero_k = wr_rdoqD64LastZero_k + 1) begin
                rdoqD64LastZero_data[wr_rdoqD64LastZero_k] = rdoqD64LastZero[wr_rdoqD64LastZero_k];
            end
            #2;
            $fwrite(fp_rdoqD64LastZero_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[0 ], rdoqD64LastZero_data[1 ], rdoqD64LastZero_data[2 ], rdoqD64LastZero_data[3 ], rdoqD64LastZero_data[4 ], rdoqD64LastZero_data[5 ], rdoqD64LastZero_data[6 ], rdoqD64LastZero_data[7 ]);
            $fwrite(fp_rdoqD64LastZero_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[8 ], rdoqD64LastZero_data[9 ], rdoqD64LastZero_data[10], rdoqD64LastZero_data[11], rdoqD64LastZero_data[12], rdoqD64LastZero_data[13], rdoqD64LastZero_data[14], rdoqD64LastZero_data[15]);
            $fwrite(fp_rdoqD64LastZero_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[16], rdoqD64LastZero_data[17], rdoqD64LastZero_data[18], rdoqD64LastZero_data[19], rdoqD64LastZero_data[20], rdoqD64LastZero_data[21], rdoqD64LastZero_data[22], rdoqD64LastZero_data[23]); 
            $fwrite(fp_rdoqD64LastZero_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[24], rdoqD64LastZero_data[25], rdoqD64LastZero_data[26], rdoqD64LastZero_data[27], rdoqD64LastZero_data[28], rdoqD64LastZero_data[29], rdoqD64LastZero_data[30], rdoqD64LastZero_data[31]);
        end
        $fclose(fp_rdoqD64LastZero_w0);
        $fclose(fp_rdoqD64LastZero_w1);
        $fclose(fp_rdoqD64LastZero_w2);
        $fclose(fp_rdoqD64LastZero_w3);
    end

    initial begin 
    integer fp_rdoq_last_x_w0,fp_rdoq_last_x_w1,fp_rdoq_last_x_w2,fp_rdoq_last_x_w3;
    integer wr_rdoq_last_x_j,wr_rdoq_last_x_k;
    reg     signed  [63: 0]     rdoq_last_x_data        [0 : 63]    ;
        #116;
        fp_rdoq_last_x_w0 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_8x8_0.txt", "w");
        fp_rdoq_last_x_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_8x8_1.txt", "w");
        fp_rdoq_last_x_w2 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_8x8_2.txt", "w");
        fp_rdoq_last_x_w3 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_8x8_3.txt", "w");
        for (wr_rdoq_last_x_j = 0; wr_rdoq_last_x_j < 8; wr_rdoq_last_x_j = wr_rdoq_last_x_j + 1) begin
            for (wr_rdoq_last_x_k = 0; wr_rdoq_last_x_k < 32; wr_rdoq_last_x_k = wr_rdoq_last_x_k + 1) begin
                rdoq_last_x_data[wr_rdoq_last_x_k] = rdoq_last_x[wr_rdoq_last_x_k];
            end
            #2;
            $fwrite(fp_rdoq_last_x_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_x_data[0 ], rdoq_last_x_data[1 ], rdoq_last_x_data[2 ], rdoq_last_x_data[3 ], rdoq_last_x_data[4 ], rdoq_last_x_data[5 ], rdoq_last_x_data[6 ], rdoq_last_x_data[7 ]);
            $fwrite(fp_rdoq_last_x_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_x_data[8 ], rdoq_last_x_data[9 ], rdoq_last_x_data[10], rdoq_last_x_data[11], rdoq_last_x_data[12], rdoq_last_x_data[13], rdoq_last_x_data[14], rdoq_last_x_data[15]);
            $fwrite(fp_rdoq_last_x_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_x_data[16], rdoq_last_x_data[17], rdoq_last_x_data[18], rdoq_last_x_data[19], rdoq_last_x_data[20], rdoq_last_x_data[21], rdoq_last_x_data[22], rdoq_last_x_data[23]); 
            $fwrite(fp_rdoq_last_x_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_x_data[24], rdoq_last_x_data[25], rdoq_last_x_data[26], rdoq_last_x_data[27], rdoq_last_x_data[28], rdoq_last_x_data[29], rdoq_last_x_data[30], rdoq_last_x_data[31]);
        end
        $fclose(fp_rdoq_last_x_w0);
        $fclose(fp_rdoq_last_x_w1);
        $fclose(fp_rdoq_last_x_w2);
        $fclose(fp_rdoq_last_x_w3);
    end

    initial begin 
    integer fp_rdoq_last_y_w0,fp_rdoq_last_y_w1,fp_rdoq_last_y_w2,fp_rdoq_last_y_w3;
    integer wr_rdoq_last_y_j,wr_rdoq_last_y_k;
    reg     signed  [63: 0]     rdoq_last_y_data        [0 : 63]    ;
        #116;
        fp_rdoq_last_y_w0 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_8x8_0.txt", "w");
        fp_rdoq_last_y_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_8x8_1.txt", "w");
        fp_rdoq_last_y_w2 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_8x8_2.txt", "w");
        fp_rdoq_last_y_w3 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_8x8_3.txt", "w");
        for (wr_rdoq_last_y_j = 0; wr_rdoq_last_y_j < 8; wr_rdoq_last_y_j = wr_rdoq_last_y_j + 1) begin
            for (wr_rdoq_last_y_k = 0; wr_rdoq_last_y_k < 32; wr_rdoq_last_y_k = wr_rdoq_last_y_k + 1) begin
                rdoq_last_y_data[wr_rdoq_last_y_k] = rdoq_last_y[wr_rdoq_last_y_k];
            end
            #2;
            $fwrite(fp_rdoq_last_y_w0, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_y_data[0 ], rdoq_last_y_data[1 ], rdoq_last_y_data[2 ], rdoq_last_y_data[3 ], rdoq_last_y_data[4 ], rdoq_last_y_data[5 ], rdoq_last_y_data[6 ], rdoq_last_y_data[7 ]);
            $fwrite(fp_rdoq_last_y_w1, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_y_data[8 ], rdoq_last_y_data[9 ], rdoq_last_y_data[10], rdoq_last_y_data[11], rdoq_last_y_data[12], rdoq_last_y_data[13], rdoq_last_y_data[14], rdoq_last_y_data[15]);
            $fwrite(fp_rdoq_last_y_w2, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_y_data[16], rdoq_last_y_data[17], rdoq_last_y_data[18], rdoq_last_y_data[19], rdoq_last_y_data[20], rdoq_last_y_data[21], rdoq_last_y_data[22], rdoq_last_y_data[23]); 
            $fwrite(fp_rdoq_last_y_w3, "%6d %6d %6d %6d %6d %6d %6d %6d \n", 
                rdoq_last_y_data[24], rdoq_last_y_data[25], rdoq_last_y_data[26], rdoq_last_y_data[27], rdoq_last_y_data[28], rdoq_last_y_data[29], rdoq_last_y_data[30], rdoq_last_y_data[31]);
        end
        $fclose(fp_rdoq_last_y_w0);
        $fclose(fp_rdoq_last_y_w1);
        $fclose(fp_rdoq_last_y_w2);
        $fclose(fp_rdoq_last_y_w3);
    end

//4x4
    initial begin 
    integer fp_tempCost_w0,fp_tempCost_w1,fp_tempCost_w2,fp_tempCost_w3,fp_tempCost_w4,fp_tempCost_w5,fp_tempCost_w6,fp_tempCost_w7;
    integer wr_tempCost_j,wr_tempCost_k;
    reg     signed  [63: 0]     tempCost_data        [0 : 63]    ;
    integer fp_endPosCost_w0,fp_endPosCost_w1,fp_endPosCost_w2,fp_endPosCost_w3,fp_endPosCost_w4,fp_endPosCost_w5,fp_endPosCost_w6,fp_endPosCost_w7;
    integer wr_endPosCost_j,wr_endPosCost_k;
    reg     signed  [63: 0]     endPosCost_data        [0 : 63]    ;
    reg     column_count   ;
        #132;
        fp_tempCost_w0 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_4x4_0.txt", "w");
        fp_tempCost_w1 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_4x4_1.txt", "w");
        fp_tempCost_w2 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_4x4_2.txt", "w");
        fp_tempCost_w3 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_4x4_3.txt", "w");
        fp_tempCost_w4 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_4x4_4.txt", "w");
        fp_tempCost_w5 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_4x4_5.txt", "w");
        fp_tempCost_w6 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_4x4_6.txt", "w");
        fp_tempCost_w7 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_4x4_7.txt", "w");
        fp_endPosCost_w0 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_0.txt", "w");
        fp_endPosCost_w1 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_1.txt", "w");
        fp_endPosCost_w2 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_2.txt", "w");
        fp_endPosCost_w3 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_3.txt", "w");
        fp_endPosCost_w4 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_4.txt", "w");
        fp_endPosCost_w5 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_5.txt", "w");
        fp_endPosCost_w6 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_6.txt", "w");
        fp_endPosCost_w7 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_7.txt", "w");
        column_count    <=  0;
        for (wr_tempCost_j = 0; wr_tempCost_j < 4; wr_tempCost_j = wr_tempCost_j + 1) begin
            for (wr_tempCost_k = 0; wr_tempCost_k < 32; wr_tempCost_k = wr_tempCost_k + 1) begin
                tempCost_data[wr_tempCost_k] = tempCost[wr_tempCost_k];
                endPosCost_data[wr_tempCost_k] = endPosCost[wr_tempCost_k];
            end
            #2;
            $fwrite(fp_tempCost_w0, "%6d %6d %6d %6d \n", 
                tempCost_data[0 ], tempCost_data[1 ], tempCost_data[2 ], tempCost_data[3 ]);
            $fwrite(fp_tempCost_w1, "%6d %6d %6d %6d \n", 
                tempCost_data[4 ], tempCost_data[5 ], tempCost_data[6 ], tempCost_data[7 ]);
            $fwrite(fp_tempCost_w2, "%6d %6d %6d %6d \n", 
                tempCost_data[8 ], tempCost_data[9 ], tempCost_data[10], tempCost_data[11]);
            $fwrite(fp_tempCost_w3, "%6d %6d %6d %6d \n", 
                tempCost_data[12], tempCost_data[13], tempCost_data[14], tempCost_data[15]);
            $fwrite(fp_tempCost_w4, "%6d %6d %6d %6d \n", 
                tempCost_data[16], tempCost_data[17], tempCost_data[18], tempCost_data[19]);
            $fwrite(fp_tempCost_w5, "%6d %6d %6d %6d \n", 
                tempCost_data[20], tempCost_data[21], tempCost_data[22], tempCost_data[23]); 
            $fwrite(fp_tempCost_w6, "%6d %6d %6d %6d \n", 
                tempCost_data[24], tempCost_data[25], tempCost_data[26], tempCost_data[27]);
            $fwrite(fp_tempCost_w7, "%6d %6d %6d %6d \n", 
                tempCost_data[28], tempCost_data[29], tempCost_data[30], tempCost_data[31]);

            if(column_count % 2)begin
                $fwrite(fp_endPosCost_w0, "%6d %6d %6d %6d \n", 
                    tempCost_data[0 ] - endPosCost_data[0 ], endPosCost_data[1 ], endPosCost_data[2 ], endPosCost_data[3 ]);
                $fwrite(fp_endPosCost_w1, "%6d %6d %6d %6d \n", 
                    tempCost_data[4 ] - endPosCost_data[4 ], endPosCost_data[5 ], endPosCost_data[6 ], endPosCost_data[7 ]);
                $fwrite(fp_endPosCost_w2, "%6d %6d %6d %6d \n", 
                    tempCost_data[8 ] - endPosCost_data[8 ], endPosCost_data[9 ], endPosCost_data[10], endPosCost_data[11]);
                $fwrite(fp_endPosCost_w3, "%6d %6d %6d %6d \n", 
                    tempCost_data[12] - endPosCost_data[12], endPosCost_data[13], endPosCost_data[14], endPosCost_data[15]);
                $fwrite(fp_endPosCost_w4, "%6d %6d %6d %6d \n", 
                    tempCost_data[16] - endPosCost_data[16], endPosCost_data[17], endPosCost_data[18], endPosCost_data[19]);
                $fwrite(fp_endPosCost_w5, "%6d %6d %6d %6d \n", 
                    tempCost_data[20] - endPosCost_data[20], endPosCost_data[21], endPosCost_data[22], endPosCost_data[23]); 
                $fwrite(fp_endPosCost_w6, "%6d %6d %6d %6d \n", 
                    tempCost_data[24] - endPosCost_data[24], endPosCost_data[25], endPosCost_data[26], endPosCost_data[27]);
                $fwrite(fp_endPosCost_w7, "%6d %6d %6d %6d \n", 
                    tempCost_data[28] - endPosCost_data[28], endPosCost_data[29], endPosCost_data[30], endPosCost_data[31]);
            end
            else begin
                $fwrite(fp_endPosCost_w0, "%6d %6d %6d %6d \n", 
                    endPosCost_data[0 ], endPosCost_data[1 ], endPosCost_data[2 ], endPosCost_data[3 ]);
                $fwrite(fp_endPosCost_w1, "%6d %6d %6d %6d \n", 
                    endPosCost_data[4 ], endPosCost_data[5 ], endPosCost_data[6 ], endPosCost_data[7 ]);
                $fwrite(fp_endPosCost_w2, "%6d %6d %6d %6d \n", 
                    endPosCost_data[8 ], endPosCost_data[9 ], endPosCost_data[10], endPosCost_data[11]);
                $fwrite(fp_endPosCost_w3, "%6d %6d %6d %6d \n", 
                    endPosCost_data[12], endPosCost_data[13], endPosCost_data[14], endPosCost_data[15]);
                $fwrite(fp_endPosCost_w4, "%6d %6d %6d %6d \n", 
                    endPosCost_data[16], endPosCost_data[17], endPosCost_data[18], endPosCost_data[19]);
                $fwrite(fp_endPosCost_w5, "%6d %6d %6d %6d \n", 
                    endPosCost_data[20], endPosCost_data[21], endPosCost_data[22], endPosCost_data[23]); 
                $fwrite(fp_endPosCost_w6, "%6d %6d %6d %6d \n", 
                    endPosCost_data[24], endPosCost_data[25], endPosCost_data[26], endPosCost_data[27]);
                $fwrite(fp_endPosCost_w7, "%6d %6d %6d %6d \n", 
                    endPosCost_data[28], endPosCost_data[29], endPosCost_data[30], endPosCost_data[31]);
            end
            column_count    <=  column_count + 1;
        end
        $fclose(fp_tempCost_w0);
        $fclose(fp_tempCost_w1);
        $fclose(fp_tempCost_w2);
        $fclose(fp_tempCost_w3);
        $fclose(fp_tempCost_w4);
        $fclose(fp_tempCost_w5);
        $fclose(fp_tempCost_w6);
        $fclose(fp_tempCost_w7);
        $fclose(fp_endPosCost_w0);
        $fclose(fp_endPosCost_w1);
        $fclose(fp_endPosCost_w2);
        $fclose(fp_endPosCost_w3);
        $fclose(fp_endPosCost_w4);
        $fclose(fp_endPosCost_w5);
        $fclose(fp_endPosCost_w6);
        $fclose(fp_endPosCost_w7);
    end

    initial begin 
    integer fp_rdoqD64LastOne_w0,fp_rdoqD64LastOne_w1,fp_rdoqD64LastOne_w2,fp_rdoqD64LastOne_w3,fp_rdoqD64LastOne_w4,fp_rdoqD64LastOne_w5,fp_rdoqD64LastOne_w6,fp_rdoqD64LastOne_w7;
    integer wr_rdoqD64LastOne_j,wr_rdoqD64LastOne_k;
    reg     signed  [63: 0]     rdoqD64LastOne_data        [0 : 63]    ;
        #132;
        fp_rdoqD64LastOne_w0 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_0.txt", "w");
        fp_rdoqD64LastOne_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_1.txt", "w");
        fp_rdoqD64LastOne_w2 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_2.txt", "w");
        fp_rdoqD64LastOne_w3 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_3.txt", "w");
        fp_rdoqD64LastOne_w4 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_4.txt", "w");
        fp_rdoqD64LastOne_w5 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_5.txt", "w");
        fp_rdoqD64LastOne_w6 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_6.txt", "w");
        fp_rdoqD64LastOne_w7 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_7.txt", "w");
        for (wr_rdoqD64LastOne_j = 0; wr_rdoqD64LastOne_j < 4; wr_rdoqD64LastOne_j = wr_rdoqD64LastOne_j + 1) begin
            for (wr_rdoqD64LastOne_k = 0; wr_rdoqD64LastOne_k < 32; wr_rdoqD64LastOne_k = wr_rdoqD64LastOne_k + 1) begin
                rdoqD64LastOne_data[wr_rdoqD64LastOne_k] = rdoqD64LastOne[wr_rdoqD64LastOne_k];
            end
            #2;
            $fwrite(fp_rdoqD64LastOne_w0, "%6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[0 ], rdoqD64LastOne_data[1 ], rdoqD64LastOne_data[2 ], rdoqD64LastOne_data[3 ]);
            $fwrite(fp_rdoqD64LastOne_w1, "%6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[4 ], rdoqD64LastOne_data[5 ], rdoqD64LastOne_data[6 ], rdoqD64LastOne_data[7 ]);
            $fwrite(fp_rdoqD64LastOne_w2, "%6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[8 ], rdoqD64LastOne_data[9 ], rdoqD64LastOne_data[10], rdoqD64LastOne_data[11]);
            $fwrite(fp_rdoqD64LastOne_w3, "%6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[12], rdoqD64LastOne_data[13], rdoqD64LastOne_data[14], rdoqD64LastOne_data[15]);
            $fwrite(fp_rdoqD64LastOne_w4, "%6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[16], rdoqD64LastOne_data[17], rdoqD64LastOne_data[18], rdoqD64LastOne_data[19]);
            $fwrite(fp_rdoqD64LastOne_w5, "%6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[20], rdoqD64LastOne_data[21], rdoqD64LastOne_data[22], rdoqD64LastOne_data[23]); 
            $fwrite(fp_rdoqD64LastOne_w6, "%6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[24], rdoqD64LastOne_data[25], rdoqD64LastOne_data[26], rdoqD64LastOne_data[27]);
            $fwrite(fp_rdoqD64LastOne_w7, "%6d %6d %6d %6d \n", 
                rdoqD64LastOne_data[28], rdoqD64LastOne_data[29], rdoqD64LastOne_data[30], rdoqD64LastOne_data[31]);
        end
        $fclose(fp_rdoqD64LastOne_w0);
        $fclose(fp_rdoqD64LastOne_w1);
        $fclose(fp_rdoqD64LastOne_w2);
        $fclose(fp_rdoqD64LastOne_w3);
        $fclose(fp_rdoqD64LastOne_w4);
        $fclose(fp_rdoqD64LastOne_w5);
        $fclose(fp_rdoqD64LastOne_w6);
        $fclose(fp_rdoqD64LastOne_w7);
    end

    initial begin 
    integer fp_rdoqD64LastZero_w0,fp_rdoqD64LastZero_w1,fp_rdoqD64LastZero_w2,fp_rdoqD64LastZero_w3,fp_rdoqD64LastZero_w4,fp_rdoqD64LastZero_w5,fp_rdoqD64LastZero_w6,fp_rdoqD64LastZero_w7;
    integer wr_rdoqD64LastZero_j,wr_rdoqD64LastZero_k;
    reg     signed  [63: 0]     rdoqD64LastZero_data        [0 : 63]    ;
        #132;
        fp_rdoqD64LastZero_w0 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_0.txt", "w");
        fp_rdoqD64LastZero_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_1.txt", "w");
        fp_rdoqD64LastZero_w2 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_2.txt", "w");
        fp_rdoqD64LastZero_w3 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_3.txt", "w");
        fp_rdoqD64LastZero_w4 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_4.txt", "w");
        fp_rdoqD64LastZero_w5 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_5.txt", "w");
        fp_rdoqD64LastZero_w6 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_6.txt", "w");
        fp_rdoqD64LastZero_w7 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_7.txt", "w");
        for (wr_rdoqD64LastZero_j = 0; wr_rdoqD64LastZero_j < 4; wr_rdoqD64LastZero_j = wr_rdoqD64LastZero_j + 1) begin
            for (wr_rdoqD64LastZero_k = 0; wr_rdoqD64LastZero_k < 32; wr_rdoqD64LastZero_k = wr_rdoqD64LastZero_k + 1) begin
                rdoqD64LastZero_data[wr_rdoqD64LastZero_k] = rdoqD64LastZero[wr_rdoqD64LastZero_k];
            end
            #2;
            $fwrite(fp_rdoqD64LastZero_w0, "%6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[0 ], rdoqD64LastZero_data[1 ], rdoqD64LastZero_data[2 ], rdoqD64LastZero_data[3 ]);
            $fwrite(fp_rdoqD64LastZero_w1, "%6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[4 ], rdoqD64LastZero_data[5 ], rdoqD64LastZero_data[6 ], rdoqD64LastZero_data[7 ]);
            $fwrite(fp_rdoqD64LastZero_w2, "%6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[8 ], rdoqD64LastZero_data[9 ], rdoqD64LastZero_data[10], rdoqD64LastZero_data[11]);
            $fwrite(fp_rdoqD64LastZero_w3, "%6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[12], rdoqD64LastZero_data[13], rdoqD64LastZero_data[14], rdoqD64LastZero_data[15]);
            $fwrite(fp_rdoqD64LastZero_w4, "%6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[16], rdoqD64LastZero_data[17], rdoqD64LastZero_data[18], rdoqD64LastZero_data[19]);
            $fwrite(fp_rdoqD64LastZero_w5, "%6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[20], rdoqD64LastZero_data[21], rdoqD64LastZero_data[22], rdoqD64LastZero_data[23]); 
            $fwrite(fp_rdoqD64LastZero_w6, "%6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[24], rdoqD64LastZero_data[25], rdoqD64LastZero_data[26], rdoqD64LastZero_data[27]);
            $fwrite(fp_rdoqD64LastZero_w7, "%6d %6d %6d %6d \n", 
                rdoqD64LastZero_data[28], rdoqD64LastZero_data[29], rdoqD64LastZero_data[30], rdoqD64LastZero_data[31]);
        end
        $fclose(fp_rdoqD64LastZero_w0);
        $fclose(fp_rdoqD64LastZero_w1);
        $fclose(fp_rdoqD64LastZero_w2);
        $fclose(fp_rdoqD64LastZero_w3);
        $fclose(fp_rdoqD64LastZero_w4);
        $fclose(fp_rdoqD64LastZero_w5);
        $fclose(fp_rdoqD64LastZero_w6);
        $fclose(fp_rdoqD64LastZero_w7);
    end

    initial begin 
    integer fp_rdoq_last_x_w0,fp_rdoq_last_x_w1,fp_rdoq_last_x_w2,fp_rdoq_last_x_w3,fp_rdoq_last_x_w4,fp_rdoq_last_x_w5,fp_rdoq_last_x_w6,fp_rdoq_last_x_w7;
    integer wr_rdoq_last_x_j,wr_rdoq_last_x_k;
    reg     signed  [63: 0]     rdoq_last_x_data        [0 : 63]    ;
        #132;
        fp_rdoq_last_x_w0 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_0.txt", "w");
        fp_rdoq_last_x_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_1.txt", "w");
        fp_rdoq_last_x_w2 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_2.txt", "w");
        fp_rdoq_last_x_w3 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_3.txt", "w");
        fp_rdoq_last_x_w4 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_4.txt", "w");
        fp_rdoq_last_x_w5 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_5.txt", "w");
        fp_rdoq_last_x_w6 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_6.txt", "w");
        fp_rdoq_last_x_w7 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_7.txt", "w");
        for (wr_rdoq_last_x_j = 0; wr_rdoq_last_x_j < 4; wr_rdoq_last_x_j = wr_rdoq_last_x_j + 1) begin
            for (wr_rdoq_last_x_k = 0; wr_rdoq_last_x_k < 32; wr_rdoq_last_x_k = wr_rdoq_last_x_k + 1) begin
                rdoq_last_x_data[wr_rdoq_last_x_k] = rdoq_last_x[wr_rdoq_last_x_k];
            end
            #2;
            $fwrite(fp_rdoq_last_x_w0, "%6d %6d %6d %6d \n", 
                rdoq_last_x_data[0 ], rdoq_last_x_data[1 ], rdoq_last_x_data[2 ], rdoq_last_x_data[3 ]);
            $fwrite(fp_rdoq_last_x_w1, "%6d %6d %6d %6d \n", 
                rdoq_last_x_data[4 ], rdoq_last_x_data[5 ], rdoq_last_x_data[6 ], rdoq_last_x_data[7 ]);
            $fwrite(fp_rdoq_last_x_w2, "%6d %6d %6d %6d \n", 
                rdoq_last_x_data[8 ], rdoq_last_x_data[9 ], rdoq_last_x_data[10], rdoq_last_x_data[11]);
            $fwrite(fp_rdoq_last_x_w3, "%6d %6d %6d %6d \n", 
                rdoq_last_x_data[12], rdoq_last_x_data[13], rdoq_last_x_data[14], rdoq_last_x_data[15]);
            $fwrite(fp_rdoq_last_x_w4, "%6d %6d %6d %6d \n", 
                rdoq_last_x_data[16], rdoq_last_x_data[17], rdoq_last_x_data[18], rdoq_last_x_data[19]);
            $fwrite(fp_rdoq_last_x_w5, "%6d %6d %6d %6d \n", 
                rdoq_last_x_data[20], rdoq_last_x_data[21], rdoq_last_x_data[22], rdoq_last_x_data[23]); 
            $fwrite(fp_rdoq_last_x_w6, "%6d %6d %6d %6d \n", 
                rdoq_last_x_data[24], rdoq_last_x_data[25], rdoq_last_x_data[26], rdoq_last_x_data[27]);
            $fwrite(fp_rdoq_last_x_w7, "%6d %6d %6d %6d \n", 
                rdoq_last_x_data[28], rdoq_last_x_data[29], rdoq_last_x_data[30], rdoq_last_x_data[31]);
        end
        $fclose(fp_rdoq_last_x_w0);
        $fclose(fp_rdoq_last_x_w1);
        $fclose(fp_rdoq_last_x_w2);
        $fclose(fp_rdoq_last_x_w3);
        $fclose(fp_rdoq_last_x_w4);
        $fclose(fp_rdoq_last_x_w5);
        $fclose(fp_rdoq_last_x_w6);
        $fclose(fp_rdoq_last_x_w7);
    end

    initial begin 
    integer fp_rdoq_last_y_w0,fp_rdoq_last_y_w1,fp_rdoq_last_y_w2,fp_rdoq_last_y_w3,fp_rdoq_last_y_w4,fp_rdoq_last_y_w5,fp_rdoq_last_y_w6,fp_rdoq_last_y_w7;
    integer wr_rdoq_last_y_j,wr_rdoq_last_y_k;
    reg     signed  [63: 0]     rdoq_last_y_data        [0 : 63]    ;
        #132;
        fp_rdoq_last_y_w0 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_0.txt", "w");
        fp_rdoq_last_y_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_1.txt", "w");
        fp_rdoq_last_y_w2 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_2.txt", "w");
        fp_rdoq_last_y_w3 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_3.txt", "w");
        fp_rdoq_last_y_w4 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_4.txt", "w");
        fp_rdoq_last_y_w5 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_5.txt", "w");
        fp_rdoq_last_y_w6 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_6.txt", "w");
        fp_rdoq_last_y_w7 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_7.txt", "w");
        for (wr_rdoq_last_y_j = 0; wr_rdoq_last_y_j < 4; wr_rdoq_last_y_j = wr_rdoq_last_y_j + 1) begin
            for (wr_rdoq_last_y_k = 0; wr_rdoq_last_y_k < 32; wr_rdoq_last_y_k = wr_rdoq_last_y_k + 1) begin
                rdoq_last_y_data[wr_rdoq_last_y_k] = rdoq_last_y[wr_rdoq_last_y_k];
            end
            #2;
            $fwrite(fp_rdoq_last_y_w0, "%6d %6d %6d %6d \n", 
                rdoq_last_y_data[0 ], rdoq_last_y_data[1 ], rdoq_last_y_data[2 ], rdoq_last_y_data[3 ]);
            $fwrite(fp_rdoq_last_y_w1, "%6d %6d %6d %6d \n", 
                rdoq_last_y_data[4 ], rdoq_last_y_data[5 ], rdoq_last_y_data[6 ], rdoq_last_y_data[7 ]);
            $fwrite(fp_rdoq_last_y_w2, "%6d %6d %6d %6d \n", 
                rdoq_last_y_data[8 ], rdoq_last_y_data[9 ], rdoq_last_y_data[10], rdoq_last_y_data[11]);
            $fwrite(fp_rdoq_last_y_w3, "%6d %6d %6d %6d \n", 
                rdoq_last_y_data[12], rdoq_last_y_data[13], rdoq_last_y_data[14], rdoq_last_y_data[15]);
            $fwrite(fp_rdoq_last_y_w4, "%6d %6d %6d %6d \n", 
                rdoq_last_y_data[16], rdoq_last_y_data[17], rdoq_last_y_data[18], rdoq_last_y_data[19]);
            $fwrite(fp_rdoq_last_y_w5, "%6d %6d %6d %6d \n", 
                rdoq_last_y_data[20], rdoq_last_y_data[21], rdoq_last_y_data[22], rdoq_last_y_data[23]); 
            $fwrite(fp_rdoq_last_y_w6, "%6d %6d %6d %6d \n", 
                rdoq_last_y_data[24], rdoq_last_y_data[25], rdoq_last_y_data[26], rdoq_last_y_data[27]);
            $fwrite(fp_rdoq_last_y_w7, "%6d %6d %6d %6d \n", 
                rdoq_last_y_data[28], rdoq_last_y_data[29], rdoq_last_y_data[30], rdoq_last_y_data[31]);
        end
        $fclose(fp_rdoq_last_y_w0);
        $fclose(fp_rdoq_last_y_w1);
        $fclose(fp_rdoq_last_y_w2);
        $fclose(fp_rdoq_last_y_w3);
        $fclose(fp_rdoq_last_y_w4);
        $fclose(fp_rdoq_last_y_w5);
        $fclose(fp_rdoq_last_y_w6);
        $fclose(fp_rdoq_last_y_w7);
    end



`endif


endmodule

