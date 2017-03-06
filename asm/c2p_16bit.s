; mc68030		; c'est pas du 68000 !

Modulo = 320/8*192
Length = Modulo/4		; number of longwords per BitPlan to write

; static/dependent BitPlanes version for one chip ram area
	
	xdef	_BEST_c2p
	
	section	c2p,CODE_P

_BEST_c2p
;	lea	_ChunkyBuffer,A0		; source (chunky)
;	lea	BitPlanes,A1		; destination (planar)

	move.l	#Modulo,A2		; Modulo
;----
;	lea	(A1,A2.L*4),A1		; A1+Modulo*4
	add.l	a2,a1
	add.l	a2,a1
	add.l	a2,a1
	add.l	a2,a1
;---
;	lea	-4(A1,A2.L*2),A3	; A1+Modulo*6-4
	lea	-4(A1),A3	; A1+Modulo*6-4
	add.l	a2,a3
	add.l	a2,a3
;---
	add.l	#Length*4,A3		; loop test value

	move.l	A3,-(SP)

	move.l	A2,A6
;---
;	lea	(A6,A2.L*8),A6		; Modulo*8
	add.l	a6,a6
	add.l	a6,a6
	add.l	a6,a6
;---
	sub.l	A2,A6			; Modulo*7
	sub.l	A2,A6			; Modulo*6

	MOVE.L	(A0)+,D0
	move.l	#$0F0F0F0F,D4		; temp
	MOVE.L	(A0)+,D1
	move.l	#$CCCCCCCC,D5		; static
	MOVE.L	(A0)+,D2
	move.l	#$AAAAAAAA,D6		; static
	MOVE.L	(A0)+,D3
	move.l	#$FF00FF00,D7		; static
	AND.L	D4,D1
	LSL.L	#4,D0
	OR.L	D1,D0
	AND.L	D4,D2
	AND.L	D4,D3
	LSL.L	#4,D2
	OR.L	D3,D2

	move.l	D4,D1
	and.l	(A0)+,D1
	move.l	D4,D3
	and.l	(A0)+,D3
	lsl.l	#4,D1
	or.l	D3,D1
	move.l	D4,D3
	and.l	(A0)+,D3
	LSL.L	#4,D3
	and.l	(A0)+,D4

	move.l	D1,A4
	OR.L	D4,D3
	move.w	D0,D1
	swap	D1
	move.w	D1,D0
	move.w	A4,D1

	MOVE.L	D0,D4
	LSL.L	#2,D4
	EOR.L	D1,D4
	AND.L	D5,D4
	EOR.L	D4,D1
	LSR.L	#2,D4

	sub.l	A2,A1			; A1+Modulo*3

	EOR.L	D4,D0

	move.l	D3,D4
	move.w	D2,D3
	swap	D3
	move.w	D3,D2
	move.w	D4,D3

	MOVE.L	D2,D4
	LSL.L	#2,D4
	EOR.L	D3,D4
	AND.L	D5,D4
	EOR.L	D4,D3
	LSR.L	#2,D4
	EOR.L	D4,D2
	MOVE.L	D0,D4
	LSL.L	#8,D4
	EOR.L	D2,D4
	AND.L	D7,D4
	EOR.L	D4,D2
	LSR.L	#8,D4
	EOR.L	D4,D0
	MOVE.L	D0,D4
	ADD.L	D4,D4
	EOR.L	D2,D4
	AND.L	D6,D4
	EOR.L	D4,D2
	LSR.L	#1,D4
	EOR.L	D4,D0

	move.l	D0,(A1)			; 1.00 (poor place) chipram write -> bit plane 4
	MOVE.L	D1,D4
	sub.l	A2,A1			; A1+Modulo*2

	LSL.L	#8,D4
	EOR.L	D3,D4
	AND.L	D7,D4
	EOR.L	D4,D3
	LSR.L	#8,D4
	EOR.L	D4,D1

	lea	-$20(A0),A0

	MOVE.L	D1,D4
	ADD.L	D4,D4
	EOR.L	D3,D4
	AND.L	D6,D4
	EOR.L	D4,D3
	lsr.l	#1,D4
	eor.l	D1,D4

	move.l	D2,(A1)			; 0.64 (average place) chipram write -> bit plane 3
	move.l	#$F0F0F0F0,D1
	move.l	(A0)+,D0
	move.l	(A0)+,A4
	and.l	D1,D0
	move.l	(A0)+,D2
	exg	D4,A4
	move.l	(A0)+,A5
	sub.l	A2,A1			; A1+Modulo*1
	and.l	D1,D4
	exg	D3,A5
	and.l	D1,D2
	lsr.l	#4,D4
	and.l	D1,D3
	or.l	D4,D0
	lsr.l	#4,D3
	move.l	D1,D4
	or.l	D3,D2
	move.l	D4,D3

	and.l	(A0)+,D1
	and.l	(A0)+,D3
	lsr.l	#4,D3
	or.l	D3,D1
	move.l	D4,D3
	and.l	(A0)+,D3
	and.l	(A0)+,D4
	move.l	A4,(A1)			; 0.01 (perfect place) chipram write -> bit plane 2
	sub.l	A2,A1			; A1+Modulo*0 (place OK)
	lsr.l	#4,D4
	or.l	D4,D3

	move.l	A5,(A1)			; 0.01 (perfect place) chipram write -> bit plane 1
	move.l	D1,A4
	add.l	A6,A1			; A1+Modulo*6

	move.w	D0,D1
	swap	D1
	move.w	D1,D0
	move.w	A4,D1

	MOVE.L	D0,D4
	LSL.L	#2,D4
	EOR.L	D1,D4
	AND.L	D5,D4
	move.l	D3,A4
	EOR.L	D4,D1
	move.w	D2,D3
	LSR.L	#2,D4
	swap	D3
	EOR.L	D4,D0

	move.w	D3,D2
	move.w	A4,D3

	MOVE.L	D2,D4
	LSL.L	#2,D4
	EOR.L	D3,D4
	AND.L	D5,D4
	EOR.L	D4,D3

	subq.l	#4,A6			; correction for bit plane 7 handling
	bra.w	GoBC2P

LoopBC2P
	move.l	(A0)+,D0
	sub.l	A2,A1			; A1+Modulo*5
	move.l	(A0)+,D1
	AND.L	D4,D0
	move.l	(A0)+,D2
	move.l	(A0)+,D3

	AND.L	D4,D2
	LSL.L	#4,D0
	LSL.L	#4,D2
	AND.L	D4,D1
	AND.L	D4,D3
	OR.L	D1,D0
	OR.L	D3,D2

	move.l	D4,D1
	and.l	(A0)+,D1
	move.l	D4,D3
	and.l	(A0)+,D3
	lsl.l	#4,D1
	or.l	D3,D1
	move.l	d4,d3
	and.l	(A0)+,D3
;	and.l	D3,D4
	move.l	A4,(A1)			; 0.04 (perfect place) chipram write -> bit plane 6
	sub.l	A2,A1			; A1+Modulo*4 (right place)
	and.l	(A0)+,D4
	move.l	A5,(A1)+		; 0.26 (perfect place) chipram write -> bit plane 5
	sub.l	A2,A1			; A1+Modulo*3
	lsl.l	#4,D3
	or.l	D4,D3
	move.l	D1,D4
	move.w	D0,D1
	swap	D1
	move.w	D1,D0
	move.w	D4,D1

	MOVE.L	D0,D4
	LSL.L	#2,D4
	EOR.L	D1,D4
	AND.L	D5,D4
	EOR.L	D4,D1
	LSR.L	#2,D4
	EOR.L	D4,D0

	move.l	D3,D4
	move.w	D2,D3
	swap	D3
	move.w	D3,D2
	move.w	D4,D3

	MOVE.L	D2,D4
	LSL.L	#2,D4
	EOR.L	D3,D4
	AND.L	D5,D4
	EOR.L	D4,D3
	LSR.L	#2,D4
	EOR.L	D4,D2
	MOVE.L	D0,D4
	LSL.L	#8,D4
	EOR.L	D2,D4
	AND.L	D7,D4
	EOR.L	D4,D2
	LSR.L	#8,D4
	EOR.L	D4,D0
	MOVE.L	D0,D4
	ADD.L	D4,D4
	EOR.L	D2,D4
	AND.L	D6,D4
	EOR.L	D4,D2
	LSR.L	#1,D4
	EOR.L	D4,D0

	move.l	D0,(A1)			; 1.00 (poor place) chipram write -> bit plane 4
	MOVE.L	D1,D4
	sub.l	A2,A1			; A1+Modulo*2

	LSL.L	#8,D4
	EOR.L	D3,D4
	AND.L	D7,D4
	EOR.L	D4,D3
	LSR.L	#8,D4
	EOR.L	D4,D1

	lea	-$20(A0),A0

	MOVE.L	D1,D4
	ADD.L	D4,D4
	EOR.L	D3,D4
	AND.L	D6,D4
	EOR.L	D4,D3
	lsr.l	#1,D4
	eor.l	D1,D4

	move.l	D2,(A1)			; 0.64 (average place) chipram write -> bit plane 3
	move.l	(A0)+,D0
	move.l	#$F0F0F0F0,D1
	move.l	(A0)+,A4
	and.l	D1,D0
	move.l	(A0)+,D2
	exg	D4,A4
	move.l	(A0)+,A5
	sub.l	A2,A1			; A1+Modulo*1
	and.l	D1,D4
	exg	D3,A5
	and.l	D1,D2
	lsr.l	#4,D4
	and.l	D1,D3
	or.l	D4,D0
	lsr.l	#4,D3
	move.l	D1,D4
	or.l	D3,D2
	move.l	D4,D3

	and.l	(A0)+,D1
	and.l	(A0)+,D3
	lsr.l	#4,D3
	or.l	D3,D1
	move.l	D4,D3
	and.l	(A0)+,D3
	and.l	(A0)+,D4
	move.l	A4,(A1)			; 0.01 (perfect place) chipram write -> bit plane 2
	sub.l	A2,A1			; A1+Modulo*0 (place OK)
	lsr.l	#4,D4
	or.l	D4,D3

	move.l	A5,(A1)			; 0.01 (perfect place) chipram write -> bit plane 1
	move.l	D1,A4
	add.l	A6,A1			; A1+Modulo*6 (-4)

	move.w	D0,D1
	swap	D1
	move.w	D1,D0
	move.w	A4,D1

	MOVE.L	D0,D4
	LSL.L	#2,D4
	EOR.L	D1,D4
	AND.L	D5,D4
	EOR.L	D4,D1
	LSR.L	#2,D4
	EOR.L	D4,D0

	move.l	D3,A4
	move.w	D2,D3
	swap	D3
	move.w	D3,D2
	move.w	A4,D3

	MOVE.L	D2,D4
	LSL.L	#2,D4
	EOR.L	D3,D4
	AND.L	D5,D4
	EOR.L	D4,D3
;--
	move.l	A3,(A1)+		; 0.76 (average place) chipram write -> bit plane 7
;--
GoBC2P
	LSR.L	#2,D4
	add.l	A2,A1			; A1+Modulo*8

	EOR.L	D4,D2
	MOVE.L	D0,D4
	LSL.L	#8,D4
	EOR.L	D2,D4
	AND.L	D7,D4
	EOR.L	D4,D2
	LSR.L	#8,D4
	EOR.L	D4,D0
	MOVE.L	D0,D4
	ADD.L	D4,D4
	EOR.L	D2,D4
	AND.L	D6,D4
	EOR.L	D4,D2
	LSR.L	#1,D4
	EOR.L	D4,D0

	move.l	D2,A3
	move.l	D0,(A1)			; 1.00 (poor place) chipram write -> bit plane 8
	MOVE.L	D1,D4
	sub.l	A2,A1			; A1+Modulo*6

	LSL.L	#8,D4
	EOR.L	D3,D4
	AND.L	D7,D4
	EOR.L	D4,D3
	LSR.L	#8,D4
	EOR.L	D4,D1
	MOVE.L	D1,D4
	ADD.L	D4,D4
	EOR.L	D3,D4
	AND.L	D6,D4
	EOR.L	D4,D3
	LSR.L	#1,D4
	EOR.L	D1,D4
	move.l	D4,A4
	move.l	D3,A5
	MOVE.L	#$0F0F0F0F,D4
	cmp.l	(SP),A1
	bne.w	LoopBC2P
	move.l	A3,(A1)			; chipram write -> bit plane 7
	sub.l	A2,A1			; A1+Modulo*5 
	addq.l	#4,SP			; restore stack
	move.l	A4,(A1)			; chipram write -> bit plane 6
	sub.l	A2,A1			; A1+Modulo*4
	move.l	A5,(A1)			; chipram write -> bit plane 5
	RTS

;(C) Rune stensland 1998

; Ham6Scrambled  Copyspeed 030 50+
; Ham6SCR -  4bpl by SP of Contraz (Rune Stensland , runebs@ifi.uio.no) 1998
; Reach me on IRCNET nick: SP^CTZ channel: #Amycoders (ofcourse :) )
; btw: this routine can get a couple of cycles faster.(even though everything
; memory pipelines on 030 50mhz or bether +
; I use a interleaved 6bpl ham6 bitmap to get extra big screens. and use
; move.l	XX,xxxx(a1) / (a1)+ 's to chipmem.
; Scrx=1280 for 320*xxx truecolour display.

SP_HAM6SCR:

	move.l	#%00001111000011110000111100001111,d6
	move.l	#%00000000111111110000000011111111,d7
	lea	chunkybuffer,a0		;pointer to word chunky buffer
	move.l	logscreen,a1		;pointer to interleaved bitmap.
	
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

SP_HAM7SCR:
	move.l	#%00001111000011110000111100001111,d6
	move.l	#%00000000111111110000000011111111,d7
	move.l	#%00010001000100010001000100010001,a5
	lea	chunkybuffer,a0 ;pointer to 15bit scrambled word chunkybuffer
	move.l	logscreen,a1	;pointer to interleaved 8bpl ham8 screen
	add.l	#(Scrx*4)/8,a1	;skip the maskbitplanes
	
	move.l	a0,a2
	addq.l	#4,a2
	move.l	#Scry,a6
	
*****************************************************

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
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	
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
