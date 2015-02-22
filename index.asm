;============================================================
; index file which loads all source code and resource files
;============================================================

;============================================================
;    specify output file
;============================================================

!cpu 6502
!to "build/trojacomm.prg",cbm    ; output file

;============================================================
; BASIC loader with start address $c000
;============================================================

* = $0801                               ; BASIC start address (#4096)
!byte $0b,$08,$df,$07,$9e,$20,$34,$30   ; BASIC loader to start at $1000...
!byte $39,$36,$00,$00,$00               ; puts BASIC line 2015 SYS 4096
* = $1000     				            ; start address for 6502 code

;============================================================
;  Main routine with IRQ setup and custom IRQ routine
;============================================================

!source "code/main.asm"
!source "code/config_symbols.asm"
!source "code/config_resources.asm"
!source "code/sub_check_keyboard.asm"
