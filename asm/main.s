
	include "blitterhelper.i"
	include "custom.i"
	include "defines.i"

	xdef 	_Frames
	xdef	_InterruptSub
	xdef 	_DeinitSub
	xdef	_WaitFrame
	xref	_Fire_Init
	xref	_Mapping_Init
	xref	_Ham_Init
	xref	_Ham8_Init
	xref	_Ham7_Init
	xref	_C2P_Init
	xref	_C2P_ecs_Init
	xref	_Hires_Init
	xref	_Wolfenstein_Init
	xref	_InterlaceCop
	xref 	_InterlaceFlag
	xref	AEnd
	xref 	mt_init
	xref 	mt_install_cia
	xref 	mt_remove_cia
	xref 	mt_Enable
	xref	pDOSBase	
*********************************************************************
	section	main,CODE_F
Init:

	move.l	4.w,a6		; execbase
	clr.l	d0
	move.l	#dosname,a1
	jsr	-408(a6)
	move.l	d0,pDOSBase
	clr.l	d0
	move.l	#gfxname,a1
	jsr	-408(a6)	; eld open library
	move.l	d0,a1
	move.l	38(a1),d4	; original copperaddr
	move.l	d4,org_copper

	jsr	-414(a6)	; close library

	move.w	$dff01c,d0
	move.w	d0,org_intena
	move.w	$dff002,d0
	move.w	d0,org_dmacon
	move.l	$6c.w,org_int3

	move.w	#$0138,d0
	bsr.w	WaitRaster

	move.w	#$7fff,$dff09a	; disable all bits in INTENA
	move.w	#$c068,$dff09a
	move.w	#$7fff,$dff09c	; disable all bits in INTREQ
	move.w	#$7fff,$dff09c	; disable all bits in INTREQ
	move.w	#$7fff,$dff096	; disable all bits in DMACON
	move.w	#$87d0,$dff096

	move.l	#IntLevel3,$6c.w
;	move.w	#$c060,$dff09a
	move.w	#$c068,$dff09a

	; mt_install_cia(a6=CUSTOM, a0=AutoVecBase, d0=PALflag.b)
	lea 	CUSTOM,a6
	move.l 	#1,d0
	move.l 	#0,a0
	jsr 	mt_install_cia

	; mt_init(a6=CUSTOM, a0=TrackerModule, a1=Samples, d0=StartPos.b)
	lea 	CUSTOM,a6
	lea 	Module,a0
	move.l 	#0,a1
	move.l 	#0,d0
	jsr 	mt_init

	bsr NextEffectInit
;--------------------------------------------------------------------	
mainloop:
.wframe:
	btst	#0,$dff005
	bne.b	.wframe
;	cmp.b	#$4,$dff006
;	bne.b	.wframe
.wframe2:
	cmp.b	#$5,$dff006
	bne.b	.wframe2
;.wframe3:
;	cmp.b	#$f1,$dff006
;	bne.b	.wframe3

	btst	#6,$bfe001
	beq.w	exit


	move.w 	EffectNext,d0
	cmp.w 	#0,d0
	beq.b 	.nonext
	bsr.w 	NextEffect
;	move.b    #1,mt_Enable
.nonext:

	move.l 	_InterruptSub,a0
	cmp.l 	#0,a0
	beq.b 	lll
	jsr		(a0)
lll:

	cmp.w 	#0,AEnd
	beq.b 	mainloop
exit:
	move.l 	_DeinitSub,a0
	cmp.l 	#0,a0
	beq.b 	.nnn
	move.l	#CopperBase,d0
	jsr		(a0)
	move.l 	#0,_DeinitSub
.nnn:
	bsr	_WaitFrame
	
	; mt_remove_cia(a6=CUSTOM)
	lea 	CUSTOM,a6
	jsr 	mt_remove_cia

	move.w	#$7fff,$dff096
	move.w	org_dmacon,d0
	or.w	#$8200,d0
	move.w	d0,$dff096
	move.l	org_copper,d0
	move.l	d0,$dff080
	move.w	#$7fff,$dff09a
	move.l	org_int3,$6c.w
	move.w	org_intena,d0
	or.l	#$c000,d0
	move	d0,$dff09a

	rts

;--------------------------------------------------------------------	
_WaitFrame:
	btst	#0,$dff005
	bne.b	_WaitFrame
;	cmp.b	#$4,$dff006
;	bne.b	_WaitFrame
_WaitFrame1:
	cmp.b	#$5,$dff006
	bne.b	_WaitFrame1
_WaitFrame2:
	cmp.b	#$6,$dff006
	bne.b	_WaitFrame2
	rts
;--------------------------------------------------------------------	
WaitRaster:			; wait for rasterline d0.w. Modifies d0-d2/a0
	move.l	#$1ff00,d2
	lsl.l	#8,d0
	and.l	d2,d0
	lea	$dff004,a0
.wr:	move.l	(a0),d1
	and.l	d2,d1
	cmp.l	d1,d0
	bne.s	.wr
	rts
;--------------------------------------------------------------------	
IntLevel3:
	movem.l	d0-a6,-(sp)
	move.w	INTREQR+$dff000,d0
	btst	#6,d0			; Blitter IRG
	bne.w	.blit_handle
	btst	#5,d0
	beq.w	IntLevel3_end
;	btst	#6,$bfe001
;	bne.w	.noend
;	cmp.w 	#1,MouseLast
;	beq.b 	.noend1
;	cmp.w 	#0,EffectNext
;	bne.b 	.noend1
;	move.w 	#1,MouseLast
;	bsr NextEffectInit
;	bra 	.ll
;.noend:
;	move.w 	#0,MouseLast
;.noend1:
	tst.w 	_BEnd
	bne.b 	.ll
	move.l 	_InterlaceFlag,d0
	move.l 	d0,d1
	and.l 	#$10,d0
	beq.b 	.noInterlace
	move.l 	d1,d0
	add.l 	#1,d0
	and.l 	#$11,d0
	move.l 	d0,_InterlaceFlag
	and.l 	#1,d1
	lsl.l 	#2,d1
	lea 	_InterlaceCop,a0
	move.l 	(a0,d1.w),a0
	move.l 	a0,$dff080
.noInterlace:
;	move.l 	_InterruptSub,a0
;	cmp.l 	#0,a0
;	beq.b 	.ll
;	jsr		(a0)
.ll:
	add.l	#1,_Frames
	move.w	#$0020,$dff09c
	move.w	#$0020,$dff09c
	bra.w	IntLevel3_end
.blit_handle:
	move.w	_BlitListBeg,d0
	move.w	_BlitListEnd,d1
	cmp.w	d0,d1
	bne.b	.blit_next
	move.w	#0,_BEnd
	move.w	#$0040,$dff09c
	move.w	#$0040,$dff09c
	bra.b	 IntLevel3_end
.blit_next:
	jsr	_StartBlitList
IntLevel3_end:
	movem.l	(sp)+,d0-a6
	rte
;--------------------------------------------------------------------	
NextEffect:
	move.l 	_DeinitSub,a0
	cmp.l 	#0,a0
	beq.b 	.nnn
	move.l	#CopperBase,d0
	jsr		(a0)
	move.l 	#0,_DeinitSub
.nnn:
	move.w	EffectCount,d0
	lsl.w 	#2,d0
	lea 	Effects,a0
	move.l 	(a0,d0.w),a0
	cmp.l 	#0,a0
	beq.b 	.lp
	jsr 	(a0)
	add.w 	#1,EffectCount
	move.w 	#0,EffectNext
	rts
.lp:
	move.w 	#1,AEnd
	move.w 	#0,EffectNext
	rts
NextEffectInit:
	move.l 	#0,_InterruptSub
	move.w	#0,_BlitListBeg
	move.w	#0,_BlitListEnd
	move.w	#0,_BEnd
	move.w 	#1,EffectNext
	rts
;--------------------------------------------------------------------	
	section ch,DATA_C
CopperBase:
	dc.w	$01fc,$4003
	dc.w	$0180,$0000
	dc.w	$ffff,$fffe
;--------------------------------------------------------------------	
	section	data,DATA_F
org_copper:
	dc.l	0
org_intena:
	dc.w	0
org_dmacon:
	dc.w	0
org_int3:
	dc.l	0
_Frames:	dc.l	0
AEnd: 	dc.w 	0
	even
_InterlaceCop:
	dc.l 	0,0
_InterlaceFlag:
	dc.l 	0
_InterruptSub:
	dc.l 	0
_DeinitSub:
	dc.l 	0
MouseLast:
	dc.w 	0
EffectNext:
	dc.w 	0
EffectCount:
	dc.w 	0
	even
Effects:
; 	dc.l 	_Wolfenstein_Init
;	dc.l 	_Fire_Init
;	dc.l 	_Mapping_Init
;	dc.l 	_Ham_Init
;	dc.l 	_Ham8_Init
	dc.l 	_Ham7_Init
;	dc.l 	_Hires_Init
;	dc.l 	_C2P_Init
;	dc.l 	_C2P_ecs_Init
	dc.l 	0
	EVEN
dosname:
	dc.b "dos.library",0
	EVEN
gfxname:
	dc.b	"graphics.library",0

	section	data,BSS_P
pDOSBase:	ds.l	1

	section	main,DATA_C
Module:
	incbin 	test.mod
