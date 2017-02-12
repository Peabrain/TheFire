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
#include "exoquant.h"


void convert(void *data);
void process(unsigned  char *mem, unsigned int *ham, int w, int h);
void convertSequence(const char *path, int len, int zz);
int changeLum(int c, int x, int y, unsigned int *pl, unsigned int bit);
int changeCol(int c, int x, int y, unsigned int *pl, unsigned int bit);

int red[256];
int green[256];
int blue[256];

typedef struct DATA
{
	int count;
	std::string _in;
	std::string _out;
	void *mem;
};

int Width = 320;
int Height = 192;
int main(int argc, const char * argv[])
{
	for (int i = 0; i < 128; i++)
	{
		red[i] = i * 2;
		green[i] = 0;
		green[128 + i] = i * 2;
		red[128 + i] = 255;
		blue[i] = 0;
		blue[128 + i] = 0;
	}
//	convertSequence("ghost",3440,2);
//	convertSequence("nvidia",4260,2);
//	convertSequence("darksouls3",3392,2);
//	convertSequence("ray",3862,2);
	convertSequence("cocoon", 11161, 3);
//	convertSequence("cocoon", 100, 3);
//	convertSequence("test",1,2);

	return 0;
}
#define THREADS 8
void convertSequence(const char *path, int len, int zz)
{
	char filename2[256];
	sprintf(filename2, "../asm/%s_hires.tmp", path);
	if (FILE *f2 = fopen(filename2, "w+b"))
	{
		fclose(f2);
	}
	if (FILE *f2 = fopen(filename2, "a+b"))
	{
		int count = 0, count2 = 0, j = 0;
		std::thread *t1[THREADS];
		DATA data[THREADS];
		for (int i = 0; i < THREADS; i++)
		{
			t1[i] = 0;
		}
		while (count < len)
		{
			std::string filename;
			std::string filename2;
			char tm[256];
			sprintf(tm, "../../data/%s/%4.4i.bmp", path, count);
			filename.append(tm);
			sprintf(tm, "../asm/%s/%4.4i.bmp.tmp", path, count2++);
			filename2.append(tm);
			data[j]._in = filename;
			data[j]._out = filename2;
			t1[j++] = new std::thread(convert, &data[j]);

			count += zz;
			if (j == THREADS || count >= len)
			{
				for (int i = 0; i < THREADS; i++)
				{
					if (t1[i] != 0)
						t1[i]->join();
				}
				for (int i = 0; i < THREADS; i++)
				{
					if (t1[i] != 0)
					{
						t1[i] = 0;
						fwrite(data[i].mem, 320 / 8 * Height * (4+6) + 2 * 31, 1, f2);
						free(data[i].mem);
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
	if (FILE *f = fopen(Data->_in.c_str(), "rb"))
	{
		fseek(f, 0L, SEEK_END);
		int sz = ftell(f);
		fseek(f, 0L, SEEK_SET);
		printf("open file %s (%i)\n", Data->_in.c_str(), sz);

		unsigned char *mem = (unsigned char*)malloc(sz);
		Data->mem = (unsigned char*)malloc(320 / 8 * Height * (4+6) + 2 * 31);
		memset(Data->mem, 0, 320 / 8 * Height * (4+6) + 2 * 31);

		fread(mem, sz, 1, f);

		fclose(f);

		process(mem + 54, (unsigned int *)Data->mem, Width, Height);

		free(mem);
	}
	else
		printf("cannot find file %s\n", Data->_in.c_str());
}
typedef struct LUM
{
	float value;
	int x, index;
	int r, g, b;
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
	unsigned char r, g, b,a;
};

void process(unsigned char *mem, unsigned int *ham, int w, int h)
{
	unsigned char *flags = new unsigned char[w * h];
	unsigned char *indexbuffer = new unsigned char[w * h];
	unsigned char *rgba_buf = new unsigned char[w * h * 4];
	memset(rgba_buf, 0, w * h * 4);
	memset(flags, 0, w * h);
	for (int i = 0; i < h * w; i++)
	{
		int r = (int)((unsigned int)mem[i * 3]);
		int g = (int)((unsigned int)mem[i * 3 + 1]);
		int b = (int)((unsigned int)mem[i * 3 + 2]);

		if (r < 256 && g < 128 && b < 128)
		{
			flags[i] = 1;
			r *= 2;
			g *= 2;
			b *= 2;
		}
		rgba_buf[i * 4] = r;
		rgba_buf[i * 4 + 1] = g;
		rgba_buf[i * 4 + 2] = b;
	}

	exq_data *pExq = exq_init();
	RGB pPalette[31];
	exq_no_transparency(pExq);
	exq_feed(pExq, rgba_buf, h * w);
	exq_quantize(pExq, 31);
	exq_get_palette(pExq, (unsigned char*)pPalette, 31);
	exq_map_image(pExq, w * h, rgba_buf, indexbuffer);

	unsigned short *pal = ((unsigned short*)ham + w / 16 * h * (4 + 6));
	for (int i = 0; i < 31; i++)
	{
		unsigned short p = ((pPalette[i].b >> 4) << 8) | ((pPalette[i].g >> 4) << 4) | (pPalette[i].r >> 4);
		p = ((p & 0xff) << 8) | ((p & 0xff00) >> 8);
		pal[i] = p;
	}
	for (int i = 0; i < w * h;i++) indexbuffer[i]++;


	for (int y = 0; y < h; y++)
	{
		unsigned int bit = 0x80000000;
		unsigned int pl[4] = { 0,0,0,0 };
		unsigned int plc[6] = { 0,0,0,0,0,0 };

		for (int x = 0; x < w; x++)
		{
//			int r = (int)((unsigned int)mem[x * 3 + (Height - 1 - y) * 3 * w]);
//			int g = (int)((unsigned int)mem[x * 3 + (Height - 1 - y) * 3 * w + 1]);
//			int b = (int)((unsigned int)mem[x * 3 + (Height - 1 - y) * 3 * w + 2]);
			int c = indexbuffer[(Height - 1 - y) * w + x];
//			int l = 0.299 * (float)pPalette[c].r + 0.587 * (float)pPalette[c].g + 0.114 * (float)pPalette[c].b;
			int r = pPalette[c - 1].r;
			int g = pPalette[c - 1].g;
			int b = pPalette[c - 1].b;
			int l = 0.299 * (float)r + 0.587 * (float)g + 0.114 * (float)b;
			if (flags[(Height - 1 - y) * w + x] == 1)
			{
				c += 32;
				l /= 2;
			}
			changeLum(l >> 1, x, y, pl, bit);
			changeCol(c, x, y, plc, bit);

			if (!(bit >>= 1))
			{
				bit = 0x80000000;
				for (int i = 0; i < 4; i++)
				{
#ifdef WIN32
					ham[320 / 32 * y + x / 32 + 320 / 32 * Height * i] = _byteswap_ulong(pl[i]);
#else
					ham[320 / 32 * y + x / 32 + 320 / 32 * Height * i] = __builtin_bswap32(pl[i]);
#endif
					pl[i] = 0;
				}
				for (int i = 0; i < 6; i++)
				{
#ifdef WIN32
					ham[320 / 32 * y + x / 32 + 320 / 32 * Height * (i + 4)] = _byteswap_ulong(plc[i]);
#else
					ham[320 / 32 * y + x / 32 + 320 / 32 * Height * (i + 4)] = __builtin_bswap32(plc[i]);
#endif
					plc[i] = 0;
				}
			}
		}

		/*        printf("LuminanzTest line %i (%i):\n",y,numOfColors);
		for(int i = 0;i < numOfColors;i++)
		printf("%i (%f) %i\n",lumlist[i].x,lumlist[i].value,lumlist[i].index);
		/**/
	}
	exq_free(pExq);
	delete rgba_buf;
	delete indexbuffer;
	delete flags;
}
int changeLum(int c, int x, int y, unsigned int *pl, unsigned int bit)
{
	int m = c;
	int p = (m & 0x07) * 2 * 7 / 8;
	if (matrix[p] & (1 << (((x) & 3) + (y & 3) * 4))) { m += 8; c += 8; }
	if (m > 127) m = 127;
	if (m < 0) m = 0;
	m >>= 3;
	//    c = (m << 4) + 7;
	for (int i = 0; i < 4; i++) if (m & (1 << i)) pl[i] |= bit;
	return c;
}
int changeCol(int c, int x, int y, unsigned int *pl, unsigned int bit)
{
	int m = c;
//	m >>= 3;
	for (int i = 0; i < 6; i++) if (m & (1 << i)) pl[i] |= bit;
	return c;
}
