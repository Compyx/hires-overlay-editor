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


render_char .proc
        rts
.pend



render_full .proc
        rts
.pend
