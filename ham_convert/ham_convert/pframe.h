#ifndef __PFRAME_H
#define __PFRAME_H
#include "frame.h"

class PFRAME : public FRAME
{
public:
	PFRAME(std::string _in, std::string _out);
	virtual ~PFRAME();

	void convert();
private:
	void process(unsigned  char *mem, int w, int h);
};
#endif

