#ifndef __DEFINES_H
#define __DEFINES_H
#include <iostream>
#include <string.h>
#include "yuv_buffer.h"

#define BLOCK_SIZE 16
#define BLOCK_SIZE_SQ (BLOCK_SIZE * BLOCK_SIZE)

//#define MYDEBUG
#define PLANES 8
#define Width  320
#define Height  192
//#define FFT_CALC
//#define DCT_CALC
#define THREADS 8
#define CT_DIM_BIT 5
#define CT_DIM (1 << CT_DIM_BIT)

typedef struct RGB
{
	unsigned char r, g, b, a;
};

typedef struct LUM
{
	float value;
	int x, y;
	unsigned int index;
	int r, g, b;
	unsigned int sortIdx;
};

extern int matrix[];
extern float yuv_matrix[3][3];
extern float yuv_imatrix[3][3];

#endif

