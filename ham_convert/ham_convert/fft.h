#ifndef __FFT_H
#define __FFT_H

typedef struct COMPLEX
{
	float real;
	float imag;
};
class FFT
{
public:
	FFT();
	virtual ~FFT();

	int FFT2D(COMPLEX *c, int nx, int ny, int dir);
private:
	int doFFT(int dir, int m, float *x, float *y);
	int FFT::Powerof2(int n, int *m, int *twopm);

};
#endif
