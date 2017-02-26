ScreenWidth = 320
ScreenHeight= 256
Planes= 8
Pl=0

	include "blitterhelper.i"
	include "custom.i"

	xdef	_C2P_Init
	xref	_InterruptSub
	xref	_loadNext	
	xref	_Frames
	xref	_DeinitSub
	xref	_BEST_c2p
	xref	_WaitFrame
	xref	AEnd
	xref	pDOSBase	

	section	C2P_test,CODE_P

;---------Bitplane init ----------
_C2P_Init:

	lea	Bitplane1,a0
	move.l	#ChipMemory,d0
	move.l 	d0,Screens
	move.l	#Planes-1,d1
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
	move.l	#Planes-1,d1
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
	move.l	#Planes-1,d1
.l3:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a0
	dbf	d1,.l3

	lea	Palette,a0
	lea	ColorCopper,a2
	move.l	#0,d6
	move.w	#8-1,d7
.clo1:	
	move.l	a2,a1
	swap	d7
	move.w	#32-1,d7
.clo:	
;	move.l	d6,d0
;	move.l	d0,d1
;	and.l	#$f,d1
;	eor.l	d1,d0
;	lsr.w	#4,d0
;	swap	d0
;	move.w	d1,d0
;	move.l	d0,d1
;	lsl.l	#4,d1
;	or.l	d1,d0
;	lsl.l	#4,d1
;	or.l	d1,d0
;	move.l	(a0)+,d0
	move.l	d6,d0
	swap	d0
	move.w	d0,4*32+4+6(a1)
	swap	d0
	move.w	d0,6(a1)
	add.l	#1,d6
	add.l	#4,a1
	dbf	d7,.clo
	add.l	#4*33*2,a2
	swap	d7
	dbf	d7,.clo1

	move.l	#CopperBase,d0
	move.w	d0,CopperAdrEnd+6
	swap	d0
	move.w	d0,CopperAdrEnd+2

	move.l	#SecondCopperList,d0
;	move.w	d0,CopperAdr1+6
;	move.w	d0,CopperAdr2+6
;	move.w	d0,CopperAdr3+6
	swap	d0
;	move.w	d0,CopperAdr1+2
;	move.w	d0,CopperAdr2+2
;	move.w	d0,CopperAdr3+2
	

	lea		_ChunkyBuffer,a0
	move.l	#$00000000,d0
	move.w	#ScreenWidth/4*ScreenHeight-1,d7
.cloop:
	move.l	d0,(a0)+
	dbf		d7,.cloop
	
	move.l 	#_C2P_InnerLoop,a0
	move.l 	a0,_InterruptSub

	move.l 	#_C2P_Deinit,a0
	move.l	a0,_DeinitSub
	
	lea	_ChunkyBuffer+ScreenWidth*2,a0
	move.w	#0,d0
	move.w	#256-1,d7
.bc:
	move.b	d0,(a0)+
	add.b	#1,d0
	dbf		d7,.bc
	
	rts
;---------------------------------
_C2P_Deinit:

	move.l	#CopperBase,$dff080
	move.l	#CopperBaseEnd,d0
	move.w	d0,CopperAdrEnd+6
	swap	d0
	move.w	d0,CopperAdrEnd+2
	move.l	#$00880000,CopperAdrEnd+8

	jsr	_WaitFrame
	jsr	_WaitFrame
	jsr	_WaitFrame
	rts
;---------------------------------
_C2P_InnerLoop:

	move.w 	#$f00,$dff180

	bsr	RenderLoop

	move.w 	#$0,$dff180	

	move.l	#$ffff5f1e,d0
	move.l	#$10000011,d1
	move.l	Screens,a0
	add.l	#ScreenWidth/8*ScreenHeight*6,a0
	move.l	d1,(a0)
	move.l	d0,4(a0)
	move.l	d0,8(a0)
	move.l	d0,12(a0)
	move.l	d0,16(a0)
	move.l	d0,20(a0)
	move.l	d0,24(a0)
	move.l	d0,28(a0)
	move.l	d0,32(a0)
	move.l	d1,36(a0)
	
;	move.l	d0,ScreenWidth/8(a0)
;	move.l	d0,ScreenWidth/8+4(a0)
;	move.l	d0,ScreenWidth/8+8(a0)
;	move.l	d0,ScreenWidth/8+12(a0)
;	move.l	#$0f0f0f0f,ScreenWidth/8*ScreenHeight*2(a0)
;	move.l	#$00ff00ff,ScreenWidth/8*ScreenHeight*3(a0)
;	add.l	#ScreenWidth/8*ScreenHeight,a0
;	move.l	#$0000ffff,(a0)
	
	lea	Screens,a0
	bsr	Switch
	lea	Copper,a0
	bsr	Switch

	move.l	Copper+8,d0
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
RenderLoop:

	lea		_ChunkyBuffer,a0
	move.l	Screens,A1		; destination (planar)
	jsr	_BEST_c2p

	rts
;--------------------------------------------------------------------	
	SECTION	chip,DATA_C
;-----------
; display dimensions
DISPW           equ     ScreenWidth
DISPH           equ     ScreenHeight
HSTART          equ     129+(256-DISPW)/4-64
HEND 	        equ     HSTART+DISPW+32-$100
VSTART          equ     32
VEND            equ     VSTART+DISPH
DFETCHSTART     equ     HSTART/4
DFETCHSTOP      equ     DFETCHSTART+16*((DISPW/32)-3)

MODE 			equ		COLORBURST+$10
;-----------
CopperBase:
	dc.w	$01fc,$4003
	dc.w	$0180,$0000

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
	
	dc.w	$0106,$4020
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

	dc.w	$0106,$4220
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

	dc.w	$0106,$6020
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
	
	dc.w	$0106,$6220
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

	dc.w	$0106,$8020
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

	dc.w	$0106,$8220
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

	dc.w	$0106,$a020
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
	
	dc.w	$0106,$a220
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
	
	dc.w	$0106,$c020
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

	dc.w	$0106,$c220
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

	dc.w	$0106,$e020
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
	
	dc.w	$0106,$e220
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
	dc.w	$0108,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$010a,0 ; ScreenWidth/8*(Planes-1)
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

	dc.w	$0106,$0020
;	dc.w	$0106,$0000
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0100,(Pl<<12)+MODE
	dc.w	$ffdf,$fffe
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0100,$0000

CopperAdr1:
;	dc.w	$0080,$0000
;	dc.w	$0082,$0000
;	dc.w	$0088,$0000
	dc.w	$ffff,$fffe

;-----------
Copper2:
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HEND
	dc.w	$0092,DFETCHSTART
	dc.w	$0094,DFETCHSTOP
	dc.w	$0108,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$010a,0 ; ScreenWidth/8*(Planes-1)
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
;	dc.w	$0106,$0000
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0100,(Pl<<12)+MODE
	dc.w	$ffdf,$fffe
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0100,$0000

CopperAdr2:
;	dc.w	$0080,$0000
;	dc.w	$0082,$0000
;	dc.w	$0088,$0000
	dc.w	$ffff,$fffe

;-----------
Copper3:
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HEND
	dc.w	$0092,DFETCHSTART
	dc.w	$0094,DFETCHSTOP
	dc.w	$0108,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$010a,0 ; ScreenWidth/8*(Planes-1)
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
;	dc.w	$0106,$0000
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0100,(Pl<<12)+MODE
	dc.w	$ffdf,$fffe
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0100,$0000
CopperAdr3:
;	dc.w	$0080,$0000
;	dc.w	$0082,$0000
;	dc.w	$0088,$0000
	dc.w	$ffff,$fffe
	
SecondCopperList:
CopperAdrEnd:
	dc.w	$0080,$0000
	dc.w	$0082,$0000
	dc.w	$ffff,$fffe
SecondCopperListEnd:
;--------------------------------------------------------------------
CopperBaseEnd:
	dc.w	$01fc,$4003
	dc.w	$0180,$000f
	dc.w	$ffff,$fffe
*********************************************************************
	SECTION	c2p_test_cb,BSS_P
_ChunkyBuffer	ds.l	320/4*256

	section mem,BSS_C
ChipMemory:
	ds.b	ScreenWidth/8*ScreenHeight*Planes*3
;--------------------------------------------------------------------
	section	data,DATA_P
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

	dc.l	$0fff0000
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
	dc.l	$0fff0000
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

********************************************************************
