//
//  main.cpp
//  ham_convert
//
//  Created by PeabrainC64 on 26.01.17.
//  Copyright © 2017 PeabrainC64. All rights reserved.
//

#include <iostream>
#include <string.h>
#include <thread>
#include <list>
#include "dct.h"
#include "fft.h"
#include "frame.h"
#include "defines.h"

//#define CHEAP
#define HAM8
//#define HIRES
#ifdef HAM8
#define PLANES 8
#else
#define PLANES 6
#endif
#ifdef HIRES
#define Width  704
#else
#define Width  320
#endif
#define Height  192
#define DITHER
//#define FFT_CALC
//#define DCT_CALC
#define THREADS 8
#define CT_DIM_BIT 3
#define CT_DIM (1 << CT_DIM_BIT)

typedef struct STATS
{
	int rendered_pattern;
	int copied_pattern;
};
STATS stats;

void convertSequence(const char *path,int i);
void convertSequence(const char *path, int start, int Len, int zz);
void processCompress(unsigned char *mem, unsigned char *ham, int w, int h);
void doDCT(unsigned char*mem, int w, int h);
void doFFT(unsigned char*mem);

int main(int argc, const char * argv[])
{
	stats.copied_pattern = 0;
	stats.rendered_pattern = 0;
//    convertSequence("ghost",0,3440,2);
//    convertSequence("nvidia",0,4260,2);
//	convertSequence("darksouls3",0,3392,2);
//    convertSequence("ray",3862,2);
//	convertSequence("cocoon", 0,11161, 1);
//	convertSequence("cocoon", 0,2000, 2);
	//	convertSequence("cocoon", 6000, 3);
	//    convertSequence("test",1,2);
	convertSequence("sc", 7905, 100, 1);
	//	convertSequence("cocoon_hd", 0, 11161, 1);
//	convertSequence("ghost_hd", 0, 3235, 1);
//	convertSequence("nvidia_hd", 0, 4260, 1);
//	convertSequence("cataclysm_hd", 0, 3660, 1);
//	convertSequence("hots_hd", 0, 2959, 1);
//	convertSequence("sc_hd", 5000, 1, 2);
//	convertSequence(argv[1], atoi(argv[2]));

//	DCT dct;
//	dct.main();

	printf("Stats:\n");
	printf("Rendered Pattern: %i\n", stats.rendered_pattern);
	printf("Copied Pattern: %i\n", stats.copied_pattern);
	return 0;
}
void convertSequence(const char *path,int i)
{
	convertSequence(path, 0,-1, i);
}
void convertSequence(const char *path,int start,int Len,int zz)
{
#define CACHES 4
	unsigned char CacheBuffer[Width / 8 * Height * PLANES * CACHES];
	int CacheIdx = 0;
	int len = start + Len;
	bool running = true;
    char filename2[256];

	memset(CacheBuffer, 0, Width / 8 * Height * PLANES * CACHES);
    sprintf(filename2,"../asm/%s.tmp",path);
    if(FILE *f2 = fopen(filename2,"w+b"))
    {
        fclose(f2);
    }
	if(FILE *f2 = fopen(filename2,"a+b"))
    {
        int count = start,count2 = 0,j = 0;
//        std::thread *t1[THREADS];
        while(running)
        {
			if (Len == -1 || count < len)
			{
				std::string filename;
				std::string filename2;
				char tm[256];
				sprintf(tm, "../../data/%s/%4.4i.bmp", path, count);
				filename.append(tm);
				sprintf(tm, "../asm/%s/%4.4i.bmp.tmp", path, count2++);
				filename2.append(tm);
				FRAME *frame = new FRAME(filename,filename2);
				if (frame->successful())
				{
					fwrite(frame->getMem(), Width / 8 * Height * PLANES, 1, f2);
//					stats.copied_pattern += data.stats;
//					stats.rendered_pattern += Width / CT_DIM * Height / CT_DIM;
					printf("Converting %s\n", filename.c_str());
					count += zz;
				}
				else running = false;
				delete frame;
			}
			else
				break;
        }
        fclose(f2);
    }
}
void processCompress(unsigned char *mem, unsigned char *ham, int w, int h)
{
	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			int b = (int)((unsigned int)mem[x * 3 + (h - 1 - y) * 3 * w]);
			int g = (int)((unsigned int)mem[x * 3 + (h - 1 - y) * 3 * w + 1]);
			int r = (int)((unsigned int)mem[x * 3 + (h - 1 - y) * 3 * w + 2]);
			int value = (0.299 * (float)r + 0.587 * (float)g + 0.114 * (float)b);
			ham[y * w + x] = value >> 2;
		}
	}
}
void doDCT(unsigned char*mem,int w,int h)
{
#ifdef DCT_CALC
	float *y_ = (float*)malloc(sizeof(float) * CT_DIM * CT_DIM);
	float *u_ = (float*)malloc(sizeof(float) * CT_DIM * CT_DIM);
	float *v_ = (float*)malloc(sizeof(float) * CT_DIM * CT_DIM);
	for (int y = 0; y < h; y += CT_DIM)
	{
		for (int x = 0; x < w; x += CT_DIM)
		{
			for (int yy = 0; yy < CT_DIM; yy++)
			{
				for (int xx = 0; xx < CT_DIM; xx++)
				{
					float b = (float)((unsigned int)mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w]) / 256.0;
					float g = (float)((unsigned int)mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w + 1]) / 256.0;
					float r = (float)((unsigned int)mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w + 2]) / 256.0;
					y_[yy * CT_DIM + xx] = yuv_matrix[0][0] * (float)r + yuv_matrix[0][1] * (float)g + yuv_matrix[0][2] * (float)b;
					u_[yy * CT_DIM + xx] = yuv_matrix[1][0] * (float)r + yuv_matrix[1][1] * (float)g + yuv_matrix[1][2] * (float)b;
					v_[yy * CT_DIM + xx] = yuv_matrix[2][0] * (float)r + yuv_matrix[2][1] * (float)g + yuv_matrix[2][2] * (float)b;
				}
			}
			DCT *dct_y = new DCT(CT_DIM, CT_DIM, y_);
			DCT *dct_u = new DCT(CT_DIM, CT_DIM, u_);
			DCT *dct_v = new DCT(CT_DIM, CT_DIM, v_);

			for (int yy = 0; yy < CT_DIM; yy++)
			{
				for (int xx = 0; xx < CT_DIM; xx++)
				{
					float r = yuv_imatrix[0][0] * y_[yy * CT_DIM + xx] + yuv_imatrix[0][1] * u_[yy * CT_DIM + xx] + yuv_imatrix[0][2] * v_[yy * CT_DIM + xx];
					float g = yuv_imatrix[1][0] * y_[yy * CT_DIM + xx] + yuv_imatrix[1][1] * u_[yy * CT_DIM + xx] + yuv_imatrix[1][2] * v_[yy * CT_DIM + xx];
					float b = yuv_imatrix[2][0] * y_[yy * CT_DIM + xx] + yuv_imatrix[2][1] * u_[yy * CT_DIM + xx] + yuv_imatrix[2][2] * v_[yy * CT_DIM + xx];
					if (r < 0) r = 0;
					if (g < 0) g = 0;
					if (b < 0) b = 0;
					if (r > 1.0) r = 1.0;
					if (g > 1.0) g = 1.0;
					if (b > 1.0) b = 1.0;
					mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w] = b * 255.0;
					mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w + 1] = g * 255.0;
					mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w + 2] = r * 255.0;
				}
			}

			delete dct_y;
			delete dct_u;
			delete dct_v;
		}
	}
	free(y_);
	free(u_);
	free(v_);
#endif
}
void doFFT(unsigned char*mem)
{
#ifdef FFT_CALC
	typedef struct AVE
	{
		float y;
		float u;
		float v;
	};
	typedef struct YUV
	{
		COMPLEX *y_;
		COMPLEX *u_;
		COMPLEX *v_;
		AVE average;
		int x, y;
		std::list<int> *equal;
	};
	YUV *yuv = (YUV*)malloc(sizeof(YUV) * Width / CT_DIM * Height / CT_DIM);
	memset(yuv, 0, sizeof(YUV) * Width / CT_DIM * Height / CT_DIM);
	FFT fft;
	for (int y = 0; y < h; y += CT_DIM)
	{
		for (int x = 0; x < w; x += CT_DIM)
		{
			int index = y / CT_DIM * Width / CT_DIM + x / CT_DIM;
			yuv[index].equal = new std::list<int>();
			yuv[index].y_ = (COMPLEX*)malloc(sizeof(COMPLEX) * CT_DIM * CT_DIM);
			yuv[index].u_ = (COMPLEX*)malloc(sizeof(COMPLEX) * CT_DIM * CT_DIM);
			yuv[index].v_ = (COMPLEX*)malloc(sizeof(COMPLEX) * CT_DIM * CT_DIM);

			COMPLEX *y_ = yuv[index].y_;
			COMPLEX *u_ = yuv[index].u_;
			COMPLEX *v_ = yuv[index].v_;

			yuv[index].average.y = 0.0;
			yuv[index].average.u = 0.0;
			yuv[index].average.v = 0.0;

			yuv[index].x = x / CT_DIM;
			yuv[index].y = y / CT_DIM;

			for (int yy = 0; yy < CT_DIM; yy++)
			{
				for (int xx = 0; xx < CT_DIM; xx++)
				{
					float b = (float)((unsigned int)mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w]) / 256.0;
					float g = (float)((unsigned int)mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w + 1]) / 256.0;
					float r = (float)((unsigned int)mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w + 2]) / 256.0;
					y_[yy * CT_DIM + xx].real = yuv_matrix[0][0] * (float)r + yuv_matrix[0][1] * (float)g + yuv_matrix[0][2] * (float)b;
					u_[yy * CT_DIM + xx].real = yuv_matrix[1][0] * (float)r + yuv_matrix[1][1] * (float)g + yuv_matrix[1][2] * (float)b;
					v_[yy * CT_DIM + xx].real = yuv_matrix[2][0] * (float)r + yuv_matrix[2][1] * (float)g + yuv_matrix[2][2] * (float)b;
					y_[yy * CT_DIM + xx].imag = 0;
					u_[yy * CT_DIM + xx].imag = 0;
					v_[yy * CT_DIM + xx].imag = 0;
					yuv[index].average.y += y_[yy * CT_DIM + xx].real;
					yuv[index].average.u += u_[yy * CT_DIM + xx].real;
					yuv[index].average.v += v_[yy * CT_DIM + xx].real;
				}
			}
			fft.FFT2D(y_, CT_DIM, CT_DIM, 1);
			fft.FFT2D(u_, CT_DIM, CT_DIM, 1);
			fft.FFT2D(v_, CT_DIM, CT_DIM, 1);

			/*			fft.FFT2D(y_, CT_DIM, CT_DIM, -1);
			fft.FFT2D(u_, CT_DIM, CT_DIM, -1);
			fft.FFT2D(v_, CT_DIM, CT_DIM, -1);

			for (int yy = 0; yy < CT_DIM; yy++)
			{
			for (int xx = 0; xx < CT_DIM; xx++)
			{
			float r = yuv_imatrix[0][0] * y_[yy * CT_DIM + xx].real + yuv_imatrix[0][1] * u_[yy * CT_DIM + xx].real + yuv_imatrix[0][2] * v_[yy * CT_DIM + xx].real;
			float g = yuv_imatrix[1][0] * y_[yy * CT_DIM + xx].real + yuv_imatrix[1][1] * u_[yy * CT_DIM + xx].real + yuv_imatrix[1][2] * v_[yy * CT_DIM + xx].real;
			float b = yuv_imatrix[2][0] * y_[yy * CT_DIM + xx].real + yuv_imatrix[2][1] * u_[yy * CT_DIM + xx].real + yuv_imatrix[2][2] * v_[yy * CT_DIM + xx].real;
			if (r < 0) r = 0;
			if (g < 0) g = 0;
			if (b < 0) b = 0;
			if (r > 1.0) r = 1.0;
			if (g > 1.0) g = 1.0;
			if (b > 1.0) b = 1.0;
			mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w] = b * 255.0;
			mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w + 1] = g * 255.0;
			mem[(x + xx) * 3 + (Height - 1 - (y + yy)) * 3 * w + 2] = r * 255.0;
			}
			}
			*/
		}
	}
	for (int i = 0; i < Width / CT_DIM * Height / CT_DIM; i++)
	{
		yuv[i].average.y /= CT_DIM * CT_DIM;
		yuv[i].average.u /= CT_DIM * CT_DIM;
		yuv[i].average.v /= CT_DIM * CT_DIM;
	}


	/*	for (int i = 0; i < Width / CT_DIM * Height / CT_DIM - 1; i++)
	{
	for (int j = i + 1; j < Width / CT_DIM * Height / CT_DIM; j++)
	{
	if (yuv[j].v_average < yuv[i].v_average)
	{
	YUV l = yuv[j];
	yuv[j] = yuv[i];
	yuv[i] = l;
	}
	}
	}
	for (int i = 0; i < Width / CT_DIM * Height / CT_DIM - 1; i++)
	{
	for (int j = i + 1; j < Width / CT_DIM * Height / CT_DIM; j++)
	{
	if (yuv[j].u_average < yuv[i].u_average)
	{
	YUV l = yuv[j];
	yuv[j] = yuv[i];
	yuv[i] = l;
	}
	}
	}
	for (int i = 0; i < Width / CT_DIM * Height / CT_DIM - 1; i++)
	{
	for (int j = i + 1; j < Width / CT_DIM * Height / CT_DIM; j++)
	{
	if (yuv[j].y_average < yuv[i].y_average)
	{
	YUV l = yuv[j];
	yuv[j] = yuv[i];
	yuv[i] = l;
	}
	}
	}
	Data->stats = 0;
	for (int i = 1,last = 0; i < Width / CT_DIM * Height / CT_DIM - 1; i++)
	{
	bool found = false;
	for (int j = last; j < i && found == false; j++)
	{
	if (fabs(yuv[i].y_average - yuv[j].y_average) <= 0.0 &&
	fabs(yuv[i].u_average - yuv[j].u_average) <= 0.0 &&
	fabs(yuv[i].v_average - yuv[j].v_average) <= 0.0)
	{
	float dif = 0;
	for (int y = 0; y < CT_DIM; y++)
	{
	for (int x = 0; x < CT_DIM; x++)
	{
	float y_dif = yuv[i].y_[y * CT_DIM + x].real - yuv[j].y_[y * CT_DIM + x].real;
	float u_dif = yuv[i].u_[y * CT_DIM + x].real - yuv[j].u_[y * CT_DIM + x].real;
	float v_dif = yuv[i].v_[y * CT_DIM + x].real - yuv[j].v_[y * CT_DIM + x].real;
	dif += sqrt(y_dif * y_dif + v_dif * v_dif + u_dif * u_dif);
	}
	}
	dif /= CT_DIM * CT_DIM;
	if (dif == 0)
	{
	found = true;
	Data->stats++;
	copyBuffer[yuv[i].y * Width / CT_DIM + yuv[i].x].pre_index = yuv[i].y * CT_DIM * Width / 8 + yuv[i].x + 1;
	}
	}
	}
	if (found == false)
	{
	last = i;
	copyBuffer[yuv[last].y * Width / CT_DIM + yuv[last].x].pre_index = yuv[last].y * CT_DIM * Width / 8 + yuv[last].x + 1;
	}
	}
	/**/

#define THRESHOLD 0.001
#define THRESHOLD1 0.01
	for (int i = Width / CT_DIM * Height / CT_DIM - 1; i >= 1; i--)
	{
		int found = -1;
		int found_min = 100000000.0;
		if (yuv[i].x != 0)
		{
			for (int j = i - 1; j >= 0; j--)
			{
				if ((fabs(yuv[i].average.y - yuv[j].average.y) <= THRESHOLD) &&
					(fabs(yuv[i].average.u - yuv[j].average.u) <= THRESHOLD) &&
					(fabs(yuv[i].average.v - yuv[j].average.v) <= THRESHOLD))
				{
					float dif = 0;
					float y_dif = 0;
					float u_dif = 0;
					float v_dif = 0;
					dif += sqrt(y_dif * y_dif + v_dif * v_dif + u_dif * u_dif);
					bool break_ = false;
					for (int y = 0; y < CT_DIM && break_ == false; y++)
					{
						for (int x = 0; x < CT_DIM && break_ == false; x++)
						{
							float y_dif_ = fabs(yuv[i].y_[y * CT_DIM + x].real - yuv[j].y_[y * CT_DIM + x].real);
							float u_dif_ = fabs(yuv[i].u_[y * CT_DIM + x].real - yuv[j].u_[y * CT_DIM + x].real);
							float v_dif_ = fabs(yuv[i].v_[y * CT_DIM + x].real - yuv[j].v_[y * CT_DIM + x].real);
							if (y_dif >= THRESHOLD1 || u_dif >= THRESHOLD1 || v_dif >= THRESHOLD1)
								break_ = true;
							else
							{
								y_dif += y_dif_;
								u_dif += u_dif_;
								v_dif += v_dif_;
							}
						}
					}
					if (!break_)
					{
						dif = sqrt(y_dif * y_dif + v_dif * v_dif + u_dif * u_dif);
						dif /= CT_DIM * CT_DIM;
						if (dif <= THRESHOLD1)
						{
							if (dif < found_min)
							{
								found = j;
								found_min = dif;
							}
						}
					}
				}
			}
			if (found != -1)
			{
				Data->stats++;
				while (!yuv[i].equal->empty())
				{
					int z = *yuv[i].equal->begin();
					yuv[i].equal->pop_front();
					yuv[found].equal->push_back(z);
				}
				yuv[found].equal->push_back(i);
			}
		}
	}
	for (int i = 0; i < Width / CT_DIM * Height / CT_DIM; i++)
	{
		if (!yuv[i].equal->empty())
		{
			for (std::list<int>::iterator it = yuv[i].equal->begin(); it != yuv[i].equal->end(); it++)
			{
				int x = yuv[*it].x;
				int y = yuv[*it].y;
				copyBuffer[y * Width / CT_DIM + x].pre_index = yuv[i].y * CT_DIM * Width / 8 + yuv[i].x + 1;
			}
			yuv[i].equal->clear();
		}
	}

	for (int i = 0; i < Width / CT_DIM * Height / CT_DIM; i++)
	{
		delete yuv[i].equal;
		free(yuv[i].y_);
		free(yuv[i].u_);
		free(yuv[i].v_);
	}
	free(yuv);
#endif
}
