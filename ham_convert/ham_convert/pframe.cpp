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
void PFRAME::convert(IFRAME *iframe)
{
	convert();

	YUV_BUFFER **iBuffers = iframe->getBuffers();
	for (int y = 0; y < Height - 4; y += 4)
	{
		for (int x = 0; x < Width - 4; x += 4)
		{
			MOVEPRE mp = iframe->movepre(x, y, yuv_buffer);
			if (mp.no_err > 16 * 4)
			{
				for (int ys = 0; ys < 4; ys++)
				{
					for (int xs = 0; xs < 4; xs++)
					{
						YUV_BUFFER *iBuffer = iBuffers[(ys % 4) * 4 + (xs % 4)];
						chunky[(y + ys) * Width + (x + xs)] = iBuffer->mem_y[(mp.x / 4) + (mp.x / 4) * Width];
					}
				}
			}
			printf("err = %i, x = %i,y = %i\n",mp.no_err,mp.x,mp.y);
		}
	}
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
			yuv_buffer->mem_y[y * w + x] = (int)(yuv_matrix[0][0] * (float)r + yuv_matrix[0][1] * (float)g + yuv_matrix[0][2] * (float)b);
			yuv_buffer->mem_u[y * w + x] = (int)(yuv_matrix[1][0] * (float)r + yuv_matrix[1][1] * (float)g + yuv_matrix[1][2] * (float)b) + 128;
			yuv_buffer->mem_v[y * w + x] = (int)(yuv_matrix[2][0] * (float)r + yuv_matrix[2][1] * (float)g + yuv_matrix[2][2] * (float)b) + 128;
			chunky[y * w + x] = yuv_buffer->mem_y[y * w + x] >> 2;
		}
	}
}
