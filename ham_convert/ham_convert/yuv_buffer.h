#ifndef __YUV_BUFFER_H
#define __YUV_BUFFER_H
#include <iostream>
#include <algorithm>
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
//#define MOVEPRE_COM_UV
#define MOVEPRE_COM_YUV
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
//		if (p_u.MPC + p_v.MPC == 0) return 1.0;
//		return (p_u.MAD + p_v.MAD) / (float)(p_u.MPC + p_v.MPC);
//		return (p_u.MAD) / (float)(p_u.MPC);
//		return (p_u.MAD + p_v.MAD + p_y.MAD) / (float)(p_u.MPC + p_v.MPC + p_y.MPC);
#if defined(MOVEPRE_COM_UV)
		return (p_u.MAD + p_v.MAD) / 2.0 / (float)getMPC();
#elif defined(MOVEPRE_COM_YUV)
		return (p_y.MSE * 0.58 + p_u.MSE * 0.3 + p_v.MSE * 0.12);
#endif
//		return (p_y.MAD + p_u.MAD + p_v.MAD) / 3.0;
	};
	int getMPC()
	{
#if defined(MOVEPRE_COM_UV)
		int min = std::min(p_u.MPC, p_v.MPC);
#elif  defined(MOVEPRE_COM_YUV)
		int min = std::min(p_u.MPC, p_v.MPC); 
		min = std::min(p_y.MPC, p_v.MPC);
#endif
		return min;
	}
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

