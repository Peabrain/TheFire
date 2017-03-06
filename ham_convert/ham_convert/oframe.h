#ifndef __OFRAME_H
#define __OFRAME_H
#include "frame.h"

class OFRAME: public FRAME
{
public:
	OFRAME(std::string _in, std::string _out);
	virtual ~OFRAME();

	void convert();
private:
	void process(unsigned  char *mem, int w, int h);

	void changeColor(int c, int x, int y);
	int prepareIndexBuffer(LUM *lumlist, int *g_tab, int w, int h, unsigned char *mem);
};

#endif

