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
.for row = 0, row < 25, row += 1
        .byte <(row * 40)
.next

; screen row MSB table
screen_row_msb
.for row = 0, row < 25, row += 1
        .byte >(row * 40)
.next

