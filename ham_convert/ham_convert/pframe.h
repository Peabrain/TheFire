#ifndef __PFRAME_H
#define __PFRAME_H
#include "frame.h"
#include "iframe.h"

class PFRAME : public FRAME
{
public:
	PFRAME(std::string _in, std::string _out);
	virtual ~PFRAME();

	void convert();
	int convert(IFRAME *iframe);
private:
	void process(unsigned  char *mem, int w, int h);

	YUV_BUFFER *yuv_buffer;
};
#endif

