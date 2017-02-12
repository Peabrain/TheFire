#ifndef __DCT_H
#define __DCT_H

class DCT
{
public:
	DCT();
	DCT(int dimX,int dimY, float *data);
	virtual ~DCT();

	void dct(float **DCTMatrix, float **Matrix, int N, int M);
	void write_mat(FILE *fp, float **testRes, int N, int M);
	void idct(float **Matrix, float **DCTMatrix, int N, int M);
	float **calloc_mat(int dimX, int dimY);
	void free_mat(float **p);

	int dimX, dimY;
	float **testBlock;
	float **testDCT;
	float **testiDCT;
	float *cosTab;
};

#endif
