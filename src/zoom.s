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
        #assert_zp row

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



; @brief        Get pointer to sprite layer 'char'
;
; @param X      column
; @param Y      row
;
; @return       X = LB, Y = MSB
;
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
        #debug_stx $0402
        #debug_sty $0403
        rts
.pend


; @brief        Get pointer to bitmap
;
; @param X      column
; @param Y      row
;
; @return       X = LSB, Y = MSB
;
bitmap_get_ptr .proc
        lda data.bitmap_char_xlsb + 8,x         ; TODO: use constant
        clc
        adc data.bitmap_char_ylsb,y
        pha
        lda data.bitmap_char_xmsb + 8,x         ; TODO: use constant
        adc data.bitmap_char_ymsb,y
        adc #>VIEW_BITMAP
        tay
        pla
        tax
        #debug_stx $0400
        #debug_sty $0401
        rts
.pend


; @brief        Get pointer to videoram
;
; @param X      column
; @param Y      row
;
; @return       X = LSB, Y = MSB
;
vidram_get_ptr .proc
        txa
        clc
        adc data.screen_row_lsb,y
        pha
        lda data.screen_row_msb,y
        adc #>VIEW_VIDRAM
        tay
        pla
        tax
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
        dst = zp + 2
        tmp = zp + 4
        color = zp + 6
        column = zp + 7
        row = zp + 8
        #assert_zp row

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

        ; get colors
        lda data.zoom_src_xchar
        clc
        adc #8
        tax
        ldy data.zoom_src_ychar
        jsr vidram_get_ptr
        stx src + 0
        sty src + 1
        ldy #0
        lda (src),y
        pha
        and #$0f
        sta data.zoom_src_colors + 1
        pla
        lsr a
        lsr a
        lsr a
        lsr a
        sta data.zoom_src_colors + 2
        lda data.overlaycolor
        sta data.zoom_src_colors + 0

        ; determine colram location of zoom
        lda data.zoom_dst_xchar
        asl a
        asl a
        asl a
        tax
        lda data.zoom_dst_ychar
        clc
        asl a
        asl a
        asl a
        adc #9
        tay
        jsr vidram_get_ptr
        stx dst + 0
        tya
        and #3
        ora #$d8
        sta dst + 1

        #debug_stx $0404
        #debug_sta $0405

        ;
        ; now actually render the zoom
        ;
        ; sprite layer has priority
        ;
        ldy #0
        sty row
more_row
        ldx #0
        stx column
        ldy row
more_pixel
        ldy row
        ldx column
        ; check sprite layer
        lda data.zoom_src_sprite,y
        and data.pixel_bitmask,x
        beq +
        lda #0
        sta color
        jmp next_pixel
+
        lda #1
        sta color
        lda data.zoom_src_bitmap,y
        and data.pixel_bitmask,x
        bne +
        inc color
+
next_pixel

        ; plot current
loadcolor
        ldx color
        ldy column
        lda data.zoom_src_colors,x
        sta (dst),y

        inc column
        lda column
        cmp #$8
        bne more_pixel

        ; add row
        lda dst
        clc
        adc #40
        sta dst
        bcc +
        inc dst +1
+

        inc row
        lda row
        cmp #$08
        bne more_row

        rts
.pend


; @brief        Render full zoom area
;
; @clobbers     all
;
render_full .proc

        jsr clear

        lda #$00
        ldx #0
        ldy #0
        jsr render_char

        lda #$01
        ldx #1
        ldy #0
        jsr render_char

        lda #$02
        ldx #2
        ldy #0
        jsr render_char

        lda #$03
        ldx #3
        ldy #0
        jsr render_char

        lda #$04
        ldx #4
        ldy #0
        jsr render_char

        lda #$10
        ldx #0
        ldy #1
        jsr render_char

        lda #$11
        ldx #1
        ldy #1
        jsr render_char

        lda #$12
        ldx #2
        ldy #1
        jsr render_char

        lda #$13
        ldx #3
        ldy #1
        jsr render_char

        lda #$14
        ldx #4
        ldy #1
        jsr render_char

        rts
.pend
