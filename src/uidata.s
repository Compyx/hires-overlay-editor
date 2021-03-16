; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass smartindent:
;
; @file     uidata.s
; @brief    UI data
;
; Contains data of the dialogs for the current application.
;
; Dialog data structure:
;
;       .byte dialog-type (in src/ui.s)
;       .byte width
;       .byte height
;       .word title
;       .word text
;       (optional data dependent on dialog-type)



dialog_ptrs
        .word welcome_dlg


welcome_dlg
        .byte ui.TYPE_INFO
        .byte 30, 6
        .word welcome_title
        .word welcome_text


; @brief        Welcome screen title
welcome_title
        .enc "screen"
        .text "hoe - hires overlay editor"
        .byte 0


; @brief        Welcome screen text
welcome_text
        .enc "screen"
        .byte $8f
        .text "hello "
        .byte $87
        .text "world! "
        .byte $8f
        .text "- this line should wrap around. carriage"
        .byte ui.CRLF
        .text "return."
        .byte $81
        .text "yay!"
        .byte $ff

