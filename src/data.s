; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass smartindent:
;
; Data section


init_done       .byte 0         ; signal that the cold-start init was done

; View data
idlebgcolor     .byte 11        ; 'idle' graphics area background color
idlefgcolor     .byte 15        ; 'idle' graphics area foreground color
overlaycolor    .byte 0         ; color of the hires overlayed sprites
vidram1color    .byte 13        ; vidram color for bitpair %01
vidram2color    .byte 12        ; vidram color for bitpair %10

; Zoom data
pixelspritecol  .byte 1         ; pixel sprite color
pixelspritexpos .byte $17 + 8   ; pixel sprite x-pos lsb
pixelspritexmsb .byte 0         ; pixel sprite x-pos msb
pixelspriteypos .byte $79 + 8   ; pixel sprite y-pos

; UI data
window_xpos     .byte 0         ; window xpos in the zoom area
window_ypos     .byte 0         ; window ypos in the zoom area
window_width    .byte 0         ; window width, excluding the frame
window_width2   .byte 0         ; window_width + 1, helps with code
window_height   .byte 0         ; window height, excluding the frame
window_framecol .byte $e        ; color of the window frame
window_text_xpos        .byte 0
window_text_ypos        .byte 0

dialog_active   .byte 0

dialog_index    .byte 0
dialog_xpos     .byte 0
dialog_ypos     .byte 0
dialog_width    .byte 0
dialog_height   .byte 0
dialog_type     .byte 0
dialog_title    .word 0
dialog_text     .word 0

; extra data (optional)
dialog_extra     .word 0


; zoom data

; Zoom destination
zoom_dst_xchar  .byte 0
zoom_dst_ychar  .byte 0

; Zoom source data
zoom_src_xchar  .byte 0
zoom_src_ychar  .byte 0

zoom_src_sprite .fill 8, 0
zoom_src_bitmap .fill 8, 0
zoom_src_colors .fill 4, 0


; Status data

; statusbar text
statusbar_text
        .enc "screen"
;        .text "0123456789abcdef0123456789abcdef01234567"
        .text "000,00 00,0 bla foo fuck me lots of text"

; statusbar colors
statusbar_colors
        .fill 40, 1


; Zoom pixel sprite data
;
; @todo write as .prg/.bin and include
;
pixel_sprite_data
        .byte %11111111, %10000000, 0
        .byte %10000000, %10000000, 0
        .byte %10000000, %10000000, 0
        .byte %10000000, %10000000, 0
        .byte %10000000, %10000000, 0
        .byte %10000000, %10000000, 0
        .byte %10000000, %10000000, 0
        .byte %10000000, %10000000, 0
        .byte %11111111, %10000000, 0
pixel_sprite_data_end


; Generic data


; screen row LSB table
screen_row_lsb
        .byte <(range(25) * 40)

; screen row MSB table
screen_row_msb
        .byte >(range(25) * 40)


; @brief        Calculate sprite layer column offset
;
; Generates 00, 01, 02, 40, 41, 42, 80, 81, 82, c0, c1, c2, 100, 101, 102 etc.
;
fn_sprite_xoffset .sfunction _xpos, (((_xpos / 3) << 6) + _xpos % 3)


; @brief        Calculate sprite layer row offset
;
; Generates 00, 03, 06 .. 3c, 200, 203, 206 .. 23c, 400, 403, 406 .. 43c
;
fn_sprite_yoffset .sfunction _ypos, ((_ypos / 21) * $200) + ((_ypos % 21) * 3)


; sprite layer column LSB
sprite_char_xlsb
        .byte <fn_sprite_xoffset(range(24))

; sprite data column MSB
sprite_char_xmsb
        .byte >fn_sprite_xoffset(range(24))

; sprite data row LSB
sprite_char_ylsb
        .byte <fn_sprite_yoffset(range(63))

; sprite data row MSB
sprite_char_ymsb
        .byte >fn_sprite_yoffset(range(63))

bitmap_char_xlsb
        .byte <(range(40) * 8)

bitmap_char_xmsb
        .byte >(range(40) * 8)

bitmap_char_ylsb
        .byte <(range(25) * $140)

bitmap_char_ymsb
        .byte >(range(25) * $140)

pixel_bitmask
        .byte $80, $40, $20, $10, $08, $04, $02, $01
