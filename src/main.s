; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass smartindent:
;

; $4000-$5f3f   work bitmap
; $6000-$63e7   work vidram
;

        VIEW_BITMAP     = $4000
        VIEW_ROWS       = 8
        VIEW_BITMAP_END = VIEW_BITMAP + VIEW_ROWS * $0140
        VIEW_SPRITES    = $4a00
        VIEW_VIDRAM     = $5000
        VIEW_POINTERS   = VIEW_VIDRAM + $03f8

        STAT_VIDRAM     = $0400 + VIEW_ROWS * 40

        ZOOM_VIDRAM     = STAT_VIDRAM + 40
        ZOOM_ROWS       = 16
        ZOOM_POINTERS   = $07f8

        ZOOM_SPRITE_PIXEL = $3fc0

        FONT_ADDR       = $3800
        FONT_SIZE       = $0400
        FONT_NAME       = "font4.prg"

        zp = $10

        * = $0801

        .word (+), 2021
        .null $9e, format("%d", main)
+       .word(0)

main
        lda #6
        sta $d020
        sta $d021


        ; only run once
        lda data.init_done
        bne init_skip
        jsr init
init_skip
        lda #1
        sta data.init_done

        lda #$55
        sta $3fff
        lda #$aa
        sta $7fff

        sei
        lda #$7f
        sta $dc0d
        sta $dd0d

        lda #$f9
        sta $d012
        lda #<lborder_irq
        ldx #>lborder_irq
        sta $0314
        stx $0315
        lda #$1b
        sta $d011

        asl $d019
        bit $dc0d
        bit $dd0d
        lda #$01
        sta $d01a
 
        cli

        jsr test_window_render

        jmp *


init .proc


        ldx #0
-
.for k = 0, k < 6, k += 1
        lda $a000 + k * 256,x
        sta $4a00 + k * 256,x
.next
        inx
        bne -
-
.for k = 0, k < 10, k += 1
        lda $e000 + k * 256,x
        sta $4000 + k * 256,x
.next
        inx
        bne -

-       lda $f000,x
        sta $5000,x
        inx
        bne -
        ldx #$3f
-       lda $f100,x
        sta $5100,x
        dex
        bpl -

        jsr view.init
        jsr status.init
        jsr zoom.init
        rts
.pend



lborder_irq
        dec $d020
        lda #$13
        sta $d011
        ldx #$40
-       dex
        bpl -
        lda #$1b
        sta $d011
        inc $d020

        lda #<uborder_irq
        ldx #>uborder_irq
        ldy #$0
do_irq
        sta $0314
        stx $0315
        sty $d012
        inc $d019
        jmp $ea81

uborder_irq
        dec $d020
        lda #0
        sta $d015
        jsr set_sprites_color
        inc $d020

        lda #<view_irq1
        ldx #>view_irq1
        ldy #$2e
        jmp do_irq


view_irq1
        dec $d020
        lda #$ff
        sta $d015
        lda #$00
        sta $d01b
        sta $d01c
        sta $d01d
        sta $d017

        jsr set_sprite_layer_xpos
        jsr set_sprite_layer_ypos1

        lda #$3b
        sta $d011
        lda #$40
        sta $d018
        lda #$02
        sta $dd00

        inc $d020

        lda #<view_irq2
        ldx #>view_irq2
        ldy #$33 + 20
        jmp do_irq


view_irq2
        inc $d020
        jsr set_sprite_layer_ypos2
        dec $d020

        lda #<view_irq3
        ldx #>view_irq3
        ldy #$33 + 20 + 21
        jmp do_irq


view_irq3
        inc $d020
        jsr set_sprite_layer_ypos3
        dec $d020

        lda #<status_irq
        ldx #>status_irq
        ldy #$72
        jmp do_irq


status_irq
        dec $d020
        lda #$1b
        sta $d011
        lda #$1e
        sta $d018
        lda #$03
        sta $dd00

        jsr set_zoom_sprites
        inc $d020

        lda #<lborder_irq
        ldx #>lborder_irq
        ldy #$f9
        jmp do_irq

set_sprite_layer_xpos .proc
        lda #$58
        sta $d000
        lda #$70
        sta $d002
        lda #$88
        sta $d004
        lda #$a0
        sta $d006
        lda #$b8
        sta $d008
        lda #$d0
        sta $d00a
        lda #$e8
        sta $d00c
        lda #$00
        sta $d00e
        lda #$80
        sta $d010
        rts
.pend


set_sprites_color .proc
        lda data.overlaycolor
        sta $d027
        sta $d028
        sta $d029
        sta $d02a
        sta $d02b
        sta $d02c
        sta $d02d
        sta $d02e
        rts
.pend


set_sprite_layer_ypos1 .proc
        lda #$33
        sta $d001
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

        ldx #$fe        ; 'filter' for SAX
        lda #((VIEW_SPRITES & $3fff) / 64) + 1
        sax VIEW_POINTERS + 0
        sta VIEW_POINTERS + 1
        lda #((VIEW_SPRITES & $3fff) / 64) + 3
        sax VIEW_POINTERS + 2
        sta VIEW_POINTERS + 3
        lda #((VIEW_SPRITES & $3fff) / 64) + 5
        sax VIEW_POINTERS + 4
        sta VIEW_POINTERS + 5
        lda #((VIEW_SPRITES & $3fff) / 64) + 7
        sax VIEW_POINTERS + 6
        sta VIEW_POINTERS + 7
        rts
.pend


set_sprite_layer_ypos2 .proc
        lda #$33 + 21
        sta $d001
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

        ldx #$fe        ; 'filter' for SAX
        lda #((VIEW_SPRITES & $3fff) / 64) + 9
        sax VIEW_POINTERS + 0
        sta VIEW_POINTERS + 1
        lda #((VIEW_SPRITES & $3fff) / 64) + 11
        sax VIEW_POINTERS + 2
        sta VIEW_POINTERS + 3
        lda #((VIEW_SPRITES & $3fff) / 64) + 13
        sax VIEW_POINTERS + 4
        sta VIEW_POINTERS + 5
        lda #((VIEW_SPRITES & $3fff) / 64) + 15
        sax VIEW_POINTERS + 6
        sta VIEW_POINTERS + 7
        rts
.pend


set_sprite_layer_ypos3 .proc
        lda #$33 + 21 + 21
        sta $d001
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

        ldx #$fe        ; 'filter' for SAX
        lda #((VIEW_SPRITES & $3fff) / 64) + 17
        sax VIEW_POINTERS + 0
        sta VIEW_POINTERS + 1
        lda #((VIEW_SPRITES & $3fff) / 64) + 19
        sax VIEW_POINTERS + 2
        sta VIEW_POINTERS + 3
        lda #((VIEW_SPRITES & $3fff) / 64) + 21
        sax VIEW_POINTERS + 4
        sta VIEW_POINTERS + 5
        lda #((VIEW_SPRITES & $3fff) / 64) + 23
        sax VIEW_POINTERS + 6
        sta VIEW_POINTERS + 7
        rts
.pend



; @brief        Set zoom sprites
;
set_zoom_sprites .proc
        lda #$01
        sta $d015
        lda #0
        sta $d010

        lda #$ff
        sta $07f8
        lda data.pixelspritecol
        sta $d027
        lda data.pixelspritexpos
        sta $d000
        lda data.pixelspriteypos
        sta $d001
        lda $d010
        ora data.pixelspritexmsb
        sta $d010
        rts
.pend


; Namespaces
;
data    .binclude "data.s"
status  .binclude "status.s"
view    .binclude "view.s"
zoom    .binclude "zoom.s"
ui      .binclude "ui.s"



test_window_render
        ldx #4
        ldy #4
        jsr ui.window_set_pos
        ldx #30
        ldy #5
        jsr ui.window_set_size
        jsr ui.window_render_frame

        ldx #<window_test_title
        ldy #>window_test_title
        jsr ui.window_render_title

        ldx #<window_test_text
        ldy #>window_test_text
        jsr ui.window_render_text

        rts

window_test_title
        .enc "screen"
        .text "hoe - hires overlay editor"
        .byte 0


window_test_text
        .enc "screen"
        .byte $8f
        .text "hello "
        .byte $87
        .text "world! "
        .byte $8f
        .text "- this line should wrap around. carriage"
        .byte $90
        .text "return."
        .byte $81
        .text "yay!"
        .byte $ff

; Font
        * = FONT_ADDR

.binary format("../data/%s", FONT_NAME), 2, FONT_SIZE
