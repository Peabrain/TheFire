;(C) Rune stensland 1998

; Ham6Scrambled  Copyspeed 030 50+
; Ham6SCR -  4bpl by SP of Contraz (Rune Stensland , runebs@ifi.uio.no) 1998
; Reach me on IRCNET nick: SP^CTZ channel: #Amycoders (ofcourse :) )
; btw: this routine can get a couple of cycles faster.(even though everything
; memory pipelines on 030 50mhz or bether +
; I use a interleaved 6bpl ham6 bitmap to get extra big screens. and use
; move.l	XX,xxxx(a1) / (a1)+ 's to chipmem.
; Scrx=1280 for 320*xxx truecolour display.

	xdef	SP_HAM7SCR
Scrw=1280
Scrx=1280
Scry=192
	section	c2pHam7,CODE_F

SP_HAM6SCR:

	move.l	#%00001111000011110000111100001111,d6
	move.l	#%00000000111111110000000011111111,d7
;	lea	chunkybuffer,a0		;pointer to word chunky buffer
;	move.l	logscreen,a1		;pointer to interleaved bitmap.
	
	move.l	a0,a2
	move.l	#Scry,a6	;screen size Y
	
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	
	move.l	d2,d4		;swap 16 (1X3)
	move.w	d0,d4
	swap	d4
	move.w	d4,d0		;1
	move.w	d2,d4		;3

	move.l	d3,d2		;swap 16 (2X4)
	move.w	d1,d2
	swap	d2
	move.w	d2,d1		;2
	move.w	d3,d2		;4

	move.l	d4,d3		;swap 4 (1X3)

	lsr.l	#4,d3
	eor.l	d0,d3
	and.l	d6,d3
	eor.l	d3,d0
	lsl.l	#4,d3
	eor.l	d3,d4

	move.l	d2,d3		;swap 4 (2X4)
	lsr.l	#4,d3
	eor.l	d1,d3

	and.l	d6,d3
	eor.l	d3,d1
	lsl.l	#4,d3
	eor.l	d3,d2

	move.l	d1,d5		;swap 8 (1x2)
	lsr.l	#8,d5
	eor.l	d0,d5
	and.l	d7,d5
	eor.l	d5,d0

	lea	Scrw/2(a2),a2
.begin

	REPT	2
	move.l	d0,3*(Scrw/8)(a1)
	lsl.l	#8,d5
	eor.l	d1,d5

	move.l	d2,d3		;swap 8 (3X4)
	lsr.l	#8,d3
	eor.l	d4,d3
	and.l	d7,d3
	eor.l	d3,d4
	lsl.l	#8,d3
	eor.l	d3,d2

	move.l	d2,a3

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	
	move.l	d4,(a1)+

	move.l	d2,d4		;swap 16 (1X3)
	move.w	d0,d4
	swap	d4
	move.w	d4,d0
	move.w	d2,d4

	move.l	d3,d2		;swap 16 (2X4)
	move.w	d1,d2
	swap	d2
	move.w	d2,d1
	move.w	d3,d2

	move.l	d4,d3		;swap 4 (1X3)

	move.l	d5,2*(Scrw/8)-4(a1)

	lsr.l	#4,d3
	eor.l	d0,d3
	and.l	d6,d3
	eor.l	d3,d0
	lsl.l	#4,d3
	eor.l	d3,d4

	move.l	d2,d3		;swap 4 (2X4)
	lsr.l	#4,d3
	eor.l	d1,d3

	move.l	a3,(Scrw/8)-4(a1)

	and.l	d6,d3
	eor.l	d3,d1
	lsl.l	#4,d3
	eor.l	d3,d2

	move.l	d1,d5		;swap 8 (1x2)
	lsr.l	#8,d5
	eor.l	d0,d5
	and.l	d7,d5
	eor.l	d5,d0

	ENDR

	cmp.l	a2,a0
	blt.w	.begin

	lea	Scrw*5/8(a1),a1
	lea	Scrw/2(a2),a2

	subq.l	#1,a6
	tst.l	a6
	bgt.w	.begin

	rts

; Ham7Scrambled  Copyspeed 030 50+
; Ham7SCR -  5bpl by SP of Contraz (Rune Stensland , runebs@ifi.uio.no) 1998
; Reach me on IRCNET nick: SP^CTZ channel: #Amycoders (ofcourse :) )
; btw: this routine can get more acurate, but then harder to maintain copyspeed 
; on 030 50. I use a interleaved 8bpl ham8 bitmap.
; Scrx=1280 for 320*xxx truecolour display.

	xref	YUV_RGB
SP_HAM7SCR:
	move.l	#%00001111000011110000111100001111,d6
	move.l	#%00000000111111110000000011111111,d7
	move.l	#%00010001000100010001000100010001,a5
	lea		YUV_RGB,a4
;	lea	chunkybuffer,a0 ;pointer to 15bit scrambled word chunkybuffer
;	move.l	logscreen,a1	;pointer to interleaved 8bpl ham8 screen
	add.l	#(Scrx*4)/8,a1	;skip the maskbitplanes
	
	move.l	a0,a2
	addq.l	#4,a2
	move.l	#Scry,a6
	
*****************************************************

	move.l	(a0)+,d0
	move.w	(a4,d0.w*2),d0
	swap	d0
	move.w	(a4,d0.w*2),d0
	swap	d0
	move.l	(a0)+,d1
	move.w	(a4,d1.w*2),d1
	swap	d1
	move.w	(a4,d1.w*2),d1
	swap	d1
	move.l	(a0)+,d2
	move.w	(a4,d2.w*2),d2
	swap	d2
	move.w	(a4,d2.w*2),d2
	swap	d2
	move.l	(a0)+,d3
	move.w	(a4,d3.w*2),d3
	swap	d3
	move.w	(a4,d3.w*2),d3
	swap	d3
	
	move.l	d2,d4		;swap 16 (1X3)
	move.w	d0,d4
	swap	d4
	move.w	d4,d0		;1
	move.w	d2,d4		;3

	move.l	d3,d2		;swap 16 (2X4)
	move.w	d1,d2
	swap	d2
	move.w	d2,d1		;2
	move.w	d3,d2		;4

	move.l	d4,d3		;swap 4 (1X3)
	lsr.l	#4,d3
	eor.l	d0,d3
	and.l	d6,d3
	eor.l	d3,d0
	lsl.l	#4,d3
	eor.l	d3,d4

	move.l	d2,d3		;swap 4 (2X4)
	lsr.l	#4,d3
	eor.l	d1,d3
	and.l	d6,d3
	eor.l	d3,d1
;	lsl.l	#4,d3
;	eor.l	d3,d2

	move.l	d1,d5		;swap 8 (1x2)
	lsr.l	#8,d5
	eor.l	d0,d5
	and.l	d7,d5
	eor.l	d5,d0		;1

	add.l	#Scrx/2,a2
.begin
	move.l	d0,2*(Scrx/8)(a1)

 	lsl.l	#4,d3
	eor.l	d3,d2

	lsl.l	#8,d5
	eor.l	d1,d5

	move.l	d2,d3		;swap 8 (3X4)
	lsr.l	#8,d3
	eor.l	d4,d3
	and.l	d7,d3
	
	eor.l	d3,d4

	move.l	d4,-1*(Scrx/8)(a1)
	lsl.l	#8,d3
	eor.l	d3,d2

	move.l	d2,a3

	move.l	a5,d1	;andmask
	and.l	d1,d0				;1
	and.l	d1,d4				;3
	and.l	d1,d2				;4

	add.l	d0,d0	 ;xxxxr4xx...
	add.l	d4,d0    ;xxxxr4g4...
	add.l	d0,d0    ;xxr4g4xx...
	add.l	d2,d0    ;xxr4g4b4...
	add.l	d0,d0	 ;r4g4b4xx...  ;add.l	a5,d0	 ;r4g4b4r4...

	move.l	d0,d4
	move.l	(a0)+,d0
	move.w	(a4,d0.w*2),d0
	swap	d0
	move.w	(a4,d0.w*2),d0
	swap	d0
	move.l	(a0)+,d1
	move.w	(a4,d1.w*2),d1
	swap	d1
	move.w	(a4,d1.w*2),d1
	swap	d1
	move.l	(a0)+,d2
	move.w	(a4,d2.w*2),d2
	swap	d2
	move.w	(a4,d2.w*2),d2
	swap	d2
	move.l	(a0)+,d3
	move.w	(a4,d3.w*2),d3
	swap	d3
	move.w	(a4,d3.w*2),d3
	swap	d3
	
	move.l	d4,3*(Scrx/8)(a1)

	move.l	d2,d4		;swap 16 (1X3)
	move.w	d0,d4
	swap	d4
	move.w	d4,d0
	move.w	d2,d4

	move.l	d3,d2		;swap 16 (2X4)
	move.w	d1,d2
	swap	d2
	move.w	d2,d1
  	move.w	d3,d2

	move.l	d4,d3		;swap 4 (1X3)

	move.l	d5,1*(Scrx/8)(a1) 

	lsr.l	#4,d3		
	eor.l	d0,d3
	and.l	d6,d3
	eor.l	d3,d0
	lsl.l	#4,d3
	eor.l	d3,d4

	move.l	d2,d3		;swap 4 (2X4)
	lsr.l	#4,d3
	eor.l	d1,d3
	and.l	d6,d3

	move.l	a3,(a1)+
	eor.l	d3,d1
				; to siste inst av merge øverst
	move.l	d1,d5		;swap 8 (1x2)
	lsr.l	#8,d5
	eor.l	d0,d5
	and.l	d7,d5
	eor.l	d5,d0

	cmp.l	a2,a0
	blt.b	.begin

	lea	Scrx*7/8(a1),a1
	lea	Scrx/2(a2),a2

	subq.l	#1,a6
	tst.l	a6
	bgt.w	.begin

	rts

	end
