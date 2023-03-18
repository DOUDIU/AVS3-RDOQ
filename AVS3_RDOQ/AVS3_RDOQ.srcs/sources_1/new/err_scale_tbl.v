module err_scale_tbl(
//system clk and rest
    input                       clk                 ,
    input                       rst_n               ,

//input parameter
    input       [6 : 0]         qp                  ,
    input       [2 : 0]         log2_size           ,

//output parameter
    output      [29: 0]         err_scale_out              
);
//integer defiition
integer             i                   ;
integer             j                   ;
//reg   definition
reg         [29: 0]     err_scale       [79: 0][5 : 0];
reg         [29: 0]     err_scale_d1    ;
//wire  definition

//output assignment
assign      err_scale_out       =   err_scale_d1;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        err_scale_d1        <=  0;
    end
    else begin
        err_scale_d1        <=   log2_size > 0 ? err_scale[qp][log2_size - 1] : 0;
    end
end

//initial err_scale_tbl
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0; i < 80; i = i + 1)begin
            for(j = 0; j <6; j = j + 1)begin
                err_scale[i][j]     <=      0;
            end
        end
    end
    else begin
        err_scale[0][0]      <=       32932      ;
        err_scale[0][1]      <=       65865      ;
        err_scale[0][2]      <=      131731      ;
        err_scale[0][3]      <=      263462      ;
        err_scale[0][4]      <=      526925      ;
        err_scale[0][5]      <=     1053850      ;

        err_scale[1][0]      <=       35734      ;
        err_scale[1][1]      <=       71468      ;
        err_scale[1][2]      <=      142936      ;
        err_scale[1][3]      <=      285873      ;
        err_scale[1][4]      <=      571747      ;
        err_scale[1][5]      <=     1143495      ;

        err_scale[2][0]      <=       38968      ;
        err_scale[2][1]      <=       77937      ;
        err_scale[2][2]      <=      155874      ;
        err_scale[2][3]      <=      311749      ;
        err_scale[2][4]      <=      623498      ;
        err_scale[2][5]      <=     1246996      ;

        err_scale[3][0]      <=       42494      ;
        err_scale[3][1]      <=       84988      ;
        err_scale[3][2]      <=      169976      ;
        err_scale[3][3]      <=      339953      ;
        err_scale[3][4]      <=      679906      ;
        err_scale[3][5]      <=     1359812      ;

        err_scale[4][0]      <=       46178      ;
        err_scale[4][1]      <=       92356      ;
        err_scale[4][2]      <=      184713      ;
        err_scale[4][3]      <=      369427      ;
        err_scale[4][4]      <=      738855      ;
        err_scale[4][5]      <=     1477711      ;

        err_scale[5][0]      <=       50533      ;
        err_scale[5][1]      <=      101067      ;
        err_scale[5][2]      <=      202135      ;
        err_scale[5][3]      <=      404270      ;
        err_scale[5][4]      <=      808540      ;
        err_scale[5][5]      <=     1617081      ;

        err_scale[6][0]      <=       55108      ;
        err_scale[6][1]      <=      110217      ;
        err_scale[6][2]      <=      220435      ;
        err_scale[6][3]      <=      440871      ;
        err_scale[6][4]      <=      881742      ;
        err_scale[6][5]      <=     1763484      ;

        err_scale[7][0]      <=       59932      ;
        err_scale[7][1]      <=      119864      ;
        err_scale[7][2]      <=      239728      ;
        err_scale[7][3]      <=      479456      ;
        err_scale[7][4]      <=      958912      ;
        err_scale[7][5]      <=     1917824      ;

        err_scale[8][0]      <=       65536      ;
        err_scale[8][1]      <=      131072      ;
        err_scale[8][2]      <=      262144      ;
        err_scale[8][3]      <=      524288      ;
        err_scale[8][4]      <=     1048576      ;
        err_scale[8][5]      <=     2097152      ;

        err_scale[9][0]      <=       71468      ;
        err_scale[9][1]      <=      142936      ;
        err_scale[9][2]      <=      285873      ;
        err_scale[9][3]      <=      571747      ;
        err_scale[9][4]      <=     1143495      ;
        err_scale[9][5]      <=     2286990      ;

        err_scale[10][0]      <=       77931      ;
        err_scale[10][1]      <=      155863      ;
        err_scale[10][2]      <=      311726      ;
        err_scale[10][3]      <=      623452      ;
        err_scale[10][4]      <=     1246905      ;
        err_scale[10][5]      <=     2493811      ;

        err_scale[11][0]      <=       85150      ;
        err_scale[11][1]      <=      170300      ;
        err_scale[11][2]      <=      340600      ;
        err_scale[11][3]      <=      681200      ;
        err_scale[11][4]      <=     1362400      ;
        err_scale[11][5]      <=     2724800      ;

        err_scale[12][0]      <=       92675      ;
        err_scale[12][1]      <=      185351      ;
        err_scale[12][2]      <=      370703      ;
        err_scale[12][3]      <=      741406      ;
        err_scale[12][4]      <=     1482812      ;
        err_scale[12][5]      <=     2965625      ;

        err_scale[13][0]      <=      101239      ;
        err_scale[13][1]      <=      202478      ;
        err_scale[13][2]      <=      404956      ;
        err_scale[13][3]      <=      809912      ;
        err_scale[13][4]      <=     1619825      ;
        err_scale[13][5]      <=     3239650      ;

        err_scale[14][0]      <=      110059      ;
        err_scale[14][1]      <=      220119      ;
        err_scale[14][2]      <=      440238      ;
        err_scale[14][3]      <=      880477      ;
        err_scale[14][4]      <=     1760954      ;
        err_scale[14][5]      <=     3521908      ;

        err_scale[15][0]      <=      120186      ;
        err_scale[15][1]      <=      240372      ;
        err_scale[15][2]      <=      480744      ;
        err_scale[15][3]      <=      961488      ;
        err_scale[15][4]      <=     1922976      ;
        err_scale[15][5]      <=     3845952      ;

        err_scale[16][0]      <=      131232      ;
        err_scale[16][1]      <=      262464      ;
        err_scale[16][2]      <=      524928      ;
        err_scale[16][3]      <=     1049857      ;
        err_scale[16][4]      <=     2099715      ;
        err_scale[16][5]      <=     4199430      ;

        err_scale[17][0]      <=      142936      ;
        err_scale[17][1]      <=      285873      ;
        err_scale[17][2]      <=      571747      ;
        err_scale[17][3]      <=     1143495      ;
        err_scale[17][4]      <=     2286990      ;
        err_scale[17][5]      <=     4573980      ;

        err_scale[18][0]      <=      155885      ;
        err_scale[18][1]      <=      311771      ;
        err_scale[18][2]      <=      623543      ;
        err_scale[18][3]      <=     1247086      ;
        err_scale[18][4]      <=     2494173      ;
        err_scale[18][5]      <=     4988347      ;

        err_scale[19][0]      <=      169842      ;
        err_scale[19][1]      <=      339684      ;
        err_scale[19][2]      <=      679368      ;
        err_scale[19][3]      <=     1358736      ;
        err_scale[19][4]      <=     2717473      ;
        err_scale[19][5]      <=     5434947      ;

        err_scale[20][0]      <=      185511      ;
        err_scale[20][1]      <=      371023      ;
        err_scale[20][2]      <=      742046      ;
        err_scale[20][3]      <=     1484093      ;
        err_scale[20][4]      <=     2968187      ;
        err_scale[20][5]      <=     5936374      ;

        err_scale[21][0]      <=      202287      ;
        err_scale[21][1]      <=      404574      ;
        err_scale[21][2]      <=      809149      ;
        err_scale[21][3]      <=     1618299      ;
        err_scale[21][4]      <=     3236599      ;
        err_scale[21][5]      <=     6473198      ;

        err_scale[22][0]      <=      220480      ;
        err_scale[22][1]      <=      440961      ;
        err_scale[22][2]      <=      881923      ;
        err_scale[22][3]      <=     1763846      ;
        err_scale[22][4]      <=     3527693      ;
        err_scale[22][5]      <=     7055387      ;

        err_scale[23][0]      <=      240210      ;
        err_scale[23][1]      <=      480421      ;
        err_scale[23][2]      <=      960842      ;
        err_scale[23][3]      <=     1921685      ;
        err_scale[23][4]      <=     3843371      ;
        err_scale[23][5]      <=     7686742      ;

        err_scale[24][0]      <=      262144      ;
        err_scale[24][1]      <=      524288      ;
        err_scale[24][2]      <=     1048576      ;
        err_scale[24][3]      <=     2097152      ;
        err_scale[24][4]      <=     4194304      ;
        err_scale[24][5]      <=     8388608      ;

        err_scale[25][0]      <=      285873      ;
        err_scale[25][1]      <=      571747      ;
        err_scale[25][2]      <=     1143495      ;
        err_scale[25][3]      <=     2286990      ;
        err_scale[25][4]      <=     4573980      ;
        err_scale[25][5]      <=     9147960      ;

        err_scale[26][0]      <=      311771      ;
        err_scale[26][1]      <=      623543      ;
        err_scale[26][2]      <=     1247086      ;
        err_scale[26][3]      <=     2494173      ;
        err_scale[26][4]      <=     4988347      ;
        err_scale[26][5]      <=     9976695      ;

        err_scale[27][0]      <=      340006      ;
        err_scale[27][1]      <=      680013      ;
        err_scale[27][2]      <=     1360027      ;
        err_scale[27][3]      <=     2720055      ;
        err_scale[27][4]      <=     5440110      ;
        err_scale[27][5]      <=    10880221      ;

        err_scale[28][0]      <=      370511      ;
        err_scale[28][1]      <=      741022      ;
        err_scale[28][2]      <=     1482045      ;
        err_scale[28][3]      <=     2964090      ;
        err_scale[28][4]      <=     5928181      ;
        err_scale[28][5]      <=    11856362      ;

        err_scale[29][0]      <=      403966      ;
        err_scale[29][1]      <=      807932      ;
        err_scale[29][2]      <=     1615864      ;
        err_scale[29][3]      <=     3231728      ;
        err_scale[29][4]      <=     6463457      ;
        err_scale[29][5]      <=    12926914      ;

        err_scale[30][0]      <=      440780      ;
        err_scale[30][1]      <=      881561      ;
        err_scale[30][2]      <=     1763122      ;
        err_scale[30][3]      <=     3526245      ;
        err_scale[30][4]      <=     7052491      ;
        err_scale[30][5]      <=    14104982      ;

        err_scale[31][0]      <=      480636      ;
        err_scale[31][1]      <=      961272      ;
        err_scale[31][2]      <=     1922545      ;
        err_scale[31][3]      <=     3845091      ;
        err_scale[31][4]      <=     7690183      ;
        err_scale[31][5]      <=    15380366      ;

        err_scale[32][0]      <=      524288      ;
        err_scale[32][1]      <=     1048576      ;
        err_scale[32][2]      <=     2097152      ;
        err_scale[32][3]      <=     4194304      ;
        err_scale[32][4]      <=     8388608      ;
        err_scale[32][5]      <=    16777216      ;

        err_scale[33][0]      <=      571747      ;
        err_scale[33][1]      <=     1143495      ;
        err_scale[33][2]      <=     2286990      ;
        err_scale[33][3]      <=     4573980      ;
        err_scale[33][4]      <=     9147960      ;
        err_scale[33][5]      <=    18295920      ;

        err_scale[34][0]      <=      623543      ;
        err_scale[34][1]      <=     1247086      ;
        err_scale[34][2]      <=     2494173      ;
        err_scale[34][3]      <=     4988347      ;
        err_scale[34][4]      <=     9976695      ;
        err_scale[34][5]      <=    19953390      ;

        err_scale[35][0]      <=      679583      ;
        err_scale[35][1]      <=     1359166      ;
        err_scale[35][2]      <=     2718333      ;
        err_scale[35][3]      <=     5436667      ;
        err_scale[35][4]      <=    10873334      ;
        err_scale[35][5]      <=    21746669      ;

        err_scale[36][0]      <=      741534      ;
        err_scale[36][1]      <=     1483068      ;
        err_scale[36][2]      <=     2966137      ;
        err_scale[36][3]      <=     5932275      ;
        err_scale[36][4]      <=    11864550      ;
        err_scale[36][5]      <=    23729101      ;

        err_scale[37][0]      <=      808540      ;
        err_scale[37][1]      <=     1617081      ;
        err_scale[37][2]      <=     3234162      ;
        err_scale[37][3]      <=     6468324      ;
        err_scale[37][4]      <=    12936648      ;
        err_scale[37][5]      <=    25873296      ;

        err_scale[38][0]      <=      881561      ;
        err_scale[38][1]      <=     1763122      ;
        err_scale[38][2]      <=     3526245      ;
        err_scale[38][3]      <=     7052491      ;
        err_scale[38][4]      <=    14104982      ;
        err_scale[38][5]      <=    28209965      ;

        err_scale[39][0]      <=      962134      ;
        err_scale[39][1]      <=     1924268      ;
        err_scale[39][2]      <=     3848537      ;
        err_scale[39][3]      <=     7697074      ;
        err_scale[39][4]      <=    15394148      ;
        err_scale[39][5]      <=    30788296      ;

        err_scale[40][0]      <=     1048576      ;
        err_scale[40][1]      <=     2097152      ;
        err_scale[40][2]      <=     4194304      ;
        err_scale[40][3]      <=     8388608      ;
        err_scale[40][4]      <=    16777216      ;
        err_scale[40][5]      <=    33554432      ;

        err_scale[41][0]      <=     1142278      ;
        err_scale[41][1]      <=     2284557      ;
        err_scale[41][2]      <=     4569114      ;
        err_scale[41][3]      <=     9138228      ;
        err_scale[41][4]      <=    18276456      ;
        err_scale[41][5]      <=    36552913      ;

        err_scale[42][0]      <=     1248537      ;
        err_scale[42][1]      <=     2497074      ;
        err_scale[42][2]      <=     4994148      ;
        err_scale[42][3]      <=     9988296      ;
        err_scale[42][4]      <=    19976592      ;
        err_scale[42][5]      <=    39953184      ;

        err_scale[43][0]      <=     1359166      ;
        err_scale[43][1]      <=     2718333      ;
        err_scale[43][2]      <=     5436667      ;
        err_scale[43][3]      <=    10873334      ;
        err_scale[43][4]      <=    21746669      ;
        err_scale[43][5]      <=    43493339      ;

        err_scale[44][0]      <=     1483068      ;
        err_scale[44][1]      <=     2966137      ;
        err_scale[44][2]      <=     5932275      ;
        err_scale[44][3]      <=    11864550      ;
        err_scale[44][4]      <=    23729101      ;
        err_scale[44][5]      <=    47458202      ;

        err_scale[45][0]      <=     1617081      ;
        err_scale[45][1]      <=     3234162      ;
        err_scale[45][2]      <=     6468324      ;
        err_scale[45][3]      <=    12936648      ;
        err_scale[45][4]      <=    25873296      ;
        err_scale[45][5]      <=    51746593      ;

        err_scale[46][0]      <=     1766022      ;
        err_scale[46][1]      <=     3532045      ;
        err_scale[46][2]      <=     7064090      ;
        err_scale[46][3]      <=    14128181      ;
        err_scale[46][4]      <=    28256363      ;
        err_scale[46][5]      <=    56512727      ;

        err_scale[47][0]      <=     1924268      ;
        err_scale[47][1]      <=     3848537      ;
        err_scale[47][2]      <=     7697074      ;
        err_scale[47][3]      <=    15394148      ;
        err_scale[47][4]      <=    30788296      ;
        err_scale[47][5]      <=    61576592      ;

        err_scale[48][0]      <=     2097152      ;
        err_scale[48][1]      <=     4194304      ;
        err_scale[48][2]      <=     8388608      ;
        err_scale[48][3]      <=    16777216      ;
        err_scale[48][4]      <=    33554432      ;
        err_scale[48][5]      <=    67108864      ;

        err_scale[49][0]      <=     2284557      ;
        err_scale[49][1]      <=     4569114      ;
        err_scale[49][2]      <=     9138228      ;
        err_scale[49][3]      <=    18276456      ;
        err_scale[49][4]      <=    36552913      ;
        err_scale[49][5]      <=    73105826      ;

        err_scale[50][0]      <=     2497074      ;
        err_scale[50][1]      <=     4994148      ;
        err_scale[50][2]      <=     9988296      ;
        err_scale[50][3]      <=    19976592      ;
        err_scale[50][4]      <=    39953184      ;
        err_scale[50][5]      <=    79906368      ;

        err_scale[51][0]      <=     2725233      ;
        err_scale[51][1]      <=     5450466      ;
        err_scale[51][2]      <=    10900932      ;
        err_scale[51][3]      <=    21801864      ;
        err_scale[51][4]      <=    43603728      ;
        err_scale[51][5]      <=    87207457      ;

        err_scale[52][0]      <=     2966137      ;
        err_scale[52][1]      <=     5932275      ;
        err_scale[52][2]      <=    11864550      ;
        err_scale[52][3]      <=    23729101      ;
        err_scale[52][4]      <=    47458202      ;
        err_scale[52][5]      <=    94916404      ;

        err_scale[53][0]      <=     3234162      ;
        err_scale[53][1]      <=     6468324      ;
        err_scale[53][2]      <=    12936648      ;
        err_scale[53][3]      <=    25873296      ;
        err_scale[53][4]      <=    51746593      ;
        err_scale[53][5]      <=   103493187      ;

        err_scale[54][0]      <=     3532045      ;
        err_scale[54][1]      <=     7064090      ;
        err_scale[54][2]      <=    14128181      ;
        err_scale[54][3]      <=    28256363      ;
        err_scale[54][4]      <=    56512727      ;
        err_scale[54][5]      <=   113025455      ;

        err_scale[55][0]      <=     3834792      ;
        err_scale[55][1]      <=     7669584      ;
        err_scale[55][2]      <=    15339168      ;
        err_scale[55][3]      <=    30678337      ;
        err_scale[55][4]      <=    61356675      ;
        err_scale[55][5]      <=   122713351      ;

        err_scale[56][0]      <=     4194304      ;
        err_scale[56][1]      <=     8388608      ;
        err_scale[56][2]      <=    16777216      ;
        err_scale[56][3]      <=    33554432      ;
        err_scale[56][4]      <=    67108864      ;
        err_scale[56][5]      <=   134217728      ;

        err_scale[57][0]      <=     4628197      ;
        err_scale[57][1]      <=     9256395      ;
        err_scale[57][2]      <=    18512790      ;
        err_scale[57][3]      <=    37025580      ;
        err_scale[57][4]      <=    74051160      ;
        err_scale[57][5]      <=   148102320      ;

        err_scale[58][0]      <=     4971026      ;
        err_scale[58][1]      <=     9942053      ;
        err_scale[58][2]      <=    19884107      ;
        err_scale[58][3]      <=    39768215      ;
        err_scale[58][4]      <=    79536431      ;
        err_scale[58][5]      <=   159072862      ;

        err_scale[59][0]      <=     5422938      ;
        err_scale[59][1]      <=    10845877      ;
        err_scale[59][2]      <=    21691754      ;
        err_scale[59][3]      <=    43383508      ;
        err_scale[59][4]      <=    86767016      ;
        err_scale[59][5]      <=   173534032      ;

        err_scale[60][0]      <=     5899680      ;
        err_scale[60][1]      <=    11799360      ;
        err_scale[60][2]      <=    23598721      ;
        err_scale[60][3]      <=    47197442      ;
        err_scale[60][4]      <=    94394885      ;
        err_scale[60][5]      <=   188789771      ;

        err_scale[61][0]      <=     6468324      ;
        err_scale[61][1]      <=    12936648      ;
        err_scale[61][2]      <=    25873296      ;
        err_scale[61][3]      <=    51746593      ;
        err_scale[61][4]      <=   103493187      ;
        err_scale[61][5]      <=   206986375      ;

        err_scale[62][0]      <=     7064090      ;
        err_scale[62][1]      <=    14128181      ;
        err_scale[62][2]      <=    28256363      ;
        err_scale[62][3]      <=    56512727      ;
        err_scale[62][4]      <=   113025455      ;
        err_scale[62][5]      <=   226050910      ;

        err_scale[63][0]      <=     7780737      ;
        err_scale[63][1]      <=    15561475      ;
        err_scale[63][2]      <=    31122951      ;
        err_scale[63][3]      <=    62245902      ;
        err_scale[63][4]      <=   124491805      ;
        err_scale[63][5]      <=   248983611      ;

        err_scale[64][0]      <=     8388608      ;
        err_scale[64][1]      <=    16777216      ;
        err_scale[64][2]      <=    33554432      ;
        err_scale[64][3]      <=    67108864      ;
        err_scale[64][4]      <=   134217728      ;
        err_scale[64][5]      <=   268435456      ;

        err_scale[65][0]      <=     9099506      ;
        err_scale[65][1]      <=    18199013      ;
        err_scale[65][2]      <=    36398027      ;
        err_scale[65][3]      <=    72796055      ;
        err_scale[65][4]      <=   145592111      ;
        err_scale[65][5]      <=   291184223      ;

        err_scale[66][0]      <=     9942053      ;
        err_scale[66][1]      <=    19884107      ;
        err_scale[66][2]      <=    39768215      ;
        err_scale[66][3]      <=    79536431      ;
        err_scale[66][4]      <=   159072862      ;
        err_scale[66][5]      <=   318145725      ;

        err_scale[67][0]      <=    10956549      ;
        err_scale[67][1]      <=    21913098      ;
        err_scale[67][2]      <=    43826196      ;
        err_scale[67][3]      <=    87652393      ;
        err_scale[67][4]      <=   175304787      ;
        err_scale[67][5]      <=   350609575      ;

        err_scale[68][0]      <=    11930464      ;
        err_scale[68][1]      <=    23860929      ;
        err_scale[68][2]      <=    47721858      ;
        err_scale[68][3]      <=    95443717      ;
        err_scale[68][4]      <=   190887435      ;
        err_scale[68][5]      <=   381774870      ;

        err_scale[69][0]      <=    13094412      ;
        err_scale[69][1]      <=    26188824      ;
        err_scale[69][2]      <=    52377649      ;
        err_scale[69][3]      <=   104755299      ;
        err_scale[69][4]      <=   209510599      ;
        err_scale[69][5]      <=   419021199      ;

        err_scale[70][0]      <=    14128181      ;
        err_scale[70][1]      <=    28256363      ;
        err_scale[70][2]      <=    56512727      ;
        err_scale[70][3]      <=   113025455      ;
        err_scale[70][4]      <=   226050910      ;
        err_scale[70][5]      <=   452101820      ;

        err_scale[71][0]      <=    15339168      ;
        err_scale[71][1]      <=    30678337      ;
        err_scale[71][2]      <=    61356675      ;
        err_scale[71][3]      <=   122713351      ;
        err_scale[71][4]      <=   245426702      ;
        err_scale[71][5]      <=   490853405      ;

        err_scale[72][0]      <=    16777216      ;
        err_scale[72][1]      <=    33554432      ;
        err_scale[72][2]      <=    67108864      ;
        err_scale[72][3]      <=   134217728      ;
        err_scale[72][4]      <=   268435456      ;
        err_scale[72][5]      <=   536870912      ;

        err_scale[73][0]      <=    17895697      ;
        err_scale[73][1]      <=    35791394      ;
        err_scale[73][2]      <=    71582788      ;
        err_scale[73][3]      <=   143165576      ;
        err_scale[73][4]      <=   286331153      ;
        err_scale[73][5]      <=   572662306      ;

        err_scale[74][0]      <=    19884107      ;
        err_scale[74][1]      <=    39768215      ;
        err_scale[74][2]      <=    79536431      ;
        err_scale[74][3]      <=   159072862      ;
        err_scale[74][4]      <=   318145725      ;
        err_scale[74][5]      <=   636291451      ;

        err_scale[75][0]      <=    21474836      ;
        err_scale[75][1]      <=    42949672      ;
        err_scale[75][2]      <=    85899345      ;
        err_scale[75][3]      <=   171798691      ;
        err_scale[75][4]      <=   343597383      ;
        err_scale[75][5]      <=   687194767      ;

        err_scale[76][0]      <=    23342213      ;
        err_scale[76][1]      <=    46684427      ;
        err_scale[76][2]      <=    93368854      ;
        err_scale[76][3]      <=   186737708      ;
        err_scale[76][4]      <=   373475417      ;
        err_scale[76][5]      <=   746950834      ;

        err_scale[77][0]      <=    25565281      ;
        err_scale[77][1]      <=    51130563      ;
        err_scale[77][2]      <=   102261126      ;
        err_scale[77][3]      <=   204522252      ;
        err_scale[77][4]      <=   409044504      ;
        err_scale[77][5]      <=   818089008      ;

        err_scale[78][0]      <=    28256363      ;
        err_scale[78][1]      <=    56512727      ;
        err_scale[78][2]      <=   113025455      ;
        err_scale[78][3]      <=   226050910      ;
        err_scale[78][4]      <=   452101820      ;
        err_scale[78][5]      <=   904203641      ;

        err_scale[79][0]      <=    29826161      ;
        err_scale[79][1]      <=    59652323      ;
        err_scale[79][2]      <=   119304647      ;
        err_scale[79][3]      <=   238609294      ;
        err_scale[79][4]      <=   477218588      ;
        err_scale[79][5]      <=   954437176      ;
    end
end

endmodule