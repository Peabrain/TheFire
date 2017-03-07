#include "yuv_buffer.h"

MOVEPRE YUV_BUFFER::movepre(int px, int py, YUV_BUFFER *org)
{

	MOVEPRE back;
	back.p_y.MSE = 160000000000000000000000.0;
	back.p_u.MSE = 160000000000000000000000.0;
	back.p_v.MSE = 160000000000000000000000.0;
	back.x = 0;
	back.y = 0;

	int p = 64 * 4;
/*	int left = back.x - p;
	int right = back.x + p + BLOCK_SIZE * 4;
	int top = back.y - p;
	int bottom = back.y + p + BLOCK_SIZE * 4;
	if (left < 0) left = 0;
	if (right > Width * 4) right = Width * 4;
	if (top < 0) top = 0;
	if (bottom > Height * 4) bottom = Height * 4;

	back = checkpos(x, y, back.x, back.y, org);
	while (p != 1)
	{
		bool new_i = false;
		if ((back.x >= left) && (back.x + 4 * BLOCK_SIZE < right) && ((back.y - p) >= top) && ((back.y - p) + 4 * BLOCK_SIZE < bottom))
		{
			MOVEPRE back_new = checkpos(x, y, back.x, back.y - p, org);
			if (back_new.p_y.MSE < back.p_y.MSE)
			{
				back = back_new;
				new_i = true;
			}
		}
		if ((back.x >= left) && (back.x + 4 * BLOCK_SIZE < right) && ((back.y + p) >= top) && ((back.y + p) + 4 * BLOCK_SIZE < bottom))
		{
			MOVEPRE back_new = checkpos(x, y, back.x, back.y + p, org);
			if (back_new.p_y.MSE < back.p_y.MSE)
			{
				back = back_new;
				new_i = true;
			}
		}
		if ((back.x - p >= left) && (back.x - p + 4 * BLOCK_SIZE < right) && (back.y >= top) && (back.y + 4 * BLOCK_SIZE < bottom))
		{
			MOVEPRE back_new = checkpos(x, y, back.x - p, back.y, org);
			if (back_new.p_y.MSE < back.p_y.MSE)
			{
				back = back_new;
				new_i = true;
			}
		}
		if ((back.x + p >= left) && (back.x + p + 4 * BLOCK_SIZE < right) && (back.y >= top) && (back.y + 4 * BLOCK_SIZE < bottom))
		{
			MOVEPRE back_new = checkpos(x, y, back.x + p, back.y, org);
			if (back_new.p_y.MSE < back.p_y.MSE)
			{
				back = back_new;
				new_i = true;
			}
		}
		if (new_i == false)
		{
			p /= 2;
			left = back.x - p;
			right = back.x + p + BLOCK_SIZE * 4;
			top = back.y - p;
			bottom = back.y + p + BLOCK_SIZE * 4;
			if (left < 0) left = 0;
			if (right > Width * 4) right = Width * 4;
			if (top < 0) top = 0;
			if (bottom > Height * 4) bottom = Height * 4;
		}
	}
	for (int ys = -1; ys <= 1; ys++)
	{
		for (int xs = -1; xs <= 1; xs++)
		{
			if(xs != 0 && ys != 0)
			if ((back.x + xs >= left) && (back.x + xs + 4 * BLOCK_SIZE < right) && (back.y + ys >= top) && (back.y + ys + 4 * BLOCK_SIZE < bottom))
			{
				MOVEPRE back_new = checkpos(x, y, back.x + xs, back.y + ys, org);
				if (back_new.p_y.MSE < back.p_y.MSE)
				{
					back = back_new;
				}
			}
		}
	}
*/
	int mem_y_q[4];
	int mem_u_q[4];
	int mem_v_q[4];
	int blockbase = (py + BLOCK_SIZE / 2 - 1) * Width + (px + BLOCK_SIZE / 2 - 1);
	mem_y_q[0] = org->mem_y[blockbase];
	mem_y_q[1] = org->mem_y[blockbase + 1];
	mem_y_q[3] = org->mem_y[blockbase + Width + 1];
	mem_y_q[2] = org->mem_y[blockbase + Width];
	mem_u_q[0] = org->mem_u[blockbase];
	mem_u_q[1] = org->mem_u[blockbase + 1];
	mem_u_q[3] = org->mem_u[blockbase + Width + 1];
	mem_u_q[2] = org->mem_u[blockbase + Width];
	mem_v_q[0] = org->mem_v[blockbase];
	mem_v_q[1] = org->mem_v[blockbase + 1];
	mem_v_q[3] = org->mem_v[blockbase + Width + 1];
	mem_v_q[2] = org->mem_v[blockbase + Width];
	int top = py * 4 - p;
	int bottom = py * 4 + p + BLOCK_SIZE * 4;
	int left = px * 4 - p;
	int right = px * 4 + p + BLOCK_SIZE * 4;
	if (top < 0) top = 0;
	if (bottom > (Height - BLOCK_SIZE) * 4) bottom = (Height - BLOCK_SIZE) * 4;
	if (left < 0) left = 0;
	if (right > (Width - BLOCK_SIZE) * 4) right = (Width - BLOCK_SIZE) * 4;
	if (right - left >= BLOCK_SIZE * 4 && bottom - top >= BLOCK_SIZE * 4)
	{
		for (int yy = top; yy < bottom; yy++)
		{
			for (int xx = left; xx < right; xx++)
			{
				int blockbase = (yy + (BLOCK_SIZE / 2 - 1) * 4) * 4 * Width + xx + (BLOCK_SIZE / 2 - 1) * 4;
				float a_y = fabs(mem_y_q[0] - (int)mem_y[blockbase]) +
					fabs(mem_y_q[1] - (int)mem_y[blockbase + 4]) +
					fabs(mem_y_q[3] - (int)mem_y[blockbase + 4 * 4 * Width + 4]) +
					fabs(mem_y_q[2] - (int)mem_y[blockbase + 4 * 4 * Width]);
				float a_u = fabs(mem_u_q[0] - (int)mem_u[blockbase]) +
					fabs(mem_u_q[1] - (int)mem_u[blockbase + 4]) +
					fabs(mem_u_q[3] - (int)mem_u[blockbase + 4 * 4 * Width + 4]) +
					fabs(mem_u_q[2] - (int)mem_u[blockbase + 4 * 4 * Width]);
				float a_v = fabs(mem_v_q[0] - (int)mem_v[blockbase]) +
					fabs(mem_v_q[1] - (int)mem_v[blockbase + 4]) +
					fabs(mem_v_q[3] - (int)mem_v[blockbase + 4 * 4 * Width + 4]) +
					fabs(mem_v_q[2] - (int)mem_v[blockbase + 4 * 4 * Width]);
				a_y /= 4;
				a_u /= 4;
				a_v /= 4;
#if defined(MOVEPRE_COM_UV)
				if ((a_u + a_v) / 2 < 3)
#elif defined(MOVEPRE_COM_YUV)
				if ((a_y + a_u + a_v) / 3 < 6)
#endif
				{
					MOVEPRE back_new = checkpos(px, py, xx, yy, org);
					if (back_new.getValue() < back.getValue() && back_new.getMPC() > BLOCK_SIZE * BLOCK_SIZE / 2)
					{
						back = back_new;
//						back.x = xx;
//						back.y = yy;
					}
				}
			}
		}
	}

/*	for (int i = 0; i < p; i++)
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
			y_s += y * 4;
			x_s += x * 4;
			if (y_s < 0 || x_s < 0 || y_s + 4 * 4 >= Height * 4 || x_s + 4 * 4 >= Width * 4) continue;
			MOVEPRE back_new = checkpos(x, y, x_s, y_s, org);
			if (back_new.p_y.MSE < back.p_y.MSE)
			{
				back.p_y = back_new.p_y;
				back.p_u = back_new.p_u;
				back.p_v = back_new.p_v;
				back.x = x_s;
				back.y = y_s;
			}
		}
	}
*/
	return back;
}
MOVEPRE YUV_BUFFER::checkpos(int px, int py, int x_s, int y_s, YUV_BUFFER *org)
{
	MOVEPRE back;
	back.p_y.MSE = 0.0;
	back.p_u.MSE = 0.0;
	back.p_v.MSE = 0.0;
	back.p_y.MAD = 0.0;
	back.p_u.MAD = 0.0;
	back.p_v.MAD = 0.0;
	back.p_y.MPC = 0;
	back.p_u.MPC = 0;
	back.p_v.MPC = 0;
	for (int yy = 0; yy < BLOCK_SIZE; yy++)
	{
		for (int xx = 0; xx < BLOCK_SIZE; xx++)
		{
			float mad_y = fabs((int)org->mem_y[(yy + py) * Width + (xx + px)] - (int)mem_y[(yy * 4 + y_s) * 4 * Width + xx * 4 + x_s]);
			float mad_u = fabs((int)org->mem_u[(yy + py) * Width + (xx + px)] - (int)mem_u[(yy * 4 + y_s) * 4 * Width + xx * 4 + x_s]);
			float mad_v = fabs((int)org->mem_v[(yy + py) * Width + (xx + px)] - (int)mem_v[(yy * 4 + y_s) * 4 * Width + xx * 4 + x_s]);
			if (mad_y < 8) back.p_y.MPC++;
			if (mad_u < 8) back.p_u.MPC++;
			if (mad_v < 8) back.p_v.MPC++;
			back.p_y.MAD += mad_y;
			back.p_u.MAD += mad_u;
			back.p_v.MAD += mad_v;
			int mse_y = (int)org->mem_y[(yy + py) * Width + (xx + px)] - (int)mem_y[(yy * 4 + y_s) * 4 * Width + xx * 4 + x_s];
			int mse_u = (int)org->mem_u[(yy + py) * Width + (xx + px)] - (int)mem_u[(yy * 4 + y_s) * 4 * Width + xx * 4 + x_s];
			int mse_v = (int)org->mem_v[(yy + py) * Width + (xx + px)] - (int)mem_v[(yy * 4 + y_s) * 4 * Width + xx * 4 + x_s];
			back.p_y.MSE += mse_y * mse_y;
			back.p_u.MSE += mse_u * mse_u;
			back.p_v.MSE += mse_v * mse_v;
		}
	}
	back.p_y.MSE /= BLOCK_SIZE_SQ;
	back.p_u.MSE /= BLOCK_SIZE_SQ;
	back.p_v.MSE /= BLOCK_SIZE_SQ;
	back.p_y.MAD /= BLOCK_SIZE_SQ;
	back.p_u.MAD /= BLOCK_SIZE_SQ;
	back.p_v.MAD /= BLOCK_SIZE_SQ;
	back.x = x_s;
	back.y = y_s;
	return back;
}
