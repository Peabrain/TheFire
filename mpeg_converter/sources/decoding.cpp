/*
 * Copyright (c) 2012 Stefano Sabatini
 * Copyright (c) 2014 Clément Bœsch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
*/
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <list>

extern "C"
{
#include <inttypes.h>
#include <libavutil/motion_vector.h>
#include <libavutil/avutil.h>
#include <libavformat/avformat.h>
#include <libavutil/avconfig.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
}
static AVFormatContext *fmt_ctx = NULL;
static AVCodecContext *video_dec_ctx = NULL;
static AVStream *video_stream = NULL;
static const char *src_filename = NULL;
static AVFrame *Frame = 0;
static int video_stream_idx = -1;
//static AVFrame *frame = NULL;
static AVPacket pkt;
static int video_frame_count = 0;
class SRC
{
public:
	uint8_t *data[3];
	int stride[3];
};
//SRC Src[100];
int maxframes = 1000;

/*class VECTOR
{
public:
	VECTOR()
	{
		init();
	}
	void init()
	{
		x = 0;
		y = 0;
		frameindexSrc = 0;
		frameindexDst = 0;
		active = false;
	}
	float x, y;
	int frameindexSrc;
	int frameindexDst;
	bool active;
};
*/
//std::list<VECTOR> vectors[320 / 8][192 / 8];

class FRAME;

std::map<int, void*> FrameList;

int bytes = 0;

class BLOCK
{
public:
	BLOCK(int w,int h,unsigned short *mem,unsigned short mov)
	{
		blockPck = 0;
		block = new unsigned short[w * h];
		memcpy(block,mem,sizeof(unsigned short) * w * h);
		movement = mov;
	}
	virtual ~BLOCK()
	{
		delete[] block;
		if (blockPck) free(blockPck);
	}


	void compress()
	{
		unsigned short *mem = block;
		std::list<unsigned short> pp;
		std::map<unsigned short, int> valueToMap;
		std::map<int, unsigned short> mapToValue;

		valueToMap.clear();
		mapToValue.clear();
		for (int j = 0; j < 16 * 16; j++)
		{
			unsigned short c = mem[j];
			if (valueToMap.find(c) == valueToMap.end())
			{
				mapToValue[valueToMap.size()] = c;
				valueToMap[c] = valueToMap.size();
			}
		}
		int zs = valueToMap.size();
		if (zs == 1)
		{
			pp.push_back(0);
			pp.push_back(mem[0]);
		}
		else
		if (zs > 16)
		{
			pp.push_back(1);
			for (int j = 0; j < 16 * 16; j++)
			{
				unsigned short c = mem[j];
				pp.push_back(c);
			}
		}
		else
		if (zs > 4)
		{
			pp.push_back(2 | (zs - 1) << 4);
			for (int m = 0; m < zs; m++)
			{
				pp.push_back(mapToValue[m]);
			}
			for (int m = zs; m < 16; m++)
			{
				pp.push_back(0);
			}
			for (int j = 0; j < 16 * 16 / 8; j++)
			{
				unsigned long hh = 0;
				for (int b = 0; b < 8; b++)
				{
					unsigned short c = mem[j * 8 + b];
					std::map<unsigned short, int>::iterator it = valueToMap.find(c);
					unsigned short n = it->second;
					//						printf("%i,",n);
					hh |= n << (4 * b);
				}
				pp.push_back(hh >> 16);
				pp.push_back(hh & 0xffff);
			}
			//				printf("\n");
			/**/
			/*				unsigned short c = mem[0 + i * 16 * 16 + offset];
			std::map<unsigned short, int>::iterator it = valueToMap.find(c);
			unsigned short nLast = it->second;
			int counter = 0;
			unsigned char pckList[256];
			for (int j = 1; j < 16 * 16; j++)
			{
			unsigned short c = mem[j + i * 16 * 16 + offset];
			std::map<unsigned short, int>::iterator it = valueToMap.find(c);
			unsigned short n = it->second;
			if ((nLast % 16) != n)
			{
			pckList[counter++] = nLast;
			nLast = n;
			}
			else
			{
			if((nLast >> 4) != 0xf)
			nLast += 0x10;
			else
			{
			pckList[counter++] = nLast;
			nLast &= 0xf;
			}
			}
			}
			pckList[counter++] = nLast;
			if (counter & 1)
			pckList[counter++] = 0;
			for (int i = 0; i < counter; i++)
			{
			//					printf("%2.2x,",pckList[i]);
			}
			for (int i = 0; i < counter / 2; i++)
			{
			unsigned short pck = pckList[i * 2] | (pckList[i * 2 + 1] << 8);
			pp.push_back(pck);
			}
			/**/
		}
		else
			//			if (zs > 4)
		{
			pp.push_back(3);
			for (int m = 0; m < zs; m++)
			{
				pp.push_back(mapToValue[m]);
			}
			for (int m = zs; m < 4; m++)
			{
				pp.push_back(0);
			}
			for (int j = 0; j < 16 * 16 / 16; j++)
			{
				unsigned long hh = 0;
				for (int b = 0; b < 16; b++)
				{
					unsigned short c = mem[j * 16 + b];
					std::map<unsigned short, int>::iterator it = valueToMap.find(c);
					unsigned short n = it->second;
					hh |= n << (2 * b);
				}
				pp.push_back(hh >> 16);
				pp.push_back(hh & 0xffff);
			}
		}
/**/
		newlen = pp.size();
		blockPck = (unsigned short *)malloc(sizeof(unsigned short) * (pp.size()));
		int i = 0;
		while (!pp.empty())
		{
			unsigned short a = *pp.begin();
			pp.pop_front();
			blockPck[i++] = a;
		}
	}

	unsigned short	movement;
	unsigned int	newlen;
	unsigned short	*blockPck;
	unsigned short	*block;
};

class FRAME
{
public:
	FRAME(AVFrame *f,int num)
	{
		YUV_Buf = 0;
//		YUV_Buf_diff = 0;
		frame = av_frame_clone(f);

		data.stride[0] = frame->width;
		data.stride[1] = frame->width;
		data.stride[2] = frame->width;
		data.data[0] = (uint8_t*)malloc(frame->width * frame->height * sizeof(uint8_t));
		data.data[1] = (uint8_t*)malloc(frame->width * frame->height * sizeof(uint8_t));
		data.data[2] = (uint8_t*)malloc(frame->width * frame->height * sizeof(uint8_t));

		SwsContext * ctx = sws_getContext(frame->width, frame->height,
			(AVPixelFormat)frame->format, frame->width, frame->height,
			AV_PIX_FMT_YUV444P, 0, 0, 0, 0);
		int inLinesize[3] = { frame->width,frame->width,frame->width }; // RGB stride
		sws_scale(ctx, frame->data, frame->linesize, 0, frame->height, data.data, data.stride);

		sd = av_frame_get_side_data(frame, AV_FRAME_DATA_MOTION_VECTORS);
		this->num = num;
	}
	virtual ~FRAME()
	{
//		if (YUV_Buf_diff) free(YUV_Buf_diff);
		for (int i = 0; i < BlockMap.size(); i++)
		{
			delete BlockMap[i];
		}
		BlockMap.clear();
		if (YUV_Buf) free(YUV_Buf);
		if(frame) av_frame_free(&frame);
		if (data.data[0]) free(data.data[0]);
		if (data.data[1]) free(data.data[1]);
		if (data.data[2]) free(data.data[2]);
	}
	void save()
	{
		FILE *pFile;

		char fname[256];
		sprintf(fname, "tmp%3.3i.ppm", num);
		pFile = fopen(fname, "wb");
		if (pFile == NULL)
			return;

		unsigned int header = 0;
		unsigned int length = 0;

		for (int i = 0; i < BlockMap.size(); i++)
		{
			BlockMap[i]->compress();
			length += BlockMap[i]->newlen;
			if (sd)
				length++;
		}

		if (!sd)
		{
			header = _byteswap_ulong(0);
			fwrite(&header, 1, sizeof(header), pFile);
			unsigned int z = _byteswap_ulong(length);
			fwrite(&z, 1, sizeof(length), pFile);
		}
		else
		{
			header = _byteswap_ulong(1);
			fwrite(&header, 1, sizeof(header), pFile);
			unsigned int z = _byteswap_ulong(length);
			fwrite(&z, 1, sizeof(length), pFile);
		}

		unsigned short *mm = new unsigned short[length];
		int m = 0;
		if (sd)
		{
			for (int i = 0; i < frame->height / 16; i++)
			{
				for (int j = 0; j < frame->width / 16; j++)
				{
					BLOCK *block = 0;
					if (BlockMap.find(i * frame->width / 16 + j) != BlockMap.end())
						block = BlockMap.find(i * frame->width / 16 + j)->second;
					mm[m++] = _byteswap_ushort(block->movement);
				}
			}
		}
		for (int i = 0; i < frame->height / 16; i++)
		{
			for (int j = 0; j < frame->width / 16; j++)
			{
				BLOCK *block = 0;
				if (BlockMap.find(i * frame->width / 16 + j) != BlockMap.end())
					block = BlockMap.find(i * frame->width / 16 + j)->second;
				for (int k = 0; k < block->newlen; k++)
					mm[m++] = _byteswap_ushort(block->blockPck[k]);
			}
		}

		fwrite(mm, 1, sizeof(unsigned short) * length, pFile);

//		for(int i = 0;i < length;i++) newmem[i] = _byteswap_ushort(newmem[i]);
//		fwrite(newmem, 1, sizeof(unsigned short) * length, pFile);
//		free(mm);
		// Write header
	//	fprintf(pFile, "P6\n%d %d\n255\n", frame->width, frame->height);

		// Write pixel data
		// for (int y = 0; y < frame->height; y++)	fwrite(data.data[0] + y * data.stride[0], 1, data.stride[0], pFile);

		// Close file
		fclose(pFile);
	}
	void copyToBlocks()
	{
		YUV_Buf = (unsigned short*)malloc(sizeof(unsigned short) * (frame->width * frame->height));
		memset(YUV_Buf, 0, sizeof(unsigned short) * (frame->width * frame->height));

		unsigned char *bufY = data.data[0];
		unsigned char *bufU = data.data[1];
		unsigned char *bufV = data.data[2];
		for (int y = 0; y < frame->height; y++)
		{
			for (int x = 0; x < frame->width; x++)
			{
				int y_ = bufY[y * data.stride[0] + x];
				int u_ = bufU[y * data.stride[0] + x];
				int v_ = bufV[y * data.stride[0] + x];
				unsigned short u = ((y_ >> 3) << 10) | ((u_ >> 3) << 5) | (v_ >> 3);
				YUV_Buf[x + y * frame->width] = u;
			}
		}

		for (int y = 0; y < frame->height / 16; y++)
		{
			for (int x = 0; x < frame->width / 16; x++)
			{
				unsigned short bl[16 * 16];
				for (int i = 0; i < 16; i++)
				{
					for (int j = 0; j < 16; j++)
					{
						bl[i * 16 + j] = YUV_Buf[(x * 16 + j) + (y * 16 + i) * frame->width];
					}
				}
				BLOCK *myblock = new BLOCK(16, 16, bl, 0xffff);
				BlockMap.insert(std::pair<unsigned short,BLOCK*>(y * frame->width / 16 + x,myblock));
			}
		}
	}
	void process()
	{
		printf("Frame: %i\n",num);

		copyToBlocks();

		if (sd)
		{
/*			if (frame->pict_type == AV_PICTURE_TYPE_P)
				printf("P-frame: %i\n", video_frame_count);
			else
				if (frame->pict_type == AV_PICTURE_TYPE_B)
					printf("B-frame: %i\n", video_frame_count);
*/
//			YUV_Buf_diff = (unsigned short*)malloc(sizeof(unsigned short) * (frame->width * frame->height + frame->width / 16 * frame->height / 16));
//			memset(YUV_Buf_diff, 0, sizeof(unsigned short) * (frame->width * frame->height + frame->width / 16 * frame->height / 16));
//			memcpy(YUV_Buf_diff, YUV_Buf, sizeof(unsigned short) * frame->width * frame->height);
			const AVMotionVector *mvs = (const AVMotionVector *)sd->data;
/*			for (int i = 0; i < frame->height / 16; i++)
			{
				for (int j = 0; j < frame->width / 16; j++)
				{
					YUV_Buf_diff[frame->width * frame->height + frame->width / 16 * i + j] = 0xffff;
				}
			}
*/			int gcount = 0;
			for (int i = 0; i < sd->size / sizeof(*mvs); i++)
			{
				const AVMotionVector *mv = &mvs[i];
				if (mv->source >= 0)
					continue;

/*				VECTOR v;
				v.init();
				v.frameindexDst = num;
				v.frameindexSrc = num - 1;// +mv->source;
				v.x = mv->src_x - mv->dst_x;
				v.y = mv->src_y - mv->dst_y;
*/
				FRAME *fr = (FRAME*)FrameList[num - 1];

				int blPos = (mv->dst_y - mv->h / 2) / 16 *frame->width / 16 + (mv->dst_x - mv->w / 2) / 16;
				BLOCK *block = 0;
				if (BlockMap.find(blPos) != BlockMap.end())
					block = BlockMap.find(blPos)->second;

				unsigned short z = (mv->src_y - mv->h / 2) * frame->width + (mv->src_x - mv->w / 2);
				block->movement = z;
//				YUV_Buf_diff[frame->width * frame->height + frame->width / 16 * (mv->dst_y - mv->h / 2) / 16 + (mv->dst_x - mv->w / 2) / 16] = z;
				for (int i = -mv->h / 2; i < mv->h / 2; i++)
				{
					for (int j = -mv->w / 2; j < mv->w / 2; j++)
					{
						if (mv->dst_y + i >= 0 && mv->dst_y + i < frame->height && mv->dst_x + j >= 0 && mv->dst_x + j < frame->width &&
							mv->src_y + i >= 0 && mv->src_y + i < frame->height && mv->src_x + j >= 0 && mv->src_x + j < frame->width)
						{
//							unsigned short a = YUV_Buf[(mv->dst_y + i) * frame->width + (mv->dst_x + j)];
							unsigned short a = block->block[(i + mv->h / 2) * 16 + j + mv->w / 2];// YUV_Buf[(mv->dst_y + i) * frame->width + (mv->dst_x + j)];
							unsigned short b = fr->YUV_Buf[(mv->src_y + i) * frame->width + (mv->src_x + j)];
							unsigned short y_diff = abs(((a >> 10) & 31) - ((b >> 10) & 31));
							unsigned short u_diff = abs(((a >> 5) & 31) - ((b >> 5) & 31));
							unsigned short v_diff = abs(((a >> 0) & 31) - ((b >> 0) & 31));
							unsigned short c = a - b;
/*							if (y_diff == 0 && (u_diff * u_diff + v_diff * v_diff) <= 2)
							{
								YUV_Buf[(mv->dst_y + i) * frame->width + (mv->dst_x + j)] = b;
								YUV_Buf_diff[(mv->dst_y + i) * frame->width + (mv->dst_x + j)] = 0;
							}
							else
*/							{
								c &= 0x7fff;
	//							YUV_Buf_diff[(mv->dst_y + i) * frame->width + (mv->dst_x + j)] = c;
								block->block[(i + mv->h / 2) * 16 + j + mv->w / 2] = c;
							}
						}
					}
				}
			}
		}
	}
	AVFrame *frame;
//	unsigned short *YUV_Buf_diff;
	int got_frame;
	SRC data;
	int ret;
	AVFrameSideData *sd;
	int num;
	std::map<unsigned short, BLOCK*> BlockMap;
protected:
	unsigned short *YUV_Buf;
};

static int decode_packet(int *got_frame, int cached)
{
	int decoded = pkt.size;
	*got_frame = 0;

	if (pkt.stream_index == video_stream_idx) 
	{
		int ret = avcodec_decode_video2(video_dec_ctx, Frame, got_frame, &pkt);
		if (ret < 0)
		{
//			fprintf(stderr, "Error decoding video frame (%s)\n", av_err2str(ret));
			return ret;
		}
		if (*got_frame) 
		{
			FRAME *fr = new FRAME(Frame, video_frame_count);
			int ret = fr->ret;
			int i;
			AVFrameSideData *sd;

/*			sd = av_frame_get_side_data(frame, AV_FRAME_DATA_MOTION_VECTORS);
			if (sd) 
			{
				if(frame->pict_type == AV_PICTURE_TYPE_P)
					printf("P-frame: %i\n", video_frame_count);
				else
					if (frame->pict_type == AV_PICTURE_TYPE_B)
						printf("B-frame: %i\n", video_frame_count);

				Src[video_frame_count].data[0] = (uint8_t*)malloc(frame->width * 3 * frame->height * sizeof(uint8_t));
				uint8_t *dst = Src[video_frame_count].data[0];
				memset(dst, 0x80, frame->width * 3 * frame->height * sizeof(uint8_t));
				const AVMotionVector *mvs = (const AVMotionVector *)sd->data;
#define A 16
				for (i = 0; i < sd->size / sizeof(*mvs); i++) 
				{
					const AVMotionVector *mv = &mvs[i];
					if (mv->source >= 0) 
						continue;

					if (mv->dst_y == 72)
						printf("");

					vectors[mv->dst_x / 8][mv->dst_y / 8].x += (float)mv->motion_x / (float)mv->motion_scale;
					vectors[mv->dst_x / 8][mv->dst_y / 8].y += (float)mv->motion_y / (float)mv->motion_scale;
					vectors[mv->dst_x / 8][mv->dst_y / 8].frameindex -= mv->source;
					int src_x = mv->dst_x + vectors[mv->dst_x / 8][mv->dst_y / 8].x;
					int src_y = mv->dst_y + vectors[mv->dst_x / 8][mv->dst_y / 8].y;
					int src_frame = video_frame_count - vectors[mv->dst_x / 8][mv->dst_y / 8].frameindex;
					if (src_frame == 0)
					{
						uint8_t *srcp = Src[src_frame].data[0];
						if (mv->dst_y >= 0 && mv->dst_y + mv->h < frame->height && mv->dst_x >= 0 && mv->dst_x + mv->w < frame->width)
						for (int i = 0; i < mv->h; i++)
						{
							for (int j = 0; j < mv->w; j++)
							{
								if (mv->dst_y + i >= 0 && mv->dst_y + i < frame->height && mv->dst_x + j >= 0 && mv->dst_x + j < frame->width &&
									src_y + i >= 0 && src_y + i < frame->height && src_x + j >= 0 && src_x + j < frame->width)
								{
									dst[((mv->dst_y + i) * frame->width + (mv->dst_x + j)) * 3] = srcp[((src_y + i) * frame->width + (src_x + j)) * 3];
									dst[((mv->dst_y + i) * frame->width + (mv->dst_x + j)) * 3 + 1] = srcp[((src_y + i) * frame->width + (src_x + j)) * 3 + 1];
									dst[((mv->dst_y + i) * frame->width + (mv->dst_x + j)) * 3 + 2] = srcp[((src_y + i) * frame->width + (src_x + j)) * 3 + 2];
								}
							}
						}
					}
//					printf("%d,%2d,%2d,%2d,%4d,%4d,%4d,%4d,0x%" PRIx64 "\n",
//					video_frame_count, mv->source,
//					mv->w, mv->h, mv->src_x, mv->src_y,
//					mv->dst_x, mv->dst_y, mv->flags);
					printf("%d,%2d,%4d,%4d,%4d,%4d,%4d,%4d\n", video_frame_count, src_frame,src_x,src_y,mv->dst_x,mv->dst_y, mv->motion_x / mv->motion_scale, mv->motion_y / mv->motion_scale);

				}

//				char fname[256];
//				sprintf(fname, "tmp%3.3i_p.ppm", video_frame_count);
//				writePic(fname, dst, frame->width, frame->height, frame->width * 3);
//			}
//			else
//			{
//				printf("I-frame: %i\n", video_frame_count);
//				char fname[256];
//				sprintf(fname, "tmp%3.3i_i.ppm", video_frame_count);
//				pgm_save(frame, fname,video_frame_count);
//			}
*/
			video_frame_count++;
			if ((!fr->sd && !FrameList.empty()) || video_frame_count >= maxframes)
			{
				printf("");
				for (std::map<int,void*>::iterator it = FrameList.begin(); it != FrameList.end(); it++)
				{
					FRAME *f = (FRAME*)it->second;
					f->process();
					f->save();
				}
				if (!fr->sd)
				{
					for (std::map<int, void*>::iterator it = FrameList.begin(); it != FrameList.end(); it++)
					{
						FRAME *f = (FRAME*)it->second;
//						f->save();
						delete f;
					}
					FrameList.clear();
				}
				FrameList[video_frame_count - 1] = fr;
			}
			else
				FrameList[video_frame_count - 1] = fr;

			if (video_frame_count >= maxframes)
				return decoded;
		}
	}
	return decoded;
}
static int open_codec_context(int *stream_idx,AVFormatContext *fmt_ctx, enum AVMediaType type)
{
	int ret;
	AVStream *st;
	AVCodecContext *dec_ctx = NULL;
	AVCodec *dec = NULL;
	AVDictionary *opts = NULL;

	ret = av_find_best_stream(fmt_ctx, type, -1, -1, NULL, 0);
	if (ret < 0) 
	{
		fprintf(stderr, "Could not find %s stream in input file '%s'\n",
				av_get_media_type_string(type), src_filename);
		return ret;
	}
	else 
	{
		*stream_idx = ret;
        st = fmt_ctx->streams[*stream_idx];

        /* find decoder for the stream */
        dec_ctx = st->codec;
        dec = avcodec_find_decoder(dec_ctx->codec_id);
        if (!dec) 
		{
            fprintf(stderr, "Failed to find %s codec\n",
                    av_get_media_type_string(type));
            return AVERROR(EINVAL);
		}

		/* Init the video decoder */
		av_dict_set(&opts, "flags2", "+export_mvs", 0);
		if ((ret = avcodec_open2(dec_ctx, dec, &opts)) < 0) 
		{
			fprintf(stderr, "Failed to open %s codec\n",
					av_get_media_type_string(type));
			return ret;
		}
	}
	return 0;
 }

int main(int argc, char **argv)
{
	int ret = 0, got_frame;

/*	if (argc != 2) 
	{
		fprintf(stderr, "Usage: %s <video>\n", argv[0]);
		exit(1);
	}
*/
	src_filename = "tmp.mpeg";// argv[1];

	av_register_all();

	if (avformat_open_input(&fmt_ctx, src_filename, NULL, NULL) < 0) 
	{
		fprintf(stderr, "Could not open source file %s\n", src_filename);
		exit(1);
	}

	if (avformat_find_stream_info(fmt_ctx, NULL) < 0) 
	{
		fprintf(stderr, "Could not find stream information\n");
		exit(1);
	}

	if (open_codec_context(&video_stream_idx, fmt_ctx, AVMEDIA_TYPE_VIDEO) >= 0) 
	{
		video_stream = fmt_ctx->streams[video_stream_idx];
		video_dec_ctx = video_stream->codec;
	}

	av_dump_format(fmt_ctx, 0, src_filename, 0);

	if (!video_stream) 
	{
		fprintf(stderr, "Could not find video stream in the input, aborting\n");
		ret = 1;
		goto end;
	}

	printf("framenum,source,blockw,blockh,srcx,srcy,dstx,dsty,flags\n");

	Frame = av_frame_alloc();

	/* initialize packet, set data to NULL, let the demuxer fill it */
	av_init_packet(&pkt);
	pkt.data = NULL;
	pkt.size = 0;

	/* read frames from the file */
	while (av_read_frame(fmt_ctx, &pkt) >= 0) 
	{
		AVPacket orig_pkt = pkt;
		do 
		{
			ret = decode_packet(&got_frame, 0);
			if (video_frame_count >= maxframes) break;
			if (ret < 0)
				break;
			pkt.data += ret;
			pkt.size -= ret;
		} 
		while (pkt.size > 0);
		av_free_packet(&orig_pkt);
		if (video_frame_count >= maxframes) break;
	}

	/* flush cached frames */
	pkt.data = NULL;
	pkt.size = 0;
	do 
	{
		decode_packet(&got_frame, 1);
		if (video_frame_count >= maxframes) break;
	}
	while (got_frame);

	end:
	avcodec_close(video_dec_ctx);
	avformat_close_input(&fmt_ctx);
	av_frame_free(&Frame);

	printf("%i\n", bytes);
	return ret < 0;
}
