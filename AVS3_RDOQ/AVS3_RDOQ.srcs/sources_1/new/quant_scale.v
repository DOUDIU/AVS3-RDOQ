module quant_scale(
//system clk and rest
    input                       clk                 ,
    input                       rst_n               ,

//input parameter
    input       [6 : 0]         qp                  ,

//output parameter
    output      [13: 0]         scale               
);
//integer defiition
integer             i                   ;

//reg   definition
reg     [13: 0]     quant_scale[79: 0]  ;

//output assigment
assign              scale       =  quant_scale[qp];




//initial quant_scale
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0; i < 80; i = i + 1)begin
            quant_scale[i]      <=  0;
        end
    end
    else begin
        quant_scale[0 ]      <=  16302      ;
        quant_scale[1 ]      <=  15024      ;
        quant_scale[2 ]      <=  13777      ;
        quant_scale[3 ]      <=  12634      ;
        quant_scale[4 ]      <=  11626      ;
        quant_scale[5 ]      <=  10624      ;
        quant_scale[6 ]      <=  9742       ;
        quant_scale[7 ]      <=  8958       ;
        quant_scale[8 ]      <=  8192       ;
        quant_scale[9 ]      <=  7512       ;
        quant_scale[10]      <=  6889       ;
        quant_scale[11]      <=  6305       ;
        quant_scale[12]      <=  5793       ;
        quant_scale[13]      <=  5303       ;
        quant_scale[14]      <=  4878       ;
        quant_scale[15]      <=  4467       ;
        quant_scale[16]      <=  4091       ;
        quant_scale[17]      <=  3756       ;
        quant_scale[18]      <=  3444       ;
        quant_scale[19]      <=  3161       ;
        quant_scale[20]      <=  2894       ;
        quant_scale[21]      <=  2654       ;
        quant_scale[22]      <=  2435       ;
        quant_scale[23]      <=  2235       ;
        quant_scale[24]      <=  2048       ;
        quant_scale[25]      <=  1878       ;
        quant_scale[26]      <=  1722       ;
        quant_scale[27]      <=  1579       ;
        quant_scale[28]      <=  1449       ;
        quant_scale[29]      <=  1329       ;
        quant_scale[30]      <=  1218       ;
        quant_scale[31]      <=  1117       ;
        quant_scale[32]      <=  1024       ;
        quant_scale[33]      <=  939        ;
        quant_scale[34]      <=  861        ;
        quant_scale[35]      <=  790        ;
        quant_scale[36]      <=  724        ;
        quant_scale[37]      <=  664        ;
        quant_scale[38]      <=  609        ;
        quant_scale[39]      <=  558        ;
        quant_scale[40]      <=  512        ;
        quant_scale[41]      <=  470        ;
        quant_scale[42]      <=  430        ;
        quant_scale[43]      <=  395        ;
        quant_scale[44]      <=  362        ;
        quant_scale[45]      <=  332        ;
        quant_scale[46]      <=  304        ;
        quant_scale[47]      <=  279        ;
        quant_scale[48]      <=  256        ;
        quant_scale[49]      <=  235        ;
        quant_scale[50]      <=  215        ;
        quant_scale[51]      <=  197        ;
        quant_scale[52]      <=  181        ;
        quant_scale[53]      <=  166        ;
        quant_scale[54]      <=  152        ;
        quant_scale[55]      <=  140        ;
        quant_scale[56]      <=  128        ;
        quant_scale[57]      <=  116        ;
        quant_scale[58]      <=  108        ;
        quant_scale[59]      <=  99         ;
        quant_scale[60]      <=  91         ;
        quant_scale[61]      <=  83         ;
        quant_scale[62]      <=  76         ;
        quant_scale[63]      <=  69         ;
        quant_scale[64]      <=  64         ;
        quant_scale[65]      <=  59         ;
        quant_scale[66]      <=  54         ;
        quant_scale[67]      <=  49         ;
        quant_scale[68]      <=  45         ;
        quant_scale[69]      <=  41         ;
        quant_scale[70]      <=  38         ;
        quant_scale[71]      <=  35         ;
        quant_scale[72]      <=  32         ;
        quant_scale[73]      <=  30         ;
        quant_scale[74]      <=  27         ;
        quant_scale[75]      <=  25         ;
        quant_scale[76]      <=  23         ;
        quant_scale[77]      <=  21         ;
        quant_scale[78]      <=  19         ;
        quant_scale[79]      <=  18         ;
    end
end


endmodule 