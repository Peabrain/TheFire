#ifndef __IFRAME_H
#define __IFRAME_H
#include "frame.h"

class IFRAME : public FRAME
{
public:
	IFRAME(std::string _in, std::string _out);
	virtual ~IFRAME();

	void convert();
	MOVEPRE movepre(int x,int y,YUV_BUFFER *org);

	YUV_BUFFER ** getBuffers() {	return yuv_buffer;};
private:
	void process(unsigned  char *mem, int w, int h);
	void createSubpixel();

	YUV_BUFFER *yuv_buffer[16];
};
#endif

