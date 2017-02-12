ScreenWidth = 320
ScreenHeight= 192
Planes= 6
Pl=6
COLORED_SCANLINE = 192

	include "blitterhelper.i"
	include "custom.i"

	xdef	_Ham_Init
	xref	_InterruptSub
	xref	_loadNext	
	xref	pDOSBase	

	section	ham,CODE_P

;---------Bitplane init ----------
_Ham_Init:

	lea	Bitplane1,a0
	move.l	#ChipMemory,d0
	move.l 	d0,Screens
	move.l	#6-1,d1
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
	move.l	#6-1,d1
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
	move.l	#6-1,d1
.l3:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a0
	dbf	d1,.l3

	lea	Palette,a0
	lea	ColorCopper1+2,a1
	lea	ColorCopper2+2,a2
	lea	ColorCopper3+2,a3
	move.w	#32-1,d7
clo:	
	move.w	(a0)+,d0
	move.w	d0,(a1)
	move.w	d0,(a2)
	move.w	d0,(a3)
	add	#4,a1
	add	#4,a2
	add	#4,a3
	dbf	d7,clo

	lea Cop1ColorList,a0
	lea Cop2ColorList,a1
	lea Cop3ColorList,a2
	move.l 	#$00dbfffe+((VSTART+7)<<24),d0
	move.w 	#0,d2
	move.w 	#(ScreenHeight/COLORED_SCANLINE)-1,d7
cl2_:
	swap 	d7
	move.l 	d0,(a0)+
	move.l 	d0,(a1)+
	move.l 	d0,(a2)+
	lea	Palette+2,a3
	move.l 	#$01820000,d1
	move.w 	d2,d3
	move.w 	#14-1,d7
cl1_:
	and.w 	#31,d3
	move.w 	(a3,d3.w),d1
	move.l 	d1,(a0)+
	move.l 	d1,(a1)+
	move.l 	d1,(a2)+
	add.l 	#$00020000,d1
	add.w 	#2,d3
	dbf 	d7,cl1_
	and.w 	#31,d3
	move.w 	(a3,d3),d1
	add.w 	#2,d3
	move.l 	d1,(a0)+
	move.l 	d1,(a1)+
	move.l 	d1,(a2)+
	add.l 	#COLORED_SCANLINE<<24,d0
	add.w 	#2,d2
	swap 	d7
	dbf 	d7,cl2_

	move.l 	#_Ham_InnerLoop,a0
	move.l 	a0,_InterruptSub

	rts
;---------------------------------
_Ham_Deinit:
	bsr 	closefile
	rts
;---------------------------------
_Ham_InnerLoop:

;	move.w 	#$fff,$dff180

	bsr	RenderLoop

;	move.w 	#$0,$dff180

	lea	Screens,a0
	bsr	Switch
	lea	Copper,a0
	bsr	Switch
	move.l	Copper+8,$dff080

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

	bsr 	loadfile

	move.l 	Screens,a0
	lea 	pic,a2
	move.l 	picindex,d0	
;	lea 	picoffsets,a3
;	move.l 	d0,d3
;	and.l 	#7,d3
;	lsl.l 	#2,d3
;	add.l 	(a3,d3.w),a2
	move.l 	a2,a1
	move.w 	#ScreenWidth/32*ScreenHeight*6-1,d7
RL0:
	move.l (a1)+,d0
	move.l d0,(a0)+
	dbf 	d7,RL0

	move.l 	a2,a6
	add.l 	#320/8*ScreenHeight*6,a6
	move.l 	Copper,a0	
	add.l 	#Cop1ColorList-Copper1+2,a0
	move.w 	#ScreenHeight/COLORED_SCANLINE-1,d7
RL0_1:
	swap 	d7
	addq 	#4,a0
	move.w 	#14-1,d7
RL0_2:
	move.w 	(a6)+,d1
	move.w 	d1,(a0)
	addq 	#4,a0
	dbf 	d7,RL0_2
	move.w 	(a6)+,d1
	move.w 	d1,(a0)
	addq 	#4,a0
	swap 	d7
	dbf 	d7,RL0_1


	move.l 	picindex,d0	
	addq 	#1,d0
;	cmp.l 	#1720,d0 ; Ghost
;	cmp.l 	#2130,d0 ; NVidia
;	cmp.l 	#1696,d0 ; DarkSouls3
;	bne.b RL_no1
;	move.l 	#0,d0
;RL_no1:
	move.l 	d0,picindex

	rts
;--------------------------------------------------------------------	
openfile:
	move.l	pDOSBase,a6	;gimme dos in a6
	moveq #0,d6			;filesize or 0 if not ok
	move.l #filename,d1
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
	move.l 	picindex,d2
;	lsr.l 	#3,d2
	mulu #(320/8*ScreenHeight*6+15*2*ScreenHeight/COLORED_SCANLINE)/2,d2
	add.l 	d2,d2

;	lsl.l 	#3,d2
	jsr -66(a6)			;DOS Read()

	move.l d5,d1			;filehdl
	move.l #pic,d2		;addr
	move.l #(320/8*ScreenHeight*6+15*2*ScreenHeight/COLORED_SCANLINE)*1,d7
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
	move.w 	#$f0,ColorCopper1+2
	rts
.error2:
;	move.w 	#$f00,ColorCopper1+2
	bsr 	closefile
	move.l 	#0,picindex
	rts
;--------------------------------------------------------------------	
	SECTION	chip,DATA_C
;-----------
; display dimensions
DISPW           equ     ScreenWidth
DISPH           equ     ScreenHeight

; display window in raster coordinates (HSTART must be odd)
HSTART          equ     129+(256-ScreenWidth)/2+8
VSTART          equ     36 ; +(256-ScreenHeight)/2
VEND            equ     VSTART+DISPH
VEND2			equ		14

; normal display data fetch start/stop (without scrolling)
DFETCHSTART     equ     HSTART/2
DFETCHSTOP      equ     DFETCHSTART+8*((DISPW/16)-1)

MODE 			equ		HAM+COLORBURST
;-----------
Copper1:
	dc.w	$01fc,$000c
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0100,$0200
	dc.w	$008e,$2c00+HSTART
	dc.w	$0090,$2c00+HSTART+ScreenWidth-$100
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
ColorCopper1:
	dc.w	$0180,$0000
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
	dc.w	$0100,(Pl<<12)+MODE
Cop1ColorList:
	ds.l 	16*ScreenHeight/COLORED_SCANLINE
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
	dc.w	$0090,$2c00+HSTART+ScreenWidth-$100
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
ColorCopper2:
	dc.w	$0180,$0000
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
	dc.w	$0100,(Pl<<12)+MODE
Cop2ColorList:
	ds.l 	16*ScreenHeight/COLORED_SCANLINE
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
	dc.w	$0090,$2c00+HSTART+ScreenWidth-$100
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
ColorCopper3:
	dc.w	$0180,$0000
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
	dc.w	$0100,(Pl<<12)+MODE
Cop3ColorList:
	ds.l 	16*ScreenHeight/COLORED_SCANLINE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

*********************************************************************
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

picoffsets:
	dc.l 	0
	dc.l 	(320/8*ScreenHeight*6+15*2*ScreenHeight)
	dc.l 	(320/8*ScreenHeight*6+15*2*ScreenHeight)*2
	dc.l 	(320/8*ScreenHeight*6+15*2*ScreenHeight)*3
	dc.l 	(320/8*ScreenHeight*6+15*2*ScreenHeight)*4
	dc.l 	(320/8*ScreenHeight*6+15*2*ScreenHeight)*5
	dc.l 	(320/8*ScreenHeight*6+15*2*ScreenHeight)*6
	dc.l 	(320/8*ScreenHeight*6+15*2*ScreenHeight)*7
filehandle:
	dc.l 	0
picindex:
	dc.l 	0
	even
filename:
;	dc.b 	"ghost.tmp",0
	dc.b 	"nvidia.tmp",0
;	dc.b 	"darksouls3.tmp",0
;	dc.b 	"ray.tmp",0
;	dc.b 	"cocoon.tmp",0
	even
pic:
	ds.b 	(320/8*ScreenHeight*6+15*2*ScreenHeight)*8
*********************************************************************
