# AVS3-RDOQ



#### 版本记录

###### V0.0 ，单尺寸流水

| 时间     | 备注               | LUT     | FF    | RAM(bits) | DSP  | Fmax(MHz) |
| -------- | ------------------ | ------- | ----- | --------- | ---- | --------- |
| 2023.4.1 | 单尺寸RDOQ流水结构 | 898543  | 49121 | 0         | 392  | 33.1      |
|          | pre_quant          | 31460   | 31855 | 0         | 32   | 177       |
|          | ocd                | 1019248 | 36430 | 0         | 382  | 33.1      |
|          | lnpd               | 3299    | 3435  | 0         | 0    | 189.25    |

| 时间     | 备注               | LUT    | FF    | RAM(bits) | DSP  | Fmax(MHz) |
| -------- | ------------------ | ------ | ----- | --------- | ---- | --------- |
| 2023.4.3 | 单尺寸RDOQ流水结构 | 413446 | 49309 | 0         | 400  |           |
|          | pre_quant          | 40216  | 5534  | 0         | 0    | 188.2     |
|          | ocd                | 254836 | 40527 | 0         | 400  | 47.58     |
|          | lnpd               | 2767   | 3187  | 0         | 0    | 189.25    |

| 时间     | 备注               | LUT    | FF    | RAM(bits) | DSP  | Fmax(MHz) |
| -------- | ------------------ | ------ | ----- | --------- | ---- | --------- |
| 2023.4.6 | 单尺寸RDOQ流水结构 | 108330 | 23364 | 0         | 368  |           |
|          | pre_quant          | 9278   | 16207 | 0         | 32   |           |
|          | ocd                | 94603  | 19085 | 0         | 288  | 110       |
|          | lnpd               | 3143   | 2584  | 0         | 0    |           |

| 时间     | 备注               | LUT   | FF    | RAM(bits) | DSP  | Fmax(MHz) |
| -------- | ------------------ | ----- | ----- | --------- | ---- | --------- |
| 2023.4.7 | 单尺寸RDOQ流水结构 | 93994 | 30111 | 0         | 320  | 109.72    |
|          | pre_quant          | 9481  | 11692 | 0         | 32   | 350.2     |
|          | ocd                | 82127 | 14429 | 0         | 288  | 110       |
|          | lnpd               | 2371  | 3950  | 0         | 0    |           |

###### v0.1 ，单尺寸流水

​	1.ocd优化, 优化计算式,提前计算err值

​	2.pre_quant优化，减少乘法器位宽

​	3.reconfirm the bit width of each variable

​	4.reduce one array of dCurrCost_tem

​	5.reduce half number of rdoq_est_last, [2 6 12 2]->[1 6 12 2]

| 时间      | 备注               | LUT   | FF    | RAM(bits) | DSP  | Fmax(MHz)   |
| --------- | ------------------ | ----- | ----- | --------- | ---- | ----------- |
| 2023.4.10 | 单尺寸RDOQ流水结构 | 76846 | 24659 | 0         | 352  | 109.72（s） |
|           | pre_quant          | 6446  | 9225  | 0         | 32   | 350.2（v）  |
|           | ocd                | 67397 | 12967 | 0         | 320  | 64.11（v）  |
|           | lnpd               | 2989  | 2427  | 0         | 0    | 189.25（v） |

1.replace the multiplication operation to add and shift operation in "temp_coef_abs_d2" which value is between 2-9

2.reduce the bit width of "i64Delta" thus reduce half amount of dsp in the calcualtion of "err" 

| 时间      | 备注               | LUT   | FF    | RAM(bits) | DSP  | Fmax(MHz)   |
| --------- | ------------------ | ----- | ----- | --------- | ---- | ----------- |
| 2023.4.12 | 单尺寸RDOQ流水结构 | 79711 | 24259 | 0         | 224  | 126.85（s） |
|           | pre_quant          | 6374  | 9879  | 0         | 32   | 350.2（v）  |
|           | ocd                | 69714 | 14757 | 0         | 192  |             |
|           | lnpd               | 2985  | 2427  | 0         | 0    | 189.25（v） |

v1.0 ，多并行流水

| 时间      | 备注               | LUT   | FF    | RAM(bits) | DSP  | Fmax(MHz) |
| --------- | ------------------ | ----- | ----- | --------- | ---- | --------- |
| 2023.4.16 | 多并行RDOQ流水结构 | 78330 | 21965 | 0         | 224  | 113.57(s) |
|           | pre_quant          | 6523  | 7349  | 0         | 32   | 335.6(s)  |
|           | ocd                | 76350 | 15857 | 0         | 192  | 113.6(s)  |
|           | lnpd               | 2854  | 2538  | 0         | 0    | 394.1(s)  |

|      |
| ---- |

v1.1，多并行流水

delete some unnecesssary delay operation in the **PQ** module cause there's so much unused signal through this module(the deleted siganl was given by the testbench file to the next stage **OCD** )

| 时间      | 备注               | LUT   | FF    | RAM(bits) | DSP  | Fmax(MHz) |
| --------- | ------------------ | ----- | ----- | --------- | ---- | --------- |
| 2023.4.21 | 多并行RDOQ流水结构 | 72017 | 23440 | 0         | 224  | 116.27(s) |
|           | pre_quant          | 6115  | 3289  | 0         | 32   | 335.6(s)  |
|           | ocd                | 63559 | 16644 | 0         | 192  | 113.6(s)  |
|           | lnpd               | 2338  | 3476  | 0         | 0    | 394.1(s)  |
