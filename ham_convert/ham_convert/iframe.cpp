#include "iframe.h"

IFRAME::IFRAME(std::string _in, std::string _out)
	:FRAME(_in, _out)
{
	type = iFrame;
	for (int ys = 0; ys < 4; ys++)
	{
		for (int xs = 0; xs < 4; xs++)
		{
			yuv_buffer[ys * 4 + xs] = new YUV_BUFFER(Width, Height);
		}
	}
}
IFRAME::~IFRAME()
{
	for (int ys = 0; ys < 4; ys++)
	{
		for (int xs = 0; xs < 4; xs++)
		{
			delete yuv_buffer[ys * 4 + xs];
		}
	}
}
void IFRAME::convert()
{
	process(tmp + 54, Width, Height);
	free(tmp);
	tmp = 0;
}
void IFRAME::process(unsigned char *mem, int w, int h)
{
	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			int b = (int)((unsigned int)mem[x * 3 + (h - 1 - y) * 3 * w]);
			int g = (int)((unsigned int)mem[x * 3 + (h - 1 - y) * 3 * w + 1]);
			int r = (int)((unsigned int)mem[x * 3 + (h - 1 - y) * 3 * w + 2]);
			yuv_buffer[0]->mem_y[y * w + x] = (int)(yuv_matrix[0][0] * (float)r + yuv_matrix[0][1] * (float)g + yuv_matrix[0][2] * (float)b);
			yuv_buffer[0]->mem_u[y * w + x] = (int)(yuv_matrix[1][0] * (float)r + yuv_matrix[1][1] * (float)g + yuv_matrix[1][2] * (float)b) + 128;
			yuv_buffer[0]->mem_v[y * w + x] = (int)(yuv_matrix[2][0] * (float)r + yuv_matrix[2][1] * (float)g + yuv_matrix[2][2] * (float)b) + 128;
			chunky[y * w + x] = yuv_buffer[0]->mem_y[y * w + x] >> 2;
		}
	}
	createSubpixel();
}
void IFRAME::createSubpixel()
{
	for (int y = 0; y < Height; y++)
	{
		for (int x = 0; x < Height; x++)
		{
			//  yuv_y_xy
			int yuv_y_00 = yuv_buffer[0]->mem_y[y * Width + x];
			int yuv_y_10 = 0;
			int yuv_y_11 = 0;
			int yuv_y_01 = 0;
			if (x + 1 < Width)
				yuv_y_10 = yuv_buffer[0]->mem_y[y * Width + x + 1];
			if (y + 1 < Height)
				yuv_y_01 = yuv_buffer[0]->mem_y[(y + 1) * Width + x];
			if (y + 1 < Height && x + 1 < Width)
				yuv_y_11 = yuv_buffer[0]->mem_y[(y + 1) * Width + x + 1];

			//  yuv_u_xy
			int yuv_u_00 = yuv_buffer[0]->mem_u[y * Width + x];
			int yuv_u_10 = 0;
			int yuv_u_11 = 0;
			int yuv_u_01 = 0;
			if (x + 1 < Width)
				yuv_u_10 = yuv_buffer[0]->mem_u[y * Width + x + 1];
			if (y + 1 < Height)
				yuv_u_01 = yuv_buffer[0]->mem_u[(y + 1) * Width + x];
			if (y + 1 < Height && x + 1 < Width)
				yuv_u_11 = yuv_buffer[0]->mem_u[(y + 1) * Width + x + 1];

			//  yuv_v_xy
			int yuv_v_00 = yuv_buffer[0]->mem_v[y * Width + x];
			int yuv_v_10 = 0;
			int yuv_v_11 = 0;
			int yuv_v_01 = 0;
			if (x + 1 < Width)
				yuv_v_10 = yuv_buffer[0]->mem_v[y * Width + x + 1];
			if (y + 1 < Height)
				yuv_v_01 = yuv_buffer[0]->mem_v[(y + 1) * Width + x];
			if (y + 1 < Height && x + 1 < Width)
				yuv_v_11 = yuv_buffer[0]->mem_v[(y + 1) * Width + x + 1];

			for (int ys = 0; ys < 4; ys++)
			{
				for (int xs = 0; xs < 4; xs++)
				{
					int yuv_y_0 = yuv_y_00 * (4 - xs) + yuv_y_10 * (xs);
					int yuv_y_1 = yuv_y_01 * (4 - xs) + yuv_y_11 * (xs);
					yuv_buffer[ys * 4 + xs]->mem_y[y * Width + x] = (yuv_y_0 * (4 - ys) + yuv_y_1 * (ys)) / 16;

					int yuv_u_0 = yuv_u_00 * (4 - xs) + yuv_u_10 * (xs);
					int yuv_u_1 = yuv_u_01 * (4 - xs) + yuv_u_11 * (xs);
					yuv_buffer[ys * 4 + xs]->mem_u[y * Width + x] = (yuv_u_0 * (4 - ys) + yuv_u_1 * (ys)) / 16;

					int yuv_v_0 = yuv_v_00 * (4 - xs) + yuv_v_10 * (xs);
					int yuv_v_1 = yuv_v_01 * (4 - xs) + yuv_v_11 * (xs);
					yuv_buffer[ys * 4 + xs]->mem_v[y * Width + x] = (yuv_v_0 * (4 - ys) + yuv_v_1 * (ys)) / 16;
				}
			}
		}
	}
}
MOVEPRE IFRAME::movepre(int x, int y, YUV_BUFFER *org)
{
	MOVEPRE mp;
	mp.no_err = 0;
	for (int ys = 0; ys < 4; ys++)
	{
		for (int xs = 0; xs < 4; xs++)
		{
			MOVEPRE m = yuv_buffer[ys * 4 + xs]->movepre(x,y,org);
			if (m.no_err > mp.no_err)
			{
				m.x = m.x << 2 | xs;
				m.y = m.y << 2 | ys;
				mp = m;
			}
		}
	}
	return mp;
}
