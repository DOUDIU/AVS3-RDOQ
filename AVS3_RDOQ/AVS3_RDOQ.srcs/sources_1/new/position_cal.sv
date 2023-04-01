module position_cal(      
//system clk and rest       
    input                                           clk                     ,
    input                                           rst_n                   ,

//input data
    input       wire    signed      [63 : 0]        rdoqD64LastOne          ,  
    input       wire    signed      [63 : 0]        temp_RdoqCost           ,  
    input       wire    signed      [63 : 0]        tempCost                ,  
    input       wire    signed      [63 : 0]        rdoq_last_x             ,
    input       wire    signed      [63 : 0]        rdoq_last_y             ,

    output      reg     signed      [6  : 0]        final_rdoq_last_x_in    ,
    output      reg     signed      [6  : 0]        final_rdoq_last_y_in    , 
    output      reg     signed      [63 : 0]        final_rdoq_cost_in      ,
    output      wire    signed      [63 : 0]        d64_best_cost_tmp_in    ,

//output data
    output      reg     signed      [6  : 0]        final_rdoq_last_x_out   ,
    output      reg     signed      [6  : 0]        final_rdoq_last_y_out   , 
    output      reg     signed      [63 : 0]        final_rdoq_cost_out     ,
    output      reg     signed      [63 : 0]        d64_best_cost_tmp_out        
);




    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            d64_best_cost_tmp_out   <=  0   ;
            final_rdoq_last_x_out   <=  0   ;
            final_rdoq_last_y_out   <=  0   ;
        end
        else begin
            if((rdoq_last_x != -1) && (temp_RdoqCost + rdoqD64LastOne < d64_best_cost_tmp_in))begin
                d64_best_cost_tmp_out   <=  temp_RdoqCost + rdoqD64LastOne  ;
                final_rdoq_last_x_out   <=  rdoq_last_x                     ;
                final_rdoq_last_y_out   <=  rdoq_last_y                     ;
            end
            else begin
                d64_best_cost_tmp_out   <=  d64_best_cost_tmp_in            ;
                final_rdoq_last_x_out   <=  final_rdoq_last_x_in            ;
                final_rdoq_last_y_out   <=  final_rdoq_last_y_in            ;
            end
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            final_rdoq_cost_out     <=  0;
        end
        else begin
            final_rdoq_cost_out     <=  final_rdoq_cost_in + tempCost       ;
        end
    end


















endmodule