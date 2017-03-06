#ifndef __YUV_BUFFER_H
#define __YUV_BUFFER_H
#include <iostream>
#include "defines.h"

class MOVEPRE
{
public:
	int no_err;
	int x, y;
};

class YUV_BUFFER
{
public:
	YUV_BUFFER()
	{
		mem_y = 0;
		mem_u = 0;
		mem_v = 0;
	}
	YUV_BUFFER(int w, int h)
	{
		mem_y = (unsigned char *)malloc(w * h);
		mem_u = (unsigned char *)malloc(w * h);
		mem_v = (unsigned char *)malloc(w * h);
	}
	virtual ~YUV_BUFFER()
	{
		if (mem_y) free(mem_y);
		if (mem_u) free(mem_u);
		if (mem_v) free(mem_v);
	}
	MOVEPRE movepre(int x,int y,YUV_BUFFER *org);
	unsigned char *mem_y;
	unsigned char *mem_u;
	unsigned char *mem_v;
};

#endif

