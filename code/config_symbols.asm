;===============================================================
; setting up some general symbols we use in our code
;================================================================

;============================================================
; symbols
;============================================================

cinv 			= $0314     ; location of IRQ vector
cnmi 			= $0318     ; location of NMI vector

screen_ram      = $0400     ; location of screen ram
pra             = $dc00     ; CIA#1 (Port Register A)
prb             = $dc01     ; CIA#1 (Port Register B)
ddra            = $dc02     ; CIA#1 (Data Direction Register A)
ddrb            = $dc03     ; CIA#1 (Data Direction Register B)

init_sid        = address_sid + $0f80     ; init routine for music
play_sid        = address_sid + $0012     ; play music routine
