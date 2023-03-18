module pre_quant#(
    parameter  IN_WIDTH     = 16                    ,
    parameter  OUT_WIDTH    = 16
)(
//system clk and rest
    input                               clk         ,
    input                               rst_n       ,

//input parameter
    input           [21: 0]             q_value     ,
    input           [4 : 0]             q_bits      ,
    
//input data
    input                               i_valid     ,
    input   signed  [IN_WIDTH - 1 : 0]  i_0         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_1         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_2         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_3         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_4         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_5         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_6         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_7         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_8         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_9         ,
    input   signed  [IN_WIDTH - 1 : 0]  i_10        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_11        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_12        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_13        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_14        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_15        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_16        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_17        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_18        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_19        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_20        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_21        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_22        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_23        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_24        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_25        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_26        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_27        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_28        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_29        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_30        ,
    input   signed  [IN_WIDTH - 1 : 0]  i_31        ,

//output parameter

//output data
    output                              o_valid     ,
    output  signed  [OUT_WIDTH - 1 : 0] o_0         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_1         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_2         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_3         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_4         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_5         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_6         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_7         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_8         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_9         ,
    output  signed  [OUT_WIDTH - 1 : 0] o_10        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_11        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_12        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_13        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_14        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_15        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_16        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_17        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_18        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_19        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_20        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_21        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_22        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_23        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_24        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_25        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_26        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_27        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_28        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_29        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_30        ,
    output  signed  [OUT_WIDTH - 1 : 0] o_31        
);
//reg definition

//wire definition
wire    signed      [IN_WIDTH - 1 : 0]      i_data  [0 : 31];


//input assignment
    assign i_data[0 ] = i_0 ;
    assign i_data[1 ] = i_1 ;
    assign i_data[2 ] = i_2 ;
    assign i_data[3 ] = i_3 ;
    assign i_data[4 ] = i_4 ;
    assign i_data[5 ] = i_5 ;
    assign i_data[6 ] = i_6 ;
    assign i_data[7 ] = i_7 ;
    assign i_data[8 ] = i_8 ;
    assign i_data[9 ] = i_9 ;
    assign i_data[10] = i_10;
    assign i_data[11] = i_11;
    assign i_data[12] = i_12;
    assign i_data[13] = i_13;
    assign i_data[14] = i_14;
    assign i_data[15] = i_15;
    assign i_data[16] = i_16;
    assign i_data[17] = i_17;
    assign i_data[18] = i_18;
    assign i_data[19] = i_19;
    assign i_data[20] = i_20;
    assign i_data[21] = i_21;
    assign i_data[22] = i_22;
    assign i_data[23] = i_23;
    assign i_data[24] = i_24;
    assign i_data[25] = i_25;
    assign i_data[26] = i_26;
    assign i_data[27] = i_27;
    assign i_data[28] = i_28;
    assign i_data[29] = i_29;
    assign i_data[30] = i_30;
    assign i_data[31] = i_31;



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin

    end
    else begin


    end
end






endmodule