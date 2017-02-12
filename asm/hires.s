ScreenWidth = 320
ScreenHeight= 192
Planes= 4
Pl=4

	include "blitterhelper.i"
	include "custom.i"

	xdef	_Hires_Init
	xref	_InterruptSub
	xref	_loadNext	
	xref	_InterlaceCop
	xref 	_InterlaceFlag
	xref	_Frames
	xref	pDOSBase	

	section	ham,CODE_F

;---------Bitplane init ----------
_Hires_Init:

	lea	Bitplane1_Lum,a0
	lea	Bitplane1_Col,a1
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
	move.l	#6-1,d1
.l1c:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a1
	dbf	d1,.l1c

	lea	Bitplane2_Lum,a0
	lea	Bitplane2_Col,a1
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
	move.l	#6-1,d1
.l2c:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a1
	dbf	d1,.l2c

	lea	Bitplane3_Lum,a0
	lea	Bitplane3_Col,a1
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
	move.l	#6-1,d1
.l3c:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#ScreenWidth/8*ScreenHeight,d0
	add.l	#8,a1
	dbf	d1,.l3c
	
	lea	Palette,a0
	lea	ColorCopper1_Lum+2,a1
	lea	ColorCopper2_Lum+2,a2
	lea	ColorCopper3_Lum+2,a3
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

	lea	Palette2,a0
	lea	ColorCopper1_Col+2,a1
	lea	ColorCopper2_Col+2,a2
	lea	ColorCopper3_Col+2,a3
	move.w	#32-1,d7
cloC:	
	move.w	(a0)+,d0
	move.w	d0,(a1)
	move.w	d0,(a2)
	move.w	d0,(a3)
	add	#4,a1
	add	#4,a2
	add	#4,a3
	dbf	d7,cloC

	move.l 	#_Hires_InnerLoop,a0
	move.l 	#_Hires_Deinit,a1
	move.l 	a1,_Hires_Deinit
	move.l 	a0,_InterruptSub

	move.l 	Copper_Lum+8,_InterlaceCop
	move.l 	Copper_Col+8,_InterlaceCop+4
	move.l 	#$10,_InterlaceFlag

	move.l	Copper_Col,$dff080

	rts
;---------------------------------
_Ham_Deinit:
	bsr 	closefile
	rts
;---------------------------------
_Hires_InnerLoop:

;	move.w 	#$fff,$dff180

	move.w _Frames,d0
	and.w 	#1,d0
;	beq.b 	endl
	bsr	RenderLoop

;	move.w 	#$0,$dff180

	lea	Screens,a0
	bsr	Switch
	lea	Copper_Lum,a0
	bsr	Switch
	lea	Copper_Col,a0
	bsr	Switch
;	move.l	Copper_Lum+8,$dff080
	move.l 	Copper_Lum+4,_InterlaceCop
	move.l 	Copper_Col+4,_InterlaceCop+4
;	move.l	Copper_Col+8,$dff080

endl:
;	bsr BlitWait
;	move.w	_BlitListEnd+2,_BlitListEnd
;	jsr	_StartBlitList
	rts
;--------------------------------------------------------------------	
_Hires_Deinit:
	move.l 	#$0,_InterlaceFlag
;	bsr 	closefile
	rts
;---------------------------------
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
	move.l 	a2,a1
	move.w 	#ScreenWidth/32*ScreenHeight*(4+6)-1,d7
RL0:
	move.l (a1)+,d0
	move.l d0,(a0)+
	dbf 	d7,RL0

	lea	pic+ScreenWidth/8*ScreenHeight*(4+6),a0
	move.l Copper_Col,a1
	add.l 	#(ColorCopper1_Col-Copper1_Col),a1
	add.l 	#6,a1
	move.w	#31-1,d7
cloCa:	
	move.w	(a0)+,d0
	move.w	d0,(a1)
	add	#4,a1
	dbf	d7,cloCa

	move.l 	picindex,d0	
	addq 	#1,d0
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
	mulu #(320/8*ScreenHeight*(4+6)+2*31)/2,d2
	add.l 	d2,d2

;	lsl.l 	#3,d2
	jsr -66(a6)			;DOS Read()

	move.l d5,d1			;filehdl
	move.l #pic,d2		;addr
	move.l #(320/8*ScreenHeight*(4+6))+2*31,d7
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
	move.w 	#$f0,ColorCopper1_Lum+2
	rts
.error2:
;	move.w 	#$f00,ColorCopper1_Lum+2
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
HSTART          equ     129+(256-ScreenWidth)/2
VSTART          equ     36 ; +(256-ScreenHeight)/2
VEND            equ     VSTART+DISPH
VEND2			equ		14

; normal display data fetch start/stop (without scrolling)
DFETCHSTART     equ     HSTART/2
DFETCHSTOP      equ     DFETCHSTART+8*((DISPW/16)-1)

MODE 			equ		COLORBURST
;-----------
Copper1_Lum:
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
	dc.w	$0104,$0200
Bitplane1_Lum:
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
ColorCopper1_Lum:
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
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

;-----------
Copper2_Lum:
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
	dc.w	$0104,$0200
Bitplane2_Lum:
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
ColorCopper2_Lum:
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
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

;-----------
Copper3_Lum:
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
	dc.w	$0104,$0200
Bitplane3_Lum:
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
ColorCopper3_Lum:
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
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

	
	;-----------
Copper1_Col:
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
	dc.w	$0104,$0200
Bitplane1_Col:
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
ColorCopper1_Col:
	dc.w	$0180,$0000
	dc.w	$0182,$0010
	dc.w	$0184,$0020
	dc.w	$0186,$0030
	dc.w	$0188,$0040
	dc.w	$018a,$0050
	dc.w	$018c,$0060
	dc.w	$018e,$0070
	dc.w	$0190,$0080
	dc.w	$0192,$0090
	dc.w	$0194,$00a0
	dc.w	$0196,$00b0
	dc.w	$0198,$00c0
	dc.w	$019a,$00d0
	dc.w	$019c,$00e0
	dc.w	$019e,$00f0
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
	dc.w	$0100,(6<<12)+MODE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

;-----------
Copper2_Col:
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
	dc.w	$0104,$0200
Bitplane2_Col:
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
ColorCopper2_Col:
	dc.w	$0180,$0000
	dc.w	$0182,$0010
	dc.w	$0184,$0020
	dc.w	$0186,$0030
	dc.w	$0188,$0040
	dc.w	$018a,$0050
	dc.w	$018c,$0060
	dc.w	$018e,$0070
	dc.w	$0190,$0080
	dc.w	$0192,$0090
	dc.w	$0194,$00a0
	dc.w	$0196,$00b0
	dc.w	$0198,$00c0
	dc.w	$019a,$00d0
	dc.w	$019c,$00e0
	dc.w	$019e,$00f0
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
	dc.w	$0100,(6<<12)+MODE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

;-----------
Copper3_Col:
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
	dc.w	$0104,$0200
Bitplane3_Col:
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
ColorCopper3_Col:
	dc.w	$0180,$0000
	dc.w	$0182,$0010
	dc.w	$0184,$0020
	dc.w	$0186,$0030
	dc.w	$0188,$0040
	dc.w	$018a,$0050
	dc.w	$018c,$0060
	dc.w	$018e,$0070
	dc.w	$0190,$0080
	dc.w	$0192,$0090
	dc.w	$0194,$00a0
	dc.w	$0196,$00b0
	dc.w	$0198,$00c0
	dc.w	$019a,$00d0
	dc.w	$019c,$00e0
	dc.w	$019e,$00f0
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
	dc.w	$0100,(6<<12)+MODE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$ffff,$fffe

*********************************************************************
	section mem,BSS_C
ChipMemory:
	ds.b	ScreenWidth/8*ScreenHeight*(4+6)
;--------------------------------------------------------------------
	section	data,DATA_F
Copper_Lum:
	dc.l	Copper1_Lum,Copper2_Lum,Copper3_Lum
Copper_Col:
	dc.l	Copper1_Col,Copper2_Col,Copper3_Col
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
Palette2:
	dc.w	$0000
	dc.w	$0f00
	dc.w	$00f0
	dc.w	$000f
	dc.w	$0f0f
	dc.w	$0500
	dc.w	$0600
	dc.w	$0700	
	dc.w	$0800
	dc.w	$0900
	dc.w	$0a00
	dc.w	$0b00
	dc.w	$0c00
	dc.w	$0d00
	dc.w	$0e00
	dc.w	$0f00
	dc.w	$0f10
	dc.w	$0f20
	dc.w	$0f30
	dc.w	$0f40
	dc.w	$0f50
	dc.w	$0f60
	dc.w	$0f70
	dc.w	$0f80
	dc.w	$0f90
	dc.w	$0fa0
	dc.w	$0fb0
	dc.w	$0fc0
	dc.w	$0fd0
	dc.w	$0fe0
	dc.w	$0ff0
	dc.w	$0ff8

filehandle:
	dc.l 	0
picindex:
	dc.l 	0
myframes:
	dc.w 	0
	even
filename:
;	dc.b 	"ghost.tmp",0
;	dc.b 	"nvidia.tmp",0
;	dc.b 	"darksouls3.tmp",0
;	dc.b 	"ray.tmp",0
	dc.b 	"cocoon_hires.tmp",0
;	dc.b 	"test_hires.tmp",0
	even
pic:
	ds.b 	(320/8*ScreenHeight*(4+6))
*********************************************************************
