/*
__reg("a3") const char* GetScrollText(__reg("d4") short pageIndex)
{
	switch (pageIndex)
	{
		case 0:
		{
			return "This is\njust\na test\nof";
		}
		case 1:
		{
			return "Variable\nwidth\nfonts\nand\nsprites";
		}
		case 2:
		{
			return "copper\nbars\nand half\nbrite\nimages";
		}
		case 3:
		{
			return "plus\nvarious\nmusic\nplayers";
		}
		case 4:
		{
			return "Lots of\nreused\nassets!\nSorry!";
		}
		case 5:
		{
			return "Now Make\nYour Own\nStuff!";
		}
	}
	return "The\nEnd";
}
*/
char *rot(int ys,char *memory)
{
	if(ys < 8)
	{
		if(ys > 0) 
		{
/*			fprintf(f,"\tlsr.l #%i,d4\n",ys);*/
			*((unsigned short*)memory) = 0xe08c | ((ys&7) << 9);memory += 2;
		}
	}
	else
	if(ys < 16)
	{
/*		fprintf(f,"\tswap d4\n");*/
		*((unsigned short*)memory) = 0x4844;memory += 2;
		if(-(ys-16) > 0) 
		{
/*			fprintf(f,"\trol.l #%i,d4\n",-(ys-16)*/
			*((unsigned short*)memory) = 0xe19c | (((-(ys-16))&7) << 9);memory += 2;
		}
	}
	else
	if(ys < 24)
	{
/*		fprintf(f,"\tswap d4\n");*/
		*((unsigned short*)memory) = 0x4844;memory += 2;
		if(ys-16 > 0) 
		{
/*			fprintf(f,"\tlsr.l #%i,d4\n",ys-16);*/
			*((unsigned short*)memory) = 0xe08c | (((ys-16)&7) << 9);memory += 2;
		}
	}
	else
	{
		if(-(ys-32) > 0) 
		{
/*			fprintf(f,"\trol.l #%i,d4\n",-(ys-32));*/
			*((unsigned short*)memory) = 0xe19c | (((-(ys-32))&7) << 9);memory += 2;
		}
	}	
	return memory;					
}

void	PreWolfenstein(__reg("a0") char *Memory)
{
	char	*memory = Memory;
	#define	Zoomstufen 128
	#define	ScreenHeight 160
	#define TexHeight 128
	#define	ScreenWidth 192
	int j;
	char **memoryTab = (char **)memory;
	int ZSize = 8;
	int	count = 0;
	int	Zoom = 0;
	int	i,ScrPos = 0,k;
	int	yr = ((ScreenHeight - ZSize) >> 1);
	int	ys = yr&31,yn = 0;
	int stop = 0;

	memory += 4*(Zoomstufen+5-8);

	for(j = 8;j < Zoomstufen+5;j++,ZSize +=2)
	{
		count = 0;
		Zoom = 0;
		ScrPos = 0;
		yr = ((ScreenHeight >> 1) - ZSize);
		ys = yr&31,yn = 0;
		stop = 0;

		*memoryTab++ = memory;

		if(yr < 0) yr = 0;

		if((yr >> 5) > 0)
		{
			int i = 0;
/*			fprintf(f,"\teor.l d5,d5\n");*/
			*((unsigned short*)memory) = 0xbb85;memory += 2;
			for(i = 0;i < (yr >> 5); i++)
			{
/*				fprintf(f,"\tmove.l d5,ScreenWidth/8*32*%i(a2)\n",ScrPos++);*/
				*((unsigned short*)memory) = 0x2545;memory += 2;
				*((unsigned short*)memory) = (ScreenWidth>>3)*32*ScrPos;memory += 2;ScrPos++;
			}
		}
/*		fprintf(f,"\teor.l d5,d5\n");*/
		*((unsigned short*)memory) = 0xbb85;memory += 2;
		yr = ((ZSize * count) >> 3) + ((ScreenHeight >> 1) - ZSize);
		for(k = 0;k < (TexHeight >> 5) && (stop == 0);k++)
		{
/*			fprintf(f,"\tmove.l (a0)+,d0\n");*/
			*((unsigned short*)memory) = 0x2018;memory += 2;
/*			fprintf(f,"\trol.l #8,d0\n");*/
			*((unsigned short*)memory) = 0xe198;memory += 2;

			for(i = 0;i < 4 && stop == 0;i++)
			{
				yn = ((ZSize * (count + 1)) >> 3) + ((ScreenHeight >> 1) - ZSize);
				Zoom = yn - yr;
/*				fprintf(f,"; yn=%i,yr=%i\n",yn,yr);*/
/*				fprintf(f,"\trol.l #8,d0\n");*/
				*((unsigned short*)memory) = 0xe198;memory += 2;
				if(yn> 0)
				{
/*					fprintf(f,"\tmove.w d0,d2\n");*/
					*((unsigned short*)memory) = 0x3400;memory += 2;
/*					fprintf(f,"\teor.b d2,d2\n");*/
					*((unsigned short*)memory) = 0xb502;memory += 2;
/*					fprintf(f,"\tmove.l %i*4(a1,d2.l),d4\n",(Zoom-1));*/
					*((unsigned int*)memory) = 0x28312800+(((Zoom-1)*4)&255);memory += 4;
					if(yr < 0)
					{
						int z = -yr,u;
						for(u = 0;u < z >> 3;u++)
						{
/*							fprintf(f,"\tlsl.l #8,d4\n");*/
							*((unsigned short*)memory) = 0xe18c;memory += 2;
						}
						if(z & 7) 
						{
/*							fprintf(f,"\tlsl.l #%i,d4\n",z & 7);*/
							*((unsigned short*)memory) = 0xe18c + ((z & 7) << 9);memory += 2;
						}
						ys = 0;
					}
					if((ys&31) + Zoom == 32)
					{
						memory = rot(ys,memory);
/*						fprintf(f,"\tor.l d4,d5\n");*/
						*((unsigned short*)memory) = 0x8a84;memory += 2;
/*						fprintf(f,"\tmove.l d5,ScreenWidth/8*32*%i(a2)\n",ScrPos++);*/
						*((unsigned short*)memory) = 0x2545;memory += 2;
						*((unsigned short*)memory) = (ScreenWidth>>3)*32*ScrPos;memory += 2;
						ScrPos++;
						if(ScrPos >= (ScreenHeight >> 5))
						{
							stop = 1;
							break;
						}
/*						fprintf(f,"\teor.l d5,d5\n");*/
						*((unsigned short*)memory) = 0xbb85;memory += 2;
					}
					else
					if((ys&31) + Zoom > 32)
					{
						int l;
/*						fprintf(f,"\tmove.l d4,d3\n");*/
						*((unsigned short*)memory) = 0x2604;memory += 2;
						memory = rot(ys,memory);
/*						fprintf(f,"\tand.l #$%x,d4\n",(unsigned int)(2<<(31-ys))-1);*/
						*((unsigned short*)memory) = 0x0284;memory += 2;
						*((unsigned int*)memory) = (unsigned int)((2<<(31-ys))-1);memory += 4;
/*						fprintf(f,"\tor.l d4,d5\n");*/
						*((unsigned short*)memory) = 0x8a84;memory += 2;
/*						fprintf(f,"\tmove.l d5,ScreenWidth/8*32*%i(a2)\n",ScrPos++);*/
						*((unsigned short*)memory) = 0x2545;memory += 2;
						*((unsigned short*)memory) = (ScreenWidth>>3)*32*ScrPos;memory += 2;
						ScrPos++;
						if(ScrPos >= (ScreenHeight>>5))
						{
							stop = 1;
							break;
						}
/*						fprintf(f,"\tmove.l d3,d5\n");*/
						*((unsigned short*)memory) = 0x2a03;memory += 2;
						l = ((32-ys) & 31);

						if(l < 8)
						{
							if(l > 0) 
							{
/*								fprintf(f,"\tlsl.l #%i,d5\n",l);*/
								*((unsigned short*)memory) = 0xe18d + ((l&7)<<9);memory += 2;
							}
						}
						else
						if(l < 16)
						{
/*							fprintf(f,"\tlsl.l #8,d5\n");*/
							*((unsigned short*)memory) = 0xe18d;memory += 2;
							if(l-8 > 0) 
							{
/*								fprintf(f,"\tlsl.l #%i,d5\n",l-8);*/
								*((unsigned short*)memory) = 0xe18d + (((l-8)&7)<<9);memory += 2;
							}
						}
						else
						if(l < 24)
						{
/*							fprintf(f,"\tlsl.l #8,d5\n");*/
							*((unsigned short*)memory) = 0xe18d;memory += 2;
/*							fprintf(f,"\tlsl.l #8,d5\n");*/
							*((unsigned short*)memory) = 0xe18d;memory += 2;
							if(l-16 > 0) 
							{
/*								fprintf(f,"\tlsl.l #%i,d5\n",l-16);*/
								*((unsigned short*)memory) = 0xe18d + (((l-16)&7)<<9);memory += 2;
								}
							}
						else
						{
/*							fprintf(f,"\tlsl.l #8,d5\n");*/
							*((unsigned short*)memory) = 0xe18d;memory += 2;
/*							fprintf(f,"\tlsl.l #8,d5\n");*/
							*((unsigned short*)memory) = 0xe18d;memory += 2;
/*							fprintf(f,"\tlsl.l #8,d5\n");*/
							*((unsigned short*)memory) = 0xe18d;memory += 2;
							if(l-24 > 0) 
							{
/*								fprintf(f,"\tlsl.l #%i,d5\n",l-24);*/
								*((unsigned short*)memory) = 0xe18d + (((l-24)&7)<<9);memory += 2;
							}
						}						
					}
					else
					{
						memory = rot(ys,memory);
/*						fprintf(f,"\tor.l d4,d5\n");*/
						*((unsigned short*)memory) = 0x8a84;memory += 2;
					}
				}
				yr = yn;
				if(yr >= ScreenHeight) stop = 1;
				ys = yr & 31;
				count++;
			}
		}
		if(ScrPos<(ScreenHeight>>5))
		{
/*			fprintf(f,"\tmove.l d5,ScreenWidth/8*32*%i(a2)\n",ScrPos++);*/
			*((unsigned short*)memory) = 0x2545;memory += 2;
			*((unsigned short*)memory) = (ScreenWidth>>3)*32*ScrPos;memory += 2;
			ScrPos++;
		}
		if(ScrPos<(ScreenHeight>>5))
		{
/*			fprintf(f,"\teor.l d5,d5\n");*/
			*((unsigned short*)memory) = 0xbb85;memory += 2;
			while(ScrPos<(ScreenHeight>>5))
			{
/*				fprintf(f,"\tmove.l d5,ScreenWidth/8*32*%i(a2)\n",ScrPos);*/
				*((unsigned short*)memory) = 0x2545;memory += 2;
				*((unsigned short*)memory) = (ScreenWidth>>3)*32*ScrPos;memory += 2;
				ScrPos++;
			}
		}
	
/*		fprintf(f,"\trts\n");*/
		*((unsigned short*)memory) = 0x4e75;memory += 2;
	}
}
void	testCommandLine(__reg("d0") _d0,__reg("d0") _d1,__reg("d0") _d2,__reg("d0") _d3,__reg("d0") _d4,__reg("d0") _d5,__reg("d0") _d6,__reg("d0") _d7)
{
	
}
#define SCALE_SHIFT 17 
int yuv_imatrix[3][3] = {
	{ 1 * (1 << SCALE_SHIFT)	,0		,1.13983 * (1 << SCALE_SHIFT) },
	{ 1 * (1 << SCALE_SHIFT)	,-0.39465 * (1 << SCALE_SHIFT)	,-0.58060 * (1 << SCALE_SHIFT) },
	{ 1 * (1 << SCALE_SHIFT)	,2.03211 * (1 << SCALE_SHIFT)	,0 }
};
short colorR[32] =
{
	0x0000,
	0x0800,
	0x0008,
	0x0808,
	0x0080,
	0x0880,
	0x0088,
	0x0888,
	0x8000,
	0x8800,
	0x8008,
	0x8808,
	0x8080,
	0x8880,
	0x8088,
	0x8888,
	0x1000,
	0x1800,
	0x1008,
	0x1808,
	0x1080,
	0x1880,
	0x1088,
	0x1888,
	0x9000,
	0x9800,
	0x9008,
	0x9808,
	0x9080,
	0x9880,
	0x9088,
	0x9888,
};
short colorG[32] = 
{
	0x0000,
	0x0400,
	0x0004,
	0x0404,
	0x0040,
	0x0440,
	0x0044,
	0x0444,
	0x4000,
	0x4400,
	0x4004,
	0x4404,
	0x4040,
	0x4440,
	0x4044,
	0x4444,
	0x0100,
	0x0500,
	0x0104,
	0x0504,
	0x0140,
	0x0540,
	0x0144,
	0x0544,
	0x4100,
	0x4500,
	0x4104,
	0x4504,
	0x4140,
	0x4540,
	0x4144,
	0x4544,
};
short colorB[32] = 
{
	0x0000,
	0x0200,
	0x0002,
	0x0202,
	0x0020,
	0x0220,
	0x0022,
	0x0222,
	0x2000,
	0x2200,
	0x2002,
	0x2202,
	0x2020,
	0x2220,
	0x2022,
	0x2222,
	0x0001,
	0x0201,
	0x0003,
	0x0203,
	0x0021,
	0x0221,
	0x0023,
	0x0223,
	0x2001,
	0x2201,
	0x2003,
	0x2203,
	0x2021,
	0x2221,
	0x2023,
	0x2223,
};

void	PreHam7(__reg("a0") short *Memory)
{
	int	y,u,v;
	int	r,g,b;
	short m;
	for(y = 0;y < 32;y++)
	{
		for(u = 0;u < 32;u++)
		{
			for(v = 0;v < 32;v++)
			{
				r = (yuv_imatrix[0][0] * y + yuv_imatrix[0][1] * (u - 16) + yuv_imatrix[0][2] * (v - 16)) >> SCALE_SHIFT;
				g = (yuv_imatrix[1][0] * y + yuv_imatrix[1][1] * (u - 16) + yuv_imatrix[1][2] * (v - 16)) >> SCALE_SHIFT;
				b = (yuv_imatrix[2][0] * y + yuv_imatrix[2][1] * (u - 16) + yuv_imatrix[2][2] * (v - 16)) >> SCALE_SHIFT;
				if(r < 0) r = 0;
				if(g < 0) g = 0;
				if(b < 0) b = 0;
				if(r >= 32) r = 31;
				if(g >= 32) g = 31;
				if(b >= 32) b = 31;
				m = colorR[r] | colorG[g] | colorB[b];
				Memory[v | (u << 5) | (y << 10)] = m;
			}
		}
	}
}
