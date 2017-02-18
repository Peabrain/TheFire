ScreenWidth = 704
ScreenHeight= 192
Planes= 8
Pl=0

	include "blitterhelper.i"
	include "custom.i"

	xdef	_Ham8_Init
	xref	_InterruptSub
	xref	_loadNext	
	xref	_Frames
	xref	_DeinitSub
	xref	AEnd
	xref	pDOSBase	

	section	ham8,CODE_P

;---------Bitplane init ----------
_Ham8_Init:

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

	lea	BitplaneSecond,a0
	lea SecondCopperList,a4
	move.w	#(SecondCopperListEnd-SecondCopperList)/4-1,d0
.l9:
	move.l	(a4)+,d7
	move.l	d7,(a0)+
	dbf		d0,.l9
	
	
	move.l	#down_pic+62,a0
	move.l	#ScreenWidth/8*24/4-1,d1
.l5:
	eor.l	#$ffffffff,(a0)+
	dbf	d1,.l5

	lea	BitplaneSecond,a0
	move.l	#down_pic+62,d0
	move.l	#8-1,d1
.l4:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth/8*24,d0
	add.l	#8,a0
	dbf	d1,.l4
	
	lea	Bitplane1_top,a0
	move.l	#pic_top,d0
	move.l	#8-1,d1
.l6:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#ScreenWidth*2/8*9,d0
	add.l	#8,a0
	dbf	d1,.l6

	lea		font8x8_basic+62,a1
	move.w	#16*16*8/4-1,d0
.l7:
	eor.l	#$ffffffff,(a1)+
	dbf		d0,.l7

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

;	lea	Palette,a0
;	lea	ColorCopper1+2,a1
;	lea	ColorCopper2+2,a2
;	lea	ColorCopper3+2,a3
;	move.w	#32-1,d7
;clo:	
;	move.w	(a0)+,d0
;	move.w	d0,(a1)
;	move.w	d0,(a2)
;	move.w	d0,(a3)
;	add	#4,a1
;	add	#4,a2
;	add	#4,a3
;	dbf	d7,clo

	move.l 	#_Ham8_InnerLoop,a0
	move.l 	a0,_InterruptSub

	move.l	_Frames,d0
	move.l 	d0,lastframe
	
	move.l 	#_Ham8_Deinit,a0
	move.l	a0,_DeinitSub
	
	bsr 	PlaySample
	rts
;---------------------------------
_Ham8_Deinit:
	move.l	#$fffffffe,CopperAdr
	rts
;---------------------------------
_Ham8_InnerLoop:

;	move.w 	#$fff,$dff180

	move.l	_Frames,d0
	move.l	d0,d1
	sub.l 	lastframe,d1
	cmp.l	#2,d1
	blt.b 	.norender
	add.l 	#2,lastframe

	
	bsr	RenderLoop

	move.l	Screens,a0
	add.l	#ScreenWidth/8*ScreenHeight*7,a0
;	move.l	#$ffffffff,(a0)
	add.l	#ScreenWidth/8-4,a0
;	move.l	#$ffffffff,(a0)

;	move.w 	#$0,$dff180	
	
	lea	Screens,a0
	bsr	Switch
	lea	Copper,a0
	bsr	Switch

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
DrawText:
;	rts
	move.w	Scroll,d2
	move.w	d2,d1
	lsr.w	#3,d1
	move.w	d2,d3
	and.w	#$1f,d2
	bne.b	.endText
	lsr.w	#5,d3
	lea		text,a2
	lea		font8x8_basic+62,a1

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
	move.w	d0,Scrolling+2

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
RenderLoop:

	bsr 	LoadMyVidFile
	
	move.l 	Screens,a3
	lea 	pic,a2
	move.l 	picindex,d0	
	move.l 	a2,a1
	move.l	a3,a0
	move.w 	#ScreenWidth/32*ScreenHeight*8-1,d7
RL0:
;	move.l (a1)+,d0
;	move.l d0,(a0)+
;	dbf 	d7,RL0

	bsr 	LoadMySndFile

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
	move.l 	d0,picindex

	rts
;--------------------------------------------------------------------	
LoadMySndFile:
	move.l 	#filenameSnd,d0
	move.l	d0,filenameptr
	
	move.l 	picindex,d0
	mulu	#884,d0
	add.l 	#10000,d0
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
	move.l 	d0,fileseek

	move.l #ScreenWidth/8*ScreenHeight*8,d0
	move.l d0,filesize

;	move.l	#pic,d0
	move.l	Screens,d0
	move.l	d0,filedest
	
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
	move.w 	#$f0,ColorCopper1+2
	rts
.error2:
;	move.w 	#$f00,ColorCopper1+2
	bsr 	closefile
	move.l 	#0,picindex
;	move.w 	#1,AEnd
	rts
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
DISPW           equ     ScreenWidth/2
DISPH           equ     ScreenHeight
HSTART          equ     129+(256-DISPW)/4-64
HEND 	        equ     HSTART+DISPW+32-$100
VSTART          equ     36+(256-ScreenHeight)/2-8
VEND            equ     VSTART+DISPH
DFETCHSTART     equ     HSTART/2
DFETCHSTOP      equ     DFETCHSTART+16*((DISPW/32)-1)

MODE 			equ		HAM+COLORBURST+HIRES+$11
MODE_DOWN		equ		COLORBURST+HIRES+$10
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

	dc.w	$0106,$0020
	dc.w	$0182,$0fff

	dc.w	$008e,$2c00+HSTART+48
	dc.w	$0090,$2c00+HEND-24
	dc.w	$0092,DFETCHSTART
	dc.w	$0094,DFETCHSTOP
	dc.w	$0108,ScreenWidth/8
	dc.w	$010a,ScreenWidth/8
Scrolling:
	dc.w	$0102,$0044

	dc.w	$0007+((VSTART-18)<<8),$fffe
	dc.w	$0180,$044f
	dc.w	$0007+((VSTART-17)<<8),$fffe
	dc.w	$0180,$033f
	dc.w	$0007+((VSTART-16)<<8),$fffe
	dc.w	$0180,$022f
	dc.w	$0007+((VSTART-15)<<8),$fffe
	dc.w	$0180,$011f
	dc.w	$0100,(0<<12)+MODE_DOWN
	dc.w	$0007+((VSTART-14)<<8),$fffe
	dc.w	$0180,$000f

	dc.w	$0007+((VSTART-8)<<8),$fffe
	dc.w	$0180,$011f
	dc.w	$0007+((VSTART-7)<<8),$fffe
	dc.w	$0180,$022f
	dc.w	$0100,$0000
	dc.w	$0007+((VSTART-6)<<8),$fffe
	dc.w	$0180,$033f
	dc.w	$0007+((VSTART-5)<<8),$fffe
	dc.w	$0180,$044f
	dc.w	$0007+((VSTART-4)<<8),$fffe
	dc.w	$0180,$0000
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
	dc.w	$0102,$0044
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
ColorCopper1:
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
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0100,(Pl<<12)+MODE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
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
	dc.w	$0108,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$010a,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$0102,$0044
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
ColorCopper2:
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
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0100,(Pl<<12)+MODE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
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
	dc.w	$0108,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$010a,0 ; ScreenWidth/8*(Planes-1)
	dc.w	$0102,$0044
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
ColorCopper3:
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
	dc.w	$0007+(VSTART<<8),$fffe
	dc.w	$0100,(Pl<<12)+MODE
	dc.w	$0007+((VEND&$ff)<<8),$fffe
	dc.w	$0180,$0000
	dc.w	$0100,$0000
CopperAdr3:
	dc.w	$0080,$0000
	dc.w	$0082,$0000
	dc.w	$0088,$0000
	
SecondCopperList:
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
CopperAdrEnd:
	dc.w	$0080,$0000
	dc.w	$0082,$0000
	dc.w	$ffff,$fffe
SecondCopperListEnd:
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
	section	data,DATA_P
Copper:
	dc.l	Copper1,Copper2,Copper3
Screens:
	dc.l	0,0,0

Palette:
	dc.w	$0000
	dc.w	$0000
	dc.w	$0111
	dc.w	$0111
	dc.w	$0222
	dc.w	$0222
	dc.w	$0333
	dc.w	$0333	
	dc.w	$0444
	dc.w	$0444
	dc.w	$0555
	dc.w	$0555
	dc.w	$0666
	dc.w	$0666
	dc.w	$0777
	dc.w	$0777
	dc.w	$0888
	dc.w	$0888
	dc.w	$0999
	dc.w	$0999
	dc.w	$0aaa
	dc.w	$0aaa
	dc.w	$0bbb
	dc.w	$0bbb
	dc.w	$0ccc
	dc.w	$0ccc
	dc.w	$0ddd
	dc.w	$0ddd
	dc.w	$0eee
	dc.w	$0eee
	dc.w	$0fff
	dc.w	$0fff

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
	dc.b 	"sc_hd.tmp",0
	even
filenameSnd:
	dc.b 	"sc.iff",0
	even
font8x8_basic:
	incbin	font.bmp
text:
	incbin	text.txt
	dc.b	0
pic:
	ds.b 	(ScreenWidth/8*ScreenHeight*Planes)
*********************************************************************
