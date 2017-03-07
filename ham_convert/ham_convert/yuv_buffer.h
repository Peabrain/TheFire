#ifndef __YUV_BUFFER_H
#define __YUV_BUFFER_H
#include <iostream>
#include "defines.h"

class PRE_PARA
{
public:
	PRE_PARA()
	{
		init();
	}
	float MSE; //mean of squarred error
	float MAD; //mean of ablotute difference
	int MPC; //matching pixel count
	void init()
	{
		MSE = 16000000000;
		MAD = 16000000000;
		MPC = 0;
	}
};
class MOVEPRE
{
public:
	PRE_PARA p_y;
	PRE_PARA p_u;
	PRE_PARA p_v;
	int x, y;

	MOVEPRE()
	{
		p_y.init();
		p_u.init();
		p_v.init();
		x = 0;
		y = 0;
	}
	float getValue()
	{
		return (p_u.MAD + p_v.MAD) / (float)(p_u.MPC + p_v.MPC);
	};
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
private:
	MOVEPRE YUV_BUFFER::checkpos(int x, int y, int x_s, int y_s, YUV_BUFFER *org);
};

#endif

