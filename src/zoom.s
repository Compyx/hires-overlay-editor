; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass smartindent:
;
; Zoom handling


; @brief        Render initial zoom area
;
; Currently renders the area with the 7x7 pixel zoom chars and then renders
; the char outlines by rendering over the 7x7 pixels char. Might be better to
; implement this by using an 8x8 chars grid for each zoomed char.
;
; @zeropage     zp+0 .. zp+2
; @clobbers     all
;
clear .proc

        vidram = zp
        row  = zp + 2

        ldx #0
-       lda #$40
        sta ZOOM_VIDRAM,x               ; $0568
        sta ZOOM_VIDRAM + $100,x        ; $0668
        sta ZOOM_VIDRAM + $180,x        ; $06e8
        lda #$00
        sta $d968,x
        sta $da68,x
        sta $dae8,x
        inx
        bne -

        lda #<ZOOM_VIDRAM
        ldx #>ZOOM_VIDRAM
        sta vidram
        stx vidram + 1
        lda #0
        sta row

more
        ldx #7
-
        lda #$42
        ldy #7
        sta (vidram),y
        ldy #15
        sta (vidram),y
        ldy #23
        sta (vidram),y
        ldy #31
        sta (vidram),y
        ldy #39
        sta (vidram),y

        lda vidram
        clc
        adc #40
        sta vidram
        bcc +
        inc vidram + 1
+
        dex
        bne -
        ldy #39
        lda #$41
-       sta (vidram),y
        dey
        bpl -

        lda #$43
        ldy #7
        sta (vidram),y
        ldy #15
        sta (vidram),y
        ldy #23
        sta (vidram),y
        ldy #31
        sta (vidram),y
        ldy #39
        sta (vidram),y

        lda row
        beq +
        rts
+
        inc row

        lda vidram
        clc
        adc #40
        sta vidram
        bcc +
        inc vidram + 1
+
        jmp more
        rts
.pend



; @brief        Create sprites for the zoom area
;
; @todo         Once the sprites are settled, export as .prg/.bin and import
create_sprites .proc
        ; create pixel zoom sprite
        ldx #0
-       lda data.pixel_sprite_data,x
        sta ZOOM_SPRITE_PIXEL,x
        inx
        cpx #data.pixel_sprite_data_end - data.pixel_sprite_data
        bne -
        lda #0
-       sta ZOOM_SPRITE_PIXEL,x
        inx
        cpx #$3f
        bne -
        rts
.pend


; @brief        Initialize zoom module
;
; Renders initial zoom area and sets up sprites.
;
; @clobbers     all
init .proc
        jsr clear
        jsr create_sprites
        rts
.pend



sprite_get_ptr .proc
        lda data.sprite_char_xlsb,x
        clc
        adc data.sprite_char_ylsb,y
        pha
        lda data.sprite_char_xmsb,x
        adc data.sprite_char_ymsb,y
        adc #>VIEW_SPRITES
        tay
        pla
        tax
        stx $0402
        sty $0403
        rts
.pend



bitmap_get_ptr .proc
        lda data.bitmap_char_xlsb + 8,x
        clc
        adc data.bitmap_char_ylsb,y
        pha
        lda data.bitmap_char_xmsb + 8,x
        adc data.bitmap_char_ymsb,y
        adc #>VIEW_BITMAP
        tay
        pla
        tax
        stx $0400
        sty $0401
        rts
.pend

; @brief        Render a single zoomed char
;
; @param A      bit 0-3: target column, 4: target row
; @param X      x-pos in data
; @param Y      y-pos in data
;
render_char .proc

        src = zp
        tmp = zp + 2

        ; store params
        stx data.zoom_src_xchar
        sty data.zoom_src_ychar
        pha
        and #$0f
        sta data.zoom_dst_xchar
        pla
        lsr a
        lsr a
        lsr a
        lsr a
        sta data.zoom_dst_ychar

        ; retrieve source data

        ; retrieve source bitmap data
        ; x/y contain source X/Y
        jsr bitmap_get_ptr
        stx src + 0
        sty src + 1
        ldy #7
-       lda (src),y
        sta data.zoom_src_bitmap,y
        dey
        bpl -

        ; retrieve source sprite layer data
        ldx data.zoom_src_xchar
        ldy data.zoom_src_ychar
        jsr sprite_get_ptr
        stx src + 0
        sty src + 1

        ldx #7
        ldy #0
-
        lda data.sprite_char_ylsb,x
        clc
        adc src + 0
        sta tmp + 0
        lda data.sprite_char_ymsb,x
        adc src + 1
        sta tmp + 1

        lda (tmp),y
        sta data.zoom_src_sprite,x
        dex
        bpl -

        rts
.pend



render_full .proc

        lda #$00
        ldx #0
        ldy #0
        jsr render_char
        rts
.pend
