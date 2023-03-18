module rdoq_top#(
    parameter  IN_WIDTH     = 16                                ,
    parameter  OUT_WIDTH    = 16
)(
//system clk and rest
    input                                   clk                 ,
    input                                   rst_n               ,

//input block information
    input           [2 : 0]                 cu_width_log2       ,//the value is between 2 and 6
    input           [2 : 0]                 cu_height_log2      ,//the value is between 2 and 6
    input           [6 : 0]                 qp                  ,
    input           [2 : 0]                 ch_type             ,//Y_C 0; U_C 1; Y_C 2;
    input           [0 : 0]                 is_intra            ,
    input   signed  [63: 0]                 lambda              ,
    input           [3 : 0]                 bit_depth           ,

//input block data
    input                                   i_valid             ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_0          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_1          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_2          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_3          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_4          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_5          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_6          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_7          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_8          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_9          ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_10         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_11         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_12         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_13         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_14         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_15         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_16         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_17         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_18         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_19         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_20         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_21         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_22         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_23         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_24         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_25         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_26         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_27         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_28         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_29         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_30         ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef_31         ,

//output block data
    output                                  o_valid             ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_0          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_1          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_2          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_3          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_4          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_5          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_6          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_7          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_8          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_9          ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_10         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_11         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_12         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_13         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_14         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_15         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_16         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_17         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_18         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_19         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_20         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_21         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_22         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_23         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_24         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_25         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_26         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_27         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_28         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_29         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_30         ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef_31         ,

//the last none zero position
    output          [3 : 0]                 final_X             ,
    output          [3 : 0]                 final_y             
);

//wire definition
wire            [13: 0]     scale                   ;
wire            [2 : 0]     ns_shift                ;
wire            [7 : 0]     ns_scale                ;
wire            [6 : 0]     ns_offset               ;
wire            [21: 0]     q_value                 ;
wire            [2 : 0]     log2_size               ;
wire            [3 : 0]     tr_shift                ;
wire            [4 : 0]     q_bits                  ;
wire            [0 : 0]     ctx_last                ;
wire    signed  [63: 0]     err_scale               ;

wire    signed  [15: 0]     pre_quant_coef  [31: 0] ;
wire                        pre_quant_valid         ;
//module instance
parameter_initial u_parameter_initial (
    //system clk and rest
    .clk                    (clk               ),
    .rst_n                  (rst_n             ),

    //input parameter
    .cu_width_log2          (cu_width_log2     ),//the value is between 2 and 6
    .cu_height_log2         (cu_height_log2    ),//the value is between 2 and 6
    .qp                     (qp                ),
    .ch_type                (ch_type           ),//Y_C 0; U_C 1; V_C 2;
    .is_intra               (is_intra          ),
    .lambda                 (lambda            ),
    .bit_depth              (bit_depth         ),

    //output parameter
    .scale                  (scale             ),
    .ns_shift               (ns_shift          ),
    .ns_scale               (ns_scale          ),
    .ns_offset              (ns_offset         ),            
    .q_value                (q_value           ),
    .log2_size              (log2_size         ),
    .tr_shift               (tr_shift          ),
    .q_bits                 (q_bits            ),
    .ctx_last               (ctx_last          ),
    .err_scale              (err_scale         )
);


pre_quant #(
    .IN_WIDTH               (16                 ),
    .OUT_WIDTH              (16                 )
)u_pre_quant(
    //system clk and rest
    .clk                    (clk                ),
    .rst_n                  (rst_n              ),

    //input parameter
    .q_value                (q_value            ),
    .q_bits                 (q_bits             ),
    
    //input data
    .i_valid                (i_valid            ),
    .i_0                    (src_coef_0         ),
    .i_1                    (src_coef_1         ),
    .i_2                    (src_coef_2         ),
    .i_3                    (src_coef_3         ),
    .i_4                    (src_coef_4         ),
    .i_5                    (src_coef_5         ),
    .i_6                    (src_coef_6         ),
    .i_7                    (src_coef_7         ),
    .i_8                    (src_coef_8         ),
    .i_9                    (src_coef_9         ),
    .i_10                   (src_coef_10        ),
    .i_11                   (src_coef_11        ),
    .i_12                   (src_coef_12        ),
    .i_13                   (src_coef_13        ),
    .i_14                   (src_coef_14        ),
    .i_15                   (src_coef_15        ),
    .i_16                   (src_coef_16        ),
    .i_17                   (src_coef_17        ),
    .i_18                   (src_coef_18        ),
    .i_19                   (src_coef_19        ),
    .i_20                   (src_coef_20        ),
    .i_21                   (src_coef_21        ),
    .i_22                   (src_coef_22        ),
    .i_23                   (src_coef_23        ),
    .i_24                   (src_coef_24        ),
    .i_25                   (src_coef_25        ),
    .i_26                   (src_coef_26        ),
    .i_27                   (src_coef_27        ),
    .i_28                   (src_coef_28        ),
    .i_29                   (src_coef_29        ),
    .i_30                   (src_coef_30        ),
    .i_31                   (src_coef_31        ),

    //output parameter

    //output data
    .o_valid                (pre_quant_valid    ),
    .o_0                    (pre_quant_coef[0 ] ),
    .o_1                    (pre_quant_coef[1 ] ),
    .o_2                    (pre_quant_coef[2 ] ),
    .o_3                    (pre_quant_coef[3 ] ),
    .o_4                    (pre_quant_coef[4 ] ),
    .o_5                    (pre_quant_coef[5 ] ),
    .o_6                    (pre_quant_coef[6 ] ),
    .o_7                    (pre_quant_coef[7 ] ),
    .o_8                    (pre_quant_coef[8 ] ),
    .o_9                    (pre_quant_coef[9 ] ),
    .o_10                   (pre_quant_coef[10] ),
    .o_11                   (pre_quant_coef[11] ),
    .o_12                   (pre_quant_coef[12] ),
    .o_13                   (pre_quant_coef[13] ),
    .o_14                   (pre_quant_coef[14] ),
    .o_15                   (pre_quant_coef[15] ),
    .o_16                   (pre_quant_coef[16] ),
    .o_17                   (pre_quant_coef[17] ),
    .o_18                   (pre_quant_coef[18] ),
    .o_19                   (pre_quant_coef[19] ),
    .o_20                   (pre_quant_coef[20] ),
    .o_21                   (pre_quant_coef[21] ),
    .o_22                   (pre_quant_coef[22] ),
    .o_23                   (pre_quant_coef[23] ),
    .o_24                   (pre_quant_coef[24] ),
    .o_25                   (pre_quant_coef[25] ),
    .o_26                   (pre_quant_coef[26] ),
    .o_27                   (pre_quant_coef[27] ),
    .o_28                   (pre_quant_coef[28] ),
    .o_29                   (pre_quant_coef[29] ),
    .o_30                   (pre_quant_coef[30] ),
    .o_31                   (pre_quant_coef[31] )
);







endmodule
