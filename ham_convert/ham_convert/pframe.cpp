#include "pframe.h"

PFRAME::PFRAME(std::string _in, std::string _out)
	:FRAME(_in, _out)
{

}
PFRAME::~PFRAME()
{

}
void PFRAME::convert()
{
	process(tmp + 54, Width, Height);
	free(tmp);
	tmp = 0;
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
			int value = (0.299 * (float)r + 0.587 * (float)g + 0.114 * (float)b);
			chunky[y * w + x] = value >> 2;
		}
	}
}
