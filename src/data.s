; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass smartindent:
;
; Data section

init_done       .byte 0

idlebgcolor     .byte 11
idlefgcolor     .byte 15
overlaycolor    .byte 0
vidram1color    .byte 13
vidram2color    .byte 12

pixelspritecol  .byte 1
pixelspritexpos .byte $17 + 8
pixelspritexmsb .byte 0
pixelspriteypos .byte $79 + 8


statusbar_text
        .enc "screen"
;        .text "0123456789abcdef0123456789abcdef01234567"
        .text "000,00  00,0  bla foo fuck me lots of text"

statusbar_colors
        .fill 40, 1

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
