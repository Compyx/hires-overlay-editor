; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass smartindent:
;
; Status display


init .proc
        ldx #39
-       lda data.statusbar_text,x
        sta STAT_VIDRAM,x
        lda data.statusbar_colors,x
        sta $d800 + (STAT_VIDRAM & $03ff),x
        dex
        bpl -
        rts
.pend
