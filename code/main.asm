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
; The Custom interrupt routine 
;================================

irq         dec $d019          ; acknowledge IRQ / clear register for next interrupt
           
            lda $fb            ; backup zero page values
            pha
            lda $fc
            pha
            
            jsr play_sid       ; play a bit of music
            ;jsr text_cycle    ; put color cycle on text
            ;jsr show_address
            jsr troja_cycle
            ;jsr background_cycle ; cycle the background
            jsr check_keyboard ; check keyboard controls

            pla
            sta $fc
            pla
            sta $fb

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
            ldy #$22
            jsr print_hex_last_row
            lda $d41c
            ldy #$24
            jsr print_hex_last_row
            lda troja_off_flag
            ldy #$26
            jsr print_hex_last_row
            rts
            
print_hex_last_row         ; A - the value
                           ; Y - the start value offset for the value on the last screen line (#$00-#$27)
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
