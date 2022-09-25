* = $0801
      
      ; Old school C64 demo effects - 26th line text scroller
      ; Geehaf September 2022
      
      !BASIC            ; create a BASIC stub
   
      sei
      lda #$7f
      sta $dc0d
      sta $dd0d
      lda #$35
      sta $01

      ldy #$30          ; draw the row numbers 01 - 25 on each line of the screen
      ldx #$31
      lda #24           
      sta $d0
aa:   stx $0401
bb:   sty $0400
      inx
      cpx #$3a
      bne +
      ldx #$30
      iny
+     clc
      lda aa+1
      adc #40
      sta aa+1
      bcc +
      inc aa+2
      clc
+     lda bb+1
      adc #40
      sta bb+1
      bcc +
      inc bb+2
+     dec $d0
      bpl aa
      
      ldx #$03            ; copy screen text from $0400 to $0c00
      ldy #$00
dd:   lda $0400,y
ee:   sta $0c00,y
      iny
      bne dd
      inc dd+2
      inc ee+2
      dex
      bpl dd
      lda #$35
      sta $0f99

      lda #$00            ; set up the 1st raster IRQ
      sta $d012
      sta $3fff
      lda #$1b
      sta $d011
      lda #$01
      sta $d01a
      lda #<irq1
      sta $fffe
      lda #>irq1
      sta $ffff
      cli
      jmp *
      
      ; This is where the action happens
      
irq1:   
      sta $d0
      stx $d1
      sty $d2
      ldy #$18          ; Set RSEL = 1 & YSCROLL = 0
      sty $d011
      lda #$08          ; 40 column mode
      sta $d016
      jsr doScroll
      lda #<irq2
      sta $fffe
      lda #>irq2
      sta $ffff
      lda #234
      sta $d012
      asl $d019
      lda $d0
      ldx $d1
      ldy $d2
      rti
irq2:
      sta $d0
      stx $d1
      sty $d2
      ldy #$1f
      lda #$34    ; set screen base to $0c00
      sta $d018
      ldx #3
-     dex
      bne -        ; Waste CPU cycles
      sty $d011    ; Set YSCROLL = 7 which forces VIC II to draw 8 lines again (remember we're currently at raster line 234). 
      lda #<irq2a
      sta $fffe
      lda #>irq2a
      sta $ffff
      lda #245
      sta $d012
      asl $d019
      lda $d0
      ldx $d1
      ldy $d2
      rti
irq2a:
      sta $d0
      stx $d1
      sty $d2
      lda #$15    ; set screen base to $0400
      sta $d018
xscroll:
      lda #$00
      sta $d016      
      lda #<irq3
      sta $fffe
      lda #>irq3
      sta $ffff
      lda #249
      sta $d012
      asl $d019
      lda $d0
      ldx $d1
      ldy $d2
      rti

irq3:      
      sta $d0
      stx $d1
      sty $d2
      lda #$15
      sta $d011   ; Set RSEL = 0 to remove border so we can see the new "26th" line
      lda #<irq1
      sta $fffe
      lda #>irq1
      sta $ffff
      lda #0
      sta $d012
      asl $d019
      lda $d0
      ldx $d1
      ldy $d2
      rti      

doScroll:
      dec xscroll+1
      bpl doFineScroll
      lda #7                  ; reset fine scroll counter
      sta xscroll+1
      ldx #0
-     lda $0401+(24*40),x     ; move our scroll text 1 char to the left
      sta $0400+(24*40),x
      inx
      cpx #39
      bne - 
textPos:
      ldy #$00
-     lda text,y        ; grab next character to display for scroller
      bne +
      tay               ; reset the pointer to the start of the message
      beq -
+     sta $0400+(25*40)-1 ; store scroll text it the last column of the last row, ready to scroll across the screen
      iny
      sty textPos+1
doFineScroll:
      rts
      
text:
      !SCR " back to basics - old school demo effects. welcome to the 26th row on the c64 screen. no sprites. no $3fff. just text characters. enjoy. bye for now, geehaf.                                      ",0
      