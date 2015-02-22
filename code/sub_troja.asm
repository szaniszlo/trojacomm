;============================================================
;    Troja - virus emulation. Makes all characters pile up
;            at the bottom of the screen.
;    (c) 2015 by Stefan Szaniszlo. All Rights Reserved
;============================================================

troja_off_flag !byte 00

troja_init  inc troja_off_flag      ; initial invocation sets the "on" flag to non-zero
            beq troja_init
troja_start lda #$bf                ; initialise pointer to the end of the second last screen line
            sta $fb
            lda #$07
            sta $fc
            rts

troja_cycle lda troja_off_flag
            beq troja_rts
            lda #$00                ; reset the on flag, the interrup routine now needs to move a character, if non is found
            sta troja_off_flag      ; theb the flag won't be set and the routine will go into low-effort mode.

troja_loop  ldy #$00                ; looping through the screen
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
            inc troja_off_flag      ; reset the troja_off_flag flag to non zero - means we moved a value in this loop
            lda #$28                ; set up to check the following line
            sbc $fb
            bcc troja_loop ; was bpl
            jmp troja_high 
troja_dec   dec $fb         ; decrement pointer to move on to the next position
            bne troja_loop  ; continue looping if no carry detected
troja_high  dec $fc         ; handle the high address
            lda #$03
            cmp $fc
            bne troja_loop  ; loop until the start of screen buffer is passed
            jsr troja_start ; reset the current position
troja_rts   rts 
