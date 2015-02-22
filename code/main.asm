;===================================
; main.asm triggers all subroutines 
; and runs the Interrupt Routine
;===================================

main
          lda #$00    ; initialise the SID player
          tax
          tay
          jsr init_sid 
          jsr troja_init
          jsr install_irq
          rts         ; return to basic


;================================
; Our custom interrupt routines 
;================================

irq        dec $d019          ; acknowledge IRQ / clear register for next interrupt
           
           jsr play_sid       ; play a bit of music
           ;jsr text_cycle     ; put color cycle on text
           ;jsr show_address
           jsr troja_cycle
           ;jsr background_cycle ; cycle the background
           jsr check_keyboard ; check keyboard controls

           jmp $ea81          ; return to Kernel routine

;============================================================
;    Just a simple test / some effects
;============================================================

text_cycle  ldx screen_ram
            inx
            txa
            ldx #$00
text_loop   sta screen_ram,x
            sta screen_ram+0x100,x
            sta screen_ram+0x200,x
            sta screen_ram+0x2E8,x
            tay
            iny
            tya
            inx
            bne text_loop 

            rts

background_cycle
            inc $d020
            rts 

;============================================================
;    Show some text on the last line of the screen
;============================================================

show_address
            lda $d41b
            ldy #$20
            jsr print_hex
            lda $d41c
            ldy #$22
            jsr print_hex
            lda #$00
            ldy #$24
            jsr print_hex
            lda $fd
            ldy #$26
            jsr print_hex
            rts
print_hex         ; accu - the value
                  ; the start value offset for the value on the last screen line (#$00-#$27)
            pha 
            lsr 
            lsr 
            lsr 
            lsr 
            tax
            clc 
            lda convtable,x 
            sta $07c0, y 
            pla 
            and #$0f 
            tax 
            lda convtable,x 
            sta $07c1, y
            rts 



convtable !byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$1,$2,$3,$4,$5,$6

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
            sta $0314    ; store in $314/$315
            stx $0315   

            lda #$00    ; trigger interrupt at row zero
            sta $d012

            lda #$00    ; set initialise background colors to black
            sta $d020

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

;============================================================
;    Troja - virus emulation. Makes all characters pile up
;            at the bottom of the screen.
;============================================================

troja_init  lda #$01      ; initial invocation sets the "on" flag to non-zero
            sta $fd
troja_start lda #$bf      ; initialise pointer to the end of the second last screen line 
            sta $fb
            lda #$07
            sta $fc
            rts

troja_cycle lda $fd
            beq troja_rts
            lda #$00      ; reset the on flag, the interrup routine now needs to move a character, if non is found
            sta $fd       ; theb the flag won't be set and the routine will go into low-effort mode.

troja_loop  ldy #$00      ; looping through the screen
            lda ($fb),y
            cmp #$20
            beq troja_dec
            tax
            ldy #$28
            lda ($fb),y
            cmp #$20
            bne troja_dec
            txa
            sta ($fb),y
            ldy #$00
            lda #$20
            sta ($fb),y
            lda #$28        ; set up to check the following line
            sta $fd         ; reset the $fd flag to non zero - means we moved a value in this loop
            sbc $fb
            bcc troja_loop ; was bpl
            jmp troja_high 
troja_dec   dec $fb         ; decrement pointer to the next position
            bne troja_loop  ; return if no carry detected
troja_high  dec $fc         ; handle the high address
            lda #$03
            cmp $fc
            bne troja_loop
            jsr troja_start
troja_rts   rts 
