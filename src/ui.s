; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass smartindent:
;
;       font    = $3800-$3bff
;       vidram  = $0400-$07e7
;


; Get vidram/colram pointers for \a X and \a Y
;
; @clobbers     all
; @stack        1
; @return       A       LSB
; @return       X       vidram MSB
; @return       Y       colram MSB
;
screenpos_get .proc
        txa
        clc
        adc data.screen_row_lsb + 9,y
        pha
        lda data.screen_row_msb + 9,y
        adc #$04        ; screen at $0400
        tax
        and #3
        ora #$d8
        tay
        pla
        rts
.pend


; @brief        Set window X,Y position
;
; @param        X       x-position
; @param        Y       y-position
;
window_set_pos .proc
        stx data.window_xpos
        sty data.window_ypos
        rts
.pend


; @brief        Set window size, excluding frame
;
; @param        X       width
; @param        Y       height
;
window_set_size .proc
        stx data.window_width
        sty data.window_height
        inx
        stx data.window_width2
        dex
        rts
.pend


; @brief        Render window frame
;
; @zeropage     zp+0 .. zp+3
; @clobbers     all
;
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


; @brief        Render window title
;
; Title must be a 0-terminated screencode string.
;
; @param        X       title LSB
; @param        Y       title MSB
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


; @brief        Render text in window
;
; @param        X       text LSB
; @param        Y       text MSB
;
; @zeropage     zp+0 .. zp+7
;
window_render_text .proc

        vidram = zp
        colram = zp + 2
        source = zp + 4
        column = zp + 6
        color  = zp + 7

        stx source + 0
        sty source + 1

        ldx data.window_xpos
        ldy data.window_ypos
        inx
        iny
        jsr screenpos_get
        sta vidram + 0
        sta colram + 0
        stx vidram + 1
        sty colram + 1

more_rows
        ldy #0
        sty column
more
        ldy #0
        lda (source),y
        cmp #$ff
        bne +
        rts     ; EOT
+
        bpl +
        ; get color
        cmp #$90
        bcs +
        and #$0f
        sta color
        jmp next_char
+
        cmp #$90
        bne +
        ; CR

        lda data.window_width
        sta column
        jmp next_char

+
        ldy column
        sta (vidram),y
        lda color
        sta (colram),y

        inc column

next_char
        inc source
        bne +
        inc source + 1
+
        lda column
        cmp data.window_width
        bcc more
more_cr
        lda vidram
        clc
        adc #40
        sta vidram
        sta colram
        bcc +
        inc vidram + 1
        inc colram + 1
+
        jmp more_rows
        rts
.pend
