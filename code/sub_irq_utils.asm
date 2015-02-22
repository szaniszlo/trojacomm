;============================================================
;    IRQ setup and cleanup
;============================================================

install_irq
            sei         ; set interrupt disable flag

            ldy #$7f    ; $7f = %01111111
            sty $dc0d   ; Turn off CIAs Timer interrupts ($7f = %01111111)
            sty $dd0d   ; Turn off CIAs Timer interrupts ($7f = %01111111)
            lda $dc0d   ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed
            lda $dd0d   ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed
             
            lda #$01    ; Set Interrupt Request Mask...
            sta $d01a   ; ...we want IRQ by Rasterbeam (%00000001)

            lda #<irq   ; point IRQ Vector to our custom irq routine
            ldx #>irq 
            sta cinv    ; store in $314/$315
            stx cinv+1   

            lda #$00    ; trigger interrupt at row zero
            sta $d012

            cli         ; clear interrupt disable flag
            rts  

deinstall_irq
            sei           ; disable interrupts
            lda #$1b
            sta $d011     ; restore text screen mode
            lda #$81
            sta $dc0d     ; enable Timer A interrupts on CIA 1
            lda #$0
            sta $d01a     ; disable video interrupts
            lda #$31
            sta cinv      ; restore old IRQ vector
            lda #$ea
            sta cinv+1
            bit $dd0d     ; re-enable NMI interrupts
            cli
            rts