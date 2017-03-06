#include <iostream>
#include "frame.h"

FRAME::FRAME(std::string _in, std::string _out)
{
	this->_in = _in;
	this->_out = _out;
	success = false;
	chunky = 0;
	tmp = 0;

	if (FILE *f = fopen(_in.c_str(), "rb"))
	{
		fseek(f, 0L, SEEK_END);
		int sz = ftell(f);
		fseek(f, 0L, SEEK_SET);

		tmp = (unsigned char*)malloc(sz);
		chunky = (unsigned char*)malloc(Width * Height);

		fread(tmp, sz, 1, f);

		fclose(f);
		success = true;
	}
	else
		printf("cannot find file %s\n", _in.c_str());

}
FRAME::~FRAME()
{
	if(chunky) free(chunky);
	if (tmp) free(tmp);
}

