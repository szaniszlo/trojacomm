;============================================================
;    Troja - virus emulation. Makes all characters pile up
;            at the bottom of the screen.
;    (c) 2015 by Stefan Szaniszlo. All Rights Reserved
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
