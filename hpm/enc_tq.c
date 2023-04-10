/* ====================================================================================================================

  The copyright in this software is being made available under the License included below.
  This software may be subject to other third party and contributor rights, including patent rights, and no such
  rights are granted under this license.

  Copyright (c) 2018, HUAWEI TECHNOLOGIES CO., LTD. All rights reserved.
  Copyright (c) 2018, SAMSUNG ELECTRONICS CO., LTD. All rights reserved.
  Copyright (c) 2018, PEKING UNIVERSITY SHENZHEN GRADUATE SCHOOL. All rights reserved.
  Copyright (c) 2018, PENGCHENG LABORATORY. All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted only for
  the purpose of developing standards within Audio and Video Coding Standard Workgroup of China (AVS) and for testing and
  promoting such standards. The following conditions are required to be met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and
      the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
      the following disclaimer in the documentation and/or other materials provided with the distribution.
    * The name of HUAWEI TECHNOLOGIES CO., LTD. or SAMSUNG ELECTRONICS CO., LTD. may not be used to endorse or promote products derived from
      this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

* ====================================================================================================================
*/

#include "enc_def.h"
#include <math.h>


#define QUANT(c, scale, offset, shift) ((s16)((((c)*(scale)) + (offset)) >> (shift)))

#if USE_RDOQ
static s64 err_scale_tbl[80][MAX_CU_DEPTH]; // [64 + 16][MAX_CU_DEPTH]
#endif

const int quant_scale[80] =   // [64 + 16]
{
    16302, 15024, 13777, 12634, 11626, 10624,  9742,  8958,
    8192,  7512,  6889,  6305,  5793,  5303,  4878,  4467,
    4091,  3756,  3444,  3161,  2894,  2654,  2435,  2235,
    2048,  1878,  1722,  1579,  1449,  1329,  1218,  1117,
    1024,   939,   861,   790,   724,   664,   609,   558,
    512,   470,   430,   395,   362,   332,   304,   279,
    256,   235,   215,   197,   181,   166,   152,   140,
    128,   116,   108,    99,    91,    83,    76,    69,
    64,    59,    54,    49,    45,    41,    38,    35,
    32,    30,    27,    25,    23,    21,    19,    18
};

/******************   DCT-2   ******************************************/

static void tx_dct2_pb2(s16 * src, s16 * dst, int shift, int line)
{
    int j;
    int E, O;
    int add = shift == 0 ? 0 : 1 << (shift - 1);
    for(j = 0; j < line; j++)
    {
        /* E and O */
        E = src[j*2+0] + src[j*2+1];
        O = src[j*2+0] - src[j*2+1];
        dst[0*line+j] = (s16)((com_tbl_tm2[DCT2][0][0]*E + add)>>shift);
        dst[1*line+j] = (s16)((com_tbl_tm2[DCT2][1][0]*O + add)>>shift);
    }
}

static void tx_dct2_pb4(s16 * src, s16 * dst, int shift, int line)
{
    int j;
    int E[2], O[2];
    int add = 1 << (shift - 1);
    for(j = 0; j < line; j++)
    {
        /* E and O */
        E[0] = src[j*4+0] + src[j*4+3];
        O[0] = src[j*4+0] - src[j*4+3];
        E[1] = src[j*4+1] + src[j*4+2];
        O[1] = src[j*4+1] - src[j*4+2];
        dst[0*line+j] = (s16)((com_tbl_tm4[DCT2][0][0]*E[0] + com_tbl_tm4[DCT2][0][1]*E[1] + add)>>shift);
        dst[2*line+j] = (s16)((com_tbl_tm4[DCT2][2][0]*E[0] + com_tbl_tm4[DCT2][2][1]*E[1] + add)>>shift);
        dst[1*line+j] = (s16)((com_tbl_tm4[DCT2][1][0]*O[0] + com_tbl_tm4[DCT2][1][1]*O[1] + add)>>shift);
        dst[3*line+j] = (s16)((com_tbl_tm4[DCT2][3][0]*O[0] + com_tbl_tm4[DCT2][3][1]*O[1] + add)>>shift);
    }
}

static void tx_dct2_pb8(s16 * src, s16 * dst, int shift, int line)
{
    int j, k;
    int E[4], O[4];
    int EE[2], EO[2];
    int add = 1 << (shift - 1);
    for(j = 0; j < line; j++)
    {
        /* E and O*/
        for(k = 0; k < 4; k++)
        {
            E[k] = src[j*8+k] + src[j*8+7-k];
            O[k] = src[j*8+k] - src[j*8+7-k];
        }
        /* EE and EO */
        EE[0] = E[0] + E[3];
        EO[0] = E[0] - E[3];
        EE[1] = E[1] + E[2];
        EO[1] = E[1] - E[2];
        dst[0*line+j] = (s16)((com_tbl_tm8[DCT2][0][0]*EE[0] + com_tbl_tm8[DCT2][0][1]*EE[1] + add)>>shift);
        dst[4*line+j] = (s16)((com_tbl_tm8[DCT2][4][0]*EE[0] + com_tbl_tm8[DCT2][4][1]*EE[1] + add)>>shift);
        dst[2*line+j] = (s16)((com_tbl_tm8[DCT2][2][0]*EO[0] + com_tbl_tm8[DCT2][2][1]*EO[1] + add)>>shift);
        dst[6*line+j] = (s16)((com_tbl_tm8[DCT2][6][0]*EO[0] + com_tbl_tm8[DCT2][6][1]*EO[1] + add)>>shift);
        dst[1*line+j] = (s16)((com_tbl_tm8[DCT2][1][0]*O[0] + com_tbl_tm8[DCT2][1][1]*O[1] + com_tbl_tm8[DCT2][1][2]*O[2] + com_tbl_tm8[DCT2][1][3]*O[3] + add)>>shift);
        dst[3*line+j] = (s16)((com_tbl_tm8[DCT2][3][0]*O[0] + com_tbl_tm8[DCT2][3][1]*O[1] + com_tbl_tm8[DCT2][3][2]*O[2] + com_tbl_tm8[DCT2][3][3]*O[3] + add)>>shift);
        dst[5*line+j] = (s16)((com_tbl_tm8[DCT2][5][0]*O[0] + com_tbl_tm8[DCT2][5][1]*O[1] + com_tbl_tm8[DCT2][5][2]*O[2] + com_tbl_tm8[DCT2][5][3]*O[3] + add)>>shift);
        dst[7*line+j] = (s16)((com_tbl_tm8[DCT2][7][0]*O[0] + com_tbl_tm8[DCT2][7][1]*O[1] + com_tbl_tm8[DCT2][7][2]*O[2] + com_tbl_tm8[DCT2][7][3]*O[3] + add)>>shift);
    }
}

static void tx_dct2_pb16(s16 * src, s16 * dst, int shift, int line)
{
    int j, k;
    int E[8], O[8];
    int EE[4], EO[4];
    int EEE[2], EEO[2];
    int add = 1 << (shift - 1);
    for(j = 0; j < line; j++)
    {
        /* E and O*/
        for(k = 0; k < 8; k++)
        {
            E[k] = src[j*16+k] + src[j*16+15-k];
            O[k] = src[j*16+k] - src[j*16+15-k];
        }
        /* EE and EO */
        for(k = 0; k < 4; k++)
        {
            EE[k] = E[k] + E[7-k];
            EO[k] = E[k] - E[7-k];
        }
        /* EEE and EEO */
        EEE[0] = EE[0] + EE[3];
        EEO[0] = EE[0] - EE[3];
        EEE[1] = EE[1] + EE[2];
        EEO[1] = EE[1] - EE[2];
        dst[ 0*line+j] = (s16)((com_tbl_tm16[DCT2][ 0][0]*EEE[0] + com_tbl_tm16[DCT2][ 0][1]*EEE[1] + add)>>shift);
        dst[ 8*line+j] = (s16)((com_tbl_tm16[DCT2][ 8][0]*EEE[0] + com_tbl_tm16[DCT2][ 8][1]*EEE[1] + add)>>shift);
        dst[ 4*line+j] = (s16)((com_tbl_tm16[DCT2][ 4][0]*EEO[0] + com_tbl_tm16[DCT2][ 4][1]*EEO[1] + add)>>shift);
        dst[12*line+j] = (s16)((com_tbl_tm16[DCT2][12][0]*EEO[0] + com_tbl_tm16[DCT2][12][1]*EEO[1] + add)>>shift);
        for(k = 2; k < 16; k += 4)
        {
            dst[k*line + j] = (s16)((com_tbl_tm16[DCT2][k][0] * EO[0] + com_tbl_tm16[DCT2][k][1] * EO[1] + com_tbl_tm16[DCT2][k][2] * EO[2] + com_tbl_tm16[DCT2][k][3] * EO[3] + add) >> shift);
        }
        for(k = 1; k < 16; k += 2)
        {
            dst[k*line + j] = (s16)((com_tbl_tm16[DCT2][k][0] * O[0] + com_tbl_tm16[DCT2][k][1] * O[1] + com_tbl_tm16[DCT2][k][2] * O[2] + com_tbl_tm16[DCT2][k][3] * O[3] +
                                     com_tbl_tm16[DCT2][k][4] * O[4] + com_tbl_tm16[DCT2][k][5] * O[5] + com_tbl_tm16[DCT2][k][6] * O[6] + com_tbl_tm16[DCT2][k][7] * O[7] + add) >> shift);
        }
    }
}

static void tx_dct2_pb32(s16 * src, s16 * dst, int shift, int line)
{
    int j, k;
    int E[16], O[16];
    int EE[8], EO[8];
    int EEE[4], EEO[4];
    int EEEE[2], EEEO[2];
    int add = 1 << (shift - 1);
    for(j = 0; j < line; j++)
    {
        /* E and O*/
        for(k = 0; k < 16; k++)
        {
            E[k] = src[j*32+k] + src[j*32+31-k];
            O[k] = src[j*32+k] - src[j*32+31-k];
        }
        /* EE and EO */
        for(k = 0; k < 8; k++)
        {
            EE[k] = E[k] + E[15-k];
            EO[k] = E[k] - E[15-k];
        }
        /* EEE and EEO */
        for(k = 0; k < 4; k++)
        {
            EEE[k] = EE[k] + EE[7-k];
            EEO[k] = EE[k] - EE[7-k];
        }
        /* EEEE and EEEO */
        EEEE[0] = EEE[0] + EEE[3];
        EEEO[0] = EEE[0] - EEE[3];
        EEEE[1] = EEE[1] + EEE[2];
        EEEO[1] = EEE[1] - EEE[2];
        dst[ 0*line+j] = (s16)((com_tbl_tm32[DCT2][ 0][0]*EEEE[0] + com_tbl_tm32[DCT2][ 0][1]*EEEE[1] + add)>>shift);
        dst[16*line+j] = (s16)((com_tbl_tm32[DCT2][16][0]*EEEE[0] + com_tbl_tm32[DCT2][16][1]*EEEE[1] + add)>>shift);
        dst[ 8*line+j] = (s16)((com_tbl_tm32[DCT2][ 8][0]*EEEO[0] + com_tbl_tm32[DCT2][ 8][1]*EEEO[1] + add)>>shift);
        dst[24*line+j] = (s16)((com_tbl_tm32[DCT2][24][0]*EEEO[0] + com_tbl_tm32[DCT2][24][1]*EEEO[1] + add)>>shift);
        for(k = 4; k < 32; k += 8)
        {
            dst[k*line + j] = (s16)((com_tbl_tm32[DCT2][k][0] * EEO[0] + com_tbl_tm32[DCT2][k][1] * EEO[1] + com_tbl_tm32[DCT2][k][2] * EEO[2] + com_tbl_tm32[DCT2][k][3] * EEO[3] + add) >> shift);
        }
        for(k = 2; k < 32; k += 4)
        {
            dst[k*line + j] = (s16)((com_tbl_tm32[DCT2][k][0] * EO[0] + com_tbl_tm32[DCT2][k][1] * EO[1] + com_tbl_tm32[DCT2][k][2] * EO[2] + com_tbl_tm32[DCT2][k][3] * EO[3] +
                                     com_tbl_tm32[DCT2][k][4] * EO[4] + com_tbl_tm32[DCT2][k][5] * EO[5] + com_tbl_tm32[DCT2][k][6] * EO[6] + com_tbl_tm32[DCT2][k][7] * EO[7] + add) >> shift);
        }
        for(k = 1; k < 32; k += 2)
        {
            dst[k*line + j] = (s16)((com_tbl_tm32[DCT2][k][0] * O[0] + com_tbl_tm32[DCT2][k][1] * O[1] + com_tbl_tm32[DCT2][k][2] * O[2] + com_tbl_tm32[DCT2][k][3] * O[3] +
                                     com_tbl_tm32[DCT2][k][4] * O[4] + com_tbl_tm32[DCT2][k][5] * O[5] + com_tbl_tm32[DCT2][k][6] * O[6] + com_tbl_tm32[DCT2][k][7] * O[7] +
                                     com_tbl_tm32[DCT2][k][8] * O[8] + com_tbl_tm32[DCT2][k][9] * O[9] + com_tbl_tm32[DCT2][k][10] * O[10] + com_tbl_tm32[DCT2][k][11] * O[11] +
                                     com_tbl_tm32[DCT2][k][12] * O[12] + com_tbl_tm32[DCT2][k][13] * O[13] + com_tbl_tm32[DCT2][k][14] * O[14] + com_tbl_tm32[DCT2][k][15] * O[15] + add) >> shift);
        }
    }
}

static void tx_dct2_pb64(s16 *src, s16 *dst, int shift, int line)
{
    const int tx_size = 64;
    const s8 * tm = com_tbl_tm64[DCT2][0];
    int j, k;
    int E[32], O[32];
    int EE[16], EO[16];
    int EEE[8], EEO[8];
    int EEEE[4], EEEO[4];
    int EEEEE[2], EEEEO[2];
    int add = 1 << (shift - 1);
    for(j = 0; j < line; j++)
    {
        for(k = 0; k < 32; k++)
        {
            E[k] = src[k] + src[63-k];
            O[k] = src[k] - src[63-k];
        }
        for (k=0; k<16; k++)
        {
            EE[k] = E[k] + E[31-k];
            EO[k] = E[k] - E[31-k];
        }
        for (k=0; k<8; k++)
        {
            EEE[k] = EE[k] + EE[15-k];
            EEO[k] = EE[k] - EE[15-k];
        }
        for (k=0; k<4; k++)
        {
            EEEE[k] = EEE[k] + EEE[7-k];
            EEEO[k] = EEE[k] - EEE[7-k];
        }
        EEEEE[0] = EEEE[0] + EEEE[3];
        EEEEO[0] = EEEE[0] - EEEE[3];
        EEEEE[1] = EEEE[1] + EEEE[2];
        EEEEO[1] = EEEE[1] - EEEE[2];
        dst[ 0       ] = (s16)((tm[ 0*64+0]*EEEEE[0] + tm[ 0*64+1]*EEEEE[1] + add)>>shift);
        dst[ 16*line ] = (s16)((tm[16*64+0]*EEEEO[0] + tm[16*64+1]*EEEEO[1] + add)>>shift);
        dst[ 32*line ] = (s16)((tm[32*64+0]*EEEEE[0] + tm[32*64+1]*EEEEE[1] + add)>>shift);
        dst[ 48*line ] = (s16)((tm[48*64+0]*EEEEO[0] + tm[48*64+1]*EEEEO[1] + add)>>shift);
        for (k=8; k<64; k+=16)
        {
            dst[ k*line ] = (s16)((tm[k*64+0]*EEEO[0] + tm[k*64+1]*EEEO[1] + tm[k*64+2]*EEEO[2] + tm[k*64+3]*EEEO[3] + add)>>shift);
        }
        for (k=4; k<64; k+=8)
        {
            dst[ k*line ] = (s16)((tm[k*64+0]*EEO[0] + tm[k*64+1]*EEO[1] + tm[k*64+2]*EEO[2] + tm[k*64+3]*EEO[3] +
                                   tm[k*64+4]*EEO[4] + tm[k*64+5]*EEO[5] + tm[k*64+6]*EEO[6] + tm[k*64+7]*EEO[7] + add)>>shift);
        }
        for (k=2; k<64; k+=4)
        {
            dst[ k*line ] = (s16)((tm[k*64+ 0]*EO[ 0] + tm[k*64+ 1]*EO[ 1] + tm[k*64+ 2]*EO[ 2] + tm[k*64+ 3]*EO[ 3] +
                                   tm[k*64+ 4]*EO[ 4] + tm[k*64+ 5]*EO[ 5] + tm[k*64+ 6]*EO[ 6] + tm[k*64+ 7]*EO[ 7] +
                                   tm[k*64+ 8]*EO[ 8] + tm[k*64+ 9]*EO[ 9] + tm[k*64+10]*EO[10] + tm[k*64+11]*EO[11] +
                                   tm[k*64+12]*EO[12] + tm[k*64+13]*EO[13] + tm[k*64+14]*EO[14] + tm[k*64+15]*EO[15] + add)>>shift);
        }
        for (k=1; k<64; k+=2)
        {
            dst[ k*line ] = (s16)((tm[k*64+ 0]*O[ 0] + tm[k*64+ 1]*O[ 1] + tm[k*64+ 2]*O[ 2] + tm[k*64+ 3]*O[ 3] +
                                   tm[k*64+ 4]*O[ 4] + tm[k*64+ 5]*O[ 5] + tm[k*64+ 6]*O[ 6] + tm[k*64+ 7]*O[ 7] +
                                   tm[k*64+ 8]*O[ 8] + tm[k*64+ 9]*O[ 9] + tm[k*64+10]*O[10] + tm[k*64+11]*O[11] +
                                   tm[k*64+12]*O[12] + tm[k*64+13]*O[13] + tm[k*64+14]*O[14] + tm[k*64+15]*O[15] +
                                   tm[k*64+16]*O[16] + tm[k*64+17]*O[17] + tm[k*64+18]*O[18] + tm[k*64+19]*O[19] +
                                   tm[k*64+20]*O[20] + tm[k*64+21]*O[21] + tm[k*64+22]*O[22] + tm[k*64+23]*O[23] +
                                   tm[k*64+24]*O[24] + tm[k*64+25]*O[25] + tm[k*64+26]*O[26] + tm[k*64+27]*O[27] +
                                   tm[k*64+28]*O[28] + tm[k*64+29]*O[29] + tm[k*64+30]*O[30] + tm[k*64+31]*O[31] + add)>>shift);
        }
        src += tx_size;
        dst ++;
    }
}

/******************   DCT-8   ******************************************/

static void tx_dct8_pb4(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i;
    int rnd_factor = 1 << (shift - 1);

    s8 *iT = com_tbl_tm4[DCT8][0];

    int c[4];
    const int  reducedLine = line;
    for (i = 0; i<reducedLine; i++)
    {
        // Intermediate Variables
        c[0] = src[0] + src[3];
        c[1] = src[2] + src[0];
        c[2] = src[3] - src[2];
        c[3] = iT[1] * src[1];

        dst[0 * line] = (s16)((iT[3] * c[0] + iT[2] * c[1] + c[3] + rnd_factor) >> shift);
        dst[1 * line] = (s16)((iT[1] * (src[0] - src[2] - src[3]) + rnd_factor) >> shift);
        dst[2 * line] = (s16)((iT[3] * c[2] + iT[2] * c[0] - c[3] + rnd_factor) >> shift);
        dst[3 * line] = (s16)((iT[3] * c[1] - iT[2] * c[2] - c[3] + rnd_factor) >> shift);

        src += 4;
        dst++;
    }
}

static void tx_dct8_pb8(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i, j, k, iSum;
    int rnd_factor = 1 << (shift - 1);

    const int uiTrSize = 8;
    s8 *iT;
    s16 *pCoef;

    const int  reducedLine = line;
    const int  cutoff = uiTrSize;
    for (i = 0; i<reducedLine; i++)
    {
        pCoef = dst;
        iT = com_tbl_tm8[DCT8][0];

        for (j = 0; j<cutoff; j++)
        {
            iSum = 0;
            for (k = 0; k<uiTrSize; k++)
            {
                iSum += src[k] * iT[k];
            }
            pCoef[i] = (s16)((iSum + rnd_factor) >> shift);
            pCoef += line;
            iT += uiTrSize;
        }
        src += uiTrSize;
    }
}

static void tx_dct8_pb16(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i, j, k, iSum;
    int rnd_factor = 1 << (shift - 1);

    const int uiTrSize = 16;
    s8 *iT;
    s16 *pCoef;

    const int  reducedLine = line;
    const int  cutoff = uiTrSize;
    for (i = 0; i<reducedLine; i++)
    {
        pCoef = dst;
        iT = com_tbl_tm16[DCT8][0];
        for (j = 0; j<cutoff; j++)
        {
            iSum = 0;
            for (k = 0; k<uiTrSize; k++)
            {
                iSum += src[k] * iT[k];
            }
            pCoef[i] = (s16)((iSum + rnd_factor) >> shift);
            pCoef += line;
            iT += uiTrSize;
        }
        src += uiTrSize;
    }
}

static void tx_dct8_pb32(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i, j, k, iSum;
    int rnd_factor = 1 << (shift - 1);

    const int uiTrSize = 32;
    s8 *iT;
    s16 *pCoef;

    const int  reducedLine = line;
    const int  cutoff = uiTrSize;
    for (i = 0; i<reducedLine; i++)
    {
        pCoef = dst;
        iT = com_tbl_tm32[DCT8][0];
        for (j = 0; j<cutoff; j++)
        {
            iSum = 0;
            for (k = 0; k<uiTrSize; k++)
            {
                iSum += src[k] * iT[k];
            }
            pCoef[i] = (s16)((iSum + rnd_factor) >> shift);
            iT += uiTrSize;
            pCoef += line;
        }
        src += uiTrSize;
    }
}

static void tx_dct8_pb64(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i, j, k, iSum;
    int rnd_factor = 1 << (shift - 1);

    const int uiTrSize = 64;
    s8 *iT;
    s16 *pCoef;

    const int  reducedLine = line;
    const int  cutoff = uiTrSize;
    for (i = 0; i<reducedLine; i++)
    {
        pCoef = dst;
        iT = com_tbl_tm64[DCT8][0];
        for (j = 0; j<cutoff; j++)
        {
            iSum = 0;
            for (k = 0; k<uiTrSize; k++)
            {
                iSum += src[k] * iT[k];
            }
            pCoef[i] = (s16)((iSum + rnd_factor) >> shift);
            iT += uiTrSize;
            pCoef += line;
        }
        src += uiTrSize;
    }
}

/******************   DST-7   ******************************************/

static void tx_dst7_pb4(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i;
    int rnd_factor = 1 << (shift - 1);

    s8 *iT = com_tbl_tm4[DST7][0];

    int c[4];
    const int  reducedLine = line;
    for (i = 0; i<reducedLine; i++)
    {
        // Intermediate Variables
        c[0] = src[0] + src[3];
        c[1] = src[1] + src[3];
        c[2] = src[0] - src[1];
        c[3] = iT[2] * src[2];

        dst[0 * line] = (s16)((iT[0] * c[0] + iT[1] * c[1] + c[3] + rnd_factor) >> shift);
        dst[1 * line] = (s16)((iT[2] * (src[0] + src[1] - src[3]) + rnd_factor) >> shift);
        dst[2 * line] = (s16)((iT[0] * c[2] + iT[1] * c[0] - c[3] + rnd_factor) >> shift);
        dst[3 * line] = (s16)((iT[1] * c[2] - iT[0] * c[1] + c[3] + rnd_factor) >> shift);

        src += 4;
        dst++;
    }
}

static void tx_dst7_pb8(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i, j, k, iSum;
    int rnd_factor = 1 << (shift - 1);

    const int uiTrSize = 8;
    s8 *iT;
    s16 *pCoef;

    const int  reducedLine = line;
    const int  cutoff = uiTrSize;
    for (i = 0; i<reducedLine; i++)
    {
        pCoef = dst;
        iT = com_tbl_tm8[DST7][0];
        for (j = 0; j<cutoff; j++)
        {
            iSum = 0;
            for (k = 0; k<uiTrSize; k++)
            {
                iSum += src[k] * iT[k];
            }
            pCoef[i] = (s16)((iSum + rnd_factor) >> shift);
            pCoef += line;
            iT += uiTrSize;
        }
        src += uiTrSize;
    }
}

static void tx_dst7_pb16(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i, j, k, iSum;
    int rnd_factor = 1 << (shift - 1);

    const int uiTrSize = 16;
    s8 *iT;
    s16 *pCoef;

    const int  reducedLine = line;
    const int  cutoff = uiTrSize;
    for (i = 0; i<reducedLine; i++)
    {
        pCoef = dst;
        iT = com_tbl_tm16[DST7][0];
        for (j = 0; j<cutoff; j++)
        {
            iSum = 0;
            for (k = 0; k<uiTrSize; k++)
            {
                iSum += src[k] * iT[k];
            }
            pCoef[i] = (s16)((iSum + rnd_factor) >> shift);
            pCoef += line;
            iT += uiTrSize;
        }
        src += uiTrSize;
    }
}

static void tx_dst7_pb32(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i, j, k, iSum;
    int rnd_factor = 1 << (shift - 1);

    const int uiTrSize = 32;
    s8 *iT;
    s16 *pCoef;


    const int  reducedLine = line;
    const int  cutoff = uiTrSize;
    for (i = 0; i<reducedLine; i++)
    {
        pCoef = dst;
        iT = com_tbl_tm32[DST7][0];
        for (j = 0; j<cutoff; j++)
        {
            iSum = 0;
            for (k = 0; k<uiTrSize; k++)
            {
                iSum += src[k] * iT[k];
            }
            pCoef[i] = (s16)((iSum + rnd_factor) >> shift);
            iT += uiTrSize;
            pCoef += line;
        }
        src += uiTrSize;
    }
}

static void tx_dst7_pb64(s16 *src, s16 *dst, int shift, int line)  // input src, output dst
{
    int i, j, k, iSum;
    int rnd_factor = 1 << (shift - 1);

    const int uiTrSize = 64;
    s8 *iT;
    s16 *pCoef;

    const int  reducedLine = line;
    const int  cutoff = uiTrSize;
    for (i = 0; i<reducedLine; i++)
    {
        pCoef = dst;
        iT = com_tbl_tm64[DST7][0];
        for (j = 0; j<cutoff; j++)
        {
            iSum = 0;
            for (k = 0; k<uiTrSize; k++)
            {
                iSum += src[k] * iT[k];
            }
            pCoef[i] = (s16)((iSum + rnd_factor) >> shift);
            iT += uiTrSize;
            pCoef += line;
        }
        src += uiTrSize;
    }
}


typedef void (*COM_TX)(s16 * coef, s16 * t, int shift, int line);
static COM_TX enc_tbl_tx[NUM_TRANS_TYPE][MAX_TR_LOG2] =
{
    {
        tx_dct2_pb2,
        tx_dct2_pb4,
        tx_dct2_pb8,
        tx_dct2_pb16,
        tx_dct2_pb32,
        tx_dct2_pb64
    },
    {
        NULL,
        tx_dct8_pb4,
        tx_dct8_pb8,
        tx_dct8_pb16,
        tx_dct8_pb32,
        tx_dct8_pb64
    },
    {
        NULL,
        tx_dst7_pb4,
        tx_dst7_pb8,
        tx_dst7_pb16,
        tx_dst7_pb32,
        tx_dst7_pb64
    }
};

static void xCTr_4_1d_Hor(s16 *src, int i_src, s16 *dst, int i_dst, int shift)
{
    int i, j, k, sum;
    int rnd_factor = shift == 0 ? 0 : 1 << (shift - 1);
    int tmpSrc[4][4];
    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            tmpSrc[i][j] = src[i * i_src + j];
        }
    }
    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            sum = rnd_factor;
            for (k = 0; k < 4; k++)
            {
                sum += tab_c4_trans[i][k] * tmpSrc[j][k];
            }
            dst[j * i_dst + i] = (s16)COM_CLIP3(-32768, 32767, sum >> shift);
        }
    }
}

static void xCTr_4_1d_Vert(s16 *src, int i_src, s16 *dst, int i_dst, int shift)
{
    int i, j, k, sum;
    int rnd_factor = shift == 0 ? 0 : 1 << (shift - 1);
    int tmpSrc[4][4];
    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            tmpSrc[i][j] = src[i* i_src + j];
        }
    }
    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            sum = rnd_factor;
            for (k = 0; k < 4; k++)
            {
                sum += tab_c4_trans[i][k] * tmpSrc[k][j];
            }
            dst[i* i_dst + j] = (s16)COM_CLIP3(-32768, 32767, sum >> shift);
        }
    }
}

static void xTr2nd_8_1d_Hor(s16 *src, int i_src)
{
    int i, j, k, sum;
    int rnd_factor;
    int tmpSrc[4][4];

    rnd_factor = 1 << (7 - 1);

    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            tmpSrc[i][j] = src[i * i_src + j];
        }
    }
    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            sum = rnd_factor;
            for (k = 0; k < 4; k++)
            {
                sum += tab_c8_trans[i][k] * tmpSrc[j][k];
            }
            src[j* i_src + i] = (s16)COM_CLIP3(-32768, 32767, sum >> 7);
        }
    }
}

static void xTr2nd_8_1d_Vert(s16 *src, int i_src)
{
    int i, j, k, sum;
    int rnd_factor;
    int tmpSrc[4][4];

    rnd_factor = 1 << (7 - 1);

    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            tmpSrc[i][j] = src[i * i_src + j];
        }
    }
    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            sum = rnd_factor;
            for (k = 0; k < 4; k++)
            {
                sum += tab_c8_trans[i][k] * tmpSrc[k][j];
            }
            src[i* i_src + j] = (s16)COM_CLIP3(-32768, 32767, sum >> 7);
        }
    }
}


static int com_get_forward_trans_shift(int log2_size, int type, int bit_depth)
{
    assert(log2_size <= 6);
    return (type == 0) ? (log2_size + bit_depth - 10) : (log2_size + 5);
}

void enc_trans(COM_MODE *mode, int plane, int blk_idx, s16 * coef, s16 *resi, int cu_width_log2, int cu_height_log2, int bIntra, int ch_type, int bit_depth, int secT_Ver_Hor, int use_alt4x4Trans)
{
    s16 coef_temp[MAX_TR_DIM];

    if((cu_width_log2 > MAX_TR_LOG2) || (cu_height_log2 > MAX_TR_LOG2))
    {
        assert(0);
    }
    else
    {
        int shift1 = com_get_forward_trans_shift(cu_width_log2, 0, bit_depth);
        int shift2 = com_get_forward_trans_shift(cu_height_log2, 1, bit_depth);
        int stride_tu = (1 << cu_width_log2);
        if (use_alt4x4Trans && cu_width_log2 == 2 && cu_height_log2 == 2)
        {
            s16 coef_temp2[16];
            assert(bIntra);
            xCTr_4_1d_Hor(resi, 4, coef_temp2, 4, shift1+1);
            xCTr_4_1d_Vert(coef_temp2, 4, coef, 4, shift2+1);
        }
        else
        {
            int nTrIdxHor = DCT2, nTrIdxVer = DCT2;

            if (plane == Y_C && mode->tb_part == SIZE_NxN)
            {
                nTrIdxHor = com_tbl_subset_inter[blk_idx &  1];
                nTrIdxVer = com_tbl_subset_inter[blk_idx >> 1];
            }

            enc_tbl_tx[nTrIdxHor][cu_width_log2 - 1](resi, coef_temp, shift1, 1 << cu_height_log2);
            enc_tbl_tx[nTrIdxVer][cu_height_log2 - 1](coef_temp, coef, shift2, 1 << cu_width_log2);

            if (secT_Ver_Hor >> 1)
            {
                assert(bIntra);
                xTr2nd_8_1d_Vert(coef, stride_tu);
            }
            if (secT_Ver_Hor & 1)
            {
                assert(bIntra);
                xTr2nd_8_1d_Hor(coef, stride_tu);
            }
        }
    }
}

static int get_transform_shift(const int bit_depth, const int tr_size_log2)
{
    return MAX_TX_DYNAMIC_RANGE - bit_depth - tr_size_log2;
}

#if USE_RDOQ
void enc_init_err_scale(int bit_depth)
{
    int qp;
    int i;
    for (qp = 0; qp < 80; qp++)
    {
        int q_value = quant_scale[qp];
        for (i = 0; i < MAX_CU_DEPTH; i++)
        {
            int tr_shift = get_transform_shift(bit_depth, i + 1);
            double err_scale = pow(2.0, SCALE_BITS -tr_shift);
            err_scale = err_scale / q_value / (1 << ((bit_depth - 8)));
            err_scale_tbl[qp][i] = (s64)(err_scale * (double)(1 << ERR_SCALE_PRECISION_BITS));
        }
    }
    return;
}

#define GET_I_COST(rate, lamba)  (rate*lamba)
#define GET_IEP_RATE             (32768)

int get_bits_0_order_exp_golomb(int value)
{
    for (int i = 0; i < 12; i++)
    {
        if (value <= (1 << (i + 1)) - 2)
        {
            return i * 2 + 1;
        }
    }
    return 25; //maybe should not happen
}

static __inline s64 get_ic_rate_cost_rl(u32 abs_level, u32 run, s32 ctx_run, u32 ctx_level, s64 lambda, u32 prev_level, int last_pos)
{
    s32 rate;
    if (abs_level == 0)
    {
        rate = 0;
        if (run == 0)
        {
            rate += rdoq_est_run[ctx_run][0];
        }
        else
        {
            rate += rdoq_est_run[ctx_run + 1][0];
        }
    }
    else
    {
        rate = GET_IEP_RATE; // sign of coeff

        if (!last_pos)
        {
            if (run == 0)
            {
                rate += rdoq_est_run[ctx_run][1];
            }
            else
            {
                rate += rdoq_est_run[ctx_run + 1][1];
            }
        }
        if (abs_level == 1)
        {
            rate += rdoq_est_level[ctx_level][1];
        }
        else if (abs_level >= 9)
        {
            rate += rdoq_est_level[ctx_level][0];
            rate += rdoq_est_level[ctx_level + 1][0] * 7;
            //get bits of exp-golomb
            rate += GET_IEP_RATE * get_bits_0_order_exp_golomb(abs_level - 9);
        }
        else
        {
            rate += rdoq_est_level[ctx_level][0];
            rate += rdoq_est_level[ctx_level + 1][0] * (s32)(abs_level - 2);
            rate += rdoq_est_level[ctx_level + 1][1];
        }
    }
    return (s64)GET_I_COST(rate, lambda);
}

static __inline u32 get_coded_level_rl(s64* rd64_uncoded_cost, s64* rd64_coded_cost, s64 level_double, u32 max_abs_level,
                                       u32 run, u16 ctx_run, u16 ctx_level, s32 q_bits, s64 err_scale, s64 lambda, u32 prev_level, int last_pos)
{
    u32 best_abs_level = 0;
    s64 err1 = (level_double * err_scale) >> ERR_SCALE_PRECISION_BITS;

    if (err1 > 0x1ffff) {
        int max_tem_level_err = 100;//位宽为20位，错误标志位置
    }


    u32 min_abs_level;
    u32 abs_level;
    *rd64_uncoded_cost = err1 * err1;


    if (*rd64_uncoded_cost > 0x1ffffffff) {
        int max_tem_level_err = 100;//位宽为36位，错误标志位置
    }


#ifdef tang_revise
    *rd64_coded_cost = *rd64_uncoded_cost + get_ic_rate_cost_rl(0, run, ctx_run, ctx_level, 1, prev_level, last_pos);
#else
    *rd64_coded_cost = *rd64_uncoded_cost + get_ic_rate_cost_rl(0, run, ctx_run, ctx_level, lambda, prev_level, last_pos);
#endif


    if (((*rd64_coded_cost > 0) ? *rd64_coded_cost : -*rd64_coded_cost) > 0x1ffffffff) {
        int max_tem_level_err = 100;//位宽为28位，错误标志位置
    }

    min_abs_level = (max_abs_level > 1 ? max_abs_level - 1 : 1);
    for (abs_level = max_abs_level; abs_level >= min_abs_level; abs_level--)
    {
        s64 i64Delta = level_double - ((s64)abs_level << q_bits);

        if (((i64Delta > 0) ? i64Delta : -i64Delta) > 0x3ffff) {
            int max_tem_level_err = 100;//位宽为28位，错误标志位置
        }




        s64 err = (i64Delta * err_scale) >> ERR_SCALE_PRECISION_BITS;




        if (i64Delta > 262143) {
            int a = 20;
        }
        if (err > 1023) {
            int a = 20;
        }
#ifdef tang_revise
        s64 dCurrCost = err * err + get_ic_rate_cost_rl(abs_level, run, ctx_run, ctx_level, 1, prev_level, last_pos);
#else
        s64 dCurrCost = err * err + get_ic_rate_cost_rl(abs_level, run, ctx_run, ctx_level, lambda, prev_level, last_pos);
#endif
        s64 dCurrCost_abs = dCurrCost > 0 ? dCurrCost : -dCurrCost;
        if (dCurrCost_abs > 0x1fffff) {
            int a = 10;
        }


        s64 rd64_coded_cost_abs = *rd64_coded_cost > 0 ? *rd64_coded_cost : -*rd64_coded_cost;
        if (rd64_coded_cost_abs > 0xfffffffff) {
            int a = 10;
        }

        if (dCurrCost < *rd64_coded_cost)
        {
            best_abs_level = abs_level;
            *rd64_coded_cost = dCurrCost;
        }
    }
    return best_abs_level;
}
#endif

static __inline int ace_get_log2(int v)
{
#ifdef _WIN32
    unsigned long index;
    _BitScanReverse(&index, v);
    return index;
#else
    return 31 - __builtin_clz(v);
#endif
}

#ifndef tang_revise
int enc_rdoq_run_length_cc(int qp, double d_lambda, int is_intra, s16 *src_coef, s16 *dst_tmp, int cu_width_log2, int cu_height_log2, int ch_type, int bit_depth)
{
    const int scale = quant_scale[qp];
    const int ns_shift = ((cu_width_log2 + cu_height_log2) & 1) ? 7 : 0;
    const int ns_scale = ((cu_width_log2 + cu_height_log2) & 1) ? 181 : 1;
    const int ns_offset = ((cu_width_log2 + cu_height_log2) & 1) ? (1 << (ns_shift - 1)) : 0;
    const int q_value = (scale * ns_scale + ns_offset) >> ns_shift;
    const int log2_size = (cu_width_log2 + cu_height_log2) >> 1;
    const int tr_shift = get_transform_shift(bit_depth, log2_size);
    const u32 max_num_coef = 1 << (cu_width_log2 + cu_height_log2);
    const u16 *scan = com_scan_tbl[COEF_SCAN_ZIGZAG][cu_width_log2 - 1][cu_height_log2 - 1];
    const int ctx_last = (ch_type == Y_C) ? 0 : 1;
    const int q_bits = QUANT_SHIFT + tr_shift;
    int num_nz_coef = 0;
    int sum_all = 0;
    u32 scan_pos;
    u32 run;
    u32 prev_level;
    s32 ctx_qt_cbf;
    u32 best_last_idx_p1 = 0;
    s16 tmp_coef[MAX_TR_DIM];
    s64 tmp_level_double[MAX_TR_DIM];
    s16 tmp_dst_coef[MAX_TR_DIM];
    const s64 lambda = (s64)(d_lambda * (double)(1 << SCALE_BITS) + 0.5);
    s64 err_scale = err_scale_tbl[qp][log2_size - 1];
    s64 d64_best_cost = 0;
    s64 d64_base_cost = 0;
    s64 d64_coded_cost = 0;
    s64 d64_uncoded_cost = 0;
    s64 d64_block_uncoded_cost = 0;
    s64 err;

    /* ===== quantization ===== */
    for (scan_pos = 0; scan_pos < max_num_coef; scan_pos++)
    {
        u32 blk_pos = scan[scan_pos];
        s64 level_double = src_coef[blk_pos];
        u32 max_abs_level;
        s8 lower_int;
        s64 temp_level;
        temp_level = ((s64)COM_ABS(src_coef[blk_pos]) * (s64)q_value);
        level_double = (int)COM_MIN(((s64)temp_level), (s64)COM_INT32_MAX - (s64)(1 << (q_bits - 1)));
        tmp_level_double[blk_pos] = level_double;
        max_abs_level = (u32)(level_double >> q_bits);
        lower_int = ((level_double - ((s64)max_abs_level << q_bits)) < (s64)(1 << (q_bits - 1))) ? 1 : 0;
        if (!lower_int)
        {
            max_abs_level++;
        }
        err = (level_double * err_scale) >> ERR_SCALE_PRECISION_BITS;
        d64_block_uncoded_cost += err * err;
        tmp_coef[blk_pos] = src_coef[blk_pos] > 0 ? (s16)max_abs_level : -(s16)(max_abs_level);
        sum_all += max_abs_level;
    }
    com_mset(dst_tmp, 0, sizeof(s16)*max_num_coef);
    if (sum_all == 0)
    {
        return num_nz_coef;
    }
    if (!is_intra && ch_type == Y_C)
    {
        d64_best_cost = d64_block_uncoded_cost + GET_I_COST(rdoq_est_ctp_zero_flag[1], lambda);
        d64_base_cost = d64_block_uncoded_cost + GET_I_COST(rdoq_est_ctp_zero_flag[0], lambda);
    }
    else
    {
        ctx_qt_cbf = ch_type;
        d64_best_cost = d64_block_uncoded_cost + GET_I_COST(rdoq_est_cbf[ctx_qt_cbf][0], lambda);
        d64_base_cost = d64_block_uncoded_cost + GET_I_COST(rdoq_est_cbf[ctx_qt_cbf][1], lambda);
    }
    run = 0;
    prev_level = 6;
    for (scan_pos = 0; scan_pos < max_num_coef; scan_pos++)
    {
        u32 blk_pos = scan[scan_pos];
        u32 level;

        int ctx_run = ((COM_MIN(prev_level - 1, 5)) << 1) + (ch_type == Y_C ? 0 : 12);
        int ctx_level = ((COM_MIN(prev_level - 1, 5)) << 1) + (ch_type == Y_C ? 0 : 12);

        level = get_coded_level_rl(&d64_uncoded_cost, &d64_coded_cost, tmp_level_double[blk_pos], COM_ABS(tmp_coef[blk_pos]),
                                   run, (u16)ctx_run, (u16)ctx_level, q_bits, err_scale, lambda, prev_level, scan_pos == max_num_coef - 1);
        tmp_dst_coef[blk_pos] = (s16)(tmp_coef[blk_pos] < 0 ? -(s32)(level) : level);
        d64_base_cost -= d64_uncoded_cost;
        d64_base_cost += d64_coded_cost;
        if (level)
        {
            /* ----- check for last flag ----- */
            s64 d64_cost_last_zero = GET_I_COST(rdoq_est_last[ctx_last][COM_MIN(prev_level - 1, 5)][ace_get_log2(scan_pos + 1)][0], lambda);
            s64 d64_cost_last_one = GET_I_COST(rdoq_est_last[ctx_last][COM_MIN(prev_level - 1, 5)][ace_get_log2(scan_pos + 1)][1], lambda);
            s64 d64_cur_is_last_cost = d64_base_cost + d64_cost_last_one;


            d64_base_cost += d64_cost_last_zero;
            if (d64_cur_is_last_cost < d64_best_cost)
            {
                d64_best_cost = d64_cur_is_last_cost;
                best_last_idx_p1 = scan_pos + 1;
            }
            run = 0;
            prev_level = level;
        }
        else
        {
            run++;
        }
    }
    /* ===== clean uncoded coeficients ===== */
    for (scan_pos = 0; scan_pos < max_num_coef; scan_pos++)
    {
        u32 blk_pos = scan[scan_pos];
        if (scan_pos < best_last_idx_p1)
        {
            if (tmp_dst_coef[blk_pos])
            {
                num_nz_coef++;
            }
        }
        else
        {
            tmp_dst_coef[blk_pos] = 0;
        }
        dst_tmp[blk_pos] = tmp_dst_coef[blk_pos];
    }
    return num_nz_coef;
}
#else

// left_col input.
void generate_left_col(int width, int height, int cu_width_log2, int cu_height_log2, u32 * left_pos, u32* bottom_pos) {
  
  int w = 1 << cu_width_log2;
  int h = 1 << cu_height_log2;

  for (int col = 0; col < width; col++) {
    for (int row = 0; row < height; row++) {
      int pos = 0;
      int sum = 0;
      // Convert 2D coordinate points to scan line points
      if (w == h) {                              // width == height
        if (row + col < w) {
          for (int i = 1; i <= row + col; i++) {
            sum += i;
          }
          if ((row + col) & 1) {
            pos = sum + row;
          }
          else {
            pos = sum + col;
          }
          sum = 0;
        }
        else {
          for (int i = 1; i <= w; i++) {
            sum += i;
          }
          for (int i = 1; i <= row + col - w; i++) {
            sum += h - i;
          }
          if ((row + col) & 1) {
            pos = sum + (w - 1 - col);
          }
          else {
            pos = sum + (h - 1 - row);
          }
          sum = 0;
        }
      }
      else if (w > h) {                        // width > height
        if (row + col < h) {
          for (int i = 1; i <= row + col; i++) {
            sum += i;
          }
          if ((row + col) & 1) {
            pos = sum + row;
          }
          else {
            pos = sum + col;
          }
          sum = 0;
        }
        else if (row + col >= w) {
          for (int i = 1; i <= h; i++) {
            sum += i;
          }
          sum += (w - h) * h;
          for (int i = 1; i <= row + col - w; i++) {
            sum += h - i;
          }
          if ((row + col) & 1) {
            pos = sum + (w - 1 - col);
          }
          else {
            pos = sum + (h - 1 - row);
          }
          sum = 0;
        }
        else {
          for (int i = 1; i <= h; i++) {
            sum += i;
          }
          sum += (row + col - h) * h;
          if ((row + col) & 1) {
            pos = sum + row;
          }
          else {
            pos = sum + (h - 1 - row);
          }
          sum = 0;
        }
      }
      else {                                   // width < height
        if (row + col < w) {
          for (int i = 1; i <= row + col; i++) {
            sum += i;
          }
          if ((row + col) & 1) {
            pos = sum + row;
          }
          else {
            pos = sum + col;
          }
          sum = 0;
        }
        else if (row + col >= h) {
          for (int i = 1; i <= w; i++) {
            sum += i;
          }
          sum += w * (h - w);
          for (int i = 1; i <= row + col - h; i++) {
            sum += w - i;
          }
          if ((row + col) & 1) {
            pos = sum + (w - 1 - col);
          }
          else {
            pos = sum + (h - 1 - row);
          }
          sum = 0;
        }
        else {
          for (int i = 1; i <= w; i++) {
            sum += i;
          }
          sum += (row + col - w) * w;
          if ((row + col) & 1) {
            pos = sum + (w - 1 - col);
          }
          else {
            pos = sum + col;
          }
          sum = 0;
        }
      }

      if (col == 0) {
        left_pos[row] = pos;
      }
      if (row == height - 1) {
        bottom_pos[col] = pos;
      }

    }
  }




}


/**
 *  Zig-zag Scanline Level Paralleled RDOQ Algorithm
 */

int enc_rdoq_run_length_cc(int qp, double d_lambda, int is_intra, s16* src_coef, s16* dst_tmp, int cu_width_log2, int cu_height_log2, int ch_type, int bit_depth) {

  int width = 1 << (cu_width_log2 < 5 ? cu_width_log2 : 5);
  int height = 1 << (cu_height_log2 < 5 ? cu_height_log2 : 5);
  int stride = 1 << cu_width_log2;
  //const u16* scan = com_scan_tbl[COEF_SCAN_ZIGZAG][cu_width_log2 - 1][cu_height_log2 - 1];
  u16 scale = quant_scale[qp];
  int ns_shift = ((cu_width_log2 + cu_height_log2) & 1) ? 7 : 0;
  int ns_scale = ((cu_width_log2 + cu_height_log2) & 1) ? 181 : 1;
  int ns_offset = ((cu_width_log2 + cu_height_log2) & 1) ? (1 << (ns_shift - 1)) : 0;
  int q_value = (scale * ns_scale + ns_offset) >> ns_shift;

  if (((q_value > 0) ? q_value : -q_value) > 0x7F) {
      int max_tem_level_err = 100;//位宽为20位，错误标志位置
  }
  int log2_size = (cu_width_log2 + cu_height_log2) >> 1;
  int tr_shift = 15 - bit_depth - log2_size;
  const u32 max_num_coef = 1 << (cu_width_log2 + cu_height_log2);
  int ctx_last = (ch_type == Y_C) ? 0 : 1;
  const int q_bits = QUANT_SHIFT + tr_shift;

  if (((q_bits > 0) ? q_bits : -q_bits) > 0x1f) {
      int max_tem_level_err = 100;//位宽为24位，错误标志位置
  }
  int num_nz_coef = 0;
  int sum_all = 0;
  //u32 run;
  u32 prev_level;
  s32 ctx_qt_cbf;
  u32 best_last_idx_p1 = 0;
  s16 tmp_coef[32];
  s64 tmp_level_double[32];
  s16 tmp_dst_coef[32][32];
  const s64 lambda = (s64)(d_lambda * (double)(1 << SCALE_BITS) + 0.5);
  if (((lambda > 0) ? lambda : -lambda) > 0xffffff) {
      int max_tem_level_err = 100;//位宽为24位，错误标志位置
  }
  s64 err_scale = err_scale_tbl[qp][log2_size - 1];

#ifdef pan_revise
  if (((err_scale > 0) ? err_scale : -err_scale) > 0xfffffff) {
      int max_tem_level_err = 100;//位宽为28位，错误标志位置
  }
#endif

#ifdef tang_revise
  //s64 diff_scale = (s64)(err_scale * err_scale / lambda);
  double lambda_sqrt = sqrt(d_lambda * (double)(1 << SCALE_BITS) + 0.5);
  s64 diff_scale = (s64)(err_scale / lambda_sqrt);

#ifdef pan_revise
  if (((diff_scale > 0)? diff_scale : -diff_scale) > 0x1FFFF) {
      int max_tem_level_err = 100;//位宽为20位，错误标志位置
  }
#endif

#endif

  s64 d64_best_cost = 0;
  s64 d64_base_cost = 0;
  s64 d64_coded_cost = 0;
  s64 d64_uncoded_cost = 0;
  s64 d64_block_uncoded_cost = 0;
  //s64 err;
  int final_x = 0;
  int final_y = 0;
  u32 level_opt[32] = { 0 };
  s64 coded_cost_mat[32] = { 0 };
  s64 uncoded_cost_mat[32] = { 0 };
  s64 tempCost[32] = { 0 };  	    // the current scan line cumulative cost.
  s64 endPosCost[32] = { 0 };     // as the last position cost.

  u16 ace_log2 = 0;
  u32 scan_pos = 0;
  s64 d64_best_cost_tmp = 0;
  s64 final_rdoq_cost = 0;       // all scan line cumulative cost.
  s8 final_rdoq_last_x = -1;
  s8 final_rdoq_last_y = -1;

  s64 base_cost_buffer_tmp[32] = { 0 };
  u32 prev_level_mat[32] = { 0 };
  u16 run_mat[32] = { 0 };
  s64 d64_cost_last_one[32] = { 0 };
  s64 d64_cost_last_zero[32] = { 0 };

  s64 rdoqD64LastOne[32];      // shifter buffer the d64_cost_last_one_tmp.
  s64 rdoqD64LastZero[32];
  s8 rdoq_last_x[32];
  s8 rdoq_last_y[32];

  for (int i = 0; i < 32; i++) {
    rdoqD64LastOne[i] = 0;
    rdoqD64LastZero[i] = 0;
    rdoq_last_x[i] = -1;
    rdoq_last_y[i] = -1;
  }

  u32 left_pos[32] = { 0 };
  u32 bottom_pos[32] = { 0 };
  generate_left_col(width, height, cu_width_log2, cu_height_log2, left_pos, bottom_pos);


#ifdef pan_revise
      static int count = 0;
      if (cu_height_log2 == 4 && cu_width_log2 == 4 && ch_type == Y_C && is_intra == 1) {
          count++;
      }

    if (count == 1000) {
        FILE* src_out;
        src_out = fopen("E:\\github\\AVS3-RDOQ\\result\\origin_data\\src\\origin_data_16x16.txt", "w");
        for (int j = 0; j < width; ++j) {
            for (int i = 0; i < height; ++i) {
                fprintf(src_out, "%6d ", src_coef[i * height + j]);
            }
            fprintf(src_out, "\n");
        }
        fclose(src_out);
        int pause = 100;


        FILE* left_pos_out;
        left_pos_out = fopen("E:\\github\\AVS3-RDOQ\\result\\origin_data\\left_pos\\left_pos.txt", "w");
        for (int i = 0; i < height; ++i) {
            fprintf(left_pos_out, "%6d ", left_pos[i]);
        }
        fclose(left_pos_out);

        FILE* bottom_pos_out;
        bottom_pos_out = fopen("E:\\github\\AVS3-RDOQ\\result\\origin_data\\bottom_pos\\bottom_pos.txt", "w");
        for (int i = 0; i < width; ++i) {
            fprintf(bottom_pos_out, "%6d ", bottom_pos[i]);
        }
        fclose(bottom_pos_out);

        FILE* rdoq_est_run_out;
        rdoq_est_run_out = fopen("E:\\github\\AVS3-RDOQ\\result\\origin_data\\rdoq_est_run\\est_run_16x16.txt", "w");
        for (int i = 0; i < 24; ++i) {
            for (int j = 0; j < 2; ++j) {
                if (((rdoq_est_run[i][j] > 0) ? rdoq_est_run[i][j] : -rdoq_est_run[i][j]) > 0x1FFFF) {
                    int max_tem_level_err = 100;//位宽为20位，错误标志位置
                }
                fprintf(rdoq_est_run_out, "%6d ", rdoq_est_run[i][j]);
            }
            fprintf(rdoq_est_run_out, "\n");
        }
        fclose(rdoq_est_run_out);

        FILE* rdoq_est_level_out;
        rdoq_est_level_out = fopen("E:\\github\\AVS3-RDOQ\\result\\origin_data\\rdoq_est_level\\est_level_16x16.txt", "w");
        for (int i = 0; i < 24; ++i) {
            for (int j = 0; j < 2; ++j) {
                if (((rdoq_est_level[i][j] > 0) ? rdoq_est_level[i][j] : -rdoq_est_level[i][j]) > 0x1FFFF) {
                    int max_tem_level_err = 100;//位宽为20位，错误标志位置
                }
                fprintf(rdoq_est_level_out, "%6d ", rdoq_est_level[i][j]);
            }
            fprintf(rdoq_est_level_out, "\n");
        }
        fclose(rdoq_est_level_out);

        FILE* rdoq_est_last_out;
        rdoq_est_last_out = fopen("E:\\github\\AVS3-RDOQ\\result\\origin_data\\rdoq_est_last\\est_last_16x16.txt", "w");
        for (int i = 0; i < 2; ++i) {
            for (int j = 0; j < 6; ++j) {
                for (int k = 0; k < 12; ++k) {
                    for (int l = 0; l < 2; ++l) {
                        if (((rdoq_est_last[i][j][k][l] > 0) ? rdoq_est_last[i][j][k][l] : -rdoq_est_last[i][j][k][l]) > 0xFFFF) {
                            int max_tem_level_err = 100;//位宽为20位，错误标志位置
                        }
                        fprintf(rdoq_est_last_out, "%6d ", rdoq_est_last[i][j][k][l]);
                    }
                    fprintf(rdoq_est_last_out, "\n");
                }
            }
        }
        fclose(rdoq_est_last_out);

        FILE* rdoq_est_cbf_out;
        rdoq_est_cbf_out = fopen("E:\\github\\AVS3-RDOQ\\result\\origin_data\\rdoq_est_cbf\\est_cbf_16x16.txt", "w");
        for (int i = 0; i < 3; ++i) {
            for (int j = 0; j < 2; ++j) {
                fprintf(rdoq_est_cbf_out, "%6d ", rdoq_est_cbf[i][j]);
            }
            fprintf(rdoq_est_cbf_out, "\n");
        }
        fclose(rdoq_est_cbf_out);
    }



    s16 tmp_coef_tem[32][32];
    u32 prev_level_mat_tem[32][32] = { 0 };
    u16 run_mat_tem[32][32] = { 0 };
    u32 level_opt_tem[32][32] = { 0 };

    s64 coded_cost_mat_tem[32][32] = { 0 };
    s64 uncoded_cost_mat_tem[32][32] = { 0 };
    s64 d64_cost_last_zero_tem[32][32] = { 0 };
    s64 d64_cost_last_one_tem[32][32] = { 0 };

    s64 tempCost_tem[32][32] = { 0 };
    s64 rdoqD64LastOne_tem[32][32];      // shifter buffer the d64_cost_last_one_tmp.
    s64 rdoqD64LastZero_tem[32][32];
    s64 endPosCost_tem[32][32] = {0};     // as the last position cost.
    s8 rdoq_last_x_tem[32][32];
    s8 rdoq_last_y_tem[32][32];
    s64 base_cost_buffer[32][32] = {0};
#endif

    if (rdoq_est_ctp_zero_flag[0] != 31977) {
        int aaa = 100;//err triger
    }
    if (rdoq_est_ctp_zero_flag[1] != 32067) {
        int aaa = 100;//err triger
    }


  if (!is_intra && ch_type == Y_C){
#ifdef tang_revise
    d64_best_cost = d64_block_uncoded_cost + rdoq_est_ctp_zero_flag[1];
    d64_base_cost = d64_block_uncoded_cost + rdoq_est_ctp_zero_flag[0];
#else
    d64_best_cost = d64_block_uncoded_cost + GET_I_COST(rdoq_est_ctp_zero_flag[1], lambda);
    d64_base_cost = d64_block_uncoded_cost + GET_I_COST(rdoq_est_ctp_zero_flag[0], lambda);
#endif 
  }
  else{
    ctx_qt_cbf = ch_type;
#ifdef tang_revise    
    d64_best_cost = d64_block_uncoded_cost + rdoq_est_cbf[ctx_qt_cbf][0];
    d64_base_cost = d64_block_uncoded_cost + rdoq_est_cbf[ctx_qt_cbf][1];
#else
    d64_best_cost = d64_block_uncoded_cost + GET_I_COST(rdoq_est_cbf[ctx_qt_cbf][0], lambda);
    d64_base_cost = d64_block_uncoded_cost + GET_I_COST(rdoq_est_cbf[ctx_qt_cbf][1], lambda);
#endif 
  }

  d64_best_cost_tmp = d64_best_cost - d64_base_cost;


#ifdef pan_revise
  if (count == 1000) {
      int pause = 100;
  }
#endif

  for (int col = 0; col < width; col++) {

    /* =============== Pre-quantization =============== */
    for (int row = 0; row < height; row++) {
      s64 level_double = src_coef[row * stride + col];


      if (((level_double > 0) ? level_double : -level_double) > 0x7FFF) {
          int max_tem_level_err = 100;
      }

      u32 max_abs_level;
      s8 lower_int;
      s64 temp_level;
      temp_level = (s64)COM_ABS(src_coef[row * stride + col]) * (s64)q_value;

      if (((temp_level > 0) ? temp_level : -temp_level) > 0x1FFFFF) {
          int max_err = 100;
      }

      level_double = (int)COM_MIN(((s64)temp_level), (s64)(COM_INT32_MAX - (s64)(1 << (q_bits - 1))));

      if (((level_double > 0) ? level_double : -level_double) > 0x1FFFFF) {
          int max_tem_level_err = 100;//位宽为20位，错误标志位置
      }
      tmp_level_double[row] = level_double;
      max_abs_level = (u32)(level_double >> q_bits);
      lower_int = ((level_double - ((s64)max_abs_level << q_bits)) < (s64)(1 << (q_bits - 1))) ? 1 : 0;
      if (!lower_int) {
        max_abs_level++;
      }


      if (max_abs_level > 0xFF) {
          int max_err = 100;
      }

      tmp_coef[row] = src_coef[row * stride + col] > 0 ? (s16)max_abs_level : -(s16)(max_abs_level);

      if (((tmp_coef[row] > 0) ? tmp_coef[row] : -tmp_coef[row]) > 0xFF) {
          int max_tem_level_err = 100;
      }


#ifdef pan_revise
      if (count == 1000) {
          tmp_coef_tem[col][row] = tmp_coef[row];
      }
#endif
    }

    /* =========== Run and prev_Level init =========== */
    for (int row = 0; row < height; row++) {
      if ((row + col) & 1) {
        if (tmp_coef[row]) {
          prev_level_mat[row] = COM_ABS(tmp_coef[row]);  // current coef
        }
        else {
          prev_level_mat[row] = 1;
        }

        if (col == 0 || row == height - 1) {//第一列或者最后一行
          if (tmp_coef[row]) {
            run_mat[row] = 0;
          }
          else {
            run_mat[row] = 1;
          }
        }
        else {
          if (level_opt[row + 1]) {
            run_mat[row] = 0;
          }
          else {
            run_mat[row] += 1;
          }
        }
      }
      else {
        if (col == 0 || row == height - 1) {//第一列或者最后一行
          if (tmp_coef[row]) {
            prev_level_mat[row] = COM_ABS(tmp_coef[row]);
            run_mat[row] = 0;
          }
          else {
            prev_level_mat[row] = 1;
            run_mat[row] = 1;
          }
        }
        else {
          if (level_opt[row + 1]) {
            prev_level_mat[row] = level_opt[row + 1];
            run_mat[row] = 0;
          }
          else {
            prev_level_mat[row] = 1;
            run_mat[row] += 1;
          }
        }
      }

#ifdef pan_revise
      if (count == 1000) {
          prev_level_mat_tem[col][row] = prev_level_mat[row];
          run_mat_tem[col][row] = run_mat[row];
      }
#endif

    }

    /* ===================== OCD ===================== */
    for (int row = 0; row < height; row++) {
      u32 level;
      int ctx_run = ((COM_MIN(prev_level_mat[row] - 1, 5)) << 1) + (ch_type == Y_C ? 0 : 12);
      int ctx_level = ((COM_MIN(prev_level_mat[row] - 1, 5)) << 1) + (ch_type == Y_C ? 0 : 12);
#ifdef tang_revise
      level = get_coded_level_rl(&d64_uncoded_cost, &d64_coded_cost, tmp_level_double[row], COM_ABS(tmp_coef[row]),
        run_mat[row], (u16)ctx_run, (u16)ctx_level, q_bits, diff_scale, lambda, prev_level_mat[row], (row == height - 1 && col == width - 1) ? 1 : 0);
#else
      level = get_coded_level_rl(&d64_uncoded_cost, &d64_coded_cost, tmp_level_double[row], COM_ABS(tmp_coef[row]),
        run_mat[row], (u16)ctx_run, (u16)ctx_level, q_bits, err_scale, lambda, prev_level_mat[row], (row == height - 1 && col == width - 1) ? 1 : 0);
#endif // tang_revise
      tmp_dst_coef[row][col] = (s16)(tmp_coef[row] < 0 ? -(s32)(level) : level);

      uncoded_cost_mat[row] = d64_uncoded_cost;
      coded_cost_mat[row] = d64_coded_cost;
      level_opt[row] = level;


      if (((coded_cost_mat[row] > 0) ? coded_cost_mat[row] : -coded_cost_mat[row]) > 0xfffff) {
          int max_tem_level_err = 100;
      }


#ifdef pan_revise
      if (count == 1000) {
          uncoded_cost_mat_tem[col][row] = uncoded_cost_mat[row];
          coded_cost_mat_tem[col][row] = coded_cost_mat[row]; 
          level_opt_tem[col][row] = level_opt[row];
      }
#endif
    }

    /* ================ Cost assignment =============== */
    for (int row = 0; row < height; row++) {

      if (col == 0) {
        scan_pos = left_pos[row];
      }
      else if (row == height - 1) {
        left_pos[height - 1] = bottom_pos[col];
        scan_pos = bottom_pos[col];
      }
      else {
        if ((row + col) & 1) {
          left_pos[row]--;
          scan_pos = left_pos[row];
        }
        else {
          left_pos[row]++;
          scan_pos = left_pos[row];
        }
      }

      /* ------- test -------- */
      //int w = 1 << cu_width_log2;
      //int h = 1 << cu_height_log2;
      //u32 blk_pos = scan[scan_pos];
      //int a = row * w + col;
      //if (a != blk_pos) {
      //  int xx = 0;
      //}

      prev_level = prev_level_mat[row];
#ifdef tang_revise
      d64_cost_last_zero[row] = rdoq_est_last[ctx_last][COM_MIN(prev_level - 1, 5)][ace_get_log2(scan_pos + 1)][0];
      d64_cost_last_one[row] = rdoq_est_last[ctx_last][COM_MIN(prev_level - 1, 5)][ace_get_log2(scan_pos + 1)][1]; // block scan order.
#else
      d64_cost_last_zero[row] = rdoq_est_last[ctx_last][COM_MIN(prev_level - 1, 5)][ace_get_log2(scan_pos + 1)][0] * lambda;
      d64_cost_last_one[row] = rdoq_est_last[ctx_last][COM_MIN(prev_level - 1, 5)][ace_get_log2(scan_pos + 1)][1] * lambda; // block scan order.
#endif // tang_revise




#ifdef pan_revise
      //int  asd = ace_get_log2(2);
      //d64_cost_last_zero[row] = rdoq_est_last[ctx_last][COM_MIN(prev_level - 1, 5)][4][0];
      //d64_cost_last_one[row]  = rdoq_est_last[ctx_last][COM_MIN(prev_level - 1, 5)][4][1];
#endif
      if (level_opt[row])
        base_cost_buffer_tmp[row] = coded_cost_mat[row] - uncoded_cost_mat[row] + d64_cost_last_zero[row];
      else
        base_cost_buffer_tmp[row] = coded_cost_mat[row] - uncoded_cost_mat[row];


      if (((base_cost_buffer_tmp[row] > 0) ? base_cost_buffer_tmp[row] : -base_cost_buffer_tmp[row]) > 0x1ffffffff) {
          int max_tem_level_err = 100;
      }

#ifdef pan_revise
      if (count == 1000) {
          base_cost_buffer[col][row] = base_cost_buffer_tmp[row];
          d64_cost_last_zero_tem[col][row] = d64_cost_last_zero[row];
          d64_cost_last_one_tem[col][row] = d64_cost_last_one[row];
      }
#endif
    }



    /* ===================== LNPD ===================== */
    for (int row = 0; row < height; row++) {

      if (col == 0) {//第一列
        if (level_opt[row]) {           // non-zero level assignment
          rdoq_last_x[row] = row;
          rdoq_last_y[row] = col;
          rdoqD64LastOne[row] = d64_cost_last_one[row];
          rdoqD64LastZero[row] = d64_cost_last_zero[row];
        }
        else {
          rdoq_last_x[row] = -1;
          rdoq_last_y[row] = -1;
        }

        if ((row + col) & 1) { 		      // left->bottom scan for (row + col) & 1 is odd case
          endPosCost[row] = level_opt[row] == 0 ? base_cost_buffer_tmp[row] : 0;
        }
        else { 													// right->top scan for (row + col) & 1 is even case
          endPosCost[row] = level_opt[row] != 0 ? base_cost_buffer_tmp[row] : 0;
        }

        tempCost[row] = base_cost_buffer_tmp[row];
      }
      else if (row == height - 1) {//最后一行 is as same as 第一列
        if (level_opt[row]) {
          rdoq_last_x[row] = row;
          rdoq_last_y[row] = col;
          rdoqD64LastOne[row] = d64_cost_last_one[row];
          rdoqD64LastZero[row] = d64_cost_last_zero[row];
        }
        else {
          rdoq_last_x[row] = -1;
          rdoq_last_y[row] = -1;
        }
        if ((row + col) & 1) { 		      // left->bottom scan for (row + col) & 1 is odd case
          endPosCost[row] = level_opt[row] == 0 ? base_cost_buffer_tmp[row] : 0;
        }
        else { 													// right->top scan for (row + col) & 1 is even case
          endPosCost[row] = level_opt[row] != 0 ? base_cost_buffer_tmp[row] : 0;
        }
        tempCost[row] = base_cost_buffer_tmp[row];
      }
      else {
        if ((row + col) & 1) {         // left->bottom scan for (row + col) & 1 is even case
          if (level_opt[row] && rdoq_last_y[row] != -1) {       // the previous non-zero position
            if (tempCost[row] - endPosCost[row] + rdoqD64LastOne[row] - d64_cost_last_one[row] + d64_cost_last_zero[row] - rdoqD64LastZero[row] > 0) { // previous position is better
              rdoq_last_x[row] = row;
              rdoq_last_y[row] = col;
              rdoqD64LastOne[row] = d64_cost_last_one[row];
              rdoqD64LastZero[row] = d64_cost_last_zero[row];
              endPosCost[row] = tempCost[row];
            }
          }
          if (level_opt[row] && rdoq_last_y[row] == -1) { 	    // y = -1, first non-zero position
            rdoq_last_x[row] = row;
            rdoq_last_y[row] = col;
            rdoqD64LastOne[row] = d64_cost_last_one[row];
            rdoqD64LastZero[row] = d64_cost_last_zero[row];
            endPosCost[row] = tempCost[row];
          }
          tempCost[row] += base_cost_buffer_tmp[row]; 		    // from the start point to current pos cost.
          if (row == 0) {  									    // substract here is to get the actual endPosCost
            endPosCost[row] = tempCost[row] - endPosCost[row];  // get an optimal value on a scan line
          }
          // - d64_cost_last_zero[row], the zero cost of the optimal value itself is removed
        }
        else { 												    // right->top scan for (row + col) & 1 is odd case 

          if (level_opt[row] && rdoq_last_y[row] != -1) { 	    // compare for intialized case.
            if (tempCost[row] + base_cost_buffer_tmp[row] + d64_cost_last_one[row] - d64_cost_last_zero[row] < endPosCost[row] + rdoqD64LastOne[row] - rdoqD64LastZero[row]) {
              rdoq_last_x[row] = row;
              rdoq_last_y[row] = col;
              rdoqD64LastOne[row] = d64_cost_last_one[row];
              rdoqD64LastZero[row] = d64_cost_last_zero[row];
              endPosCost[row] = tempCost[row] + base_cost_buffer_tmp[row];
            }
          }
          if (level_opt[row] && rdoq_last_y[row] == -1) { 	    // cost initial again. purpose.
            rdoq_last_x[row] = row;
            rdoq_last_y[row] = col;
            rdoqD64LastOne[row] = d64_cost_last_one[row];
            rdoqD64LastZero[row] = d64_cost_last_zero[row];
            endPosCost[row] = tempCost[row] + base_cost_buffer_tmp[row];
          }

          tempCost[row] += base_cost_buffer_tmp[row];

        }
      }
#ifdef pan_revise
      if (count == 1000) {
        tempCost_tem[col][row] = tempCost[row];
        rdoqD64LastOne_tem[col][row]    = rdoqD64LastOne[row];
        rdoqD64LastZero_tem[col][row]   = rdoqD64LastZero[row];
        endPosCost_tem[col][row] = endPosCost[row];
        rdoq_last_x_tem[col][row] = rdoq_last_x[row];
        rdoq_last_y_tem[col][row] = rdoq_last_y[row];
      }
#endif
    }

    /* ---- optimal value in the top left ---- */
    s64 temp_RdoqCost = final_rdoq_cost + endPosCost[0] - rdoqD64LastZero[0];
    if ((rdoq_last_y[0] != -1) && (temp_RdoqCost + rdoqD64LastOne[0] < d64_best_cost_tmp)) {
      d64_best_cost_tmp = temp_RdoqCost + rdoqD64LastOne[0];
      final_rdoq_last_x = rdoq_last_x[0];
      final_rdoq_last_y = rdoq_last_y[0];
    }
    final_rdoq_cost += tempCost[0];

    /* shift register, aligned to the next line */
    for (int row = 1; row < height; row++) {
      rdoq_last_x[row - 1] = rdoq_last_x[row];
      rdoq_last_y[row - 1] = rdoq_last_y[row];
      rdoqD64LastOne[row - 1] = rdoqD64LastOne[row];
      rdoqD64LastZero[row - 1] = rdoqD64LastZero[row];
      endPosCost[row - 1] = endPosCost[row];
      tempCost[row - 1] = tempCost[row];
      run_mat[row - 1] = run_mat[row];
      left_pos[row - 1] = left_pos[row];
    }

  }

#ifdef pan_revise
  if (count == 1000) {

      FILE* rdoq_last_x_out;
      rdoq_last_x_out = fopen("E:\\github\\AVS3-RDOQ\\result\\lnpd\\hpm_rdoq_last_x\\hpm_rdoq_last_x_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(rdoq_last_x_out, "%6d ", rdoq_last_x_tem[j][i]);
          }
          fprintf(rdoq_last_x_out, "\n");
      }
      fclose(rdoq_last_x_out);

      FILE* rdoq_last_y_out;
      rdoq_last_y_out = fopen("E:\\github\\AVS3-RDOQ\\result\\lnpd\\hpm_rdoq_last_y\\hpm_rdoq_last_y_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(rdoq_last_y_out, "%6d ", rdoq_last_y_tem[j][i]);
          }
          fprintf(rdoq_last_y_out, "\n");
      }
      fclose(rdoq_last_y_out);

      FILE* endPosCost_out;
      endPosCost_out = fopen("E:\\github\\AVS3-RDOQ\\result\\lnpd\\hpm_endPosCost\\hpm_endPosCost_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(endPosCost_out, "%6lld ", endPosCost_tem[j][i]);
          }
          fprintf(endPosCost_out, "\n");
      }
      fclose(endPosCost_out);

      FILE* rdoqD64LastZero_out;
      rdoqD64LastZero_out = fopen("E:\\github\\AVS3-RDOQ\\result\\lnpd\\hpm_rdoqD64LastZero\\hpm_rdoqD64LastZero_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(rdoqD64LastZero_out, "%6lld ", rdoqD64LastZero_tem[j][i]);
          }
          fprintf(rdoqD64LastZero_out, "\n");
      }
      fclose(rdoqD64LastZero_out);

      FILE* rdoqD64LastOne_out;
      rdoqD64LastOne_out = fopen("E:\\github\\AVS3-RDOQ\\result\\lnpd\\hpm_rdoqD64LastOne\\hpm_rdoqD64LastOne_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(rdoqD64LastOne_out, "%6lld ", rdoqD64LastOne_tem[j][i]);
          }
          fprintf(rdoqD64LastOne_out, "\n");
      }
      fclose(rdoqD64LastOne_out);


      FILE* tempCost_tem_out;
      tempCost_tem_out = fopen("E:\\github\\AVS3-RDOQ\\result\\lnpd\\hpm_tempCost\\hpm_tempCost_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(tempCost_tem_out, "%6lld ", tempCost_tem[j][i]);
          }
          fprintf(tempCost_tem_out, "\n");
      }
      fclose(tempCost_tem_out);

      //FILE* last_zero_out;
      //last_zero_out = fopen("E:\\github\\AVS3-RDOQ\\result\\lnpd\\hpm_last_zero\\hpm_last_zero_16x16.txt", "w");
      //for (int j = 0; j < width; ++j) {
      //    for (int i = 0; i < height; ++i) {
      //        fprintf(last_zero_out, "%6lld ", d64_cost_last_zero_tem[j][i]);
      //    }
      //    fprintf(last_zero_out, "\n");
      //}
      //fclose(last_zero_out);

      //FILE* last_one_out;
      //last_one_out = fopen("E:\\github\\AVS3-RDOQ\\result\\lnpd\\hpm_last_one\\hpm_last_one_16x16.txt", "w");
      //for (int j = 0; j < width; ++j) {
      //    for (int i = 0; i < height; ++i) {
      //        fprintf(last_one_out, "%6lld ", d64_cost_last_one_tem[j][i]);
      //    }
      //    fprintf(last_one_out, "\n");
      //}
      //fclose(last_one_out);


      FILE* base_cost_buffer_out;
      base_cost_buffer_out = fopen("E:\\github\\AVS3-RDOQ\\result\\ocd\\hpm_base_cost_buffer\\hpm_base_cost_buffer_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(base_cost_buffer_out, "%6lld ", base_cost_buffer[j][i]);
          }
          fprintf(base_cost_buffer_out, "\n");
      }
      fclose(base_cost_buffer_out);
  }
#endif

#ifdef pan_revise
  if (count == 1000) {
      FILE* tmp_coef_out;
      tmp_coef_out = fopen("E:\\github\\AVS3-RDOQ\\result\\pq\\pq_hpm_coeff\\pq_hpm_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(tmp_coef_out, "%6d ", tmp_coef_tem[j][i]);
          }
          fprintf(tmp_coef_out, "\n");
      }
      fclose(tmp_coef_out);

      FILE* prev_level_out;
      prev_level_out = fopen("E:\\github\\AVS3-RDOQ\\result\\ocd\\hpm_prevel\\hpm_prevel_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(prev_level_out, "%6d ", prev_level_mat_tem[j][i]);
          }
          fprintf(prev_level_out, "\n");
      }
      fclose(prev_level_out);

      FILE* run_out;
      run_out = fopen("E:\\github\\AVS3-RDOQ\\result\\ocd\\hpm_run\\hpm_run_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(run_out, "%6d ", run_mat_tem[j][i]);
          }
          fprintf(run_out, "\n");
      }
      fclose(run_out);

      FILE* uncoded_cost_out;
      uncoded_cost_out = fopen("E:\\github\\AVS3-RDOQ\\result\\ocd\\hpm_uncoded_cost\\hpm_uncoded_cost_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(uncoded_cost_out, "%16lld ", uncoded_cost_mat_tem[j][i]);
          }
          fprintf(uncoded_cost_out, "\n");
      }
      fclose(uncoded_cost_out);


      FILE* coded_cost_out;
      coded_cost_out = fopen("E:\\github\\AVS3-RDOQ\\result\\ocd\\hpm_coded_cost\\hpm_coded_cost_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(coded_cost_out, "%16lld ", coded_cost_mat_tem[j][i]);
          }
          fprintf(coded_cost_out, "\n");
      }
      fclose(coded_cost_out);

      FILE* level_opt_out;
      level_opt_out = fopen("E:\\github\\AVS3-RDOQ\\result\\ocd\\hpm_level_opt\\hpm_level_opt_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(level_opt_out, "%6d ", level_opt_tem[j][i]);
          }
          fprintf(level_opt_out, "\n");
      }
      fclose(level_opt_out);

      FILE* tmp_dst_out;
      tmp_dst_out = fopen("E:\\github\\AVS3-RDOQ\\result\\ocd\\hpm_dst_coef\\hpm_dst_coef_16x16.txt", "w");
      for (int j = 0; j < width; ++j) {
          for (int i = 0; i < height; ++i) {
              fprintf(tmp_dst_out, "%6d ", tmp_dst_coef[i][j]);
          }
          fprintf(tmp_dst_out, "\n");
      }
      fclose(tmp_dst_out);

  }
#endif

#ifdef pan_revise
  if (count == 1000) {
      int pause = 100;
  }
#endif

  /* --- optimal value in the bottom right --- */
  for (int row = 0; row < height - 1; row++) {

      if (row & 1)
          endPosCost[row] = tempCost[row] - endPosCost[row];

  }

  for (int row = 0; row < height - 1; row++) {
    s64 temp_RdoqCost = final_rdoq_cost + endPosCost[row] - rdoqD64LastZero[row];

    if (rdoq_last_x[row] != -1 && temp_RdoqCost + rdoqD64LastOne[row] < d64_best_cost_tmp)
    {
      d64_best_cost_tmp = temp_RdoqCost + rdoqD64LastOne[row];
      final_rdoq_last_x = rdoq_last_x[row];
      final_rdoq_last_y = rdoq_last_y[row];
    }
    final_rdoq_cost += tempCost[row];

  }
  final_x = final_rdoq_last_x;
  final_y = final_rdoq_last_y;

#ifdef pan_revise
  if (count == 1000) {
      int pause = 100;
  }
#endif

  com_mset(dst_tmp, 0, sizeof(s16) * max_num_coef);

  /* ======= clean uncoded coeficients ======= */
  for (int col = 0; col < width; col++) {
    for (int row = 0; row < height; row++) {
      s16 dst_temp;
      s16 src_temp = tmp_dst_coef[row][col];
      if (row + col < final_x + final_y) {
        dst_temp = src_temp;
      }
      else if (row + col == final_x + final_y) {
        if ((final_x + final_y) & 1) {
          if (row > final_x && col < final_y) {
            dst_temp = 0;
          }
          else {
            dst_temp = src_temp;
          }
        }
        else {
          if (row < final_x && col > final_y) {
            dst_temp = 0;
          }
          else {
            dst_temp = src_temp;
          }
        }
      }
      else {
        dst_temp = 0;
      }
      dst_tmp[row * stride + col] = dst_temp;
      num_nz_coef += !!(dst_temp);
    }
  }
  //if (ch_type == 0) {
  //  FILE* fp_out;
  //  fp_out = fopen("coeff_out_para.txt", "a+");
  //  for (int i = 0; i < 1 << cu_height_log2; i++) {
  //    for (int j = 0; j < 1 << cu_width_log2; j++) {

  //      fprintf(fp_out, "%4d", dst_tmp[i * (1 << cu_width_log2) + j]);
  //    }
  //    fprintf(fp_out, "\n");
  //  }
  //  fprintf(fp_out, "\n");
  //  fclose(fp_out);
  //
  //}

  return num_nz_coef;
}

#endif




int enc_quant_nnz(ENC_CTX *ctx, int qp, double lambda, int is_intra, s16 * coef, int cu_width_log2, int cu_height_log2, int ch_type, int slice_type)
{
    int bit_depth = ctx->info.bit_depth_internal;
    int num_nz_coef = 0;
    int scale  = quant_scale[qp];
    int width = 1 << cu_width_log2;
    int height = 1 << cu_height_log2;

    if (width > 32)
    {
        int i, j;
        s16 *p = coef;
        for (i = 0; i < height; i++)
        {
            for (j = 32; j < width; j++)
            {
                p[j] = 0;
            }
            p += width;
        }
    }
    if (height > 32)
    {
        memset(coef + 32 * width, 0, sizeof(s16) * width * height - 32 * width);
    }

#if USE_RDOQ
    if(!ctx->info.pic_header.pic_wq_enable)
    {
        s64 lev;
        s64 offset;
        int i;
        int shift;
        int tr_shift;
        int log2_size = (cu_width_log2 + cu_height_log2) >> 1;
        int ns_shift = ((cu_width_log2 + cu_height_log2) & 1) ? 7 : 0;
        int ns_scale = ((cu_width_log2 + cu_height_log2) & 1) ? 181 : 1;
        s64 zero_coeff_threshold;
        BOOL is_coded = 0;

        tr_shift = get_transform_shift(bit_depth, log2_size - ns_shift);
        shift = QUANT_SHIFT + tr_shift;
#define FAST_RDOQ_INTRA_RND_OFST  201 //171
#define FAST_RDOQ_INTER_RND_OFST  153 //85
        offset = (s64)((slice_type == SLICE_I) ? FAST_RDOQ_INTRA_RND_OFST : FAST_RDOQ_INTER_RND_OFST) << (s64)(shift - 9);
        zero_coeff_threshold = ((s64)1 << (s64)shift) - offset;
        for(i = 0; i < (1 << (cu_width_log2 + cu_height_log2)); i++)
        {
            lev = (s64)COM_ABS(coef[i]) * (s64)scale * ns_scale;
            if(lev >= zero_coeff_threshold)
            {
                is_coded = 1;
                break;
            }
        }
        if(!is_coded)
        {
            memset(coef, 0, sizeof(coef[0])*((s64)1 << (cu_width_log2 + cu_height_log2)));
            return num_nz_coef;
        }

        if((cu_height_log2 > MAX_TR_LOG2) || (cu_width_log2 > MAX_TR_LOG2))
        {
            s16 t[MAX_TR_DIM];
            int m, n;
            int nnz_tmp = 0;
            int tu_width_log2 = (cu_width_log2 > MAX_TR_LOG2) ? MAX_TR_LOG2 : cu_width_log2;
            int tu_height_log2 = (cu_height_log2 > MAX_TR_LOG2) ? MAX_TR_LOG2 : cu_height_log2;
            int log_w_loop2 = (cu_width_log2 > MAX_TR_LOG2) ? (1 << (cu_width_log2 - MAX_TR_LOG2)) : 1;
            int log_h_loop2 = (cu_height_log2 > MAX_TR_LOG2) ? (1 << (cu_height_log2 - MAX_TR_LOG2)) : 1;
            int stride = (1 << cu_width_log2);
            int stride1 = (1 << tu_width_log2);
            for(n = 0; n < log_h_loop2; n++)
            {
                for(m = 0; m < log_w_loop2; m++)
                {
                    int l;
                    s16 * coef_temp = &coef[n * MAX_TR_SIZE * stride + m * MAX_TR_SIZE];
                    //copy to temp
                    for(l = 0; l < (1 << tu_height_log2); l++)
                    {
                        memcpy(&t[l*stride1], coef_temp, sizeof(s16)*stride1);
                        coef_temp += stride;
                    }
                    nnz_tmp = enc_rdoq_run_length_cc(qp, lambda, is_intra, t, t, tu_width_log2, tu_height_log2, ch_type, bit_depth);
                    num_nz_coef += nnz_tmp;
                    //copy backto coefbuf
                    coef_temp = &coef[n * MAX_TR_SIZE * stride + m * MAX_TR_SIZE];
                    for(l = 0; l < (1 << tu_height_log2); l++)
                    {
                        memcpy(coef_temp, &t[l*stride1], sizeof(s16)*stride1);
                        coef_temp += stride;
                    }
                }
            }
        }
        else
        {
            num_nz_coef = enc_rdoq_run_length_cc(qp, lambda, is_intra, coef, coef, cu_width_log2, cu_height_log2, ch_type, bit_depth);
        }
    }
    else
#endif
    {
        s64 offset;
        int i, j;
        int w = 1 << cu_width_log2;
        int h = 1 << cu_height_log2;
        int shift;
        int tr_shift;
        int log2_size = (cu_width_log2 + cu_height_log2) >> 1;
        int ns_shift = ((cu_width_log2 + cu_height_log2) & 1) ? 7 : 0;
        int ns_scale = ((cu_width_log2 + cu_height_log2) & 1) ? 181 : 1;
        int wq_width;
        int idx_shift;
        int idx_step;
        u8* wq;

        tr_shift = get_transform_shift(bit_depth, log2_size - ns_shift);
        shift = QUANT_SHIFT + tr_shift;
        offset = (s64)((slice_type == SLICE_I) ? 171 : 85) << (s64)(shift - 9);

        if (cu_width_log2 == 2 && cu_height_log2 == 2)
        {
            wq = ctx->wq[0];
            idx_shift = 0;
            idx_step = 1;
            wq_width = 4;
        }
        else
        {
            wq = ctx->wq[1];
            idx_shift = max(cu_width_log2, cu_height_log2) - 3;
            idx_step = 1 << idx_shift;
            wq_width = 8;
        }

        for (i = 0; i < h; i++)
        {
            for (j = 0; j < w; j++)
            {
                int weight = wq[j >> idx_shift];
                int sign = COM_SIGN_GET(coef[j]);
                int lev = (s16)(((s64)COM_ABS(coef[j]) * (s64)scale * ns_scale * 64 / weight + offset) >> shift);
                coef[j] = (s16)COM_SIGN_SET(lev, sign);
                num_nz_coef += !!(coef[j]);
            }
            coef += w;

            if ((i + 1) % idx_step == 0)
            {
                wq += wq_width;
            }
        }
    }
    return num_nz_coef;
}

#if TR_EARLY_TERMINATE
int est_pred_info_bits(ENC_CORE* core)
{
    COM_MODE* mod_cur = &core->mod_info_curr;
    int bits_residual = 2 + 4 + (mod_cur->num_nz[TB0][Y_C] == 0 ? 5 : 10);//(cbf u + cbf v) + (4 cbf_y) + (run + sign + level + last)
    int bits_pred = 0;
    if (mod_cur->cu_mode == MODE_DIR)
    {
        bits_pred = 6;
    }
    else if (mod_cur->cu_mode == MODE_INTER)
    {
        bits_pred = 10;
    }
    else
    {
        bits_pred = 2;
    }

    return bits_pred + bits_residual;
}
#endif

int enc_tq_nnz(ENC_CTX* ctx, COM_MODE *mode, int plane, int blk_idx, int qp, double lambda, s16 * coef, s16 *resi, int cu_width_log2, int cu_height_log2, int slice_type, int ch_type, int is_intra, int secT_Ver_Hor, int use_alt4x4Trans)
{
#if CHROMA_NOT_SPLIT
    assert(cu_width_log2 >= 2 && cu_height_log2 >= 2);
#endif
    int bit_depth = ctx->info.bit_depth_internal;
    enc_trans(mode, plane, blk_idx, coef, resi, cu_width_log2, cu_height_log2, is_intra, ch_type, bit_depth, secT_Ver_Hor, use_alt4x4Trans);
    return enc_quant_nnz(ctx, qp, lambda, is_intra, coef, cu_width_log2, cu_height_log2, ch_type, slice_type);
}

int enc_tq_yuv_nnz(ENC_CTX *ctx, ENC_CORE *core, COM_MODE *cur_mode, s16 coef[N_C][MAX_CU_DIM], s16 resi[N_C][MAX_CU_DIM],
                   int slice_type, int is_intra, int use_secTrans[MAX_NUM_TB], int use_alt4x4Trans, s8 refi[REFP_NUM], s16 mv[REFP_NUM][MV_D], u8 is_mv_from_mvf)
{
    int i;
    ENC_PINTER *pi = &ctx->pinter;
    COM_MODE *mod_info_curr = &core->mod_info_curr;
    int bit_depth = ctx->info.bit_depth_internal;
    int cu_width_log2 = mod_info_curr->cu_width_log2;
    int cu_height_log2 = mod_info_curr->cu_height_log2;
    cu_nz_cln(cur_mode->num_nz);

    // test 2Nx2N, loop luma and chroma
    cur_mode->tb_part = SIZE_2Nx2N;
    for (i = 2; i >= 0; i--)
    {
        int plane_width_log2 = cu_width_log2 - (i != Y_C);
        int plane_height_log2 = cu_height_log2 - (i != Y_C);
        int qp = (i == Y_C ? pi->qp_y : (i == U_C ? pi->qp_u : pi->qp_v));
        double lambda = (i == Y_C ? ctx->lambda[0] : (i == U_C ? ctx->lambda[1] : ctx->lambda[2]));
        int secT_VH = i == Y_C ? use_secTrans[TB0] : 0;
        int alt4x4 = i == Y_C ? use_alt4x4Trans : 0;

#if CHROMA_NOT_SPLIT
        //skip transform & quantization according to tree_status
        if (ctx->tree_status == TREE_L && i != Y_C)
        {
            cur_mode->num_nz[TB0][i] = 0;
            continue;
        }
        if (ctx->tree_status == TREE_C && i == Y_C)
        {
            cur_mode->num_nz[TB0][i] = 0;
            continue;
        }
#endif
#if TR_SAVE_LOAD
        if (core->best_tb_part_hist == 255 || core->best_tb_part_hist == SIZE_2Nx2N || i != Y_C)
        {
#endif
            cur_mode->num_nz[TB0][i] = enc_tq_nnz(ctx, cur_mode, i, 0, qp, lambda, coef[i], resi[i], plane_width_log2, plane_height_log2, slice_type, i, is_intra, secT_VH, alt4x4);
#if TR_SAVE_LOAD
        }
        else
        {
            cur_mode->num_nz[TB0][Y_C] = 0; //no need to try 2Nx2N transform
        }
#endif
    }

    int try_sub_block_transform = is_tb_avaliable(ctx->info, cu_width_log2, cu_height_log2, cur_mode->pb_part, is_intra ? MODE_INTRA : MODE_INTER);
    if (ctx->tree_status == TREE_C)
        try_sub_block_transform = 0;

    //fast algorithm
    if (try_sub_block_transform)
    {
#if TR_SAVE_LOAD
        if (core->best_tb_part_hist == SIZE_2Nx2N)
            try_sub_block_transform = 0;
#endif
#if TR_EARLY_TERMINATE
        if (try_sub_block_transform && core->best_tb_part_hist == 255)
        {
            COM_MODE* mod_curr = &core->mod_info_curr;
            int bits_est = est_pred_info_bits(core);
            double bits_cost = RATE_TO_COST_LAMBDA(ctx->lambda[Y_C], bits_est);
            s64    dist_cost = core->dist_pred_luma >> (cur_mode->num_nz[TB0][Y_C] == 0 ? 4 : 6);
            if (bits_cost + dist_cost > core->cost_best)
                try_sub_block_transform = 0;
        }
#endif
    }

    if (try_sub_block_transform)
    {
        s16 bak_2Nx2N_coef[MAX_CU_DIM], *cur_coef = coef[Y_C];
        int bak_2Nx2N_num_nz = cur_mode->num_nz[TB0][Y_C];
        int cu_size = 1 << (cu_width_log2 + cu_height_log2);
        int cu_width = 1 << cu_width_log2;
        int cu_height = 1 << cu_height_log2;
        int x = mod_info_curr->x_pos;
        int y = mod_info_curr->y_pos;
        pel *pred = cur_mode->pred[Y_C];
        pel *org = pi->Yuv_org[Y_C] + (y * pi->stride_org[Y_C]) + x;
        double cost_2Nx2N, cost_NxN;
        int part_num;
        int log2_tb_w, log2_tb_h, tb_size;
        int cu_w = 1 << cu_width_log2;
        int cu_h = 1 << cu_height_log2;
        PART_SIZE part_size = get_tb_part_size_by_pb(cur_mode->pb_part, is_intra? MODE_INTRA : MODE_INTER);

        if (bak_2Nx2N_num_nz)
        {
            memcpy(bak_2Nx2N_coef, cur_coef, sizeof(s16) *cu_size);
        }

        // check sub-TB
        cur_mode->tb_part = part_size;
        part_num = get_part_num(part_size);
        get_tb_width_height_log2(cu_width_log2, cu_height_log2, part_size, &log2_tb_w, &log2_tb_h);
        tb_size = 1 << (log2_tb_w + log2_tb_h);

        for (i = 0; i < part_num; i++)
        {
            s16 resi_buf[MAX_CU_DIM], *tb_resi = resi[Y_C];

            if (part_num > 1)
            {
                int k, pos_x, pos_y;
                int tu_w = 1 << log2_tb_w;
                int tu_h = 1 << log2_tb_h;
                s16 *s, *d;

                get_tb_start_pos(cu_w, cu_h, part_size, i, &pos_x, &pos_y);

                s = resi[Y_C] + pos_y * cu_w + pos_x;
                d = resi_buf;

                for (k = 0; k < tu_h; k++)
                {
                    memcpy(d, s, sizeof(s16) * tu_w);
                    d += tu_w;
                    s += cu_w;
                }
                tb_resi = resi_buf;
            }

            cur_mode->num_nz[i][Y_C] = enc_tq_nnz(ctx, cur_mode, Y_C, i, pi->qp_y, ctx->lambda[Y_C], coef[Y_C] + i * tb_size, tb_resi, log2_tb_w, log2_tb_h, slice_type, Y_C, is_intra, use_secTrans[i], use_alt4x4Trans);
        }

        if (bak_2Nx2N_num_nz && is_cu_plane_nz(cur_mode->num_nz, Y_C))
        {
            pel rec[MAX_CU_DIM];
            pel resi_it[MAX_CU_DIM];
            // cost for NxN
            int j, bit_cnt;
            s16 bak_NxN_coef[MAX_CU_DIM];
            int bak_NxN_num_nz[MAX_NUM_TB];

            memcpy(bak_NxN_coef, cur_coef, sizeof(s16) *cu_size);
            for (j = 0; j < MAX_NUM_TB; j++)
            {
                bak_NxN_num_nz[j] = cur_mode->num_nz[j][Y_C];
            }
            com_itdq_plane(cur_mode, Y_C, cur_coef, resi_it, ctx->wq, cu_width_log2, cu_height_log2, pi->qp_y, bit_depth, use_secTrans, use_alt4x4Trans);
            com_recon(cur_mode->tb_part, resi_it, pred, cur_mode->num_nz, Y_C, cu_width, cu_height, cu_width, rec, bit_depth);
            cost_NxN = (double)(enc_ssd_16b(cu_width_log2, cu_height_log2, rec, org, cu_width, pi->stride_org[Y_C], bit_depth));

            SBAC_LOAD(core->s_temp_run, core->s_curr_best[cu_width_log2 - 2][cu_height_log2 - 2]);
            bit_cnt = enc_get_bit_number(&core->s_temp_run);

            enc_bit_est_inter_comp(ctx, core, cur_coef, Y_C);
            bit_cnt = enc_get_bit_number(&core->s_temp_run) - bit_cnt;
            cost_NxN += RATE_TO_COST_LAMBDA(ctx->lambda[Y_C], bit_cnt);

            //////////////////////////////////////////////////////////////////////////////////////////

            memcpy(cur_coef, bak_2Nx2N_coef, sizeof(s16) *cu_size);
            cu_plane_nz_cln(cur_mode->num_nz, Y_C);
            cur_mode->num_nz[TB0][Y_C] = bak_2Nx2N_num_nz;
            cur_mode->tb_part = SIZE_2Nx2N;

            com_itdq_plane(cur_mode, Y_C, cur_coef, resi_it, ctx->wq, cu_width_log2, cu_height_log2, pi->qp_y, bit_depth, use_secTrans, use_alt4x4Trans);
            com_recon(cur_mode->tb_part, resi_it, pred, cur_mode->num_nz, Y_C, cu_width, cu_height, cu_width, rec, bit_depth);
            cost_2Nx2N = (double)(enc_ssd_16b(cu_width_log2, cu_height_log2, rec, org, cu_width, pi->stride_org[Y_C], bit_depth));

            SBAC_LOAD(core->s_temp_run, core->s_curr_best[cu_width_log2 - 2][cu_height_log2 - 2]);
            bit_cnt = enc_get_bit_number(&core->s_temp_run);

            enc_bit_est_inter_comp(ctx, core, cur_coef, Y_C);
            bit_cnt = enc_get_bit_number(&core->s_temp_run) - bit_cnt;
            cost_2Nx2N += RATE_TO_COST_LAMBDA(ctx->lambda[Y_C], bit_cnt);

            if (cost_NxN < cost_2Nx2N)
            {
                memcpy(cur_coef, bak_NxN_coef, sizeof(s16) *cu_size);
                for (j = 0; j < MAX_NUM_TB; j++)
                {
                    cur_mode->num_nz[j][Y_C] = bak_NxN_num_nz[j];
                }
                cur_mode->tb_part = get_tb_part_size_by_pb(cur_mode->pb_part, is_intra ? MODE_INTRA : MODE_INTER);
            }
        }
        else if (bak_2Nx2N_num_nz)
        {
            memcpy(cur_coef, bak_2Nx2N_coef, sizeof(s16) *cu_size);
            cu_plane_nz_cln(cur_mode->num_nz, Y_C);
            cur_mode->num_nz[TB0][Y_C] = bak_2Nx2N_num_nz;
            cur_mode->tb_part = SIZE_2Nx2N;
        }
    }

    check_set_tb_part(cur_mode);

    return is_cu_nz(cur_mode->num_nz);
}

