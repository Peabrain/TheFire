; mc68030		; c'est pas du 68000 !

Modulo = $2800
Length = $A00		; number of longwords per BitPlan to write

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
	and.l	D3,D4
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

;	SECTION	c2p_test_new,BSS_C
;BitPlanes:	ds.l	320/32*256*8

	end
