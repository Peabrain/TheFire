#include "oframe.h"
#include "exoquant.h"

OFRAME::OFRAME(std::string _in, std::string _out)
	:FRAME(_in, _out)
{

}
OFRAME::~OFRAME()
{

}
void OFRAME::convert()
{
	process(tmp + 54, Width, Height);
	free(tmp);
	tmp = 0;
}
void OFRAME::process(unsigned char *mem, int w, int h)
{
	unsigned int *blockCodeVert = 0;
	//	unsigned int *blockCodeHori = 0;
	int colorIndexTab[0x1000];
	LUM *lumlist = new LUM[Width * Height];
	int g_tab[64];
	stats = 0;
	blockCodeVert = (unsigned int*)malloc(sizeof(unsigned int) * Width * 3 * (Height - (CT_DIM - 1)));
	//	blockCodeHori = (unsigned int*)malloc(sizeof(unsigned int) * Width / CT_DIM * Height);
	unsigned char *mem_tmp = (unsigned char *)malloc(Width * Height * 3);

	//	for (int i = 0; i < Width * Height * 3; i++) mem[i] = mem[i] >> 4;

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
	numOfColors = prepareIndexBuffer(lumlist, g_tab, w, h, mem);

	int aktsetX = 0;
	int ra = 0;
	int ga = 0;
	int ba = 0;
	for (int y = 0; y < h; y++)
	{
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

			int rd = abs(ra - r) * 3;// +50 + 25);
			int gd = abs(ga - g) * 6;// -150);
			int bd = abs(ba - b) * 1;// +50 + 25);

			int ga_ = ga;
			int ba_ = ba;
			int ra_ = ra;

			if (gd >= rd)
			{
				if (gd >= bd)
				{
					ga = g;
					code = 3;
				}
				else
				{
					ba = b;
					code = 1;
				}
			}
			else
			{
				if (rd >= bd)
				{
					ra = r;
					code = 2;
				}
				else
				{
					ba = b;
					code = 1;
				}
			}

			if (aktsetX < numOfColors && lumlist[aktsetX].x == x && lumlist[aktsetX].y == y)
			{
				int rd = abs(ra - r) * 3;// +50 + 25);
				int gd = abs(ga - g) * 6;// -150);
				int bd = abs(ba - b) * 1;// +50 + 25);
				float lum0 = 3 * (float)rd + 6 * (float)gd + 1 * (float)bd;

				int a_ = g_tab[lumlist[aktsetX].index];

				rd = abs(a_ - r) * 3;// +50 + 25);
				gd = abs(a_ - g) * 6;// -150);
				bd = abs(a_ - b) * 1;// +50 + 25);

				float lum1 = 3 * (float)rd + 6 * (float)gd + 1 * (float)bd;
				if (lum0 >= lum1)
				{
					ra = a_;
					ga = a_;
					ba = a_;
					code = 0;
					b = lumlist[aktsetX].index;
				}
				aktsetX++;
			}

			switch (code)
			{
			case 0:
			{
				changeColor(b, x, y);
			}break;
			case 1:
			{
				changeColor((b >> 2) | 0x40, x, y);
			}break;
			case 2:
			{
				changeColor((r >> 2) | 0x80, x, y);
			}break;
			case 3:
			{
				changeColor((g >> 2) | 0xc0, x, y);
			}break;
			}
			/**/
		}
	}
	if (lumlist) delete[] lumlist;
	free(mem_tmp);
	free(blockCodeVert);
	//	free(blockCodeHori);
}
void OFRAME::changeColor(int c, int x, int y)
{
	chunky[y * Width + x] = c;
}

int OFRAME::prepareIndexBuffer(LUM *lumlist, int *g_tab, int w, int h, unsigned char *mem)
{
	int ra = 0;
	int ga = 0;
	int ba = 0;
	int cop = 0;
	int numOfColors = 0;
	memset(lumlist, 0, sizeof(LUM) * Width * Height);
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

	unsigned char *tmprgb_buffer = new unsigned char[Height * Width * 4];
	unsigned char *indexbuffer = new unsigned char[Height * Width * 4];
	int			  *lumlist_idx = new int[Height * Width * 4];
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
	exq_no_transparency(pExq);
	exq_feed(pExq, tmprgb_buffer, numOfColors);
	RGB pPalette[64];
	for (int i = 0; i < 64; i++)
	{
		pPalette[i].r = (i << 2);
		pPalette[i].g = (i << 2);
		pPalette[i].b = (i << 2);
		g_tab[i] = pPalette[i].r;
	}
	exq_set_palette(pExq, (unsigned char*)pPalette, 64);

	exq_map_image(pExq, numOfColors, tmprgb_buffer, indexbuffer);

	int lsIndex = -1;
	int lsY = -1;
	int gg = 0;
	for (int i = 0; i < numOfColors; i++)
	{
		int nIndex = indexbuffer[i];
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

	exq_free(pExq);
	delete[]tmprgb_buffer;
	delete[]indexbuffer;
	delete[]lumlist_idx;

	return numOfColors;
}
