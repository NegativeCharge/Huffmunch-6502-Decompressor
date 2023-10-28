LOAD_ADDR = &5800
BACKWARD_DECOMPRESS = FALSE

\ Allocate vars in ZP
ORG &80
GUARD &9F
.zp_start
    INCLUDE ".\lib\huffmunch.h.asm"
.zp_end

\ Main
CLEAR 0, LOAD_ADDR
GUARD LOAD_ADDR
ORG &1100
.start
    INCLUDE ".\lib\huffmunch.s.asm"

.entry_point

    \\ Turn off cursor by directly poking crtc
    lda #&0b
    sta &fe00
    lda #&20
    sta &fe01

    lda #LO(comp_data)
    sta huffmunch_zpblock+0

    lda #HI(comp_data)
    sta huffmunch_zpblock+1

    ldx #0
	ldy #0
	jsr huffmunch_load
    sty page_bytes+1
	stx page_bytes+0

    ldx #LO(LOAD_ADDR)
    stx write_chr+1
    ldy #HI(LOAD_ADDR)
    sty write_chr+2

    lda #0
    sta byte_ptr+0
    sta byte_ptr+1

.next_chr
	jsr huffmunch_read
    sta current_byte
    
    lda byte_ptr+0
    clc
    adc #1
    sta byte_ptr+0
    lda byte_ptr+1
    adc #0
    sta byte_ptr+1

    lda page_bytes+0
    cmp byte_ptr+0
    bne continue

    lda page_bytes+1
    cmp byte_ptr+1
    beq all_done

.continue
    lda current_byte

.write_chr	
    sta &ffff				; **SELF-MODIFIED**
	inc write_chr+1
	bne next_chr
	inc write_chr+2
	bne next_chr

.all_done
    jmp all_done
    
.comp_data
    INCBIN ".\tests\test_0.bin.hfm"

.end

SAVE "HUFFMCH", start, end, entry_point

\ ******************************************************************
\ *	Memory Info
\ ******************************************************************

PRINT "------------------------"
PRINT " Huffmunch Decompressor "
PRINT "------------------------"
PRINT "CODE size      = ", ~end-start
PRINT "------------------------"
PRINT "LOAD ADDR      = ", ~start
PRINT "HIGH WATERMARK = ", ~P%
PRINT "RAM BYTES FREE = ", ~LOAD_ADDR-P%
PRINT "------------------------"

PUTBASIC "loader.bas","LOADER"
PUTFILE  "BOOT","!BOOT", &FFFF  