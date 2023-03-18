module rdoq_top#(
    parameter  IN_WIDTH     = 16                                    ,
    parameter  OUT_WIDTH    = 16    
)(  
//system clk and rest   
    input                                   clk                     ,
    input                                   rst_n                   ,

//input block information
    input           [2 : 0]                 cu_width_log2           ,//the value is between 2 and 6
    input           [2 : 0]                 cu_height_log2          ,//the value is between 2 and 6
    input           [21: 0]                 q_value                 ,
    input           [4 : 0]                 q_bits                  ,

    input           [6 : 0]                 qp                      ,
    input           [2 : 0]                 ch_type                 ,//Y_C 0; U_C 1; Y_C 2;
    input           [0 : 0]                 is_intra                ,
    input   signed  [63: 0]                 lambda                  ,
    input           [3 : 0]                 bit_depth               ,

//input block data
    input                                   i_valid                 ,
    input   signed  [IN_WIDTH - 1 : 0]      src_coef    [0 : 31]    ,

//output block data
    output                                  o_valid                 ,
    output  signed  [OUT_WIDTH - 1 : 0]     dst_coef    [0 : 31]    ,

//the last none zero position
    output          [3 : 0]                 final_X                 ,
    output          [3 : 0]                 final_y             
);

//wire definition
wire            [13: 0]     scale                   ;
wire            [2 : 0]     ns_shift                ;
wire            [7 : 0]     ns_scale                ;
wire            [6 : 0]     ns_offset               ;
wire            [2 : 0]     log2_size               ;
wire            [3 : 0]     tr_shift                ;
wire            [0 : 0]     ctx_last                ;
wire    signed  [63: 0]     err_scale               ;

wire    signed  [15: 0]     pre_quant_coef  [31: 0] ;
wire                        pre_quant_valid         ;


//module instance
/*parameter_initial u_parameter_initial (
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
*/

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
    .i_data                 (src_coef           ),

    //output parameter

    //output data
    .o_valid                (pre_quant_valid    ),
    .o_data                 (dst_coef           )
);







endmodule
