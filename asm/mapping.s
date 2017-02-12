ScreenWidth = 192
ScreenHeight= 192
Planes= 4
Pl=4

	include "blitterhelper.i"

	xdef	_Mapping_Init
	xref	_InterruptSub

	section	mapping,CODE_P

;---------Bitplane init ----------
_Mapping_Init:

	lea	Bitplane1,a0
	move.l	#ChipMemory,d0
	move.l 	d0,Screens
	move.l	#4-1,d1
.l1:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a0
	dbf	d1,.l1

	lea	Bitplane2,a0
	move.l 	d0,Screens+4
	move.l	#4-1,d1
.l2:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a0
	dbf	d1,.l2

	lea	Bitplane3,a0
	move.l 	d0,Screens+8
	move.l	#4-1,d1
.l3:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a0
	dbf	d1,.l3

	move.l 	d0,ScreenTmpPtr
	add.l 	#ScreenWidth/8*ScreenHeight*Planes,d0
	move.l 	d0,BufferMask8
	add.l 	#ScreenWidth/8,d0
	move.l 	d0,BufferMask4
	add.l 	#ScreenWidth/8,d0
	move.l 	d0,BufferMask2
	add.l 	#ScreenWidth/8,d0
	move.l 	d0,BufferMask1
	add.l 	#ScreenWidth/8,d0

	move.l	BufferMask8,a0
	move.l	BufferMask4,a1
	move.l	BufferMask2,a2
	move.l	BufferMask1,a3
	move.l	#$ff00ff00,d0
	move.l	#$f0f0f0f0,d1
	move.l	#$cccccccc,d2
	move.l	#$aaaaaaaa,d3
	move.w	#ScreenWidth/32-1,d7
IBM8:	
	move.l	d0,(a0)+
	move.l	d1,(a1)+
	move.l	d2,(a2)+
	move.l	d3,(a3)+
	dbf	d7,IBM8


	lea	Palette+2,a0
	lea	ColorCopper1+2,a1
	lea	ColorCopper2+2,a2
	lea	ColorCopper3+2,a3
	move.w	#31-1,d7
clo:	
	move.w	(a0)+,d0
	move.w	d0,(a1)
	move.w	d0,(a2)
	move.w	d0,(a3)
	add	#4,a1
	add	#4,a2
	add	#4,a3
	dbf	d7,clo

	move.l 	#_Mapping_InnerLoop,a0
	move.l 	a0,_InterruptSub

	rts
;---------------------------------
_Mapping_InnerLoop:

	move.w 	#$fff,$dff180

	bsr	RenderLoop

	move.w 	#$0,$dff180

	lea	Screens,a0
	bsr	Switch
	lea	Copper,a0
	bsr	Switch
	move.l	Copper+8,$dff080

	bsr BlitWait
	move.w	_BlitListEnd+2,_BlitListEnd
	jsr	_StartBlitList
	rts
;--------------------------------------------------------------------	
BlitWait:
	cmp.w	#0,_BEnd
	bne.b	BlitWait
	rts
;--------------------------------------------------------------------	
Switch:
	move.l	(a0),d0
	move.l	4(a0),d1
	move.l	8(a0),d2
	move.l	d1,(a0)
	move.l	d2,4(a0)
	move.l	d0,8(a0)
	rts
;--------------------------------------------------------------------	
RenderLoop:

	lea ChunkyMemory,a0
	lea BPlane,a1
	move.l 	(a1),d0
	move.l 	4(a1),d1
	move.l 	8(a1),d2
	move.l 	12(a1),d3

	bsr 	Shifting
	bsr 	Shifting

	move.l 	d0,(a1)
	move.l 	d1,4(a1)
	move.l 	d2,8(a1)
	move.l 	d3,12(a1)

	move.w 	#ScreenWidth/32*ScreenHeight-1,d7
cl1:
	move.l 	d0,(a0)+
	move.l 	d1,(a0)+
	move.l 	d2,(a0)+
	move.l 	d3,(a0)+
	dbf 	d7,cl1

	bsr 	Chunky

	rts
Shifting:
	move.l 	d0,d4
	move.l 	d1,d5
	move.l 	d2,d6
	move.l 	d3,d7
	and.l 	#$f,d4
	and.l 	#$f,d5
	and.l 	#$f,d6
	and.l 	#$f,d7
	ror.l 	#$4,d4
	ror.l 	#$4,d5
	ror.l 	#$4,d6
	ror.l 	#$4,d7
	lsr.l 	#$4,d0
	lsr.l 	#$4,d1
	lsr.l 	#$4,d2
	lsr.l 	#$4,d3
	or.l 	d7,d0
	or.l 	d4,d1
	or.l 	d5,d2
	or.l 	d6,d3
	rts
;--------------------------------------------------------------------	
Chunky:

	move.l 	Screens+4,a1
	move.l 	a1,BltSrc
	move.l 	BltSrc,a0
	lea 	ChunkyMemory,a1

	move.w 	#ScreenHeight-1,d7
RenLo2:	
	swap 	d7
	move.w 	#ScreenWidth/32-1,d7
RenLo1:	
	movem.l (a1)+,d0-d3

	swap	d2
	move.w 	d2,d4
	move.w 	d0,d2
	move.w 	d4,d0
	swap	d2

	swap	d3
	move.w 	d3,d4
	move.w 	d1,d3
	move.w 	d4,d1
	swap	d3

	move.l 	d0,(a0)
	move.l 	d1,ScreenWidth/8*ScreenHeight(a0)
	move.l 	d2,ScreenWidth/8*ScreenHeight*2(a0)
	move.l 	d3,ScreenWidth/8*ScreenHeight*3(a0)
	addq	#4,a0

	dbf 	d7,RenLo1
	swap 	d7
	dbf 	d7,RenLo2

	bsr 	ChunkyBlt

	rts
;--------------------------------------------------------------------	
ChunkyBlt:

;	bra 	tm

OFFSET = ScreenWidth/8*ScreenHeight-2
; 8 bit
	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a2
	move.l	BltSrc,a1
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask8,20(a6)				; C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$0fe48000,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a2
	move.l	BltSrc,a1
	add.l	#OFFSET,a1
	add.l	#OFFSET,a2
	add.l	#ScreenWidth/8*ScreenHeight,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask8,20(a6)
	add.l 	#ScreenWidth/8-2,20(a6); C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$8fe40002,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a2
	move.l	BltSrc,a1
	add.l	#ScreenWidth/8*ScreenHeight*2,a1
	add.l	#ScreenWidth/8*ScreenHeight*2,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask8,20(a6)				; C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$0fe48000,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a2
	move.l	BltSrc,a1
	add.l	#ScreenWidth/8*ScreenHeight*2,a1
	add.l	#ScreenWidth/8*ScreenHeight*3,a2
	add.l	#OFFSET,a1
	add.l	#OFFSET,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask8,20(a6)
	add.l 	#ScreenWidth/8-2,20(a6); C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$8fe40002,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit


; 4 bit
	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a1
	move.l	BltSrc,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask4,20(a6)				; C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight*2,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$0fe44000,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a1
	move.l	BltSrc,a2
	add.l	#OFFSET,a1
	add.l	#OFFSET,a2
	add.l	#ScreenWidth/8*ScreenHeight*2,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask4,20(a6)
	add.l 	#ScreenWidth/8-2,20(a6); C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight*2,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$4fe40002,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a1
	move.l	BltSrc,a2
	add.l	#ScreenWidth/8*ScreenHeight*1,a1
	add.l	#ScreenWidth/8*ScreenHeight*1,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask4,20(a6)				; C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight*2,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$0fe44000,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a1
	move.l	BltSrc,a2
	add.l	#ScreenWidth/8*ScreenHeight*1,a1
	add.l	#ScreenWidth/8*ScreenHeight*3,a2
	add.l	#OFFSET,a1
	add.l	#OFFSET,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask4,20(a6)
	add.l 	#ScreenWidth/8-2,20(a6); C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight*2,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$4fe40002,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

; 2 bit
	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a2
	move.l	BltSrc,a1
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask2,20(a6)				; C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$0fe42000,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a2
	move.l	BltSrc,a1
	add.l	#OFFSET,a1
	add.l	#OFFSET,a2
	add.l	#ScreenWidth/8*ScreenHeight,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask2,20(a6)
	add.l 	#ScreenWidth/8-2,20(a6); C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$2fe40002,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a2
	move.l	BltSrc,a1
	add.l	#ScreenWidth/8*ScreenHeight*2,a1
	add.l	#ScreenWidth/8*ScreenHeight*2,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask2,20(a6)				; C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$0fe42000,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a2
	move.l	BltSrc,a1
	add.l	#ScreenWidth/8*ScreenHeight*2,a1
	add.l	#ScreenWidth/8*ScreenHeight*3,a2
	add.l	#OFFSET,a1
	add.l	#OFFSET,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask2,20(a6)
	add.l 	#ScreenWidth/8-2,20(a6); C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$2fe40002,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

; 1 bit
	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a1
	move.l	BltSrc,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	add.l	#ScreenWidth/8*ScreenHeight*3,a2
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask1,20(a6)				; C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight*2,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$0fe41000,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a1
	move.l	BltSrc,a2
	add.l	#OFFSET,a1
	add.l	#OFFSET,a2
	add.l	#ScreenWidth/8*ScreenHeight*2,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask1,20(a6)
	add.l 	#ScreenWidth/8-2,20(a6); C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight*2,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$1fe40002,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a1
	move.l	BltSrc,a2
	add.l	#ScreenWidth/8*ScreenHeight*1,a1
	add.l	#ScreenWidth/8*ScreenHeight*1,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask1,20(a6)				; C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight*2,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$0fe41000,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	lea 	_BltTmp,a6
	move.l	ScreenTmpPtr,a1
	move.l	BltSrc,a2
	add.l	#ScreenWidth/8*ScreenHeight*1,a1
	add.l	#OFFSET,a1
	add.l	#OFFSET,a2
	move.w	#(ScreenHeight)*64+((ScreenWidth/16)&63),36(a6)	; Size
	move.w	#-1,34(a6)
	move.w	#-1,32(a6)
	move.l	#-1,28(a6)
	move.l	a2,24(a6)					; D-Dest
	move.l	BufferMask1,20(a6)
	add.l 	#ScreenWidth/8-2,20(a6); C-Mask
	move.l	a1,a3
	add.l	#ScreenWidth/8*ScreenHeight*2,a3
	move.l	a3,16(a6)					; B-Src1
	move.l	a1,12(a6)					; A-Src0
	move.w	#0,10(a6)		; D-Mod
	move.w	#-ScreenWidth/8,8(a6)		; C-Mod
	move.w	#0,6(a6)		; B-Mod
	move.w	#0,4(a6)		; A-Mod
	move.l	#$1fe40002,(a6)				; BlitCon0/1
	lea 	_BltTmp,a1
	jsr	_SetBlit

	rts
;--------------------------------------------------------------------
	SECTION	chip,DATA_C
;-----------
; display dimensions
DISPW           equ     ScreenWidth
DISPH           equ     ScreenHeight

; display window in raster coordinates (HSTART must be odd)
HSTART          equ     129+(256-ScreenWidth)/2
VSTART          equ     36+(256-ScreenHeight)/2
VEND            equ     VSTART+DISPH
VEND2			equ		14

; normal display data fetch start/stop (without scrolling)
DFETCHSTART     equ     HSTART/2
DFETCHSTOP      equ     DFETCHSTART+8*((DISPW/16)-1)
;-----------
Copper1:
	dc.w	$01fc,$000c
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0100,$0200
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HSTART+ScreenWidth-$100+16
	dc.w	$0092,DFETCHSTART
	dc.w	$0094,DFETCHSTOP
	dc.w	$0108,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$010a,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$0102,$0000
	dc.w	$0104,$0000
Bitplane1:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
	dc.w	$00e8,$0000
	dc.w	$00ea,$0000
	dc.w	$00ec,$0000
	dc.w	$00ee,$0000
	dc.w	$00f0,$0000
	dc.w	$00f2,$0000
	dc.w	$00f4,$0000
	dc.w	$00f6,$0000
ColorCopper1:
;	dc.w	$0180,$0008
	dc.w	$0182,$0533
	dc.w	$0184,$0966
	dc.w	$0186,$0ddd
	dc.w	$0188,$0888
	dc.w	$018a,$0aaa
	dc.w	$018c,$0ccc
	dc.w	$018e,$0eee
	dc.w	$0190,$0866
	dc.w	$0192,$0a64
	dc.w	$0194,$0976
	dc.w	$0196,$0b76
	dc.w	$0198,$0a86
	dc.w	$019a,$0998
	dc.w	$019c,$0e44
	dc.w	$019e,$0e55
	dc.w	$01a0,$0d86
	dc.w	$01a2,$099a
	dc.w	$01a4,$0e56
	dc.w	$01a6,$0e85
	dc.w	$01a8,$0ca8
	dc.w	$01aa,$0f78
	dc.w	$01ac,$0e97
	dc.w	$01ae,$0abc
	dc.w	$01b0,$0caa
	dc.w	$01b2,$0fb5
	dc.w	$01b4,$0f9a
	dc.w	$01b6,$0ccc
	dc.w	$01b8,$0fc7
	dc.w	$01ba,$0fbb
	dc.w	$01bc,$0fdb
	dc.w	$01be,$0fff

	dc.w	$0106,$0000
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0100,(Pl<<12)
	dc.w	$0180,$0348
	IFLT	(256-VEND)
	dc.w 	$ffdf,$fffe
	ENDIF
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

;-----------
Copper2:
	dc.w	$01fc,$000c
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0100,$0200
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HSTART+ScreenWidth-$100+16
	dc.w	$0092,DFETCHSTART
	dc.w	$0094,DFETCHSTOP
	dc.w	$0108,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$010a,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$0102,$0000
	dc.w	$0104,$0000
Bitplane2:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
	dc.w	$00e8,$0000
	dc.w	$00ea,$0000
	dc.w	$00ec,$0000
	dc.w	$00ee,$0000
	dc.w	$00f0,$0000
	dc.w	$00f2,$0000
	dc.w	$00f4,$0000
	dc.w	$00f6,$0000
ColorCopper2:
;	dc.w	$0180,$0008
	dc.w	$0182,$0533
	dc.w	$0184,$0966
	dc.w	$0186,$0ddd
	dc.w	$0188,$0888
	dc.w	$018a,$0aaa
	dc.w	$018c,$0ccc
	dc.w	$018e,$0eee
	dc.w	$0190,$0866
	dc.w	$0192,$0a64
	dc.w	$0194,$0976
	dc.w	$0196,$0b76
	dc.w	$0198,$0a86
	dc.w	$019a,$0998
	dc.w	$019c,$0e44
	dc.w	$019e,$0e55
	dc.w	$01a0,$0d86
	dc.w	$01a2,$099a
	dc.w	$01a4,$0e56
	dc.w	$01a6,$0e85
	dc.w	$01a8,$0ca8
	dc.w	$01aa,$0f78
	dc.w	$01ac,$0e97
	dc.w	$01ae,$0abc
	dc.w	$01b0,$0caa
	dc.w	$01b2,$0fb5
	dc.w	$01b4,$0f9a
	dc.w	$01b6,$0ccc
	dc.w	$01b8,$0fc7
	dc.w	$01ba,$0fbb
	dc.w	$01bc,$0fdb
	dc.w	$01be,$0fff

	dc.w	$0106,$0000
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0100,(Pl<<12)
	dc.w	$0180,$0348
	IFLT	(256-VEND)
	dc.w 	$ffdf,$fffe
	ENDIF
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

;-----------
Copper3:
	dc.w	$01fc,$000c
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0100,$0200
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HSTART+ScreenWidth-$100+16
	dc.w	$0092,DFETCHSTART
	dc.w	$0094,DFETCHSTOP
	dc.w	$0108,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$010a,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$0102,$0000
	dc.w	$0104,$0000
Bitplane3:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
	dc.w	$00e8,$0000
	dc.w	$00ea,$0000
	dc.w	$00ec,$0000
	dc.w	$00ee,$0000
	dc.w	$00f0,$0000
	dc.w	$00f2,$0000
	dc.w	$00f4,$0000
	dc.w	$00f6,$0000
ColorCopper3:
;	dc.w	$0180,$0008
	dc.w	$0182,$0533
	dc.w	$0184,$0966
	dc.w	$0186,$0ddd
	dc.w	$0188,$0888
	dc.w	$018a,$0aaa
	dc.w	$018c,$0ccc
	dc.w	$018e,$0eee
	dc.w	$0190,$0866
	dc.w	$0192,$0a64
	dc.w	$0194,$0976
	dc.w	$0196,$0b76
	dc.w	$0198,$0a86
	dc.w	$019a,$0998
	dc.w	$019c,$0e44
	dc.w	$019e,$0e55
	dc.w	$01a0,$0d86
	dc.w	$01a2,$099a
	dc.w	$01a4,$0e56
	dc.w	$01a6,$0e85
	dc.w	$01a8,$0ca8
	dc.w	$01aa,$0f78
	dc.w	$01ac,$0e97
	dc.w	$01ae,$0abc
	dc.w	$01b0,$0caa
	dc.w	$01b2,$0fb5
	dc.w	$01b4,$0f9a
	dc.w	$01b6,$0ccc
	dc.w	$01b8,$0fc7
	dc.w	$01ba,$0fbb
	dc.w	$01bc,$0fdb
	dc.w	$01be,$0fff

	dc.w	$0106,$0000
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0100,(Pl<<12)
	dc.w	$0180,$0348
	IFLT	(256-VEND)
	dc.w 	$ffdf,$fffe
	ENDIF
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

*********************************************************************
	section mem,BSS_C
ChipMemory:
	ds.b	ScreenWidth/8*ScreenHeight*Planes*(3+1)+(ScreenWidth/8*4)
ScreenTmpPtr:
	dc.l 	0
	section mem,BSS_P
ChunkyMemory:
	ds.b	ScreenWidth*ScreenHeight/2
;--------------------------------------------------------------------
	section	data,DATA_P
Copper:
	dc.l	Copper1,Copper2,Copper3
Screens:
	dc.l	0,0,0

BltSrc:	dc.l	0
BufferMask8:
	dc.l 	0
BufferMask4:
	dc.l 	0
BufferMask2:
	dc.l 	0
BufferMask1:
	dc.l 	0
Scroll:
	dc.w 	0
BPlane:
	dc.l 	$01234567,$89abcdef,$fedcba98,$76543210
Palette:
	dc.w	$0000
	dc.w	$0111
	dc.w	$0222
	dc.w	$0333
	dc.w	$0444
	dc.w	$0555
	dc.w	$0666
	dc.w	$0777	
	dc.w	$0888
	dc.w	$0999
	dc.w	$0aaa
	dc.w	$0bbb
	dc.w	$0ccc
	dc.w	$0ddd
	dc.w	$0eee
	dc.w	$0fff
	dc.w	$0f60
	dc.w	$0f70
	dc.w	$0f80
	dc.w	$0f91
	dc.w	$0fa2
	dc.w	$0fa3
	dc.w	$0fb4
	dc.w	$0fb4
	dc.w	$0fc5
	dc.w	$0fc5
	dc.w	$0fd6
	dc.w	$0fd6
	dc.w	$0fe7
	dc.w	$0fe7
	dc.w	$0ff8
	dc.w	$0ff8

*********************************************************************
