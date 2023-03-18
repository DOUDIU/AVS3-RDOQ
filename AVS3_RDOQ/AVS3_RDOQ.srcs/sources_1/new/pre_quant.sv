module pre_quant#(
    parameter  IN_WIDTH     = 16                            ,
    parameter  OUT_WIDTH    = 16        
)(      
//system clk and rest       
    input                               clk                 ,
    input                               rst_n               ,

//input parameter       
    input           [21: 0]             q_value             ,
    input           [4 : 0]             q_bits              ,

//input data        
    input                               i_valid             ,
    input   signed  [15 : 0]            i_data  [0 : 31]    ,

//output parameter

//output data
    output                              o_valid             ,
    output  signed  [15 : 0]            o_data  [0 : 31]    
);
//parameter definition
parameter   COM_INT32_MAX   =   64'h7FFFFFFF    ;


//integer definition
integer i,j;
genvar  l;

//reg definition
reg     signed  [63 : 0]    temp_level          [0 : 31]        ;//16 + 22 = 38
reg     signed  [63 : 0]    level_double        [0 : 31]        ;
reg     signed  [63 : 0]    level_double_d1     [0 : 31]        ;
reg             [31 : 0]    max_abs_level       [0 : 31]        ;
reg             [31 : 0]    max_abs_level_t     [0 : 31]        ;

reg                         src_coef_sign       [0 : 3][0 : 31] ;

reg             [4  : 0]    q_bits_d1                           ;   
reg             [4  : 0]    q_bits_d2                           ;   
reg             [4  : 0]    q_bits_d3                           ;

reg                         i_valid_d           [0 :  3]        ;


//wire definition   
wire            [15 : 0]    i_data_abs          [0 : 31]        ;

//assignment
generate
    for(l = 0; l < 32; l = l + 1)begin
        assign i_data_abs[l]   =  i_data[l] > 0 ? i_data[l] : (~i_data[l] + 1) ;
    end
endgenerate


generate
    for(l = 0; l < 32; l = l + 1)begin
        assign o_data[l]   =  src_coef_sign[3][l] ? -max_abs_level_t[l] : max_abs_level_t[l] ;
    end
endgenerate

assign  o_valid =   i_valid_d[3];

//delay operation
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0; i < 4; i = i + 1)begin
            i_valid_d[i]        <=  0;
        end
        for(i = 0; i < 4; i = i + 1)begin
            for(j = 0; j < 32; j = j + 1)begin
                src_coef_sign[i][j]     <=  0;
            end
        end
    end
    else begin
        i_valid_d[0]        <=  i_valid;
        for(i = 1; i < 4; i = i + 1)begin
            i_valid_d[i]        <=  i_valid_d[i-1];
        end
        for(i = 1; i < 4; i = i + 1)begin
            for(j = 0; j < 32; j = j + 1)begin
                src_coef_sign[i][j]     <=  src_coef_sign[i-1][j];
            end
        end
    end
end


//pipe 1

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                temp_level[i]           <=  0;
                src_coef_sign[0][i]     <=  0;   
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                temp_level[i]           <=  i_data_abs[i] * q_value ;
                src_coef_sign[0][i]     <=  i_data[i][15]; 
            end
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            q_bits_d1   <=  0           ;
        end
        else begin
            q_bits_d1   <=  q_bits      ;
        end
    end


//pipe 2

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            q_bits_d2   <=  0           ;
        end
        else begin
            q_bits_d2   <=  q_bits_d1   ;
        end
    end


    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double[i]     <=  0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                level_double[i]     <=  temp_level[i] > COM_INT32_MAX - (1 << (q_bits_d1 - 1)) ? COM_INT32_MAX - (1 << (q_bits_d1 - 1)) : temp_level[i] ;
            end
        end
    end

//pipe 3

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            q_bits_d3   <=  0           ;
            for(i = 0; i < 32; i = i + 1)begin
                level_double_d1[i]      <=  0;
            end
        end
        else begin
            q_bits_d3   <=  q_bits_d2   ;
            for(i = 0; i < 32; i = i + 1)begin
                level_double_d1[i]      <=  level_double[i];
            end
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                max_abs_level[i]    <=  0;
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                max_abs_level[i]    <=  level_double[i] >> q_bits_d2;
            end
        end
    end

//pipe 4

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 32; i = i + 1)begin
                max_abs_level_t[i]      <=      0;   
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1)begin
                max_abs_level_t[i]      <=      (level_double_d1[i] - (max_abs_level[i] << q_bits_d3)) < (1 << (q_bits_d3 - 1)) ? max_abs_level[i] : max_abs_level[i] + 1;
            end
        end
    end



endmodule