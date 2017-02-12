#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "dct.h"

#define M_PI 3.1415926535897932384626433832795
DCT::DCT()
{
	testBlock = 0;
	testDCT = 0;
	testiDCT = 0;
	cosTab = 0;
}
DCT::~DCT()
{
	if(testBlock) free_mat(testBlock);
	if(testDCT) free_mat(testDCT);
	if(testiDCT) free_mat(testiDCT);
	if (cosTab) free(cosTab);
}

DCT::DCT(int dimX, int dimY,float *data)
{
	this->dimX = dimX;
	this->dimY = dimY;
	testBlock = calloc_mat(dimX, dimY);
	testDCT = calloc_mat(dimX, dimY);
	testiDCT = calloc_mat(dimX, dimY);
	cosTab = (float*)malloc(sizeof(float) * dimX);

	for (int u = 0; u < dimY; ++u) 
	{
		cosTab[u] = cos(M_PI / ((float)dimX)*((float)u + 1. / 2.));
	}


	for (int i = 0; i<dimX; i++) {
		for (int j = 0; j<dimY; j++) {
			testBlock[i][j] = data[j * dimX + i];
		}
	}

	dct(testDCT, testBlock, dimX, dimY);
	for (int i = 0; i < dimY / 2; i++)
	{
		for (int j = 0; j < dimX / 2; j++)
		{
			testDCT[i + 4][j] = 0;
			testDCT[i + 4][j + 4] = 0;
			testDCT[i][j + 4] = 0;
		}
	}
/**/
	idct(testiDCT, testDCT, dimX, dimY);

	for (int i = 0; i<dimX; i++) {
		for (int j = 0; j<dimY; j++) {
			data[j * dimX + i] = testBlock[i][j];
		}
	}
}



float **DCT::calloc_mat(int dimX, int dimY) {
	float **m = (float **)calloc(dimX, sizeof(float*));
	float *p = (float *)calloc(dimX*dimY, sizeof(float));
	int i;
	for (i = 0; i <dimX; i++) {
		m[i] = &p[i*dimY];

	}
	return m;
}

void DCT::free_mat(float **m) {
	free(m[0]);
	free(m);
}

void DCT::write_mat(FILE *fp, float **m, int N, int M) {

	int i, j;
	for (i = 0; i< N; i++) {
		fprintf(fp, "%f", m[i][0]);
		for (j = 1; j < M; j++) {
			fprintf(fp, "\t%f", m[i][j]);
		}
		fprintf(fp, "\n");
	}
	fprintf(fp, "\n");
}

void DCT::dct(float **DCTMatrix, float **Matrix, int N, int M) {

	int i, j, u, v;
	for (u = 0; u < N; ++u) {
		for (v = 0; v < M; ++v) {
			DCTMatrix[u][v] = 0;
			for (i = 0; i < N; i++) {
				for (j = 0; j < M; j++) {
					DCTMatrix[u][v] += Matrix[i][j] * cosTab[(i * u) % dimX] * cosTab[(j * v) % dimX];
				}
			}
		}
	}
}

void DCT::idct(float **Matrix, float **DCTMatrix, int N, int M) {
	int i, j, u, v;

	for (u = 0; u < N; ++u) {
		for (v = 0; v < M; ++v) {
			Matrix[u][v] = 1 / 4.*DCTMatrix[0][0];
			for (i = 1; i < N; i++) {
				Matrix[u][v] += 1 / 2.*DCTMatrix[i][0];
			}
			for (j = 1; j < M; j++) {
				Matrix[u][v] += 1 / 2.*DCTMatrix[0][j];
			}

			for (i = 1; i < N; i++) {
				for (j = 1; j < M; j++) {
					DCTMatrix[u][v] += Matrix[i][j] * cosTab[(i * u) % dimX] * cosTab[(j * v) % dimX];
				}
			}
			Matrix[u][v] *= 2. / ((float)N)*2. / ((float)M);
		}
	}
}
