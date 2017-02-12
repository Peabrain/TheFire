ScreenWidth = 128
ScreenHeight= (144+16)

	include "blitterhelper.i"

	xdef	_Fire_Init
	xref	_InterruptSub

	section	fire,CODE_P

;---------Bitplane init ----------
_Fire_Init:

	lea	Bitplane1,a0
	move.l	#ChipMemory,a1
	move.l 	a1,Screens
	move.l 	a1,d0
	add.l	#ScreenWidth/8*ScreenHeight*7,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	add.l	#8,a0
	move.l 	a1,d0
	add.l	#ScreenWidth/8*ScreenHeight*3,d0
	move.l	#4-1,d1
.l1:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a0
	dbf	d1,.l1
	add.l 	#ScreenWidth/8*ScreenHeight*8,a1

	lea	Bitplane2,a0
;	move.l	#Screen2,a1
	move.l 	a1,Screens+4
	move.l 	a1,d0
	add.l	#ScreenWidth/8*ScreenHeight*7,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	add.l	#8,a0
	move.l 	a1,d0
	add.l	#ScreenWidth/8*ScreenHeight*3,d0
	move.l	#4-1,d1
.l2:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a0
	dbf	d1,.l2
	add.l 	#ScreenWidth/8*ScreenHeight*8,a1

	lea	Bitplane3,a0
;	move.l	#Screen3,a1
	move.l 	a1,Screens+8
	move.l 	a1,d0
	add.l	#ScreenWidth/8*ScreenHeight*7,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	add.l	#8,a0
	move.l 	a1,d0
	add.l	#ScreenWidth/8*ScreenHeight*3,d0
	move.l	#4-1,d1
.l3:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a0
	dbf	d1,.l3
	add.l 	#ScreenWidth/8*ScreenHeight*8,a1
	move.l 	a1,ScreenTmp1
	add.l 	#ScreenWidth/8*ScreenHeight*8,a1
	move.l 	a1,CarryScreen
	add.l 	#ScreenWidth/8*ScreenHeight*1,a1
	move.l 	a1,Dither1
	add.l 	#ScreenWidth/8*ScreenHeight*1,a1
	move.l 	a1,Dither2
	add.l 	#ScreenWidth/8*ScreenHeight*1,a1


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

	lea	Palette_+2,a0
	lea	ColorCopper1_+2,a1
	lea	ColorCopper2_+2,a2
	lea	ColorCopper3_+2,a3
	move.w	#31-1,d7
clo1:	
	move.w	(a0)+,d0
	move.w	d0,(a1)
	move.w	d0,(a2)
	move.w	d0,(a3)
	add	#4,a1
	add	#4,a2
	add	#4,a3
	dbf	d7,clo1

	move.l 	Dither1,a0
	move.l 	#$aaaaaaaa,d0
	move.w 	#ScreenHeight-1,d6
da2:
	swap	d6
	move.w 	#ScreenWidth/32-1,d6
da1:
	move.l 	d0,(a0)+
	dbf 	d6,da1
	eor.l 	#$ffffffff,d0
	swap	d6
	dbf 	d6,da2

	move.l 	Dither2,a0
	move.l 	#$44444444,d0
	move.w 	#ScreenHeight/2-1,d6
da3:
	swap	d6
	move.w 	#ScreenWidth/32-1,d6
da4:
	move.l 	#0,ScreenWidth/8*1(a0)
	move.l 	d0,(a0)+
	dbf 	d6,da4
	add.l 	#ScreenWidth/8*1,a0
	swap	d6
	dbf 	d6,da3

	move.l 	#_Fire_InnerLoop,a0
	move.l 	a0,_InterruptSub

	rts
;---------------------------------
_Fire_InnerLoop:
	bsr	RenderLoop

	lea	Screens,a0
	bsr	Switch
	lea	Copper,a0
	bsr	Switch
	move.l	Copper+8,$dff080

	move.w	_BlitListEnd+2,_BlitListEnd
	bsr BlitWait
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
DrawNew:
	move.w 	#3-1,d7
das4:
	swap	d7
	bsr 	Rnd

	move.l 	d0,d1
	and.l 	#127,d1
	move.l 	d1,d2
	and.l 	#15,d2
	lsr.l 	#4,d1
	add.l 	d1,d1

	bsr 	Rnd

	move.w 	d0,d4
	lsr.w 	#4,d4
	and.w 	#3,d4
	mulu	#ScreenWidth/8,d4
	move.l 	Screens,a2
	add.l 	d4,a2
	add.l 	#ScreenWidth/8*(ScreenHeight-17-4),a2

	bsr 	Rnd

	move.w 	d0,d4
	lsr.w 	#3,d4

	add.l 	d1,a2

	move.l 	d2,d3
	ror.l 	#4,d3
	or.l	#%00001100<<16,d3
	btst 	#0,d4
	beq.b 	das2
	or.l	#%11111100<<16,d3
das2:
	move.w	#16*64+2,d2
	move.w 	#7-1,d7
das:
	move.l 	a2,a0
	move.l 	#QuadMask,d0
	move.l 	a0,d1
	bsr 	Copy4
	add.l 	#ScreenWidth/8*ScreenHeight,a2
	dbf 	d7,das
	swap	d7
	dbf 	d7,das4

	rts
;--------------------------------------------------------------------	
Rnd:
	add.l 	#$7d313,RAND
	move.l 	RAND,d0
	add.l 	#$fe427843,d0
	add.l 	d0,RAND+4
	move.l 	RAND+4,d0
	rts
;--------------------------------------------------------------------	
RenderLoop:

	bsr 	DrawNew
;--- Addieren

	bsr		Addierer
	rts
;--------------------------------------------------------------------	
;--- addierer
BLOCKY = 4
BLOCKY1 = 3
Addierer:

;-----------------
	move.l	CarryScreen,a2
	move.w	#blith*64+blitw,d0
	bsr	ClrScr

	move.l	Screens,a0		; a
	move.l	ScreenTmp1,a1	; d

	move.l 	#$30000000,d5
	move.w 	#6-1,d7
klj:
	move.l	a0,d0		; a
	move.l 	d0,d1 		; b
	add.l 	#ScreenWidth/8*BLOCKY,d1
	move.l	CarryScreen,d2	; c
	move.l	CarryScreen,d3	; d	
	move.w	#(blith-BLOCKY)*64+blitw,d4
	bsr	BlAddCarry

	move.l	a1,d3		; d
	add.l 	#ScreenWidth/8*ScreenHeight,a0
	add.l 	#ScreenWidth/8*ScreenHeight,a1
	move.l	a0,d0		; a
	move.l 	d0,d1 				; b
	add.l 	#ScreenWidth/8*BLOCKY,d1
	move.l	CarryScreen,d2	; c
	move.w	#(blith-BLOCKY)*64+blitw,d4
	bsr	BlAdd

	dbf		d7,klj

	move.l	a1,d3		; d
	move.l	a0,d0		; a
	move.l 	d0,d1 				; b
	add.l 	#ScreenWidth/8*BLOCKY,d1
	move.l	CarryScreen,d2	; c
;	move.l	d0,d3		; d
	move.w	#(blith-BLOCKY)*64+blitw,d4
	bsr	BlAddCarry

;	rts
;-----------------
bm:
	move.l	CarryScreen,a2
	move.w	#blith*64+blitw,d0
	bsr	ClrScr

	move.l	Screens,a0		; a
	add.l 	#ScreenWidth/8-2,a0
	move.l	Screens+4,a1		; b
	add.l 	#ScreenWidth/8-2,a1

	move.l 	#$20000000,d5
	move.w 	#6-1,d7
klj1:
	move.l	a0,d0		; a
	move.l 	d0,d1 				; b
	add.l 	#ScreenWidth/8*(BLOCKY1),d1
	move.l	CarryScreen,d2	; c
	move.l	CarryScreen,d3	; d	
	move.w	#(blith-(BLOCKY1))*64+blitw,d4
	bsr	BlAddCarryR

	move.l	a1,d3		; d
	add.l 	#ScreenWidth/8*ScreenHeight,a0
	add.l 	#ScreenWidth/8*ScreenHeight,a1
	move.l	a0,d0		; a
	move.l 	d0,d1 				; b
	add.l 	#ScreenWidth/8*(BLOCKY1),d1
	move.l	CarryScreen,d2	; c
	move.w	#(blith-(BLOCKY1))*64+blitw,d4
	bsr	BlAddR

	dbf		d7,klj1

	move.l	a0,d0		; a
	move.l 	d0,d1 				; b
	add.l 	#ScreenWidth/8*(BLOCKY1),d1
	move.l	CarryScreen,d2	; c
	move.l	a1,d3		; d
	move.w	#(blith-(BLOCKY1))*64+blitw,d4
	bsr	BlAddCarryR

;-----------------

	move.l	CarryScreen,a2
	move.w	#blith*64+blitw,d0
	bsr	ClrScr

	move.l	Screens+4,a0		; a
	move.l	Screens+4,a2		; d
	move.l	ScreenTmp1,a1	; d

	move.l 	#$00000000,d5
	move.w 	#6-1,d7
klj2:
	move.l	a0,d0		; a
	move.l 	a1,d1 				; b
	move.l	CarryScreen,d2	; c
	move.l	CarryScreen,d3	; d	
	move.w	#blith*64+blitw,d4
	bsr	BlAddCarry

	move.l	a2,d3		; d
	add.l 	#ScreenWidth/8*ScreenHeight,a0
	add.l 	#ScreenWidth/8*ScreenHeight,a1
	add.l 	#ScreenWidth/8*ScreenHeight,a2
	move.l	a0,d0		; a
	move.l 	a1,d1 				; b
	move.l	CarryScreen,d2	; c
	move.w	#blith*64+blitw,d4
	bsr	BlAdd

	dbf		d7,klj2

	move.l	a0,d0		; a
	move.l 	a1,d1 				; b
	move.l	CarryScreen,d2	; c
	move.l	a2,d3		; d
	move.w	#blith*64+blitw,d4
	bsr	BlAddCarry

	move.l	Screens+4,d3
	move.l	d3,d0
	add.l 	#ScreenWidth/8*ScreenHeight*7,d3
	move.l 	d0,d1
	add.l 	#ScreenWidth/8*ScreenHeight*1,d0
	add.l 	#ScreenWidth/8*ScreenHeight*2,d1
	move.l	Dither1,d2
	move.w	#blith*64+blitw,d4
	bsr	Copy2

	move.l	Screens+4,d3
	move.l	d3,d0
	add.l 	#ScreenWidth/8*ScreenHeight*7,d3
	move.l 	d0,d1
	add.l 	#ScreenWidth/8*ScreenHeight*0,d0
	add.l 	#ScreenWidth/8*ScreenHeight*7,d1
	move.l	Dither2,d2
	move.w	#blith*64+blitw,d4
	bsr	Copy2


	rts	
;--------------------------------------------------------------------
ClrScr:
	; a1 = dst
	; d0 = Size
	movem.l 	a1,-(sp)
	lea 	_BltTmp,a1
	move.w	d0,36(a1)	; Size
	MOVE.W	#0,34(a1)
	MOVE.W	#0,32(a1)
	MOVE.L	#-1,28(a1)
	move.l	a2,24(a1)					; D-Dest
	move.l	#0,20(a1)				; C-Mask
	move.l	#0,16(a1)					; B-Src1
	move.l	#0,12(a1)					; A-Src0
	move.w	#0,10(a1)		; D-Mod
	move.w	#0,8(a1)		; C-Mod
	move.w	#0,6(a1)		; B-Mod
	move.w	#0,4(a1)		; A-Mod
	move.l	#$01000000,(a1)				; BlitCon0/1
	jsr	_SetBlit
	movem.l 	(sp)+,a1
	rts
;--------------------------------------------------------------------
blitw	=ScreenWidth/16			;sprite width in words
blith	=ScreenHeight			;sprite height in lines
Copy:
	movem.l 	a1/d2,-(sp)
	lea 	_BltTmp,a1
	move.w	d2,36(a1)
	move.w	#-1,34(a1)
	move.w	#-1,32(a1)
	move.l	#-1,28(a1)
	move.l	d1,24(a1)
	move.l	a2,20(a1)
	move.l	d1,16(a1)
	move.l	d0,12(a1)
	move.w	#0,10(a1)
	move.w	#0,8(a1)
	move.w	#0,6(a1)
	move.w	#0,4(a1)
	move.l	#%11111100<<16,d2
	or.l	#$0d000000,d2
	cmp.l	#0,a1
	beq.b	.Copy0
	move.l	#%11101100<<16,d2
	or.l	#$0f000000,d2
.Copy0:
	move.l	d2,(a1)
	jsr	_SetBlit
	movem.l 	(sp)+,a1/d2
	rts
Copy2:
	movem.l 	a1/d2,-(sp)
	lea 	_BltTmp,a1
	move.w	d4,36(a1)
	move.w	#-1,34(a1)
	move.w	#-1,32(a1)
	move.l	#-1,28(a1)
	move.l	d3,24(a1)	; d Dest
	move.l	d2,20(a1)	; c Dither
	move.l	d1,16(a1)	; b Dest
	move.l	d0,12(a1)	; a 0.5-Plane
	move.w	#0,10(a1)
	move.w	#0,8(a1)
	move.w	#0,6(a1)
	move.w	#0,4(a1)
	move.l	#%11101100<<16,d2
	or.l	#$0f000000,d2
	move.l	d2,(a1)
	jsr	_SetBlit
	movem.l 	(sp)+,a1/d2
	rts
Copy3:
	movem.l 	a1/d2,-(sp)
	lea 	_BltTmp,a1
	move.w	d2,36(a1)
	move.w	#-1,34(a1)
	move.w	#-1,32(a1)
	move.l	#-1,28(a1)
	move.l	d1,24(a1)
	move.l	#0,20(a1)
	move.l	#0,16(a1)
	move.l	d0,12(a1)
	move.w	#0,10(a1)
	move.w	#0,8(a1)
	move.w	#0,6(a1)
	move.w	#0,4(a1)
	move.l	#%11110000<<16,d2
	or.l	#$09000000,d2
	move.l	d2,(a1)
	jsr	_SetBlit
	movem.l 	(sp)+,a1/d2
	rts
Copy4:
	movem.l 	a1/d2,-(sp)
	lea 	_BltTmp,a1
	move.w	d2,36(a1)
	move.w	#-1,34(a1)
	move.w	#-1,32(a1)
	move.l	#-1,28(a1)
	move.l	d1,24(a1)
	move.l	#0,20(a1)
	move.l	d1,16(a1)
	move.l	d0,12(a1)
	move.w	#ScreenWidth/8-4,10(a1)
	move.w	#0,8(a1)
	move.w	#ScreenWidth/8-4,6(a1)
;	move.w	#-4,4(a1)
;	move.l	#%11110000<<16,d2
	move.l 	d3,d2
	or.l	#$0d000000,d2
	move.l	d2,(a1)
	jsr	_SetBlit
	movem.l 	(sp)+,a1/d2
	rts
;--------------------------------------------------------------------
BlAdd:
	movem.l 	a1/d2,-(sp)
	lea 	_BltTmp,a1
	move.w	d4,36(a1)
	move.w	#-1,34(a1)
	move.w	#-1,32(a1)
	move.l	#-1,28(a1)
	move.l	d3,24(a1)
	move.l	d2,20(a1)
	move.l	d1,16(a1)
	move.l	d0,12(a1)
	move.w	#0,10(a1)
	move.w	#0,8(a1)
	move.w	#0,6(a1)
	move.w	#0,4(a1)
	move.l	#%10010110<<16,d2
	or.l	#$0f000000,d2
	or.l 	d5,d2
	move.l	d2,(a1)
	jsr	_SetBlit
	movem.l 	(sp)+,a1/d2

	rts

BlAddR:
	movem.l 	a1/d2,-(sp)
	lea 	_BltTmp,a1
	move.w	d4,36(a1)
	move.w	#-1,34(a1)
	move.w	#-1,32(a1)
	move.l	#-1,28(a1)
	move.l	d3,24(a1)
	move.l	d2,20(a1)
	move.l	d1,16(a1)
	move.l	d0,12(a1)
	move.w	#-ScreenWidth/8*2,10(a1)
	move.w	#-ScreenWidth/8*2,8(a1)
	move.w	#-ScreenWidth/8*2,6(a1)
	move.w	#-ScreenWidth/8*2,4(a1)
	move.l	#%10010110<<16,d2
	or.l	#$0f000002,d2
	or.l 	d5,d2
	move.l	d2,(a1)
	jsr	_SetBlit
	movem.l 	(sp)+,a1/d2

	rts
;--------------------------------------------------------------------
BlAddCarry:
	movem.l 	a1/d2,-(sp)
	lea 	_BltTmp,a1
	move.w	d4,36(a1)
	move.w	#-1,34(a1)
	move.w	#-1,32(a1)
	move.l	#-1,28(a1)
	move.l	d3,24(a1)
	move.l	d2,20(a1)
	move.l	d1,16(a1)
	move.l	d0,12(a1)
	move.w	#0,10(a1)
	move.w	#0,8(a1)
	move.w	#0,6(a1)
	move.w	#0,4(a1)
	move.l	#%11101000<<16,d2
	or.l	#$0f000000,d2
	or.l 	d5,d2
	move.l	d2,(a1)
	jsr	_SetBlit
	movem.l 	(sp)+,a1/d2

	rts
BlAddCarryR:
	movem.l 	a1/d2,-(sp)
	lea 	_BltTmp,a1
	move.w	d4,36(a1)
	move.w	#-1,34(a1)
	move.w	#-1,32(a1)
	move.l	#-1,28(a1)
	move.l	d3,24(a1)
	move.l	d2,20(a1)
	move.l	d1,16(a1)
	move.l	d0,12(a1)
	move.w	#-ScreenWidth/8*2,10(a1)
	move.w	#-ScreenWidth/8*2,8(a1)
	move.w	#-ScreenWidth/8*2,6(a1)
	move.w	#-ScreenWidth/8*2,4(a1)
	move.l	#%11101000<<16,d2
	or.l	#$0f000002,d2
	or.l 	d5,d2
	move.l	d2,(a1)
	jsr	_SetBlit
	movem.l 	(sp)+,a1/d2

	rts
;--------------------------------------------------------------------
	SECTION	chip,DATA_C
;-----------
; display dimensions
DISPW           equ     ScreenWidth
DISPH           equ     ScreenHeight

; display window in raster coordinates (HSTART must be odd)
HSTART          equ     129+(256-ScreenWidth)/2
VSTART          equ     36+48
VEND            equ     VSTART+DISPH-22
VEND2			equ		14

; normal display data fetch start/stop (without scrolling)
DFETCHSTART     equ     HSTART/2
DFETCHSTOP      equ     DFETCHSTART+8*((DISPW/16)-1)
;-----------
Copper1:
	dc.w	$01fc,$000c
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0007+((VSTART-1)<<8),$fffe
	dc.w	$0180,$0fff
	dc.w	$0100,$0200
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HSTART+ScreenWidth+16-$100
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
;	dc.w	$0100,(Planes<<12)
	dc.w	$0100,(5<<12)
	dc.w	$0180,$0348
;	IFGT	(256-VEND)
	dc.w	$0007+(VEND<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0108,-ScreenWidth/8*4
	dc.w	$010a,-ScreenWidth/8*4
ColorCopper1_:
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
	dc.w	$0007+((VEND+1)<<8),$fffe
	dc.w	$0180,$0124
	dc.w	$0100,(5<<12)
	dc.w	$ffdf,$fffe
	dc.w	$0007+((VEND2)<<8),$fffe
	dc.w	$0180,$0fff
	dc.w	$0100,$0000
	dc.w	$0007+((VEND2+1)<<8),$fffe
	dc.w	$0180,$0000
;	ENDC
	dc.w	$ffff,$fffe

;-----------
Copper2:
	dc.w	$01fc,$000c
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0007+((VSTART-1)<<8),$fffe
	dc.w	$0180,$0fff
	dc.w	$0100,$0200
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HSTART+ScreenWidth+16-$100
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
;	dc.w	$0100,(Planes<<12)
	dc.w	$0100,(5<<12)
	dc.w	$0180,$0348
;	IFGT	(256-VEND)
	dc.w	$0007+(VEND<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0108,-ScreenWidth/8*4
	dc.w	$010a,-ScreenWidth/8*4
ColorCopper2_:
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
	dc.w	$0007+((VEND+1)<<8),$fffe
	dc.w	$0180,$0124
	dc.w	$0100,(5<<12)
	dc.w	$ffdf,$fffe
	dc.w	$0007+((VEND2)<<8),$fffe
	dc.w	$0180,$0fff
	dc.w	$0100,$0000
	dc.w	$0007+((VEND2+1)<<8),$fffe
	dc.w	$0180,$0000
;	endc
	dc.w	$ffff,$fffe

;-----------
Copper3:
	dc.w	$01fc,$000c
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0007+((VSTART-1)<<8),$fffe
	dc.w	$0180,$0fff
	dc.w	$0100,$0200
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HSTART+ScreenWidth+16-$100
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
;	dc.w	$0100,(Planes<<12)
	dc.w	$0100,(5<<12)
	dc.w	$0180,$0348
;	IFGT	(256-VEND)
	dc.w	$0007+(VEND<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0108,-ScreenWidth/8*4
	dc.w	$010a,-ScreenWidth/8*4
ColorCopper3_:
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
	dc.w	$0007+((VEND+1)<<8),$fffe
	dc.w	$0180,$0124
	dc.w	$0100,(5<<12)
	dc.w	$ffdf,$fffe
	dc.w	$0007+((VEND2)<<8),$fffe
	dc.w	$0180,$0fff
	dc.w	$0100,$0000
	dc.w	$0007+((VEND2+1)<<8),$fffe
	dc.w	$0180,$0000
;	endc
	dc.w	$ffff,$fffe

QuadMask:
	dc.l 	%00011111111110000000000000000000
	dc.l 	%01111111111111100000000000000000
	dc.l 	%01111111111111100000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%11111111111111110000000000000000
	dc.l 	%01111111111111100000000000000000
	dc.l 	%01111111111111100000000000000000
	dc.l 	%00011111111110000000000000000000
*********************************************************************
	section mem,BSS_C
ChipMemory:
	ds.b	ScreenWidth/8*ScreenHeight*(8*4+1)
;--------------------------------------------------------------------
	section	data,DATA_P
Dither1:
	dc.l	0
Dither2:
	dc.l	0
ScreenTmp1:
	dc.l 	0
CarryScreen:
	dc.l 	0
Copper:
	dc.l	Copper1,Copper2,Copper3
Screens:
	dc.l	0,0,0
BltSrc:	dc.l	0
BltDst:	dc.l	0
BltClr:	dc.l	0
RAND:	dc.l 	0,0

Palette:
	dc.w	$0000
	dc.w	$0346
	dc.w	$0245
	dc.w	$0323
	dc.w	$0411
	dc.w	$0500
	dc.w	$0600
	dc.w	$0700	
	dc.w	$0800
	dc.w	$0900
	dc.w	$0a00
	dc.w	$0b10
	dc.w	$0c20
	dc.w	$0d30
	dc.w	$0e40
	dc.w	$0f50
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
Palette_:
	dc.w	$0000
	dc.w	$0124
	dc.w	$0124
	dc.w	$0224
	dc.w	$0224
	dc.w	$0324
	dc.w	$0324
	dc.w	$0424	
	dc.w	$0424
	dc.w	$0524
	dc.w	$0524
	dc.w	$0624
	dc.w	$0634
	dc.w	$0734
	dc.w	$0734
	dc.w	$0834
	dc.w	$0844
	dc.w	$0844
	dc.w	$0854
	dc.w	$0854
	dc.w	$0864
	dc.w	$0864
	dc.w	$0864
	dc.w	$0864
	dc.w	$0874
	dc.w	$0874
	dc.w	$0874
	dc.w	$0874
	dc.w	$0884
	dc.w	$0884
	dc.w	$0884
	dc.w	$0884

*********************************************************************
