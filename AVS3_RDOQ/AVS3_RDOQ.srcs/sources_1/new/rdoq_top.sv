
`define file_write

module rdoq_top(      
//system clk and rest       
    input                       clk                                                 ,
    input                       rst_n                                               ,

//input block information                           
    input           [21 : 0]    q_value                                             ,
    input           [4  : 0]    q_bits                                              ,

    input           [2  : 0]    cu_width_log2                                       ,//the value is between 2 and 6
    input           [2  : 0]    cu_height_log2                                      ,//the value is between 2 and 6
    input           [2  : 0]    ch_type                                             ,//Y_C 0; U_C 1; Y_C 2;
    input   signed  [27 : 0]    err_scale                                           ,
    input   signed  [23 : 0]    lambda                                              ,
    input   signed  [19 : 0]    diff_scale                                          ,

    // input           [6  : 0]    qp                                                  ,
    // input           [0  : 0]    is_intra                                            ,
    // input           [3  : 0]    bit_depth                                           ,

    input           [16 : 0]    rdoq_est_last       [0 :  1][0 :  5][0 : 11][0 : 1] ,//pending
    input           [16 : 0]    rdoq_est_level      [0 : 23][0 :  1]                ,//pending
    input           [16 : 0]    rdoq_est_run        [0 : 23][0 :  1]                ,//pending
    input           [9  : 0]    left_pos            [0 : 31]                        ,//the max value is 1023
    input           [9  : 0]    bottom_pos          [0 : 31]                        ,//the max value is 1023

//input block data  
    input                       i_valid                                             ,
    input   signed  [15 : 0]    src_coef            [0 : 31]                        ,

//output block data                      

    output  signed  [15 : 0]    o_tmp_dst_coef      [0 : 31]                        ,
    output                      o_valid                                             ,
    output  signed  [6  : 0]    o_rdoq_last_x                                       ,
    output  signed  [6  : 0]    o_rdoq_last_y                                       ,
    output  signed  [63 : 0]    o_final_rdoq_cost                                   ,
    output  signed  [63 : 0]    o_d64_best_cost_tmp                                 
);

//integer definition
integer i,j,k,l,m   ;
genvar  o,p,q,r     ;

//wire definition
wire            [13: 0]     scale                                                       ;
wire            [2 : 0]     ns_shift                                                    ;
wire            [7 : 0]     ns_scale                                                    ;
wire            [6 : 0]     ns_offset                                                   ;
wire            [2 : 0]     log2_size                                                   ;
wire            [3 : 0]     tr_shift                                                    ;
wire            [0 : 0]     ctx_last                                                    ;

wire    signed  [15: 0]     pre_quant_coef              [31: 0]                         ;
wire                        pre_quant_valid                                             ;
wire            [2 : 0]     pre_quant_width_log2                                        ;
wire            [2 : 0]     pre_quant_height_log2                                       ;
wire            [2 : 0]     pre_quant_ch_type                                           ;
wire    signed  [23: 0]     pre_quant_level_double      [31: 0]                         ;
wire            [4 : 0]     pre_quant_q_bits                                            ;
wire    signed  [27: 0]     pre_quant_err_scale                                         ;
wire    signed  [23: 0]     pre_quant_lambda                                            ;
wire            [16: 0]     pre_quant_rdoq_est_last     [0 :  1][0 :  5][0 : 11][0 : 1] ;//pending
wire            [16: 0]     pre_quant_rdoq_est_level    [0 : 23][0 :  1]                ;//pending
wire            [16: 0]     pre_quant_rdoq_est_run      [0 : 23][0 :  1]                ;//pending
wire            [9 : 0]     pre_quant_left_pos          [0 : 31]                        ;
wire            [9 : 0]     pre_quant_bottom_pos        [0 : 31]                        ;


wire                        ocd_valid                                                   ;
wire            [2  : 0]    ocd_width_log2                                              ;
wire            [2  : 0]    ocd_height_log2                                             ;
wire            [15 : 0]    ocd_level_opt               [0 : 31]                        ;
wire                        ocd_tmp_dst_coef_sign       [0 : 31]                        ;//the sign of tmp_dst_coef 1- 0+
wire    signed  [63 : 0]    ocd_d64_cost_last_zero      [0 : 31]                        ;
wire    signed  [63 : 0]    ocd_d64_cost_last_one       [0 : 31]                        ; 
wire    signed  [63 : 0]    ocd_base_cost_buffer_tmp    [0 : 31]                        ;

wire    signed  [15 : 0]    lnpd_tmp_dst_coef           [0 : 31]                        ;
wire                        lnpd_valid                                                  ;
wire    signed  [6  : 0]    lnpd_rdoq_last_x                                            ;
wire    signed  [6  : 0]    lnpd_rdoq_last_y                                            ;
wire    signed  [63 : 0]    lnpd_final_rdoq_cost                                        ;
wire    signed  [63 : 0]    lnpd_d64_best_cost_tmp                                      ;


//assignment
generate
    for(o = 0; o < 32; o = o + 1)begin
        assign  o_tmp_dst_coef[o]   =   lnpd_tmp_dst_coef[o];
    end
endgenerate

assign  o_valid                 =   lnpd_valid                  ;
assign  o_rdoq_last_x           =   lnpd_rdoq_last_x            ;
assign  o_rdoq_last_y           =   lnpd_rdoq_last_y            ;
assign  o_final_rdoq_cost       =   lnpd_final_rdoq_cost        ;
assign  o_d64_best_cost_tmp     =   lnpd_d64_best_cost_tmp      ;



    pre_quant u_pre_quant(
        //system clk and rest
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        //input parameter   
        .q_value                (q_value                    ),
        .q_bits                 (q_bits                     ),

        .i_width_log2           (cu_width_log2              ),      
        .i_height_log2          (cu_height_log2             ),   
        .i_ch_type              (ch_type                    ),  
        .i_q_bits               (q_bits                     ),
        .i_err_scale            (err_scale                  ),
        .i_lambda               (lambda                     ),

        .i_rdoq_est_last        (rdoq_est_last              ),
        .i_rdoq_est_level       (rdoq_est_level             ),
        .i_rdoq_est_run         (rdoq_est_run               ),
        .i_left_pos             (left_pos                   ),
        .i_bottom_pos           (bottom_pos                 ),

        //input data    
        .i_valid                (i_valid                    ),
        .i_data                 (src_coef                   ),

        //output parameter
        .o_width_log2           (pre_quant_width_log2       ),
        .o_height_log2          (pre_quant_height_log2      ),
        .o_ch_type              (pre_quant_ch_type          ),
        .o_q_bits               (pre_quant_q_bits           ),
        .o_err_scale            (pre_quant_err_scale        ),
        .o_lambda               (pre_quant_lambda           ),

        .o_rdoq_est_last        (pre_quant_rdoq_est_last    ),
        .o_rdoq_est_level       (pre_quant_rdoq_est_level   ),
        .o_rdoq_est_run         (pre_quant_rdoq_est_run     ),
        .o_left_pos             (pre_quant_left_pos         ),
        .o_bottom_pos           (pre_quant_bottom_pos       ),

        //output data
        .o_valid                (pre_quant_valid            ),
        .o_level_double         (pre_quant_level_double     ),
        .o_data                 (pre_quant_coef             )
    );


    ocd u_ocd(      
    //system clk and rest       
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

    //input parameter       
        .i_width_log2           (pre_quant_width_log2       ),      
        .i_height_log2          (pre_quant_height_log2      ),   
        .i_ch_type              (pre_quant_ch_type          ),
        .i_q_bits               (pre_quant_q_bits           ),
        .i_err_scale            (pre_quant_err_scale        ),
        .i_lambda               (pre_quant_lambda           ),
        .i_diff_scale           (diff_scale                 ),//haven't adopt delay operation
    
        .i_rdoq_est_last        (pre_quant_rdoq_est_last    ),
        .i_rdoq_est_level       (pre_quant_rdoq_est_level   ),
        .i_rdoq_est_run         (pre_quant_rdoq_est_run     ),
        .i_left_pos             (pre_quant_left_pos         ),
        .i_bottom_pos           (pre_quant_bottom_pos       ),


    //input data                
        .i_valid                (pre_quant_valid            ),
        .i_level_double         (pre_quant_level_double     ),
        .i_data                 (pre_quant_coef             ),

    //output parameter      
        .o_width_log2           (ocd_width_log2             ),
        .o_height_log2          (ocd_height_log2            ),

    //output data       
        .o_valid                (ocd_valid                  ),
        .o_level_opt            (ocd_level_opt              ),
        .o_tmp_dst_coef_sign    (ocd_tmp_dst_coef_sign      ),
        .o_d64_cost_last_zero   (ocd_d64_cost_last_zero     ),
        .o_d64_cost_last_one    (ocd_d64_cost_last_one      ),
        .o_base_cost_buffer_tmp (ocd_base_cost_buffer_tmp   )
    );

    lnpd u_lnpd(      
    //system clk and rest       
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),

    //input parameter           
        .i_width_log2               (ocd_width_log2             ),//the value is between 2 and 6
        .i_height_log2              (ocd_height_log2            ),//the value is between 2 and 6            

    //input data 
        .i_valid                    (ocd_valid                  ),
        .i_level_opt                (ocd_level_opt              ),
        .i_tmp_dst_coef_sign        (ocd_tmp_dst_coef_sign      ),//the sign of tmp_dst_coef 1- 0+
        .i_d64_cost_last_zero       (ocd_d64_cost_last_zero     ),
        .i_d64_cost_last_one        (ocd_d64_cost_last_one      ),
        .i_base_cost_buffer_tmp     (ocd_base_cost_buffer_tmp   ),

    //output parameter                      

    //output data                 
        .o_tmp_dst_coef             (lnpd_tmp_dst_coef          ),
        .o_valid                    (lnpd_valid                 ),
        .o_rdoq_last_x              (lnpd_rdoq_last_x           ),
        .o_rdoq_last_y              (lnpd_rdoq_last_y           ),
        .o_final_rdoq_cost          (lnpd_final_rdoq_cost       ),
        .o_d64_best_cost_tmp        (lnpd_d64_best_cost_tmp     )                                      
    );               



endmodule




















