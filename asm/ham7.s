ScreenWidth = 1280
ScreenHeight= 192
Planes= 8
Pl=0
Frames=10

DEN_CPU68000	=0			;1=speed gain for 68000 ONLY. +12b code
DEN_SIZEOPTI	=0			;1=1.1% slower, -30b code.
DEN_FLASHADDR	=0			;or f.ex. $dff181 to flash a color reg.
DEN_BINARY	=0			;1=use binary, else use the source Luke

	include "blitterhelper.i"
	include "custom.i"

	xdef	_Ham7_Init
	xref	_InterruptSub
	xref	_loadNext	
	xref	_Frames
	xref	_DeinitSub
	xref	SP_HAM7SCR
	xref	_PreHam7
	xref	AEnd
	xref	pDOSBase	

	xdef	YUV_RGB

	section	ham7,CODE_F

;---------Bitplane init ----------
_Ham7_Init:
	lea	Bitplane1,a0
	move.l	#ChipMemory,d0
	move.l 	d0,Screens
	move.l	#Planes-1,d1
.l1:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8,d0
	add.l	#8,a0
	dbf	d1,.l1
	add.l	#ScreenWidth/8*Planes*(ScreenHeight-1),d0

	lea	Bitplane2,a0
	move.l 	d0,Screens+4
	move.l	#Planes-1,d1
.l2:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8,d0
	add.l	#8,a0
	dbf	d1,.l2
	add.l	#ScreenWidth/8*Planes*(ScreenHeight-1),d0

	lea	Bitplane3,a0
	move.l 	d0,Screens+8
	move.l	#Planes-1,d1
.l3:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8,d0
	add.l	#8,a0
	dbf	d1,.l3
	add.l	#ScreenWidth/8*Planes*(ScreenHeight-1),d0

;	lea	BitplaneSecond,a0
;	lea SecondCopperList,a4
;	move.w	#(SecondCopperListEnd-SecondCopperList)/4-1,d0
;.l9:
;	move.l	(a4)+,d7
;	move.l	d7,(a0)+
;	dbf		d0,.l9
	
	
;	move.l	#down_pic+62,a0
;	move.l	#ScreenWidth/8*24/4-1,d1
;.l5:
;	eor.l	#$ffffffff,(a0)+
;	dbf	d1,.l5

;	lea	BitplaneSecond,a0
;	move.l	#down_pic+62,d0
;	move.l	#8-1,d1
;.l4:
;	move.w	d0,6(a0)
;	swap	d0
;	move.w	d0,2(a0)
;	swap	d0
;	add.l	#ScreenWidth/8*24,d0
;	add.l	#8,a0
;	dbf	d1,.l4
	
;	lea	Bitplane1_top,a0
;	move.l	#pic_top,d0
;	move.l	#8-1,d1
;.l6:
;	move.w	d0,6(a0)
;	swap	d0
;	move.w	d0,2(a0)
;	swap	d0
;	add.l	#ScreenWidth*2/8*9,d0
;	add.l	#8,a0
;	dbf	d1,.l6

;	lea		font8x8_basic+62,a1
;	move.w	#16*16*8/4-1,d0
;.l7:
;	eor.l	#$ffffffff,(a1)+
;	dbf		d0,.l7

	move.l	#CopperBase,d0
	move.w	d0,CopperAdrEnd+6
	swap	d0
	move.w	d0,CopperAdrEnd+2

	move.l	#SecondCopperList,d0
	move.w	d0,CopperAdr1+6
	move.w	d0,CopperAdr2+6
	move.w	d0,CopperAdr3+6
	swap	d0
	move.w	d0,CopperAdr1+2
	move.w	d0,CopperAdr2+2
	move.w	d0,CopperAdr3+2

	lea	Palette,a0
	lea	ColorCopper,a2
	move.w	#2-1,d7
.clo1:	
	move.w	a2,a1
	swap	d7
	move.w	#32-1,d7
.clo:	
	move.l	(a0)+,d0
	move.w	d0,4*32+4+6(a1)
	swap	d0
	move.w	d0,6(a1)
	add.l	#4,a1
	dbf	d7,.clo
	add.l	#4*33*2,a2
	swap	d7
	dbf	d7,.clo1

	move.l 	#_Ham7_InnerLoop,a0
	move.l 	a0,_InterruptSub

;	move.l	_Frames,d0
;	move.l 	d0,lastframe
	
	move.l 	#_Ham7_Deinit,a0
	move.l	a0,_DeinitSub
	
;	bsr 	PlaySample

;	bsr 	LoadMyVidFile

;	lea		pic,a0
;	move.w	#$001f,d0
;	move.w	#320-1,d7
;.fl:
;	move.w	d0,(a0)+
;	dbf		d7,.fl

	move.l	#%01100110011001100110011001100110,d0
	move.l	#%11011101110111011101110111011101,d1
	move.l	Screens,a0
	move.l	Screens+4,a1
	move.l	Screens+8,a2
	move.w	#ScreenHeight-1,d7
.lp1:
	swap	d7
	move.w	#ScreenWidth/32-1,d7
.lp:
	move.l	d1,ScreenWidth/8(a0)
	move.l	d0,(a0)+
	move.l	d1,ScreenWidth/8(a1)
	move.l	d0,(a1)+
	move.l	d1,ScreenWidth/8(a2)
	move.l	d0,(a2)+
	dbf		d7,.lp
	add.l	#ScreenWidth/8*(Planes-1),a0
	add.l	#ScreenWidth/8*(Planes-1),a1
	add.l	#ScreenWidth/8*(Planes-1),a2
	swap	d7
	dbf		d7,.lp1

	; r3g3b3r4 r0g0b0g4 r2g2b2XX r1g1b1b4

	lea		YUV_RGB,a0
	jsr		_PreHam7			
			
	rts
;---------------------------------
_Ham7_Deinit:
	move.l	#$fffffffe,CopperAdr
	rts
;---------------------------------
_Ham7_InnerLoop:

;	move.w 	#$fff,$dff180
	
	bsr	RenderLoop
	
	lea	Screens,a0
	bsr	Switch
	lea	Copper,a0
	bsr	Switch

	bra	te

	move.w	DownColLast,d0
	move.w	DownPosLast,d1
	lea		DownCol,a0
	move.l	d1,d2
	lsl.w	#2,d2
	move.l	(a0,d2.w),a1
	move.w	d0,2(a1)
	move.w	#$0fff,6(a1)
	add.w	#1,d1
	cmp.w	#28*2,d1
	bne.b	.not
	move.w	#0,d1
.not:
	move.w	d1,DownPosLast
	move.w	d1,d2
	lsl.w	#2,d2
	move.l	(a0,d2.w),a1
	move.w	2(a1),DownColLast
	move.w	#$088f,2(a1)
	move.w	#$0ff0,6(a1)

.norender:
	bsr.b	DrawText

te:
	add.l	#1,lastframe
;	cmp.l	#294,lastframe
;	bne.b	.sf
;	move.l	#0,lastframe
.sf:	
;	move.w 	#$f00,$dff180	

	move.l	Copper,d0
	move.w	d0,CopperAdr+6
	swap	d0
	move.w	d0,CopperAdr+2
	move.l	#CopperBase,$dff080
	
;	bsr BlitWait
;	move.w	_BlitListEnd+2,_BlitListEnd
;	jsr	_StartBlitList
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
copyblock_empty:
	movem.l	d0/d1/d2/d3/d6/a1/a2/a3,-(sp)
	move.w	(a0)+,d6
	move.w	d6,d0
	and.w	#$f,d6
	cmp.w	#0,d6
	bne.b	.cbe1
	move.w	(a0)+,d6
	move.w	d6,d0
	swap	d0
	move.w	d6,d0
	move.w	#15,d6
.cbe0_0:
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	add.l	#(320-16)*2,a2
	dbf		d6,.cbe0_0
	bra.b	.cbe_end
.cbe1:	
	cmp.w	#1,d6
	bne.b	.cbe2
	move.w	#15,d6
.cbe1_0:
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	add.l	#(320-16)*2,a2
	dbf		d6,.cbe1_0
	bra.b	.cbe_end
.cbe2:
	move.l	a0,a1
	move.w	d0,d6
	lsr.w	#8,d6
	lsr.w	#5,d6
	move.w	#1,d3
	lsl.w	d6,d3
	sub.w	#1,d3
	lsr.l	#4,d0
	and.w	d3,d0
	addq	#1,d0
	add.w	d0,a0
	add.w	d0,a0
	eor.l	d1,d1
	moveq	#17,d2
	move.l	#(320-16)*2,d5
.cbe4_6:
	swap	d1
	eor.w	d1,d1
	move.b	(a0)+,d1
	move.w	d1,d0
	and.w	d3,d1
	lsr.w	d6,d0
	move.w	(a1,d1.w*2),d1
	swap	d1
	add.w	#1,d1
	add.w	d0,d1
	swap	d1
.cbe4_4:
	subq	#1,d2
	beq.b	.cbe4_2
.cbe4_3:
	move.w	d1,(a2)+
	dbf		d0,.cbe4_4
	bra.b	.cbe4_5
.cbe4_2:
	add.l	d5,a2
	moveq	#16,d2
	bra.b	.cbe4_3
.cbe4_5:
	swap	d1
	cmp.w	#256,d1
	bne.b	.cbe4_6
	move.l	a0,d0
	and.l	#1,d0
	beq.b	.cbe4_7
	addq	#1,a0
.cbe4_7:
	bra.b	.cbe_end

.cbe_end:
	movem.l	(sp)+,d0/d1/d2/d3/d6/a1/a2/a3
	rts
;--------------------------------------------------------------------	
copyblock:
	movem.l	d0/d1/d4/d6/d7/a1/a2/a3,-(sp)
	add.l	d0,a1
	add.l	d0,a1
	move.w	(a0)+,d6
	move.w	d6,d0
	and.w	#$f,d6
	cmp.w	#0,d6
	bne.b	.cb1
	move.w	(a0)+,d6
	move.w	d6,d1
	swap	d1
	move.w	d6,d1
	move.l	#$7fff7fff,d7
	move.w	#15,d6
.cb0_1:
	move.l	d1,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	d1,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	d1,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	d1,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	d1,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	d1,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	d1,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	d1,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	add.l	#(320-16)*2,a1
	add.l	#(320-16)*2,a2
	dbf		d6,.cb0_1
	bra.b	.cb_end 
.cb1:
	cmp.w	#1,d6
	bne.b	.cb2
	move.l	#$7fff7fff,d7
	move.w	#15,d6
.cb1_1:
	move.l	(a0)+,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	(a0)+,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	(a0)+,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	(a0)+,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	(a0)+,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	(a0)+,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	(a0)+,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	move.l	(a0)+,d0
	add.l	(a1)+,d0
	and.l	d7,d0
	move.l	d0,(a2)+
	add.l	#(320-16)*2,a1
	add.l	#(320-16)*2,a2
	dbf		d6,.cb1_1
	bra.b 	.cb_end
	
.cb2:
	move.l	a0,a3
	move.w	d0,d6
	lsr.w	#8,d6
	lsr.w	#5,d6
	move.w	#1,d7
	lsl.w	d6,d7
	sub.w	#1,d7
	lsr.l	#4,d0
	and.w	d7,d0
	addq	#1,d0
	add.w	d0,a0
	add.l	d0,a0
	eor.l	d1,d1
	move.w	#$7fff,d4
	moveq	#17,d2
	move.l	#(320-16)*2,d5
.cb4_6:
	swap	d1
	eor.w	d1,d1
	move.b	(a0)+,d1
	move.w	d1,d0
	and.w	d7,d1
	lsr.w	d6,d0
	move.w	(a3,d1.w*2),d1
	swap	d1
	add.w	#1,d1
	add.w	d0,d1
	swap	d1
.cb4_4:
	subq	#1,d2
	beq.b	.cb4_2
.cb4_3:
	move.w	d1,d3
	add.w	(a1)+,d3
	and.w	d4,d3
	move.w	d3,(a2)+
	dbf		d0,.cb4_4
	bra.b	.cb4_5
.cb4_2:
	add.l	d5,a1
	add.l	d5,a2
	moveq	#16,d2
	bra.b	.cb4_3
.cb4_5:
	swap	d1
	cmp.w	#256,d1
	bne.b	.cb4_6
	move.l	a0,d0
	and.l	#1,d0
	beq.b	.cb4_7
	addq	#1,a0
.cb4_7:
	bra.b 	.cb_end
.cb_end:
	movem.l	(sp)+,d0/d1/d4/d6/d7/a1/a2/a3
	rts
;--------------------------------------------------------------------	
DrawText:
	rts
	move.w	Scroll,d2
	move.w	d2,d1
	lsr.w	#3,d1
	move.w	d2,d3
	and.w	#$1f,d2
	bne.b	.endText
	lsr.w	#5,d3
	lea		text,a2
;	lea		font8x8_basic+62,a1

	lea		pic_top,a0
	add.w	d3,a0
	move.w	TextPos,d7

.drText:
	eor.l	d0,d0
	move.w	(a2,d7.w),d0
	cmp.w	#$0d0a,d0
	bne.b	.no0D0A
	add.w	#2,d7
	bra.b	.drText
.no0D0A:
	eor.l	d0,d0
	move.b	(a2,d7.w),d0
	bne.b 	.drText2
;	bra .endText
	move.w	#0,d7
	move.w	d7,TextPos
	bra.b	.drText
.drText2:
	move.w	d0,d1
	and.w	#$f,d1
	eor.w	d1,d0
	lsl.w	#3,d0
	add.w	d1,d0
	move.l	a0,a2
	add.w	#704/8,a2
	move.b	(a1,d0.w),(a0)
	move.b	16*1(a1,d0.w),ScreenWidth*2/8*1(a0)
	move.b	16*2(a1,d0.w),ScreenWidth*2/8*2(a0)
	move.b	16*3(a1,d0.w),ScreenWidth*2/8*3(a0)
	move.b	16*4(a1,d0.w),ScreenWidth*2/8*4(a0)
	move.b	16*5(a1,d0.w),ScreenWidth*2/8*5(a0)
	move.b	16*6(a1,d0.w),ScreenWidth*2/8*6(a0)
	move.b	16*7(a1,d0.w),ScreenWidth*2/8*7(a0)
	move.b	(a1,d0.w),(a2)
	move.b	16*1(a1,d0.w),ScreenWidth*2/8*1(a2)
	move.b	16*2(a1,d0.w),ScreenWidth*2/8*2(a2)
	move.b	16*3(a1,d0.w),ScreenWidth*2/8*3(a2)
	move.b	16*4(a1,d0.w),ScreenWidth*2/8*4(a2)
	move.b	16*5(a1,d0.w),ScreenWidth*2/8*5(a2)
	move.b	16*6(a1,d0.w),ScreenWidth*2/8*6(a2)
	move.b	16*7(a1,d0.w),ScreenWidth*2/8*7(a2)
	add.w	#1,d7
	move.w	d7,TextPos	
.endText:

	
	move.w	Scroll,d2
	move.w	d2,d1
;	lsr.w	#1,d1
	move.w	#$3f,d0
	sub.w	d1,d0
	and.w	#$3f,d0
	move.w	d0,d1
	lsr.w	#3,d0
	and.w	#7,d1
	lsr.w	#1,d1
	lsl.w	#8,d1
	or.w	d1,d0
;	move.w	d0,Scrolling+2

	lea	Bitplane1_top,a0
	move.l	#pic_top,d0
	move.w	Scroll,d3
	lsr.w	#6,d3
	ext.l	d3
	add.l	d3,d0
	add.l	d3,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.w	Scroll,d2
	add.w	#1,d2
	cmp.w	#4*704,d2
	blt.b	.endf
	move.w	#$0,d2
.endf:
	move.w	d2,Scroll
	rts
;--------------------------------------------------------------------	
RenderImage:
;	lea		picorgNibble,a0
;	lea 	picorg,a1
;	bsr.b 	Denibble

	lea		pic,a2
	move.l	lastframe,d0
	and.l	#1,d0
	mulu.l	#320*192*2,d0
	add.l	d0,a2			;dst

	move.l	picorgPtr,a0
;	lea	picorg,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	a0,a6
	add.l	d1,a6
	add.l	d1,a6
	move.l	a6,picorgPtr
	cmp.l	#0,d0
	bne.b	.lgd
	move.w	#192/16-1,d6
.lgd2_:
	move.w	#320/16-1,d7
.lgd1_:
	bsr.b	copyblock_empty
	add.l	#16*2,a2
	dbf		d7,.lgd1_
	add.l	#(320*(16-1))*2,a2
	dbf		d6,.lgd2_
	
	bra.b	.RIende
.lgd:
	move.l	a0,a3
	add.l	#320/16*192/16*2,a0					; thisblock

	lea		pic,a1
	move.l	lastframe,d0
	add.l	#1,d0
	and.l	#1,d0
	mulu.l	#320*192*2,d0
	add.l	d0,a1

	move.w	#192/16-1,d6
.cp2:
	swap	d6
	move.w	#320/16-1,d6
.cp0:
	eor.l	d0,d0
	move.w	(a3)+,d0						; thisblockadd
	cmp.w	#$ffff,d0
	beq.b	.ldg
	bsr		copyblock
	bra.b	.ldg1
.ldg:	
	bsr		copyblock_empty
.ldg1:
	add.l	#16*2,a2
	dbf		d6,.cp0
	add.l	#320*(16-1)*2,a2
	swap	d6
	dbf		d6,.cp2
.RIende:

	move.l	picorgPtr,a6
	cmp.l	#picorgend,a6
	bne.b	.lcf
	lea		picorg,a6
	move.l	a6,picorgPtr
.lcf:
	lea		pic,a0
	move.l	lastframe,d0
	and.l	#1,d0
	mulu.l	#320*192*2,d0
	add.l	d0,a0
	move.l	Screens+8,a1	;pointer to interleaved 8bpl ham8 screen
	jsr	SP_HAM7SCR
	rts
;--------------------------------------------------------------------	
RenderLoop:

;	bsr 	LoadMyVidFile

	bsr		RenderImage

;	bsr 	LoadMySndFile

	lea 	pic,a0
	move.l	SndPos,d0
	lea		SoundData,a1
	move.w 	#221-1,d7
RL1:
	move.l (a0)+,d1
	move.l d1,(a1,d0)
	add.l 	#4,d0
	cmp.l	#22096,d0
	bne.b	.mm
	moveq	#0,d0
.mm:
	dbf 	d7,RL1
	move.l	d0,SndPos

	move.l 	picindex,d0	
	addq 	#1,d0
	cmp.l	#Frames,d0
	bne	.nn
	move.l	#0,d0
.nn:	move.l 	d0,picindex

	rts
;--------------------------------------------------------------------	
LoadMySndFile:
	move.l 	#filenameSnd,d0
	move.l	d0,filenameptr
	
	move.l 	picindex,d0
	mulu	#884,d0
	add.l 	#10000,d0		;org
	move.l 	d0,fileseek

	move.l #884*2,d0
	move.l d0,filesize

	move.l	#pic,d0
	move.l	d0,filedest
	
	bsr		loadfile
	rts
;--------------------------------------------------------------------	
LoadMyVidFile:
	move.l 	#filenameVid,d0
	move.l	d0,filenameptr
	
	move.l 	picindex,d0
	mulu #ScreenWidth/8*ScreenHeight*2,d0
	add.l 	d0,d0
	add.l 	d0,d0
	move.l	#0,d0
	move.l 	d0,fileseek

	move.l #ScreenWidth/8*ScreenHeight*8*Frames,d0
	move.l d0,filesize

	move.l	#pic,d0
;	move.l	Screens,d0
	move.l	d0,filedest

;	lea		pic,a0
;	move.l	Screens,A1		; destination (planar)
;	jsr	_BEST_c2p
	
	bsr		loadfile
	rts
;--------------------------------------------------------------------	
openfile:
	move.l	pDOSBase,a6	;gimme dos in a6
	moveq #0,d6			;filesize or 0 if not ok
	move.l filenameptr,d1
	move.l #1005,d2		;mode_old - file must exist
	jsr -30(a6)			;DOS Open()
	move.l 	d0,filehandle
	rts
;--------------------------------------------------------------------	
closefile:
	move.l filehandle,d1			;file handle
	jsr -36(a6)			;DOS Close()
	rts
;--------------------------------------------------------------------	
loadfile:
;	bsr changefileindex

	move.l 	picindex,d0
;	and.l 	#7,d0
;	beq.b 	.loadingNext8
;	rts
.loadingNext8:
	bsr 	openfile	
	move.l filehandle,d5			;copy file handle
	beq.s .error1

;-66 : Seek(file,position,offset)(D1/D2/D3)
	move.l d5,d1			;filehdl
	move.l #-1,d3
	move.l 	fileseek,d2
	jsr -66(a6)			;DOS Seek()

	move.l d5,d1			;filehdl
;	move.l Screens,d2
	move.l filedest,d2		;addr
	move.l filesize,d7
	move.l d7,d3		;maxlen cap
	jsr -42(a6)			;DOS Read()
	cmp.l d7,d0
	bne.s .error2
	move.l d7,d6			;loading ok! (set to size!)
;.notok:	
	move.l filehandle,d1			;copy file handle
	bsr 	closefile
	rts
.error1:
;	move.w 	#$f0,ColorCopper1+2
	rts
.error2:
;	move.w 	#$f00,ColorCopper1+2
	bsr 	closefile
	move.l 	#0,picindex
;	move.w 	#1,AEnd
	rts
;--------------------------------------------------------------------	
	IF DEN_BINARY=1
Denibble:
	INCBIN "Denibbler102.bin"	;binary for CPU68000=0 & SIZEOPTI=1
	ELSE
	INCLUDE "Denibbler102.S"	;source
	ENDC
;--------------------------------------------------------------------	
PlaySample:
	
	lea     CUSTOM,a0       ; Custom chip base address
	lea     SoundData,a1 ;Address of data to
							;  audio location register 0

	move.l  a1,AUD0LCH(a0)  ;The 680x0 writes this as though it were a
							;  32-bit register at the low-bits location
							;  (common to all locations and pointer
							;  registers in the system).
	move.l  a1,AUD1LCH(a0)  ;The 680x0 writes this as though it were a
							;  32-bit register at the low-bits location
							;  (common to all locations and pointer
							;  registers in the system).
	move.w  #22096/2,AUD0LEN(a0)  ;Set length in words
	move.w  #22096/2,AUD1LEN(a0)  ;Set length in words
	move.w  #48,AUD0VOL(a0) ;Use maximum volume
	move.w  #48,AUD1VOL(a0) ;Use maximum volume
	move.w  #161,AUD0PER(a0)
	move.w  #161,AUD1PER(a0)
	move.w  #(DMAF_SETCLR!DMAF_AUD0!DMAF_AUD1!DMAF_MASTER),DMACON(a0)

	rts                     ; Return to main code...
;--------------------------------------------------------------------	
	SECTION	chip,DATA_C
down_pic:
	incbin 	down_pic.bmp
	ds.b	ScreenWidth/8*24*7
;-----------
; display dimensions
DISPW           equ     ScreenWidth/4
DISPH           equ     ScreenHeight
HSTART          equ     129+(256-DISPW)/4-32
HEND 	        equ     HSTART+DISPW-$100+64
VSTART          equ     36; +(256-ScreenHeight)/2-10
VEND            equ     VSTART+DISPH
DFETCHSTART     equ     HSTART/2
DFETCHSTOP      equ     DFETCHSTART+8*((DISPW/16)-1)

MODE 			equ		HIRES+HAM+COLORBURST+$11+$40
MODE_DOWN		equ		0;COLORBURST+HIRES+$10
;-----------
CopperBase:
	dc.w	$01fc,$4003
	dc.w	$0180,$0000

Bitplane1_top:
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
	dc.w	$00f8,$0000
	dc.w	$00fa,$0000
	dc.w	$00fc,$0000
	dc.w	$00fe,$0000

;	dc.w	$0106,$0020
;	dc.w	$0182,$0fff

;	dc.w	$008e,$2c00+HSTART+48
;	dc.w	$0090,$2c00+HEND-24
;	dc.w	$0092,DFETCHSTART
;	dc.w	$0094,DFETCHSTOP
;	dc.w	$0108,ScreenWidth/8
;	dc.w	$010a,ScreenWidth/8
;Scrolling:
;	dc.w	$0102,$0044

;	dc.w	$0007+((VSTART-18)<<8),$fffe
;	dc.w	$0180,$044f
;	dc.w	$0007+((VSTART-17)<<8),$fffe
;	dc.w	$0180,$033f
;	dc.w	$0007+((VSTART-16)<<8),$fffe
;	dc.w	$0180,$022f
;	dc.w	$0007+((VSTART-15)<<8),$fffe
;	dc.w	$0180,$011f
;	dc.w	$0100,(0<<12)+MODE_DOWN
;	dc.w	$0007+((VSTART-14)<<8),$fffe
;	dc.w	$0180,$000f

;	dc.w	$0007+((VSTART-8)<<8),$fffe
;	dc.w	$0180,$011f
;	dc.w	$0007+((VSTART-7)<<8),$fffe
;	dc.w	$0180,$022f
;	dc.w	$0100,$0000
;	dc.w	$0007+((VSTART-6)<<8),$fffe
;	dc.w	$0180,$033f
;	dc.w	$0007+((VSTART-5)<<8),$fffe
;	dc.w	$0180,$044f
;	dc.w	$0007+((VSTART-4)<<8),$fffe
;	dc.w	$0180,$0000

ColorCopper:
	dc.w	$0106,$0020
	dc.w	$0180,$0000
	dc.w	$0182,$0000
	dc.w	$0184,$0000
	dc.w	$0186,$0000
	dc.w	$0188,$0111
	dc.w	$018a,$0111
	dc.w	$018c,$0111
	dc.w	$018e,$0111
	dc.w	$0190,$0222
	dc.w	$0192,$0222
	dc.w	$0194,$0222
	dc.w	$0196,$0222
	dc.w	$0198,$0333
	dc.w	$019a,$0333
	dc.w	$019c,$0333
	dc.w	$019e,$0333
	dc.w	$01a0,$0444
	dc.w	$01a2,$0444
	dc.w	$01a4,$0444
	dc.w	$01a6,$0444
	dc.w	$01a8,$0555
	dc.w	$01aa,$0555
	dc.w	$01ac,$0555
	dc.w	$01ae,$0555
	dc.w	$01b0,$0666
	dc.w	$01b2,$0666
	dc.w	$01b4,$0666
	dc.w	$01b6,$0666
	dc.w	$01b8,$0777
	dc.w	$01ba,$0777
	dc.w	$01bc,$0777
	dc.w	$01be,$0777

	dc.w	$0106,$0220
	dc.w	$0180,$0000
	dc.w	$0182,$0444
	dc.w	$0184,$0888
	dc.w	$0186,$0ccc
	dc.w	$0188,$0000
	dc.w	$018a,$0444
	dc.w	$018c,$0888
	dc.w	$018e,$0ccc
	dc.w	$0190,$0000
	dc.w	$0192,$0444
	dc.w	$0194,$0888
	dc.w	$0196,$0ccc
	dc.w	$0198,$0000
	dc.w	$019a,$0444
	dc.w	$019c,$0888
	dc.w	$019e,$0ccc
	dc.w	$01a0,$0000
	dc.w	$01a2,$0444
	dc.w	$01a4,$0888
	dc.w	$01a6,$0ccc
	dc.w	$01a8,$0000
	dc.w	$01aa,$0444
	dc.w	$01ac,$0888
	dc.w	$01ae,$0ccc
	dc.w	$01b0,$0000
	dc.w	$01b2,$0444
	dc.w	$01b4,$0888
	dc.w	$01b6,$0ccc
	dc.w	$01b8,$0000
	dc.w	$01ba,$0444
	dc.w	$01bc,$0888
	dc.w	$01be,$0ccc

	dc.w	$0106,$2020
	dc.w	$0180,$0888
	dc.w	$0182,$0888
	dc.w	$0184,$0888
	dc.w	$0186,$0888
	dc.w	$0188,$0999
	dc.w	$018a,$0999
	dc.w	$018c,$0999
	dc.w	$018e,$0999
	dc.w	$0190,$0aaa
	dc.w	$0192,$0aaa
	dc.w	$0194,$0aaa
	dc.w	$0196,$0aaa
	dc.w	$0198,$0bbb
	dc.w	$019a,$0bbb
	dc.w	$019c,$0bbb
	dc.w	$019e,$0bbb
	dc.w	$01a0,$0ccc
	dc.w	$01a2,$0ccc
	dc.w	$01a4,$0ccc
	dc.w	$01a6,$0ccc
	dc.w	$01a8,$0ddd
	dc.w	$01aa,$0ddd
	dc.w	$01ac,$0ddd
	dc.w	$01ae,$0ddd
	dc.w	$01b0,$0eee
	dc.w	$01b2,$0eee
	dc.w	$01b4,$0eee
	dc.w	$01b6,$0eee
	dc.w	$01b8,$0fff
	dc.w	$01ba,$0fff
	dc.w	$01bc,$0fff
	dc.w	$01be,$0fff
	
	dc.w	$0106,$2220
	dc.w	$0180,$0000
	dc.w	$0182,$0444
	dc.w	$0184,$0888
	dc.w	$0186,$0ccc
	dc.w	$0188,$0000
	dc.w	$018a,$0444
	dc.w	$018c,$0888
	dc.w	$018e,$0ccc
	dc.w	$0190,$0000
	dc.w	$0192,$0444
	dc.w	$0194,$0888
	dc.w	$0196,$0ccc
	dc.w	$0198,$0000
	dc.w	$019a,$0444
	dc.w	$019c,$0888
	dc.w	$019e,$0ccc
	dc.w	$01a0,$0000
	dc.w	$01a2,$0444
	dc.w	$01a4,$0888
	dc.w	$01a6,$0ccc
	dc.w	$01a8,$0000
	dc.w	$01aa,$0444
	dc.w	$01ac,$0888
	dc.w	$01ae,$0ccc
	dc.w	$01b0,$0000
	dc.w	$01b2,$0444
	dc.w	$01b4,$0888
	dc.w	$01b6,$0ccc
	dc.w	$01b8,$0000
	dc.w	$01ba,$0444
	dc.w	$01bc,$0888
	dc.w	$01be,$0ccc

	dc.w	$0106,$0020
	
CopperAdr:
	dc.w	$0080,$0000
	dc.w	$0082,$0000
	dc.w	$0088,$0000
	dc.w	$ffff,$fffe

Copper1:	
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HEND
	dc.w	$0092,DFETCHSTART
	dc.w	$0094,DFETCHSTOP
	dc.w	$0108,ScreenWidth/8*(Planes-1)
	dc.w	$010a,ScreenWidth/8*(Planes-1)
	dc.w	$0102,$0000
	dc.w	$0104,$0200
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
	dc.w	$00f8,$0000
	dc.w	$00fa,$0000
	dc.w	$00fc,$0000
	dc.w	$00fe,$0000

	dc.w	$0106,$00c0
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0096,$87d0
	dc.w	$0100,(Pl<<12)+MODE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0096,$84d0
	dc.w	$0180,$0000
	dc.w	$0100,$0000

CopperAdr1:
	dc.w	$0080,$0000
	dc.w	$0082,$0000
	dc.w	$0088,$0000

;-----------
Copper2:
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HEND
	dc.w	$0092,DFETCHSTART
	dc.w	$0094,DFETCHSTOP
	dc.w	$0108,ScreenWidth/8*(Planes-1)
	dc.w	$010a,ScreenWidth/8*(Planes-1)
	dc.w	$0102,$0000
	dc.w	$0104,$0200
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
	dc.w	$00f8,$0000
	dc.w	$00fa,$0000
	dc.w	$00fc,$0000
	dc.w	$00fe,$0000

	dc.w	$0106,$0020
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0096,$87d0
	dc.w	$0100,(Pl<<12)+MODE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0096,$84d0
	dc.w	$0180,$0000
	dc.w	$0100,$0000

CopperAdr2:
	dc.w	$0080,$0000
	dc.w	$0082,$0000
	dc.w	$0088,$0000

;-----------
Copper3:
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HEND
	dc.w	$0092,DFETCHSTART
	dc.w	$0094,DFETCHSTOP
	dc.w	$0108,ScreenWidth/8*(Planes-1)
	dc.w	$010a,ScreenWidth/8*(Planes-1)
	dc.w	$0102,$0000
	dc.w	$0104,$0200
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
	dc.w	$00f8,$0000
	dc.w	$00fa,$0000
	dc.w	$00fc,$0000
	dc.w	$00fe,$0000

	dc.w	$0106,$0020
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0096,$87d0
	dc.w	$0100,(Pl<<12)+MODE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0096,$84d0
	dc.w	$0180,$0000
	dc.w	$0100,$0000
CopperAdr3:
	dc.w	$0080,$0000
	dc.w	$0082,$0000
	dc.w	$0088,$0000
	
SecondCopperList:
CopperAdrEnd:
	dc.w	$0080,$0000
	dc.w	$0082,$0000
	dc.w	$ffff,$fffe
SecondCopperListEnd:
BitplaneSecond:
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
	dc.w	$00f8,$0000
	dc.w	$00fa,$0000
	dc.w	$00fc,$0000
	dc.w	$00fe,$0000

	dc.w	$0106,$0020
	dc.w	$0182,$0fff
	
	dc.w 	$ffdf,$fffe
	dc.w	$0007+(((VEND+4)&$ff)<<8),$fffe
CA:	dc.w	$0180,$044f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+5)&$ff)<<8),$fffe
CB:	dc.w	$0180,$033f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+6)&$ff)<<8),$fffe
CC:	dc.w	$0180,$022f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+7)&$ff)<<8),$fffe
CD:	dc.w	$0180,$011f
	dc.w	$0182,$0fff
	dc.w	$0100,(0<<12)+MODE_DOWN
	dc.w	$0007+(((VEND+8)&$ff)<<8),$fffe
CE:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+9)&$ff)<<8),$fffe
CF:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+10)&$ff)<<8),$fffe
CG:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+11)&$ff)<<8),$fffe
CH:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+12)&$ff)<<8),$fffe
CI:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+13)&$ff)<<8),$fffe
CJ:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+14)&$ff)<<8),$fffe
CK:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+15)&$ff)<<8),$fffe
CL:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+16)&$ff)<<8),$fffe
CM:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+17)&$ff)<<8),$fffe
CN:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+18)&$ff)<<8),$fffe
CO:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+19)&$ff)<<8),$fffe
CP:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+20)&$ff)<<8),$fffe
CQ:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+21)&$ff)<<8),$fffe
CR:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+22)&$ff)<<8),$fffe
CS:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+23)&$ff)<<8),$fffe
CT:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+24)&$ff)<<8),$fffe
CU:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+25)&$ff)<<8),$fffe
CU1:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+26)&$ff)<<8),$fffe
CU2:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+27)&$ff)<<8),$fffe
CU3:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+28)&$ff)<<8),$fffe
CU4:	dc.w	$0180,$000f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+29)&$ff)<<8),$fffe
CV:	dc.w	$0180,$011f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+30)&$ff)<<8),$fffe
CW:	dc.w	$0180,$022f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+31)&$ff)<<8),$fffe
CX:	dc.w	$0180,$033f
	dc.w	$0182,$0fff
	dc.w	$0100,$0000
	dc.w	$0007+(((VEND+32)&$ff)<<8),$fffe
CY:	dc.w	$0180,$044f
	dc.w	$0182,$0fff
	dc.w	$0007+(((VEND+33)&$ff)<<8),$fffe
	dc.w	$0180,$0000
;CopperAdrEnd:
;	dc.w	$0080,$0000
;	dc.w	$0082,$0000
;	dc.w	$ffff,$fffe
;SecondCopperListEnd:
;--------------------------------------------------------------------
*********************************************************************
	section mem,BSS_C
ChipMemory:
	ds.b	ScreenWidth/8*ScreenHeight*Planes*3
pic_top:
	ds.b	ScreenWidth*2/8*9*Planes
SoundData:                       ; Audio data must be in Chip memory
	ds.b	22096
;--------------------------------------------------------------------
	section	data,DATA_F
Copper:
	dc.l	Copper1,Copper2,Copper3
Screens:
	dc.l	0,0,0

Palette:
	dc.l	$00000000
	dc.l	$00000444
	dc.l	$00000888
	dc.l	$00000ccc
	dc.l	$01110000
	dc.l	$01110444
	dc.l	$01110888
	dc.l	$01110ccc
	dc.l	$02220000
	dc.l	$02220444
	dc.l	$02220888
	dc.l	$02220ccc
	dc.l	$03330000
	dc.l	$03330444
	dc.l	$03330888
	dc.l	$03330ccc
	dc.l	$04440000
	dc.l	$04440444
	dc.l	$04440888
	dc.l	$04440ccc
	dc.l	$05550000
	dc.l	$05550444
	dc.l	$05550888
	dc.l	$05550ccc
	dc.l	$06660000
	dc.l	$06660444
	dc.l	$06660888
	dc.l	$06660ccc
	dc.l	$07770000
	dc.l	$07770444
	dc.l	$07770888
	dc.l	$07770ccc
	dc.l	$08880000
	dc.l	$08880444
	dc.l	$08880888
	dc.l	$08880ccc
	dc.l	$09990000
	dc.l	$09990444
	dc.l	$09990888
	dc.l	$09990ccc
	dc.l	$0aaa0000
	dc.l	$0aaa0444
	dc.l	$0aaa0888
	dc.l	$0aaa0ccc
	dc.l	$0bbb0000
	dc.l	$0bbb0444
	dc.l	$0bbb0888
	dc.l	$0bbb0ccc
	dc.l	$0ccc0000
	dc.l	$0ccc0444
	dc.l	$0ccc0888
	dc.l	$0ccc0ccc
	dc.l	$0ddd0000
	dc.l	$0ddd0444
	dc.l	$0ddd0888
	dc.l	$0ddd0ccc
	dc.l	$0eee0000
	dc.l	$0eee0444
	dc.l	$0eee0888
	dc.l	$0eee0ccc
	dc.l	$0fff0000
	dc.l	$0fff0444
	dc.l	$0fff0888
	dc.l	$0fff0ccc

picorg:
	incbin	tmp00000.ppm
	incbin	tmp00001.ppm
	incbin	tmp00002.ppm
	incbin	tmp00003.ppm
	incbin	tmp00004.ppm
	incbin	tmp00005.ppm
	incbin	tmp00006.ppm
	incbin	tmp00007.ppm
	incbin	tmp00008.ppm
	incbin	tmp00009.ppm
	incbin	tmp00010.ppm
	incbin	tmp00011.ppm
	incbin	tmp00012.ppm
	incbin	tmp00013.ppm
	incbin	tmp00014.ppm
	incbin	tmp00015.ppm
	incbin	tmp00016.ppm
	incbin	tmp00017.ppm
	incbin	tmp00018.ppm
	incbin	tmp00019.ppm
	incbin	tmp00020.ppm
	incbin	tmp00021.ppm
	incbin	tmp00022.ppm
	incbin	tmp00023.ppm
	incbin	tmp00024.ppm
	incbin	tmp00025.ppm
	incbin	tmp00026.ppm
	incbin	tmp00027.ppm
	incbin	tmp00028.ppm
	incbin	tmp00029.ppm
	incbin	tmp00030.ppm
	incbin	tmp00031.ppm
	incbin	tmp00032.ppm
	incbin	tmp00033.ppm
	incbin	tmp00034.ppm
	incbin	tmp00035.ppm
	incbin	tmp00036.ppm
	incbin	tmp00037.ppm
	incbin	tmp00038.ppm
	incbin	tmp00039.ppm
	incbin	tmp00040.ppm
	incbin	tmp00041.ppm
	incbin	tmp00042.ppm
	incbin	tmp00043.ppm
	incbin	tmp00044.ppm
	incbin	tmp00045.ppm
	incbin	tmp00046.ppm
	incbin	tmp00047.ppm
	incbin	tmp00048.ppm
	incbin	tmp00049.ppm
	incbin	tmp00050.ppm
	incbin	tmp00051.ppm
	incbin	tmp00052.ppm
	incbin	tmp00053.ppm
	incbin	tmp00054.ppm
	incbin	tmp00055.ppm
	incbin	tmp00056.ppm
	incbin	tmp00057.ppm
	incbin	tmp00058.ppm
	incbin	tmp00059.ppm
	incbin	tmp00060.ppm
	incbin	tmp00061.ppm
	incbin	tmp00062.ppm
	incbin	tmp00063.ppm
	incbin	tmp00064.ppm
	incbin	tmp00065.ppm
	incbin	tmp00066.ppm
	incbin	tmp00067.ppm
	incbin	tmp00068.ppm
	incbin	tmp00069.ppm
	incbin	tmp00070.ppm
	incbin	tmp00071.ppm
	incbin	tmp00072.ppm
	incbin	tmp00073.ppm
	incbin	tmp00074.ppm
	incbin	tmp00075.ppm
	incbin	tmp00076.ppm
	incbin	tmp00077.ppm
	incbin	tmp00078.ppm
	incbin	tmp00079.ppm
	incbin	tmp00080.ppm
	incbin	tmp00081.ppm
	incbin	tmp00082.ppm
	incbin	tmp00083.ppm
	incbin	tmp00084.ppm
	incbin	tmp00085.ppm
	incbin	tmp00086.ppm
	incbin	tmp00087.ppm
	incbin	tmp00088.ppm
	incbin	tmp00089.ppm
	incbin	tmp00090.ppm
	incbin	tmp00091.ppm
	incbin	tmp00092.ppm
	incbin	tmp00093.ppm
	incbin	tmp00094.ppm
	incbin	tmp00095.ppm
	incbin	tmp00096.ppm
	incbin	tmp00097.ppm
	incbin	tmp00098.ppm
	incbin	tmp00099.ppm
	incbin	tmp00100.ppm
	incbin	tmp00101.ppm
	incbin	tmp00102.ppm
	incbin	tmp00103.ppm
	incbin	tmp00104.ppm
	incbin	tmp00105.ppm
	incbin	tmp00106.ppm
	incbin	tmp00107.ppm
	incbin	tmp00108.ppm
	incbin	tmp00109.ppm
	incbin	tmp00110.ppm
	incbin	tmp00111.ppm
	incbin	tmp00112.ppm
	incbin	tmp00113.ppm
	incbin	tmp00114.ppm
	incbin	tmp00115.ppm
	incbin	tmp00116.ppm
	incbin	tmp00117.ppm
	incbin	tmp00118.ppm
	incbin	tmp00119.ppm
	incbin	tmp00120.ppm
	incbin	tmp00121.ppm
	incbin	tmp00122.ppm
	incbin	tmp00123.ppm
	incbin	tmp00124.ppm
	incbin	tmp00125.ppm
	incbin	tmp00126.ppm
	incbin	tmp00127.ppm
	incbin	tmp00128.ppm
	incbin	tmp00129.ppm
	incbin	tmp00130.ppm
	incbin	tmp00131.ppm
	incbin	tmp00132.ppm
	incbin	tmp00133.ppm
	incbin	tmp00134.ppm
	incbin	tmp00135.ppm
	incbin	tmp00136.ppm
	incbin	tmp00137.ppm
	incbin	tmp00138.ppm
	incbin	tmp00139.ppm
	incbin	tmp00140.ppm
	incbin	tmp00141.ppm
	incbin	tmp00142.ppm
	incbin	tmp00143.ppm
	incbin	tmp00144.ppm
	incbin	tmp00145.ppm
	incbin	tmp00146.ppm
	incbin	tmp00147.ppm
	incbin	tmp00148.ppm
	incbin	tmp00149.ppm
	incbin	tmp00150.ppm
	incbin	tmp00151.ppm
	incbin	tmp00152.ppm
	incbin	tmp00153.ppm
	incbin	tmp00154.ppm
	incbin	tmp00155.ppm
	incbin	tmp00156.ppm
	incbin	tmp00157.ppm
	incbin	tmp00158.ppm
	incbin	tmp00159.ppm
	incbin	tmp00160.ppm
	incbin	tmp00161.ppm
	incbin	tmp00162.ppm
	incbin	tmp00163.ppm
	incbin	tmp00164.ppm
	incbin	tmp00165.ppm
	incbin	tmp00166.ppm
	incbin	tmp00167.ppm
	incbin	tmp00168.ppm
	incbin	tmp00169.ppm
	incbin	tmp00170.ppm
	incbin	tmp00171.ppm
	incbin	tmp00172.ppm
	incbin	tmp00173.ppm
	incbin	tmp00174.ppm
	incbin	tmp00175.ppm
	incbin	tmp00176.ppm
	incbin	tmp00177.ppm
	incbin	tmp00178.ppm
	incbin	tmp00179.ppm
	incbin	tmp00180.ppm
	incbin	tmp00181.ppm
	incbin	tmp00182.ppm
	incbin	tmp00183.ppm
	incbin	tmp00184.ppm
	incbin	tmp00185.ppm
	incbin	tmp00186.ppm
	incbin	tmp00187.ppm
	incbin	tmp00188.ppm
	incbin	tmp00189.ppm
	incbin	tmp00190.ppm
	incbin	tmp00191.ppm
	incbin	tmp00192.ppm
	incbin	tmp00193.ppm
	incbin	tmp00194.ppm
	incbin	tmp00195.ppm
	incbin	tmp00196.ppm
	incbin	tmp00197.ppm
	incbin	tmp00198.ppm
	incbin	tmp00199.ppm
	incbin	tmp00200.ppm
	incbin	tmp00201.ppm
	incbin	tmp00202.ppm
	incbin	tmp00203.ppm
	incbin	tmp00204.ppm
	incbin	tmp00205.ppm
	incbin	tmp00206.ppm
	incbin	tmp00207.ppm
	incbin	tmp00208.ppm
	incbin	tmp00209.ppm
	incbin	tmp00210.ppm
	incbin	tmp00211.ppm
	incbin	tmp00212.ppm
	incbin	tmp00213.ppm
	incbin	tmp00214.ppm
	incbin	tmp00215.ppm
	incbin	tmp00216.ppm
	incbin	tmp00217.ppm
	incbin	tmp00218.ppm
	incbin	tmp00219.ppm
	incbin	tmp00220.ppm
	incbin	tmp00221.ppm
	incbin	tmp00222.ppm
	incbin	tmp00223.ppm
	incbin	tmp00224.ppm
	incbin	tmp00225.ppm
	incbin	tmp00226.ppm
	incbin	tmp00227.ppm
	incbin	tmp00228.ppm
	incbin	tmp00229.ppm
	incbin	tmp00230.ppm
	incbin	tmp00231.ppm
	incbin	tmp00232.ppm
	incbin	tmp00233.ppm
	incbin	tmp00234.ppm
	incbin	tmp00235.ppm
	incbin	tmp00236.ppm
	incbin	tmp00237.ppm
	incbin	tmp00238.ppm
	incbin	tmp00239.ppm
	incbin	tmp00240.ppm
	incbin	tmp00241.ppm
	incbin	tmp00242.ppm
	incbin	tmp00243.ppm
	incbin	tmp00244.ppm
	incbin	tmp00245.ppm
	incbin	tmp00246.ppm
	incbin	tmp00247.ppm
	incbin	tmp00248.ppm
	incbin	tmp00249.ppm
	incbin	tmp00250.ppm
	incbin	tmp00251.ppm
	incbin	tmp00252.ppm
	incbin	tmp00253.ppm
	incbin	tmp00254.ppm
	incbin	tmp00255.ppm
	incbin	tmp00256.ppm
	incbin	tmp00257.ppm
	incbin	tmp00258.ppm
	incbin	tmp00259.ppm
	incbin	tmp00260.ppm
	incbin	tmp00261.ppm
	incbin	tmp00262.ppm
	incbin	tmp00263.ppm
	incbin	tmp00264.ppm
	incbin	tmp00265.ppm
	incbin	tmp00266.ppm
	incbin	tmp00267.ppm
	incbin	tmp00268.ppm
	incbin	tmp00269.ppm
	incbin	tmp00270.ppm
	incbin	tmp00271.ppm
	incbin	tmp00272.ppm
	incbin	tmp00273.ppm
	incbin	tmp00274.ppm
	incbin	tmp00275.ppm
	incbin	tmp00276.ppm
	incbin	tmp00277.ppm
	incbin	tmp00278.ppm
	incbin	tmp00279.ppm
	incbin	tmp00280.ppm
	incbin	tmp00281.ppm
	incbin	tmp00282.ppm
	incbin	tmp00283.ppm
	incbin	tmp00284.ppm
	incbin	tmp00285.ppm
	incbin	tmp00286.ppm
	incbin	tmp00287.ppm
	incbin	tmp00288.ppm
	incbin	tmp00289.ppm
	incbin	tmp00290.ppm
	incbin	tmp00291.ppm
	incbin	tmp00292.ppm
	incbin	tmp00293.ppm
	incbin	tmp00294.ppm
picorgend:
TextPos:
	dc.w	0
	even
SndPos:
	dc.l	884*8
filehandle:
	dc.l 	0
picindex:
	dc.l 	0
lastframe:
	dc.l	0
filenameptr:
	dc.l	0
fileseek:
	dc.l 	0
filesize:
	dc.l 	0
filedest:
	dc.l	0
DownColLast:
	dc.w	$000f
DownPosLast:
	dc.w	0
Scroll:
	dc.w	0
	even
DownCol:
	dc.l	CA,CB,CC,CD,CE,CF,CG,CH,CI,CJ,CK,CL,CM,CN,CO,CP,CQ,CR,CS,CT,CU,CU1,CU2,CU3,CU4,CV,CW,CX
	dc.l	CY,CX,CW,CV,CU4,CU3,CU2,CU1,CU,CT,CS,CR,CQ,CP,CO,CN,CM,CL,CK,CJ,CI,CH,CG,CF,CE,CD,CC,CB
filenameVid:
	dc.b 	"sc.tmp",0
	even
filenameSnd:
	dc.b 	"sc.iff",0
	even
;font8x8_basic:
;	incbin	font.bmp
	even
picorgPtr:
	dc.l	picorg
;picorgNibble:
;	incbin	tmp000.ppm.nib
text:
	incbin	text.txt
	dc.b	0
	section	pic,BSS_F
YUV_RGB:
	ds.w	32*32*32
pic:
	ds.b 	(ScreenWidth*ScreenHeight*2)*2
*********************************************************************
