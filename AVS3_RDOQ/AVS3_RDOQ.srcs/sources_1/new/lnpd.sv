module lnpd(      
//system clk and rest       
    input                       clk                                             ,
    input                       rst_n                                           ,

//input parameter           
    input           [2 : 0]     i_width_log2                                    ,//the value is between 2 and 6
    input           [2 : 0]     i_height_log2                                   ,//the value is between 2 and 6            

//input data 
    input                       i_valid                                         ,
    input           [15 : 0]    i_level_opt             [0 : 31]                ,
    input                       i_tmp_dst_coef_sign     [0 : 31]                ,//the sign of tmp_dst_coef 1- 0+
    input   signed  [63 : 0]    i_d64_cost_last_zero    [0 : 31]                ,
    input   signed  [63 : 0]    i_d64_cost_last_one     [0 : 31]                , 
    input   signed  [63 : 0]    i_base_cost_buffer_tmp  [0 : 31]                ,

//output parameter                      

//output data                 
    output                      o_valid                                         
);


//local parameter definition

//integer definition
integer i,j,k,l,m   ;
genvar  o,p,q,r     ;

//reg definition
reg             [2  : 0]    i_width_log2_d1                                     ;//the value is between 2 and 6
reg             [2  : 0]    i_height_log2_d1                                    ;//the value is between 2 and 6  
reg             [15 : 0]    i_level_opt_d1              [0 : 31]                ;
reg     signed  [63 : 0]    i_d64_cost_last_zero_d1     [0 : 31]                ;
reg     signed  [63 : 0]    i_d64_cost_last_one_d1      [0 : 31]                ; 
reg     signed  [63 : 0]    i_base_cost_buffer_tmp_d1   [0 : 31]                ;

reg     signed  [63 : 0]    tempCost                    [0 : 31]                ;
reg     signed  [63 : 0]    endPosCost                  [0 : 31]                ;

reg     signed  [63 : 0]    rdoqD64LastZero             [0 : 31]                ;
reg     signed  [63 : 0]    rdoqD64LastOne              [0 : 31]                ;

reg             [6  : 0]    column_cnt                                          ;

reg     signed  [6  : 0]    rdoq_last_x                 [0 : 31]                ;
reg     signed  [6  : 0]    rdoq_last_y                 [0 : 31]                ;

//wire definition   

wire    signed  [63 : 0]    tempCost_tem                [0 : 31]                ;
wire    signed  [63 : 0]    rdoqD64LastZero_tem         [0 : 31]                ;
wire    signed  [63 : 0]    rdoqD64LastOne_tem          [0 : 31]                ;
wire    signed  [6  : 0]    rdoq_last_x_tem             [0 : 31]                ;
wire    signed  [6  : 0]    rdoq_last_y_tem             [0 : 31]                ;
wire    signed  [63 : 0]    endPosCost_tem              [0 : 31]                ;

//assignment


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

    //do shift operation to the former temCost
    generate
        for(o = 1; o < 32; o = o + 1)begin
            assign  tempCost_tem[o - 1]     =   tempCost[o];
        end
        assign  tempCost_tem[31]    =   tempCost[31];
    endgenerate

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
            for(i = 8 ; i < 15; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end            
            for(i = 16; i < 31; i = i + 1)begin
                tempCost[i]     <=  i_base_cost_buffer_tmp_d1[i] + tempCost_tem[i];
            end
            //determine the value of the last row 
            case(i_height_log2_d1)
                3'd2: begin    
                        tempCost[3 ]    <=  i_base_cost_buffer_tmp_d1[3 ];
                        tempCost[7 ]    <=  0;//pending, not used
                        tempCost[15]    <=  0;//pending, not used
                        tempCost[31]    <=  0;//pending, not used
                    end
                3'd3: begin
                        tempCost[3 ]    <=  i_base_cost_buffer_tmp_d1[3 ] + tempCost_tem[3 ];
                        tempCost[7 ]    <=  i_base_cost_buffer_tmp_d1[7 ];
                        tempCost[15]    <=  0;//pending, not used
                        tempCost[31]    <=  0;//pending, not used
                    end
                3'd4: begin
                        tempCost[3 ]    <=  i_base_cost_buffer_tmp_d1[3 ] + tempCost_tem[3 ];
                        tempCost[7 ]    <=  i_base_cost_buffer_tmp_d1[7 ] + tempCost_tem[7 ];
                        tempCost[15]    <=  i_base_cost_buffer_tmp_d1[15];
                        tempCost[31]    <=  0;//pending, not used
                    end
                3'd5: begin
                        tempCost[3 ]    <=  i_base_cost_buffer_tmp_d1[3 ] + tempCost_tem[3 ];
                        tempCost[7 ]    <=  i_base_cost_buffer_tmp_d1[7 ] + tempCost_tem[7 ];
                        tempCost[15]    <=  i_base_cost_buffer_tmp_d1[15] + tempCost_tem[15];
                        tempCost[31]    <=  i_base_cost_buffer_tmp_d1[31];
                    end
                default : begin
                        tempCost[3 ]    <=  0;
                        tempCost[7 ]    <=  0;
                        tempCost[15]    <=  0;
                        tempCost[31]    <=  0;
                    end
            endcase
        end
    end




    //do shift operation to the former rdoqD64LastOne and rdoqD64LastZero
    generate
        for(o = 1; o < 32; o = o + 1)begin
            assign  rdoqD64LastOne_tem [o - 1]     =   rdoqD64LastOne [o];
            assign  rdoqD64LastZero_tem[o - 1]     =   rdoqD64LastZero[o];
        end
        assign  rdoqD64LastOne_tem [31]    =   rdoqD64LastOne [31];
        assign  rdoqD64LastZero_tem[31]    =   rdoqD64LastZero[31];
    endgenerate

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
                    if(rdoq_last_y[i] != -1)begin
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
            for(i = 1; i < 3; i = i + 2)begin
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
            for(i = 5; i < 7; i = i + 2)begin
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
            for(i = 9; i < 15; i = i + 2)begin
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
            for(i = 17; i < 31; i = i + 2)begin
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
                            rdoqD64LastOne  [ 3]    <=  i_d64_cost_last_one_d1 [ 3]  ;
                            rdoqD64LastZero [ 3]    <=  i_d64_cost_last_zero_d1[ 3]  ;
                        end
                        else begin
                            rdoqD64LastOne  [ 3]    <=  rdoqD64LastOne_tem[ 3]       ;
                            rdoqD64LastZero [ 3]    <=  rdoqD64LastZero_tem[ 3]      ;
                        end
                        rdoqD64LastOne  [ 7]    <=  0;//pending, not used
                        rdoqD64LastZero [ 7]    <=  0;//pending, not used
                        rdoqD64LastOne  [15]    <=  0;//pending, not used
                        rdoqD64LastZero [15]    <=  0;//pending, not used
                        rdoqD64LastOne  [31]    <=  0;//pending, not used
                        rdoqD64LastZero [31]    <=  0;//pending, not used
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

                        rdoqD64LastOne  [15]    <=  0;//pending, not used
                        rdoqD64LastZero [15]    <=  0;//pending, not used
                        rdoqD64LastOne  [31]    <=  0;//pending, not used
                        rdoqD64LastZero [31]    <=  0;//pending, not used
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

                        if(i_level_opt_d1[15])begin
                            rdoqD64LastOne  [15]    <=  i_d64_cost_last_one_d1 [15]  ;
                            rdoqD64LastZero [15]    <=  i_d64_cost_last_zero_d1[15]  ;
                        end
                        else begin
                            rdoqD64LastOne  [15]    <=  rdoqD64LastOne_tem [15]      ;
                            rdoqD64LastZero [15]    <=  rdoqD64LastZero_tem[15]      ;
                        end

                        rdoqD64LastOne  [31]    <=  0;//pending, not used
                        rdoqD64LastZero [31]    <=  0;//pending, not used
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
                        rdoqD64LastOne  [15]    <=  0;
                        rdoqD64LastZero [15]    <=  0;
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
                for(i = 1; i < 3; i = i + 2)begin
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
                for(i = 5; i < 7; i = i + 2)begin
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
                for(i = 9; i < 15; i = i + 2)begin
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
                for(i = 17; i < 31; i = i + 2)begin
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
                            if(i_level_opt_d1[ 3])begin
                                rdoqD64LastOne  [ 3]    <=  i_d64_cost_last_one_d1 [ 3]  ;
                                rdoqD64LastZero [ 3]    <=  i_d64_cost_last_zero_d1[ 3]  ;
                            end
                            else begin
                                rdoqD64LastOne  [ 3]    <=  rdoqD64LastOne_tem  [ 3]    ;
                                rdoqD64LastZero [ 3]    <=  rdoqD64LastZero_tem [ 3]    ;
                            end
                            rdoqD64LastOne  [ 7]    <=  0;//pending, not used
                            rdoqD64LastZero [ 7]    <=  0;//pending, not used
                            rdoqD64LastOne  [15]    <=  0;//pending, not used
                            rdoqD64LastZero [15]    <=  0;//pending, not used
                            rdoqD64LastOne  [31]    <=  0;//pending, not used
                            rdoqD64LastZero [31]    <=  0;//pending, not used
                        end
                    3'd3    : begin
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
                                rdoqD64LastOne  [ 7]    <=  i_d64_cost_last_one_d1 [ 7]  ;
                                rdoqD64LastZero [ 7]    <=  i_d64_cost_last_zero_d1[ 7]  ;
                            end
                            else begin
                                rdoqD64LastOne  [ 7]    <=  rdoqD64LastOne_tem [ 7]  ;
                                rdoqD64LastZero [ 7]    <=  rdoqD64LastZero_tem[ 7]  ;
                            end

                            rdoqD64LastOne  [15]    <=  0;//pending, not used
                            rdoqD64LastZero [15]    <=  0;//pending, not used
                            rdoqD64LastOne  [31]    <=  0;//pending, not used
                            rdoqD64LastZero [31]    <=  0;//pending, not used
                        end
                    3'd4    : begin
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
                            
                            if(i_level_opt_d1[15])begin
                                rdoqD64LastOne  [15]    <=  i_d64_cost_last_one_d1 [15]  ;
                                rdoqD64LastZero [15]    <=  i_d64_cost_last_zero_d1[15]  ;
                            end
                            else begin
                                rdoqD64LastOne  [15]    <=  rdoqD64LastOne_tem [15]  ;
                                rdoqD64LastZero [15]    <=  rdoqD64LastZero_tem[15]  ;
                            end


                            rdoqD64LastOne  [31]    <=  0;//pending, not used
                            rdoqD64LastZero [31]    <=  0;//pending, not used
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
                            rdoqD64LastOne  [15]    <=  0;
                            rdoqD64LastZero [15]    <=  0;
                            rdoqD64LastOne  [31]    <=  0;
                            rdoqD64LastZero [31]    <=  0;
                        end
                endcase
            end
        end
    end

    //do shift operation to the former rdoq_last_x and rdoq_last_y
    generate
        for(o = 1; o < 32; o = o + 1)begin
            assign  rdoq_last_x_tem[o - 1]     =   rdoq_last_x[o];
            assign  rdoq_last_y_tem[o - 1]     =   rdoq_last_y[o];
        end
        assign  rdoq_last_x_tem[31]    =   rdoq_last_x[31];
        assign  rdoq_last_y_tem[31]    =   rdoq_last_y[31];
    endgenerate

    //calculate rdoq_last_x and rdoq_last_y
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                rdoq_last_x [i] = -1;
                rdoq_last_y [i] = -1;
            end
        end
        else if(column_cnt[0])begin
            for(i = 0; i < 32; i = i + 2)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                            rdoq_last_x[i]      <=      i                   ;
                            rdoq_last_y[i]      <=      column_cnt          ;
                        end
                        else begin
                            rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                            rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      i           ;
                        rdoq_last_y[i]      <=      column_cnt  ;
                    end
                end
                else begin
                    rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                    rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                end
            end
            
            //odd rows except the last row of each matrix
            for(i = 1; i < 3; i = i + 2)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            rdoq_last_x[i]      <=      i           ;
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                        else begin
                            rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                            rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      i           ;
                        rdoq_last_y[i]      <=      column_cnt  ;
                    end
                end
                else begin
                    rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                    rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                end
            end
            for(i = 5; i < 7; i = i + 2)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            rdoq_last_x[i]      <=      i           ;
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                        else begin
                            rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                            rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      i           ;
                        rdoq_last_y[i]      <=      column_cnt  ;
                    end
                end
                else begin
                    rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                    rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                end
            end
            for(i = 9; i < 15; i = i + 2)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            rdoq_last_x[i]      <=      i           ;
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                        else begin
                            rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                            rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      i           ;
                        rdoq_last_y[i]      <=      column_cnt  ;
                    end
                end
                else begin
                    rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                    rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                end
            end            
            for(i = 17; i < 31; i = i + 2)begin
                if(i_level_opt_d1[i])begin
                    if(rdoq_last_y_tem[i] != -1)begin
                        if( (tempCost_tem[i] + i_base_cost_buffer_tmp_d1[i] + i_d64_cost_last_one_d1[i] - i_d64_cost_last_zero_d1[i]) < (endPosCost_tem[i] + rdoqD64LastOne_tem[i] - rdoqD64LastZero_tem[i]) )begin
                            rdoq_last_x[i]      <=      i           ;
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                        else begin
                            rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                            rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      i           ;
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
                        if(i_level_opt_d1[ 3])begin
                            rdoq_last_x[ 3]    <=  3            ;
                            rdoq_last_y[ 3]    <=  column_cnt   ;
                        end
                        else begin
                            rdoq_last_x[ 3]    <=  -1   ;
                            rdoq_last_y[ 3]    <=  -1   ;
                        end
                        rdoq_last_x[ 7]    <=  0;//pending, not used
                        rdoq_last_y[ 7]    <=  0;//pending, not used
                        rdoq_last_x[15]    <=  0;//pending, not used
                        rdoq_last_y[15]    <=  0;//pending, not used
                        rdoq_last_x[31]    <=  0;//pending, not used
                        rdoq_last_y[31]    <=  0;//pending, not used
                    end
                3'd3    : begin
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
                            rdoq_last_x[ 7]    <=  7            ;
                            rdoq_last_y[ 7]    <=  column_cnt   ;
                        end
                        else begin
                            rdoq_last_x[ 7]    <=  -1   ;
                            rdoq_last_y[ 7]    <=  -1   ;
                        end
                        rdoq_last_x[15]    <=  0;//pending, not used
                        rdoq_last_y[15]    <=  0;//pending, not used
                        rdoq_last_x[31]    <=  0;//pending, not used
                        rdoq_last_y[31]    <=  0;//pending, not used
                    end
                3'd4    : begin
                        if(i_level_opt_d1[ 3])begin
                            if(rdoq_last_y_tem[ 3] != -1)begin
                                if( (tempCost_tem[ 3] + i_base_cost_buffer_tmp_d1[ 3] + i_d64_cost_last_one_d1[ 3] - i_d64_cost_last_zero_d1[ 3]) < (endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - rdoqD64LastZero_tem[ 3]) )begin
                                    rdoq_last_x[ 3]      <=      3           ;
                                    rdoq_last_y[ 3]      <=      column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[ 3]      <=      8;//rdoq_last_x_tem[ 3]  ;
                                    rdoq_last_y[ 3]      <=      8;//rdoq_last_y_tem[ 3]  ;
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

                        if(i_level_opt_d1[15])begin
                            rdoq_last_x[15]    <=  15           ;
                            rdoq_last_y[15]    <=  column_cnt   ;
                        end
                        else begin
                            rdoq_last_x[15]    <=  -1   ;
                            rdoq_last_y[15]    <=  -1   ;
                        end
                        rdoq_last_x[31]    <=  0;//pending, not used
                        rdoq_last_y[31]    <=  0;//pending, not used
                    end
                3'd5    : begin
                        if(i_level_opt_d1[ 3])begin
                            if(rdoq_last_y_tem[ 3] != -1)begin
                                if( (tempCost_tem[ 3] + i_base_cost_buffer_tmp_d1[ 3] + i_d64_cost_last_one_d1[ 3] - i_d64_cost_last_zero_d1[ 3]) < (endPosCost_tem[ 3] + rdoqD64LastOne_tem[ 3] - rdoqD64LastZero_tem[ 3]) )begin
                                    rdoq_last_x[ 3]      <=      3           ;
                                    rdoq_last_y[ 3]      <=      column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[ 3]      <=      8;//rdoq_last_x_tem[ 3]  ;
                                    rdoq_last_y[ 3]      <=      8;//rdoq_last_y_tem[ 3]  ;
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

                        if(i_level_opt_d1[15])begin
                            if(rdoq_last_y_tem[15] != -1)begin
                                if( (tempCost_tem[15] + i_base_cost_buffer_tmp_d1[15] + i_d64_cost_last_one_d1[15] - i_d64_cost_last_zero_d1[15]) < (endPosCost_tem[15] + rdoqD64LastOne_tem[15] - rdoqD64LastZero_tem[15]) )begin
                                    rdoq_last_x[15]      <=     15           ;
                                    rdoq_last_y[15]      <=      column_cnt  ;
                                end
                                else begin
                                    rdoq_last_x[15]      <=      rdoq_last_x_tem[15]  ;
                                    rdoq_last_y[15]      <=      rdoq_last_y_tem[15]  ;
                                end
                            end
                            else begin
                                rdoq_last_x[15]      <=     15           ;
                                rdoq_last_y[15]      <=      column_cnt  ;
                            end
                        end
                        else begin
                            rdoq_last_x[15]      <=      rdoq_last_x_tem[15]  ;
                            rdoq_last_y[15]      <=      rdoq_last_y_tem[15]  ;
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
                        rdoqD64LastOne  [ 3]    <=  0;
                        rdoqD64LastZero [ 3]    <=  0;
                        rdoqD64LastOne  [ 7]    <=  0;
                        rdoqD64LastZero [ 7]    <=  0;
                        rdoqD64LastOne  [15]    <=  0;
                        rdoqD64LastZero [15]    <=  0;
                        rdoqD64LastOne  [31]    <=  0;
                        rdoqD64LastZero [31]    <=  0;
                    end
            endcase
        end
        else begin
            //the first column
            if(column_cnt == 0)begin
                for(i = 0; i < 32; i = i + 1)begin
                    if(i_level_opt_d1[i])begin
                            rdoq_last_x[i]      <=      i           ;
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
                                rdoq_last_x[i]      <=      i           ;
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            rdoq_last_x[i]      <=      i           ;
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                        rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                    end
                end

                //odd rows except the last row of each matrix
                for(i = 1; i < 3; i = i + 2)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                rdoq_last_x[i]      <=      i           ;
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            rdoq_last_x[i]      <=      i           ;
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                        rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                    end
                end
                for(i = 5; i < 7; i = i + 2)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                rdoq_last_x[i]      <=      i           ;
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            rdoq_last_x[i]      <=      i           ;
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                        rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                    end
                end
                for(i = 9; i < 15; i = i + 2)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                rdoq_last_x[i]      <=      i           ;
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            rdoq_last_x[i]      <=      i           ;
                            rdoq_last_y[i]      <=      column_cnt  ;
                        end
                    end
                    else begin
                        rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                        rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                    end
                end            
                for(i = 17; i < 31; i = i + 2)begin
                    if(i_level_opt_d1[i])begin
                        if(rdoq_last_y_tem[i] != -1)begin
                            if(tempCost_tem[i] - endPosCost_tem[i] + rdoqD64LastOne_tem[i] - i_d64_cost_last_one_d1[i] + i_d64_cost_last_zero_d1[i] - rdoqD64LastZero_tem[i] > 0)begin
                                rdoq_last_x[i]      <=      i           ;
                                rdoq_last_y[i]      <=      column_cnt  ;
                            end
                            else begin
                                rdoq_last_x[i]      <=      rdoq_last_x_tem[i]  ;
                                rdoq_last_y[i]      <=      rdoq_last_y_tem[i]  ;
                            end
                        end
                        else begin
                            rdoq_last_x[i]      <=      i           ;
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
                            if(i_level_opt_d1[ 3])begin
                                rdoq_last_x[ 3]    <=  3            ;
                                rdoq_last_y[ 3]    <=  column_cnt   ;
                            end
                            else begin
                                rdoq_last_x[ 3]    <=  -1   ;
                                rdoq_last_y[ 3]    <=  -1   ;
                            end
                            rdoq_last_x[ 7]    <=  0;//pending, not used
                            rdoq_last_y[ 7]    <=  0;//pending, not used
                            rdoq_last_x[15]    <=  0;//pending, not used
                            rdoq_last_y[15]    <=  0;//pending, not used
                            rdoq_last_x[31]    <=  0;//pending, not used
                            rdoq_last_y[31]    <=  0;//pending, not used
                        end
                    3'd3    : begin
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
                                rdoq_last_x[ 7]    <=  7            ;
                                rdoq_last_y[ 7]    <=  column_cnt   ;
                            end
                            else begin
                                rdoq_last_x[ 7]    <=  -1   ;
                                rdoq_last_y[ 7]    <=  -1   ;
                            end
                            rdoq_last_x[15]    <=  0;//pending, not used
                            rdoq_last_y[15]    <=  0;//pending, not used
                            rdoq_last_x[31]    <=  0;//pending, not used
                            rdoq_last_y[31]    <=  0;//pending, not used
                        end
                    3'd4    : begin
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
                            if(i_level_opt_d1[15])begin
                                rdoq_last_x[15]    <=  15           ;
                                rdoq_last_y[15]    <=  column_cnt   ;
                            end
                            else begin
                                rdoq_last_x[15]    <=  -1   ;
                                rdoq_last_y[15]    <=  -1   ;
                            end
                            rdoq_last_x[31]    <=  0;//pending, not used
                            rdoq_last_y[31]    <=  0;//pending, not used
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
                            rdoqD64LastOne  [ 3]    <=  0;
                            rdoqD64LastZero [ 3]    <=  0;
                            rdoqD64LastOne  [ 7]    <=  0;
                            rdoqD64LastZero [ 7]    <=  0;
                            rdoqD64LastOne  [15]    <=  0;
                            rdoqD64LastZero [15]    <=  0;
                            rdoqD64LastOne  [31]    <=  0;
                            rdoqD64LastZero [31]    <=  0;
                        end
                endcase
            end
        end
    end

    wire    calculate_0[0 : 31];
    wire    calculate_1[0 : 31];
    generate 
        for(o = 0; o < 32; o = o + 1)begin
            assign  calculate_0[o]  =    tempCost_tem[o] - endPosCost_tem[o] + rdoqD64LastOne_tem[o] - i_d64_cost_last_one_d1[o] + i_d64_cost_last_zero_d1[o] - rdoqD64LastZero_tem[o] > 0;
            assign  calculate_1[o]  =    (tempCost_tem[o] + i_base_cost_buffer_tmp_d1[o] + i_d64_cost_last_one_d1[o] - i_d64_cost_last_zero_d1[o]) < (endPosCost_tem[o] + rdoqD64LastOne_tem[o] - rdoqD64LastZero_tem[o]);
        end
    endgenerate

    //do shift operation to the former endPosCost
    generate
        for(o = 1; o < 32; o = o + 1)begin
            assign  endPosCost_tem[o - 1]     =   endPosCost[o];
        end
        assign  endPosCost_tem[31]    =   endPosCost[31];
    endgenerate

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
            for(i = 1; i < 3; i = i + 2)begin
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
            for(i = 5; i < 7; i = i + 2)begin
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
            for(i = 9; i < 15; i = i + 2)begin
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
            for(i = 17; i < 31; i = i + 2)begin
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
                        endPosCost[ 3]      <=      i_level_opt_d1[ 3] != 0 ? i_base_cost_buffer_tmp_d1[ 3] : 0;
                        endPosCost[ 7]      <=      0;//pending, not used
                        endPosCost[15]      <=      0;//pending, not used
                        endPosCost[31]      <=      0;//pending, not used
                    end
                3'd3    : begin
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
                        endPosCost[ 7]      <=      i_level_opt_d1[ 7] != 0 ? i_base_cost_buffer_tmp_d1[ 7] : 0;
                        endPosCost[15]      <=      0;//pending, not used
                        endPosCost[31]      <=      0;//pending, not used
                    end
                3'd4    : begin
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
                        endPosCost[15]      <=      i_level_opt_d1[15] != 0 ? i_base_cost_buffer_tmp_d1[15] : 0;
                        endPosCost[31]      <=      0;//pending, not used
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
                        endPosCost[31]      <=      i_level_opt_d1[31] != 0 ? i_base_cost_buffer_tmp_d1[31] : 0;
                    end
                default : begin
                        endPosCost[ 3]      <=      0;
                        endPosCost[ 7]      <=      0;
                        endPosCost[15]      <=      0;
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
                for(i = 1; i < 3; i = i + 2)begin
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
                for(i = 5; i < 7; i = i + 2)begin
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
                for(i = 9; i < 15; i = i + 2)begin
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
                for(i = 17; i < 31; i = i + 2)begin
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
                            endPosCost[ 3]      <=      i_level_opt_d1[ 3] == 0 ? i_base_cost_buffer_tmp_d1[ 3] : 0;
                            endPosCost[ 7]      <=      0;//pending, not used
                            endPosCost[15]      <=      0;//pending, not used
                            endPosCost[31]      <=      0;//pending, not used
                        end
                    3'd3    : begin
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

                            endPosCost[ 7]      <=      i_level_opt_d1[ 7] == 0 ? i_base_cost_buffer_tmp_d1[ 7] : 0;
                            endPosCost[15]      <=      0;//pending, not used
                            endPosCost[31]      <=      0;//pending, not used
                        end
                    3'd4    : begin
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

                            endPosCost[15]      <=      i_level_opt_d1[15] == 0 ? i_base_cost_buffer_tmp_d1[15] : 0;
                            endPosCost[31]      <=      0;//pending, not used
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

                            endPosCost[31]      <=      i_level_opt_d1[31] == 0 ? i_base_cost_buffer_tmp_d1[31] : 0;
                        end
                    default : begin
                            endPosCost[ 3]      <=      0;
                            endPosCost[ 7]      <=      0;
                            endPosCost[15]      <=      0;
                            endPosCost[31]      <=      0;
                        end
                endcase
            end
        end
    end







//test bench

integer fp_tempCost_w1;
integer wr_tempCost_j,wr_tempCost_k;
reg     signed  [63: 0]     tempCost_data        [0 : 63]    ;
initial begin 
    #18;
    fp_tempCost_w1 = $fopen("../../../../../result/lnpd/fpga_tempCost/fpga_tempCost_16x16.txt", "w");
    for (wr_tempCost_j = 0; wr_tempCost_j < 16; wr_tempCost_j = wr_tempCost_j + 1) begin
        for (wr_tempCost_k = 0; wr_tempCost_k < 16; wr_tempCost_k = wr_tempCost_k + 1) begin
            tempCost_data[wr_tempCost_k] = tempCost[wr_tempCost_k];
        end
        #2;
        $fwrite(fp_tempCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            tempCost_data[0 ], tempCost_data[1 ], tempCost_data[2 ], tempCost_data[3 ], tempCost_data[4 ], tempCost_data[5 ], tempCost_data[6 ], tempCost_data[7 ], 
            tempCost_data[8 ], tempCost_data[9 ], tempCost_data[10], tempCost_data[11], tempCost_data[12], tempCost_data[13], tempCost_data[14], tempCost_data[15]);
    end
    $fclose(fp_tempCost_w1);
end


integer fp_rdoqD64LastOne_w1;
integer wr_rdoqD64LastOne_j,wr_rdoqD64LastOne_k;
reg     signed  [63: 0]     rdoqD64LastOne_data        [0 : 63]    ;
initial begin 
    #18;
    fp_rdoqD64LastOne_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_16x16.txt", "w");
    for (wr_rdoqD64LastOne_j = 0; wr_rdoqD64LastOne_j < 16; wr_rdoqD64LastOne_j = wr_rdoqD64LastOne_j + 1) begin
        for (wr_rdoqD64LastOne_k = 0; wr_rdoqD64LastOne_k < 16; wr_rdoqD64LastOne_k = wr_rdoqD64LastOne_k + 1) begin
            rdoqD64LastOne_data[wr_rdoqD64LastOne_k] = rdoqD64LastOne[wr_rdoqD64LastOne_k];
        end
        #2;
        $fwrite(fp_rdoqD64LastOne_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            rdoqD64LastOne_data[0 ], rdoqD64LastOne_data[1 ], rdoqD64LastOne_data[2 ], rdoqD64LastOne_data[3 ], rdoqD64LastOne_data[4 ], rdoqD64LastOne_data[5 ], rdoqD64LastOne_data[6 ], rdoqD64LastOne_data[7 ], 
            rdoqD64LastOne_data[8 ], rdoqD64LastOne_data[9 ], rdoqD64LastOne_data[10], rdoqD64LastOne_data[11], rdoqD64LastOne_data[12], rdoqD64LastOne_data[13], rdoqD64LastOne_data[14], rdoqD64LastOne_data[15]);
    end
    $fclose(fp_rdoqD64LastOne_w1);
end

integer fp_rdoqD64LastZero_w1;
integer wr_rdoqD64LastZero_j,wr_rdoqD64LastZero_k;
reg     signed  [63: 0]     rdoqD64LastZero_data        [0 : 63]    ;
initial begin 
    #18;
    fp_rdoqD64LastZero_w1 = $fopen("../../../../../result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_16x16.txt", "w");
    for (wr_rdoqD64LastZero_j = 0; wr_rdoqD64LastZero_j < 16; wr_rdoqD64LastZero_j = wr_rdoqD64LastZero_j + 1) begin
        for (wr_rdoqD64LastZero_k = 0; wr_rdoqD64LastZero_k < 16; wr_rdoqD64LastZero_k = wr_rdoqD64LastZero_k + 1) begin
            rdoqD64LastZero_data[wr_rdoqD64LastZero_k] = rdoqD64LastZero[wr_rdoqD64LastZero_k];
        end
        #2;
        $fwrite(fp_rdoqD64LastZero_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            rdoqD64LastZero_data[0 ], rdoqD64LastZero_data[1 ], rdoqD64LastZero_data[2 ], rdoqD64LastZero_data[3 ], rdoqD64LastZero_data[4 ], rdoqD64LastZero_data[5 ], rdoqD64LastZero_data[6 ], rdoqD64LastZero_data[7 ], 
            rdoqD64LastZero_data[8 ], rdoqD64LastZero_data[9 ], rdoqD64LastZero_data[10], rdoqD64LastZero_data[11], rdoqD64LastZero_data[12], rdoqD64LastZero_data[13], rdoqD64LastZero_data[14], rdoqD64LastZero_data[15]);
    end
    $fclose(fp_rdoqD64LastZero_w1);
end


integer fp_endPosCost_w1;
integer wr_endPosCost_j,wr_endPosCost_k;
reg     signed  [63: 0]     endPosCost_data        [0 : 63]    ;
initial begin 
    #18;
    fp_endPosCost_w1 = $fopen("../../../../../result/lnpd/fpga_endPosCost/fpga_endPosCost_16x16.txt", "w");
    for (wr_endPosCost_j = 0; wr_endPosCost_j < 16; wr_endPosCost_j = wr_endPosCost_j + 1) begin
        for (wr_endPosCost_k = 0; wr_endPosCost_k < 16; wr_endPosCost_k = wr_endPosCost_k + 1) begin
            endPosCost_data[wr_endPosCost_k] = endPosCost[wr_endPosCost_k];
        end
        #2;
        $fwrite(fp_endPosCost_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            endPosCost_data[0 ], endPosCost_data[1 ], endPosCost_data[2 ], endPosCost_data[3 ], endPosCost_data[4 ], endPosCost_data[5 ], endPosCost_data[6 ], endPosCost_data[7 ], 
            endPosCost_data[8 ], endPosCost_data[9 ], endPosCost_data[10], endPosCost_data[11], endPosCost_data[12], endPosCost_data[13], endPosCost_data[14], endPosCost_data[15]);
    end
    $fclose(fp_endPosCost_w1);
end

integer fp_rdoq_last_x_w1;
integer wr_rdoq_last_x_j,wr_rdoq_last_x_k;
reg     signed  [63: 0]     rdoq_last_x_data        [0 : 63]    ;
initial begin 
    #18;
    fp_rdoq_last_x_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_16x16.txt", "w");
    for (wr_rdoq_last_x_j = 0; wr_rdoq_last_x_j < 16; wr_rdoq_last_x_j = wr_rdoq_last_x_j + 1) begin
        for (wr_rdoq_last_x_k = 0; wr_rdoq_last_x_k < 16; wr_rdoq_last_x_k = wr_rdoq_last_x_k + 1) begin
            rdoq_last_x_data[wr_rdoq_last_x_k] = rdoq_last_x[wr_rdoq_last_x_k];
        end
        #2;
        $fwrite(fp_rdoq_last_x_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            rdoq_last_x_data[0 ], rdoq_last_x_data[1 ], rdoq_last_x_data[2 ], rdoq_last_x_data[3 ], rdoq_last_x_data[4 ], rdoq_last_x_data[5 ], rdoq_last_x_data[6 ], rdoq_last_x_data[7 ], 
            rdoq_last_x_data[8 ], rdoq_last_x_data[9 ], rdoq_last_x_data[10], rdoq_last_x_data[11], rdoq_last_x_data[12], rdoq_last_x_data[13], rdoq_last_x_data[14], rdoq_last_x_data[15]);
    end
    $fclose(fp_rdoq_last_x_w1);
end

integer fp_rdoq_last_y_w1;
integer wr_rdoq_last_y_j,wr_rdoq_last_y_k;
reg     signed  [63: 0]     rdoq_last_y_data        [0 : 63]    ;
initial begin 
    #18;
    fp_rdoq_last_y_w1 = $fopen("../../../../../result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_16x16.txt", "w");
    for (wr_rdoq_last_y_j = 0; wr_rdoq_last_y_j < 16; wr_rdoq_last_y_j = wr_rdoq_last_y_j + 1) begin
        for (wr_rdoq_last_y_k = 0; wr_rdoq_last_y_k < 16; wr_rdoq_last_y_k = wr_rdoq_last_y_k + 1) begin
            rdoq_last_y_data[wr_rdoq_last_y_k] = rdoq_last_y[wr_rdoq_last_y_k];
        end
        #2;
        $fwrite(fp_rdoq_last_y_w1, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d \n", 
            rdoq_last_y_data[0 ], rdoq_last_y_data[1 ], rdoq_last_y_data[2 ], rdoq_last_y_data[3 ], rdoq_last_y_data[4 ], rdoq_last_y_data[5 ], rdoq_last_y_data[6 ], rdoq_last_y_data[7 ], 
            rdoq_last_y_data[8 ], rdoq_last_y_data[9 ], rdoq_last_y_data[10], rdoq_last_y_data[11], rdoq_last_y_data[12], rdoq_last_y_data[13], rdoq_last_y_data[14], rdoq_last_y_data[15]);
    end
    $fclose(fp_rdoq_last_y_w1);
end
















endmodule
















