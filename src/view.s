; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass smartindent:
;
; View handling


; Clear the 'idle' area in the view
;
; @zeropage     zp+0 .. zp+4
; @clobbers     all
;
clear_idle_area .proc

        vidram = zp
        vidramcolor = zp + 2
        bitmap_left = zp + 3
        bitmap_right= zp + 5

        lda #<VIEW_VIDRAM
        ldx #>VIEW_VIDRAM
        sta vidram
        stx vidram + 1

        lda #<(VIEW_BITMAP)
        ldx #>(VIEW_BITMAP)
        sta bitmap_left + 0
        stx bitmap_left + 1

        lda #<(VIEW_BITMAP + 32 * 8)
        ldx #>(VIEW_BITMAP + 32 * 8)
        sta bitmap_right + 0
        stx bitmap_right + 1

        lda data.idlefgcolor
        asl a
        asl a
        asl a
        asl a
        ora data.idlebgcolor
        sta vidramcolor

        ldx #VIEW_ROWS
more
        lda vidramcolor

        ldy #0
-       sta (vidram),y
        iny
        cpy #8
        bne -

        lda #0
        ldy #$3f
-       sta (bitmap_left),y
        sta (bitmap_right),y
        dey
        bpl -

        ldy #32
        lda vidramcolor
-       sta (vidram),y
        iny
        cpy #40
        bne -

        lda vidram
        clc
        adc #40
        sta vidram
        bcc +
        inc vidram + 1
+

        lda bitmap_left
        clc
        adc #$40
        sta bitmap_left
        lda bitmap_left + 1
        adc #1
        sta bitmap_left + 1

        lda bitmap_right
        clc
        adc #$40
        sta bitmap_right
        lda bitmap_right + 1
        adc #1
        sta bitmap_right + 1
        dex
        bne more

        rts
.pend


init .proc
        jsr clear_idle_area
        rts
.pend
