#include "defines.h"

int matrix[] = {
	0b0000000000000000,
	0b0000000000001000,
	0b0000000000101000,
	0b0000000100101000,
	0b0100000100101000,
	0b0110000100101000,
	0b0110100100101000,
	0b0110100101101000,
	0b0110100101101001,
	0b0110110101101001,
	0b0111110101101001,
	0b0111110101101011,
	0b0111110111101011,
	0b0111110111111011,
	0b0111110111111111,
	0b1111110111111111,
	0b1111111111111111,
};
/**/
/*int matrix[] = {
0b0000000000000000,
0b0000000000000001,
0b0000010000000001,
0b0000010000000101,
0b0000010100000101,
0b0000010100100101,
0b1000010100100101,
0b1000010110100101,
0b1010010110100101,
0b1010010110100111,
0b1010110110100111,
0b1010110110101111,
0b1010111110101111,
0b1010111110111111,
0b1110111110111111,
0b1111111110111111,
0b1111111111111111,
};
/**/
/*int matrix[] = {
0b0000000000000000,
0b0000000000100000,
0b1000000000100000,
0b1000000001100000,
0b1001000001100000,
0b1001000001100010,
0b1001100001100010,
0b1001100001100110,
0b1001100101100110,
0b1001101101100110,
0b1001101101101110,
0b1001111101101110,
0b1001111101101111,
0b1001111101111111,
0b1101111101111111,
0b1101111111111111,
0b1111111111111111,
};
/**/
float yuv_matrix[3][3] = {
	{ 0.299		,0.587		,0.114 },
	{ -0.14713	,-0.28886	,0.436 },
	{ 0.615		,-0.51499	,-0.10001 }
};
float yuv_imatrix[3][3] = {
	{ 1		,0			,1.13983 },
	{ 1		,-0.39465	,-0.58060 },
	{ 1		,2.03211	,0 }
};