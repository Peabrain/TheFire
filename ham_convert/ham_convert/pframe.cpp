#include <thread>
#include "pframe.h"

PFRAME::PFRAME(std::string _in, std::string _out)
	:FRAME(_in, _out)
{
	type = pFrame;
	yuv_buffer = new YUV_BUFFER(Width,Height);
}
PFRAME::~PFRAME()
{
	delete yuv_buffer;
}
void PFRAME::convert()
{
	process(tmp + 54, Width, Height);
	free(tmp);
	tmp = 0;
}
typedef struct AA
{
	int y;
	YUV_BUFFER *buf;
	IFRAME *ifr;
	unsigned char *chunky;
	int pre;
}AA;
void pro(void *s);
int PFRAME::convert(IFRAME *iframe)
{
	convert();

	int pre = 0;
	std::thread aas_th[Height / BLOCK_SIZE];
	AA aas[Height / BLOCK_SIZE];
	for (int y = 0; y < Height / BLOCK_SIZE; y++)
	{
		aas[y].buf = yuv_buffer;
		aas[y].ifr = iframe;
		aas[y].y = y * BLOCK_SIZE;
		aas[y].chunky = chunky;
		aas_th[y] = std::thread(pro, &aas[y]);
//		aas_th[y].join();
	}

	for (int y = 0; y < Height / BLOCK_SIZE; y++)
	{
		aas_th[y].join();
		pre += aas[y].pre;
	}
	printf("pre = %i/%i\n", pre, Width / BLOCK_SIZE * Height / BLOCK_SIZE);
	return pre;
}
void pro(void *s)
{
	AA *g = (AA*)s;
	g->pre = 0;
	YUV_BUFFER **iBuffers = g->ifr->getBuffers();
	for (int x = 0; x < Width / BLOCK_SIZE; x++)
	{
		MOVEPRE mp = g->ifr->movepre(x * BLOCK_SIZE, g->y, g->buf);
		if (mp.getValue() < 32)
		{
			YUV_BUFFER *iBuffer = iBuffers[(mp.y % 4) * 4 + (mp.x % 4)];
			for (int ys = 0; ys < BLOCK_SIZE; ys++)
			{
				for (int xs = 0; xs < BLOCK_SIZE; xs++)
				{
#if defined(MYDEBUG)
					if(xs == 0 || ys == 0 || xs == BLOCK_SIZE - 1 || ys == BLOCK_SIZE - 1)
						g->chunky[(g->y + ys) * Width + (x * BLOCK_SIZE + xs)] = 63 | 0x80;
					else
#endif
						g->chunky[(g->y + ys) * Width + (x * BLOCK_SIZE + xs)] = iBuffer->mem_y[(mp.x >> 2) + xs + (ys + (mp.y >> 2)) * Width] >> 2;
				}
			}
			//				printf("(%i,%i) err = %f, x = %i,y = %i\n", x, y, mp.MSE, mp.x, mp.y);
			g->pre++;
		}
	}
	printf("+");
}
void PFRAME::process(unsigned char *mem, int w, int h)
{
	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			int b = (int)((unsigned int)mem[x * 3 + (h - 1 - y) * 3 * w]);
			int g = (int)((unsigned int)mem[x * 3 + (h - 1 - y) * 3 * w + 1]);
			int r = (int)((unsigned int)mem[x * 3 + (h - 1 - y) * 3 * w + 2]);
			yuv_buffer->mem_y[y * w + x] = (unsigned char)((yuv_matrix[0][0] * (float)r + yuv_matrix[0][1] * (float)g + yuv_matrix[0][2] * (float)b));
			yuv_buffer->mem_u[y * w + x] = (unsigned char)((yuv_matrix[1][0] * (float)r + yuv_matrix[1][1] * (float)g + yuv_matrix[1][2] * (float)b) + 128);
			yuv_buffer->mem_v[y * w + x] = (unsigned char)((yuv_matrix[2][0] * (float)r + yuv_matrix[2][1] * (float)g + yuv_matrix[2][2] * (float)b) + 128);
			chunky[y * w + x] = yuv_buffer->mem_y[y * w + x] >> 2;
		}
	}
	extern void doDCT(unsigned char *mem, int w, int h);
	doDCT(yuv_buffer->mem_y, w, h);
	//	yuv_buffer->createEmboss();
}
