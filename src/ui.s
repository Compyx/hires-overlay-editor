; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass smartindent:
;
;   font = $3800-$3bff
;

; Get vidram/colram pointers for \a X and \a Y
;
; @clobbers     all
; @return       X ay
screenpos_get .proc
        stx xadd + 1
        lda data.screen_row_lsb + 9,y
        clc
xadd    adc #0
        sta lsbres + 1
        lda data.screen_row_msb + 9,y
        adc #$04
        sta msbres + 1
        and #3
        ora #$d8
        sta colres + 1

lsbres  lda #0
msbres  ldx #0
colres  ldy #0
        rts
.pend


        rts


window_set_pos .proc
        stx data.window_xpos
        sty data.window_ypos
        rts
.pend


window_set_size .proc
        stx data.window_width
        sty data.window_height
        inx
        stx data.window_width2
        dex
        rts
.pend


window_render_frame .proc

        vidram = zp
        colram = zp + 2

        ldx data.window_xpos
        ldy data.window_ypos
        jsr screenpos_get
        sta vidram + 0
        sta colram + 0
        stx vidram + 1
        sty colram + 1

        ; render top
        ldy #$00
        lda #$44
        sta (vidram),y
        lda data.window_framecol
        sta (colram),y

        iny
-       lda #$48
        sta (vidram),y
        lda data.window_framecol
        sta (colram),y
        iny
        cpy data.window_width2
        bne -
        sta (colram),y
        lda #$45
        sta (vidram),y

        ; render sides + background
        lda vidram + 0
        clc
        adc #40
        sta vidram + 0
        sta colram + 0
        bcc +
        inc vidram + 1
        inc colram + 1
+
        ldx data.window_height
more_rows
        ldy #0
        lda #$49
        sta (vidram),y
        lda data.window_framecol
        sta (colram),y
        iny
        lda #$20        ; space
-       sta (vidram),y
        iny
        cpy data.window_width2
        bne -
        lda #$49
        sta (vidram),y
        lda data.window_framecol
        sta (colram),y

        lda vidram + 0
        clc
        adc #40
        sta vidram + 0
        sta colram + 0
        bcc +
        inc vidram + 1
        inc colram + 1
+
        dex
        bne more_rows

        ; render bottom
        ldy #0
        lda #$46
        sta (vidram),y
        lda data.window_framecol
        tax
        sta (colram),y
        iny

-       lda #$48
        sta (vidram),y
        txa
        sta (colram),y
        iny
        cpy data.window_width2
        bne -
        sta (colram),y
        lda #$47
        sta (vidram),y
        rts
.pend


window_render_title .proc

        vidram = zp
        colram = zp + 2
        title = zp + 4

        stx title + 0
        sty title + 1

        ldx data.window_xpos
        ldy data.window_ypos
        jsr screenpos_get
        sta vidram + 0
        sta colram + 0
        stx vidram + 1
        sty colram + 1

        ldy #1
        lda #$4a
        sta (vidram),y

        lda vidram + 0
        clc
        adc #2
        sta vidram + 0
        sta colram + 0
        bcc +
        inc vidram + 1
        inc colram + 1
+
        ldy #0
-
        lda (title),y
        bne +
        lda #$4b
        sta (vidram),y
        rts
+
        sta (vidram),y
        lda #$01
        sta (colram),y
        iny
        bne -
        rts
.pend

