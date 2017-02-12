	xdef	_SetBlit
	xdef	_StartBlitList
	xdef	_BlitListBeg
	xdef	_BlitListEnd
	xdef	_BltTmp
	xdef	_BEnd
	
	include "custom.i"
	include "defines.i"
;--------------------------------------------------------------------
	section	tex,CODE_P
_SetBlit:
	movem.l 	a0/a1/d0,-(sp)
	lea	_BlitList,a0
	lea _BltTmp,a1
	eor.l	d0,d0
	move.w	_BlitListEnd+2,d0
	muls.w	#38,d0
	move.l	(a1),(a0,d0)	; BLTCON0
	move.w	4(a1),4(a0,d0)	; BLTAMOD
	move.w	6(a1),6(a0,d0)	; BLTBMOD
	move.w	8(a1),8(a0,d0)	; BLTCMOD
	move.w	10(a1),10(a0,d0)	; BLTDMOD
	move.l	12(a1),12(a0,d0)	; BLTAPTH
	move.l	16(a1),16(a0,d0)	; BLTBPTH
	move.l	20(a1),20(a0,d0)	; BLTCPTH
	move.l	24(a1),24(a0,d0)	; BLTDPTH
	move.l	28(a1),28(a0,d0)	; BLTAFWM
	move.w	32(a1),32(a0,d0)	; BLTADAT
	move.w	34(a1),34(a0,d0)	; BLTBDAT
	move.w	36(a1),36(a0,d0)	; BLTSIZE
	move.w	_BlitListEnd+2,d0
	addq.w	#1,d0
	and.w	#BlitListLen-1,d0
	move.w	d0,_BlitListEnd+2
	movem.l 	(sp)+,a0/a1/d0
	rts
;--------------------------------------------------------------------
_StartBlitList:
	lea	_BlitList,a0
	eor.l	d0,d0
	move.w	_BlitListBeg,d0
	move.w	_BlitListEnd,d1
	cmp.w	d0,d1
	beq.w	.NoBlitList
	move.w	#1,_BEnd
	muls.w	#38,d0
	lea	$dff000,a6
.WAIT:
	BTST	#$6,$2(A6)	; Wait on the blitter
	BNE.S	.WAIT
	add.l	d0,a0
;	move.l	#$ffffffff,BLTAFWM(a6)
	move.w	4(a0),BLTAMOD(a6)
	move.w	6(a0),BLTBMOD(a6)
	move.w	8(a0),BLTCMOD(a6)
	move.w	10(a0),BLTDMOD(a6)
	move.l	12(a0),BLTAPTH(a6)
	move.l	16(a0),BLTBPTH(a6)
	move.l	20(a0),BLTCPTH(a6)
	move.l	24(a0),BLTDPTH(a6)
	move.l	28(a0),BLTAFWM(A6)	; FirstLastMask
	move.w	32(a0),BLTADAT(A6)	; BLT data A
	move.w	34(a0),BLTBDAT(A6)
	move.w	_BlitListBeg,d0
	addq.w	#1,d0
	and.w	#BlitListLen-1,d0
	move.w	d0,_BlitListBeg
	move.l	(a0),BLTCON0(a6)
	move.w	36(a0),BLTSIZE(a6)
.NoBlitList:
	rts
;--------------------------------------------------------------------
	section	tex,DATA_P
_BEnd:	dc.w 	0
_BlitListBeg:
	dc.w	0
_BlitListEnd:
	dc.w	0,0
	section	tex,BSS_P
_BlitList:
	ds.b	38*BlitListLen
_BltTmp:
	ds.b 	38
;--------------------------------------------------------------------
