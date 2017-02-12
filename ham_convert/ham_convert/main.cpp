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
#include "exoquant.h"

#define Width  320
#define Height  192
//#define DITHER
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
float yuv_matrix[3][3] = {
	{ 0.299		,0.587		,0.144 },
	{ -0.14713	,-0.28886	,0.436 },
	{ 0.615		,-0.51499	,-0.10001 }
};
float yuv_imatrix[3][3] = {
	{ 1		,0			,1.13983 },
	{ 1		,-0.39465	,-0.58060 },
	{ 1		,2.03211	,0 }
};

typedef struct LUM
{
	float value;
	int x, y;
	unsigned int index;
	int r, g, b;
	unsigned int sortIdx;
};
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
typedef struct RGB
{
	unsigned char r, g, b, a;
};

typedef struct DATA
{
    int count;
    std::string _in;
    std::string _out;
    void *mem;
	int stats;
};

void convert(void *data);
void process(unsigned  char *mem, unsigned char *ham, int w, int h, DATA *Data);
void convertSequence(const char *path,int start, int Len, int zz);
int changeColor(int c, int x, int y, unsigned char *pl, unsigned int bit, int lum, bool dith);
int prepareIndexBuffer(LUM *lumlist, int *r_tab, int *g_tab, int *b_tab, unsigned short *ham_color, int w, int h, unsigned char *mem);
void doDCT(unsigned char*mem, int w, int h);
void doFFT(unsigned char*mem);
unsigned int getBlockCodeHori(unsigned char *mem);
unsigned int getBlockCodeVert(unsigned char *mem);

int main(int argc, const char * argv[])
{
	stats.copied_pattern = 0;
	stats.rendered_pattern = 0;
//    convertSequence("ghost",0,3440,2);
    convertSequence("nvidia",0,4260,2);
//	convertSequence("darksouls3",0,3392,2);
//    convertSequence("ray",3862,2);
//	convertSequence("cocoon", 0,11161, 2);
//	convertSequence("cocoon", 0,2000, 2);
	//	convertSequence("cocoon", 6000, 3);
	//    convertSequence("test",1,2);

//	DCT dct;
//	dct.main();

	printf("Stats:\n");
	printf("Rendered Pattern: %i\n", stats.rendered_pattern);
	printf("Copied Pattern: %i\n", stats.copied_pattern);
	return 0;
}
void convertSequence(const char *path,int start,int Len,int zz)
{
#define CACHES 4
	unsigned char CacheBuffer[320 / 8 * Height * 6 * CACHES];
	int CacheIdx = 0;
	int len = start + Len;
    char filename2[256];

	memset(CacheBuffer, 0, 320 / 8 * Height * 6 * CACHES);
    sprintf(filename2,"../asm/%s.tmp",path);
    if(FILE *f2 = fopen(filename2,"w+b"))
    {
        fclose(f2);
    }
    if(FILE *f2 = fopen(filename2,"a+b"))
    {
        int count = start,count2 = 0,j = 0;
        std::thread *t1[THREADS];
        DATA data[THREADS];
        for(int i = 0;i < THREADS;i++)
        {
            t1[i]= 0;
        }
        while(count < len)
        {
            std::string filename;
            std::string filename2;
            char tm[256];
            sprintf(tm,"../../data/%s/%4.4i.bmp",path,count);
            filename.append(tm);
            sprintf(tm,"../asm/%s/%4.4i.bmp.tmp",path,count2++);
            filename2.append(tm);
            data[j]._in = filename;
            data[j]._out = filename2;
            t1[j++] = new std::thread(convert,&data[j]);
			data[j].stats = 0;

            count += zz;
            if(j == THREADS || count >= len)
            {
				for (int i = 0; i < THREADS; i++)
				{
					if (t1[i] != 0)
						t1[i]->join();
				}
				for(int i = 0;i < THREADS;i++)
                {
                    if(t1[i] != 0)
                    {
                        t1[i]= 0;

						for (int y = 0; y < Height / CT_DIM; y++)
						{
							for (int x = 0; x < Width / 8; x++)
							{
								int scrpos = y * CT_DIM * Width / 8 + x;
								unsigned char *mem = (unsigned char *)data[i].mem + scrpos;
								int found = -1;
								for (int kk = 0; kk < CACHES && (found == -1); kk++)
								{
									int k = (CacheIdx - kk) & (CACHES - 1);
									for (int l = 0; l < Width / 8 * (Height - CT_DIM) && (found == -1);l++)
									{
										bool fail = false;
										for (int p = 0; p < 6 && !fail; p++)
										{
											for (int i = 0; i < CT_DIM && !fail; i++)
											{
												if (mem[i * Width / 8 + p * Width / 8 * Height] != CacheBuffer[l + k * 320 / 8 * Height * 6 + i * Width / 8 + p * Width / 8 * Height]) fail = true;
											}
										}
										if (fail == false)
										{
											found = l + k * 320 / 8 * Height * 6;
										}
									}
								}
								if (found != -1)
								{
									data[i].stats++;
									for (int p = 0; p < 6; p++)
									{
										for (int i = 0; i < CT_DIM; i++)
										{
											mem[i * Width / 8 + p * Width / 8 * Height] = CacheBuffer[found + i * Width / 8 + p * Width / 8 * Height];
										}
									}
									printf("");
								}
							}
						}
						fwrite(data[i].mem, 320 / 8 * Height * 6 + 2 * 15 * (Height / Height), 1, f2);

						memccpy(CacheBuffer + CacheIdx * 320 / 8 * Height * 6,data[i].mem,1, 320 / 8 * Height * 6);
                        free(data[i].mem);
					
						stats.copied_pattern += data[i].stats;
						stats.rendered_pattern += Width / CT_DIM * Height / CT_DIM;
						printf("open file %s , double %ix%i : %i\n", data[i]._in.c_str(), CT_DIM, CT_DIM, data[i].stats);
						CacheIdx = (CacheIdx + 1) % CACHES;
					}
                }
				for (int i = 0; i < THREADS; i++)
				{
					if (t1[i] != 0)
						t1[i] = 0;
				}
				j = 0;
            }
        }
        fclose(f2);
    }
}
void convert(void *data)
{
    DATA *Data = (DATA*)data;
    if(FILE *f = fopen(Data->_in.c_str(),"rb"))
    {
        fseek(f, 0L, SEEK_END);
        int sz = ftell(f);
        fseek(f, 0L, SEEK_SET);

        unsigned char *mem = (unsigned char*)malloc(sz);
        Data->mem = (unsigned char*)malloc(320 / 8 * Height * 6 + 2 * 15 * (Height / Height));
		memset(Data->mem,0, 320 / 8 * Height * 6 + 2 * 15 * (Height / Height));
        
        fread(mem,sz,1,f);
        
        fclose(f);

        process(mem+54,(unsigned char *)Data->mem,Width,Height,Data);

        free(mem);
    }
    else
        printf("cannot find file %s\n",Data->_in.c_str());
}
void process(unsigned char *mem,unsigned char *ham,int w,int h, DATA *Data)
{
	unsigned int *blockCodeVert = 0;
//	unsigned int *blockCodeHori = 0;
	int colorIndexTab[0x1000];
	LUM *lumlist = new LUM[320 * Height];
	int r_tab[16];
    int g_tab[16];
    int b_tab[16];
	Data->stats = 0;
	blockCodeVert = (unsigned int*)malloc(sizeof(unsigned int) * Width * 3 * (Height - (CT_DIM - 1)));
//	blockCodeHori = (unsigned int*)malloc(sizeof(unsigned int) * Width / CT_DIM * Height);
	unsigned short *ham_color = (unsigned short *)(ham + 320 / 8 * Height * 6);
	unsigned char *mem_tmp = (unsigned char *)malloc(Width * Height * 3);

	doDCT(mem,Width,Height);
	doFFT(mem);
	for (int i = 0; i < Width * Height * 3; i++)
		mem_tmp[i] = mem[i] >> 4;

/*	for (int i = 0; i < Width * 3 * (Height - (CT_DIM - 1)); i++) blockCodeVert[i] = getBlockCodeVert(mem_tmp + i);
//	for (int i = 0; i < Width / CT_DIM * Height; i++) blockCodeHori[i] = getBlockCodeVert(mem_tmp + i * 8);

	for (int yy = 0; yy < Height / CT_DIM; yy++)
	{
		int y = yy * CT_DIM;
		for (int xx = 0; xx < Width / CT_DIM; xx++)
		{
			int x = xx * CT_DIM * 3;
			int ScrPos = y * Width * 3 + x;
			int ScrVPos = y * Width * 3 + x;
			int ScrHPos = y * Width * 3 + xx;

			for (int i = 0; i < yy * Width / CT_DIM + xx; i += CT_DIM * 3)
			{
				int j = 0;
				for (j = 0; j < CT_DIM * 3; j++)
				{
					if (blockCodeVert[ScrVPos + j] != blockCodeVert[i + j])
						break;
				}
				if (j == CT_DIM * 3)
				{
					Data->stats++;
					break;
					printf("");
				}
			}
		}
	}
*/
	int numOfColors = 0;
	numOfColors = prepareIndexBuffer(lumlist, r_tab, g_tab, b_tab, ham_color, w, h, mem);


	int aktsetX = 0;
	int ra = 0;
	int ga = 0;
	int ba = 0;
	for(int y = 0;y < h;y++)
    {
		unsigned char bit = 0x80;
		unsigned char pl[6] = {0,0,0,0,0,0};

		ba = 0;
		ga = 0;
		ra = 0;

		for (int x = 0; x < w; x++)
		{
			int code = 0;
#ifdef DITHER
			bool dith = true;
#else
			bool dith = false;
#endif

			int b = (int)((unsigned int)mem[x * 3 + (Height - 1 - y) * 3 * w]);
			int g = (int)((unsigned int)mem[x * 3 + (Height - 1 - y) * 3 * w + 1]);
			int r = (int)((unsigned int)mem[x * 3 + (Height - 1 - y) * 3 * w + 2]);

			int rd = abs(ra - r) *(299);// +50 + 25);
			int gd = abs(ga - g) *(587);// -150);
			int bd = abs(ba - b) *(114);// +50 + 25);

			int ga_ = ga;
			int ba_ = ba;
			int ra_ = ra;

			if (gd >= rd)
			{
				if (gd >= bd)
				{
					ga_ = g;
					code = 3;
				}
				else
				{
					ba_ = b;
					code = 1;
				}
			}
			else
			{
				if (rd >= bd)
				{
					ra_ = r;
					code = 2;
				}
				else
				{
					ba_ = b;
					code = 1;
				}
			}

			if (aktsetX < numOfColors && lumlist[aktsetX].x == x && lumlist[aktsetX].y == y)
			{
				int rd = abs(ra_ - r) * (299);// +50 + 25);
				int gd = abs(ga_ - g) * (587);// -150);
				int bd = abs(ba_ - b) * (114);// +50 + 25);
				float lum0 = 0.299 * (float)rd + 0.587 * (float)gd + 0.114 * (float)bd;

				ra = r_tab[lumlist[aktsetX].index - 1];
				ga = g_tab[lumlist[aktsetX].index - 1];
				ba = b_tab[lumlist[aktsetX].index - 1];

				rd = abs(ra - r) * (299);// +50 + 25);
				gd = abs(ga - g) * (587);// -150);
				bd = abs(ba - b) * (114);// +50 + 25);

				float lum1 = 0.299 * (float)rd + 0.587 * (float)gd + 0.114 * (float)bd;
				if (lum0 < lum1)
				{
					ra = ra_;
					ga = ga_;
					ba = ba_;
				}
				else
				{
					code = 0;
					b = lumlist[aktsetX].index << 4;
					dith = false;
				}
				aktsetX++;
			}


			switch (code)
			{
			case 0:
			{
				int l = 0.299 * (float)ra + 0.587 * (float)ga + 0.114 * (float)ba;
				changeColor(b, x, y, pl, bit, l, dith);
			}break;
			case 1:
			{
				pl[4] |= bit;
				int l = 0.299 * (float)ra + 0.587 * (float)ga + 0.114 * (float)ba;
				ba = changeColor(b, x, y, pl, bit, l, dith);
			}break;
			case 2:
			{
				pl[5] |= bit;
				int l = 0.299 * (float)ra + 0.587 * (float)ga + 0.114 * (float)ba;
				ra = changeColor(r, x, y, pl, bit, l, dith);
			}break;
			case 3:
			{
				pl[4] |= bit;
				pl[5] |= bit;
				int l = 0.299 * (float)ra + 0.587 * (float)ga + 0.114 * (float)ba;
				ga = changeColor(g, x, y, pl, bit, l, dith);
			}break;
			}

			bit >>= 1;
			if (bit == 0)
			{
				bit = 0x80;
				for (int i = 0; i < 6; i++)
				{
#ifdef WIN32
					ham[320 / 8 * y + x / 8 + 320 / 8 * Height * i] = pl[i];// _byteswap_ulong(pl[i]);
//					ham[(320 / 8 * y + x / 8) * 6 + i] = pl[i];// _byteswap_ulong(pl[i]);
#else
					ham[320 / 8 * y + x / 8 + 320 / 8 * Height * i] = pl[i];// __builtin_bswap32(pl[i]);
#endif
					pl[i] = 0;
				}
			}
		}
    }
	if (lumlist) delete [] lumlist;
	free(mem_tmp);
	free(blockCodeVert);
//	free(blockCodeHori);
}
int changeColor(int c,int x,int y,unsigned char *pl,unsigned int bit, int lum,bool dith)
{
    int m = c;
#ifdef DITHER
	if (dith)
	{
		int p = ((m) & 0x0e) >> 1;
		if (matrix[p] & (1 << (((x) & 3) + (y & 3) * 4))) { m += 16; }
		if (m > 255) m = 255;
		if (m < 0) m = 0;
		c = m;
	}
#endif
//	c = m;
    m >>= 4;
    for(int i = 0;i < 4;i++) if(m & (1 << i)) pl[i] |= bit;
    return c;
}

int prepareIndexBuffer(LUM *lumlist, int *r_tab,int *g_tab,int *b_tab, unsigned short *ham_color,int w,int h,unsigned char *mem)
{
	int ra = 0;
	int ga = 0;
	int ba = 0;
	int cop = 0;
	int numOfColors = 0;
	memset(lumlist, 0, sizeof(LUM) * 320 * Height);
	for (int yy = 0; yy < Height; yy++)
	{
		ra = 0;
		ga = 0;
		ba = 0;
		for (int x = 0; x < w; x++, cop++)
		{
			int b = (int)((unsigned int)mem[x * 3 + (Height - 1 - yy) * 3 * w]);
			int g = (int)((unsigned int)mem[x * 3 + (Height - 1 - yy) * 3 * w + 1]);
			int r = (int)((unsigned int)mem[x * 3 + (Height - 1 - yy) * 3 * w + 2]);
			int rd = abs(ra - r);
			int gd = abs(ga - g);
			int bd = abs(ba - b);

			lumlist[cop].value = 0.299 * (float)rd + 0.587 * (float)gd + 0.114 * (float)bd;
			lumlist[cop].r = r;
			lumlist[cop].g = g;
			lumlist[cop].b = b;
			lumlist[cop].x = x;
			lumlist[cop].y = yy;

			ra = r;
			ga = g;
			ba = b;
		}
	}

	unsigned char *tmprgb_buffer = new unsigned char[Height * 320 * 4];
	unsigned char *indexbuffer = new unsigned char[Height * 320 * 4];
	int			  *lumlist_idx = new int[Height * 320 * 4];
	for (int i = 0; i < cop; i++)
	{
		if (lumlist[i].value > 8)
		{
			lumlist_idx[numOfColors] = i;
			tmprgb_buffer[numOfColors * 4] = lumlist[i].r;
			tmprgb_buffer[numOfColors * 4 + 1] = lumlist[i].g;
			tmprgb_buffer[numOfColors * 4 + 2] = lumlist[i].b;
			tmprgb_buffer[numOfColors * 4 + 3] = 0;
			numOfColors++;
		}
	}

	exq_data *pExq = exq_init();
	RGB pPalette[15];
	exq_no_transparency(pExq);
	exq_feed(pExq, tmprgb_buffer, numOfColors);

	for (int i = 0; i < 15; i++)
	{
		pPalette[i].r = (i << 4);
		pPalette[i].g = (i << 4);
		pPalette[i].b = (i << 4);
	}
	exq_set_palette(pExq, (unsigned char*)pPalette, 15);
//	exq_quantize_hq(pExq, 15);
//	exq_get_palette(pExq, (unsigned char*)pPalette, 15);
	exq_map_image(pExq, numOfColors, tmprgb_buffer, indexbuffer);

	for (int i = 0; i < 15; i++)
	{
		pPalette[i].r += 8;
		pPalette[i].g += 8;
		pPalette[i].b += 8;
		if (pPalette[i].r > 255) pPalette[i].r = 255;
		if (pPalette[i].g > 255) pPalette[i].g = 255;
		if (pPalette[i].b > 255) pPalette[i].b = 255;

		r_tab[i] = pPalette[i].r;
		g_tab[i] = pPalette[i].g;
		b_tab[i] = pPalette[i].b;
		int r = (r_tab[i]) >> 4;
		int g = (g_tab[i]) >> 4;
		int b = (b_tab[i]) >> 4;
		unsigned short h = (r << 8) | (g << 4) | (b);
		h = ((h & 0xff) << 8) | ((h & 0xff00) >> 8);
		ham_color[i] = h;
	}

	int lsIndex = -1;
	int lsY = -1;
	int gg = 0;
	for (int i = 0; i < numOfColors; i++)
	{
		int nIndex = indexbuffer[i] + 1;
		if (lsIndex != nIndex || lsY != lumlist[lumlist_idx[i]].y)
		{
			lumlist[gg] = lumlist[lumlist_idx[i]];
			lumlist[gg].index = nIndex;
			lsIndex = nIndex;
			lsY = lumlist[lumlist_idx[i]].y;
			gg++;
		}
	}
	numOfColors = gg;
	for (int i = 0; i < numOfColors; i++)
	{
		lumlist[i].sortIdx = (lumlist[i].x % CT_DIM) | ((lumlist[i].y % CT_DIM) << 8) | ((lumlist[i].x >> CT_DIM_BIT) << 16) | ((lumlist[i].y >> CT_DIM_BIT) << 24);
	}
/*	for (int i = 0; i < numOfColors - 1; i++)
	{
		for (int j = i + 1; j < numOfColors; j++)
		{
			if (lumlist[j].sortIdx < lumlist[i].sortIdx)
			{
				LUM l = lumlist[j];
				lumlist[j] = lumlist[i];
				lumlist[i] = l;
			}
		}
	}
	*/
	exq_free(pExq);
	delete[]tmprgb_buffer;
	delete[]indexbuffer;
	delete[]lumlist_idx;

	return numOfColors;
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
unsigned int getBlockCodeVert(unsigned char *mem)
{
	unsigned int u = 0;
	for (int i = 0; i < CT_DIM; i++)
	{
		u |= ((unsigned int)mem[i * Width * 3 / 8]) << (4 * i);
	}
	return u;
}
unsigned int getBlockCodeHori(unsigned char *mem)
{
	unsigned int u = 0;
	for (int i = 0; i < CT_DIM; i++)
	{
		u |= ((unsigned int)mem[i]) << (4 * i);
	}
	return u;
}
