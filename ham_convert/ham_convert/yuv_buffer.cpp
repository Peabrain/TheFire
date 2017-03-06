#include "yuv_buffer.h"

MOVEPRE YUV_BUFFER::movepre(int x, int y, YUV_BUFFER *org)
{
	MOVEPRE back;
	back.no_err = 0;
	back.x = 0;
	back.y = 0;
	for (int i = 0; i < 4; i++)
	{
		int j = i * 2 * 4;
		int x_s = 0;
		int y_s = 0;
		if (!j)
			j = 1;
		for (int k = 0; k < j; k++)
		{
			int u = 0;
			int v = 0;
			if (i)
			{
				u = k % (i * 2);
				v = k / (i * 2);
			}
			switch (v)
			{
			case 0:
			{
				x_s = -i * 2 / 2 + u;
				y_s = -i * 2 / 2;
			}break;
			case 1:
			{
				x_s = i * 2 / 2;
				y_s = -i * 2 / 2 + u;
			}break;
			case 2:
			{
				x_s = i * 2 / 2 - u;
				y_s = i * 2 / 2;
			}break;
			case 3:
			{
				x_s = -i * 2 / 2;
				y_s = i * 2 / 2 - u;
			}break;
			}
			if (x_s + x >= 0 && y_s + y >= 0 && x_s + x + 4 < Width && y_s + y + 4 < Height)
			{
				int no_err = 0;
				for (int yy = 0; yy < 4; yy++)
				{
					for (int xx = 0; xx < 4; xx++)
					{
						if ((abs(org->mem_y[(yy + y) * Width + (xx + x)] - mem_y[(y + y_s) * Width + x + x_s]) < 4) &&
							(abs(org->mem_u[(yy + y) * Width + (xx + x)] - mem_u[(y + y_s) * Width + x + x_s]) < 4) &&
							(abs(org->mem_v[(yy + y) * Width + (xx + x)] - mem_v[(y + y_s) * Width + x + x_s]) < 4))
						{
							no_err += (4 - abs(org->mem_y[(yy + y) * Width + (xx + x)] - mem_y[(y + y_s) * Width + x + x_s])) +
								(4 - abs(org->mem_u[(yy + y) * Width + (xx + x)] - mem_u[(y + y_s) * Width + x + x_s])) +
								(4 - abs(org->mem_v[(yy + y) * Width + (xx + x)] - mem_v[(y + y_s) * Width + x + x_s]));
						}
					}
				}
				if (no_err > back.no_err)
				{
					back.no_err = no_err;
					back.x = x_s;
					back.y = y_s;
				}
			}
		}
	}
	return back;
}
