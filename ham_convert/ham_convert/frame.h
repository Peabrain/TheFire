#ifndef __FRAME_H
#define __FRAME_H
#include "defines.h"

class FRAME
{
public:
	FRAME(std::string _in, std::string _out);
	virtual ~FRAME();

	bool successful() { return success; };
	void *getMem() { return chunky; };
	virtual void convert() = 0;

private:
	virtual void process(unsigned  char *mem, int w, int h) = 0;
protected:
	std::string _in;
	std::string _out;
	unsigned char *chunky;
	int stats;
	bool success;

	unsigned char *tmp;
};

#endif

