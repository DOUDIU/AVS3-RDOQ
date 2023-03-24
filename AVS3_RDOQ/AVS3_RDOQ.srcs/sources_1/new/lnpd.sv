module rdoq_top(      
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

























endmodule