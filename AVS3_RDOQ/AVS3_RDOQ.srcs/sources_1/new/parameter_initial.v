module parameter_initial (
//system clk and rest
    input                       clk                 ,
    input                       rst_n               ,

//input parameter
    input           [2 : 0]     cu_width_log2       ,//the value is between 2 and 4
    input           [2 : 0]     cu_height_log2      ,//the value is between 2 and 4
    input           [6 : 0]     qp                  ,
    input           [2 : 0]     ch_type             ,//Y_C 0; U_C 1; V_C 2;
    input           [0 : 0]     is_intra            ,
    input   signed  [63: 0]     lambda              ,
    input           [3 : 0]     bit_depth           ,

//output parameter
    output          [13: 0]     scale               ,
    output          [2 : 0]     ns_shift            ,
    output          [7 : 0]     ns_scale            ,
    output          [6 : 0]     ns_offset           ,
    output          [21: 0]     q_value             ,
    output          [3 : 0]     log2_size           ,
    output          [3 : 0]     tr_shift            ,
    output          [4 : 0]     q_bits              ,
    output          [0 : 0]     ctx_last            ,
    output  signed  [29: 0]     err_scale           
);
localparam  Y_C             =   2'd0,
            U_C             =   2'd1,
            V_C             =   2'd2;
localparam  QUANT_SHIFT     =   14  ;

//wire definition
wire            [4 : 0]     q_bits_t    ;
wire    signed  [29: 0]     err_scale_t ;   
wire            [13: 0]     scale_t     ;  
wire            [21: 0]     q_value_t   ;      

//reg definition
reg         [2 : 0]     ns_shift_t      ; 
reg         [7 : 0]     ns_scale_t      ; 
reg         [3 : 0]     log2_size_t     ;
reg         [0 : 0]     ctx_last_t      ;

reg         [2 : 0]     ns_shift_t_d1   ; 
reg         [7 : 0]     ns_scale_t_d1   ; 
reg         [3 : 0]     log2_size_t_d1  ;
reg         [0 : 0]     ctx_last_t_d1   ;

reg         [6 : 0]     ns_offset_t ;
reg         [3 : 0]     tr_shift_t  ;

reg         [2 : 0]     cu_width_log2_d1    ;   
reg         [2 : 0]     cu_height_log2_d1   ;   
reg         [3 : 0]     bit_depth_d1        ;
reg         [6 : 0]     qp_d1               ;
  
reg         [13: 0]     scale_t_d1      ;  

//output assignment
assign      ns_shift        =       ns_shift_t_d1   ;
assign      ns_scale        =       ns_scale_t_d1   ;
assign      log2_size       =       log2_size_t_d1  ;
assign      ctx_last        =       ctx_last_t_d1   ;

assign      ns_offset       =       ns_offset_t     ;
assign      q_value         =       q_value_t       ;
assign      tr_shift        =       tr_shift_t      ;
assign      q_bits          =       q_bits_t        ;

assign      err_scale       =       err_scale_t     ;
assign      scale           =       scale_t_d1      ;



//pipe 1
    quant_scale u_quant_scale(
        //system clk and rest
        .clk                 (clk           ),
        .rst_n               (rst_n         ),

        //input parameter   
        .qp                  (qp            ),

        //output parameter  
        .scale               (scale_t       )
    );

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cu_width_log2_d1    <=  0               ;
            cu_height_log2_d1   <=  0               ;
            bit_depth_d1        <=  0               ;
            qp_d1               <=  0               ;
        end
        else begin
            cu_width_log2_d1    <=  cu_width_log2   ;
            cu_height_log2_d1   <=  cu_height_log2  ;
            bit_depth_d1        <=  bit_depth       ;
            qp_d1               <=  qp              ;
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ns_shift_t      <=      0   ;
            ns_scale_t      <=      0   ;
            log2_size_t     <=      0   ;//the minimum one 
            ctx_last_t      <=      0   ;
        end
        else begin
            ns_shift_t      <=      ((cu_width_log2 + cu_height_log2) & 1) ?   7 : 0                            ;
            ns_scale_t      <=      ((cu_width_log2 + cu_height_log2) & 1) ? 181 : 1                            ;
            log2_size_t     <=      (cu_width_log2 + cu_height_log2 ) >> 1                                      ;
            ctx_last_t      <=      (ch_type == Y_C) ? 0 : 1                                                    ;
        end
    end


//pipe 2

    err_scale_tbl u_err_scale_tbl(
    //system clk and rest
        .clk                 (clk           ),
        .rst_n               (rst_n         ),

    //input parameter
        .qp                  (qp_d1         ),
        .log2_size           (log2_size_t   ),

    //output parameter
        .err_scale_out       (err_scale_t   )         
    );

    assign      q_bits_t        =       QUANT_SHIFT + tr_shift_t                                                ;
    assign      q_value_t       =       (scale_t * ns_scale_t + ns_offset_t) >> ns_shift_t                      ;

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ns_offset_t     <=      0   ;
            tr_shift_t      <=      0   ;
        end
        else begin
            ns_offset_t     <=      ((cu_width_log2_d1 + cu_height_log2_d1) & 1) ? (1 << (ns_shift_t - 1)) : 0  ;
            tr_shift_t      <=      15 - bit_depth_d1 - log2_size_t                                             ;
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ns_shift_t_d1   <=      0           ;
            ns_scale_t_d1   <=      0           ;
            log2_size_t_d1  <=      0           ;
            ctx_last_t_d1   <=      0           ;
        end
        else begin
            ns_shift_t_d1   <=      ns_shift_t  ;
            ns_scale_t_d1   <=      ns_scale_t  ;
            log2_size_t_d1  <=      log2_size_t ;
            ctx_last_t_d1   <=      ctx_last_t  ;
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            scale_t_d1      <=      0           ;
        end
        else begin
            scale_t_d1      <=      scale_t     ;
        end
    end









endmodule






