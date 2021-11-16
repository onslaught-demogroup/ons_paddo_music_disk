/*
Demo Sourcecode

----------------------------------------
Memory map:
$0800         : BASIC start
$0ff0 - $3000 : Music Buffer
$3000 - $5000 : Petscii Buffer
$5000 - $C000 : Code
$C000 - $D000 : Load Buffer


----------------------------------------
ZeroPage:
$50-$5f Keyboard Handler
$9e-$9f IRQ Load Setup
$ab-$ae Scroller
$d0-$ef Exomizer
$fd-$fe GoatTracker
$f0-$f3 IRQ Load Runtime
$60/$61 General demo controller
*/
.var dzp_lo = $60
.var dzp_hi = $61

/*
----------------------------------------
Macros
----------------------------------------
*/
.import source "const.asm"
.import source "macro.asm"

/*
----------------------------------------
Memory management
----------------------------------------
*/
.import source "petscii_addresses.asm"

/*
----------------------------------------
Autogenerated Modules
----------------------------------------
*/
.import source "sid_include.asm"
.import source "petscii_include.asm"

/*
----------------------------------------
Template Code Modules
(these get loaded into the template space)
----------------------------------------
*/
.segment xys_routine [outPrg="ab.prg"]
*=$7000
.pc=* "XYSwinger Effect"
.import source "xyswinger.asm"
.pc = * "Tile Scroller Effect"
.import source "scroller.asm"

.segment megalogo [outPrg="ac.prg"]
*=$8500
.pc = * "Mega Logo"
.import source "biglogo_include.asm"

.segment xys_fadeout [outPrg="ad.prg"]
*=$3000
.pc = * "XYSwinger Effect Fadeout"
.import source "xyswinger_fadeout.asm"

/*
Main memory map:
$7000
$a000 - $c000: Menu lib and items
*/
.segment menu_core [outPrg="ba.prg"]
*=$a400
.pc = * "Song Titles"
.import source "menu_items.asm"
*=$a000
.pc = * "Menu Core"
.import source "menu.asm"

/*
----------------------------------------
Common Utils
----------------------------------------
*/

/*
Main Demo BASIC Entry
*/
.segment demo_main [outPrg="demo.prg"]
*=$0801
BasicUpstart2(start)

/*
Global flags
*/
enable_music:
.byte $00

enable_effect:
.byte $00

demo_state:
.byte $00

/*
Buffers:
*/

/*
----------------------------------------
Sprite
----------------------------------------
*/
.pc=$0a00
.for(var i=0;i<8;i++){
    .byte $ff, $ff, $ff
}
.for(var i=0;i<13;i++){
    .byte $00, $00, $00
}

/*
----------------------------------------
Music
----------------------------------------
*/

// $0f00 - $3000 is reserved for music
.pc=$0f00 "Music Buffer (and temporary irq loader drivecode)"
loader_init:
.import source "loader_init.asm"
.var music_song = $0f00
.var music_speed = $0f01
.var music_init = $0f02
.var music_play = $0f04

// $3000 - $5000 is reserved for packed animation in main demo
.pc=$3000 "PETSCII Animation Buffers"


/*
----------------------------------------
Base code that never gets replaced
----------------------------------------
*/
.pc=$5000 "Code"
.pc=* "Exomizer"
.import source "exo.asm"

.pc=* "RLE Depacker"
.import source "rle_depacker.asm"

.pc=* "IRQ Loader"
.import source "loader_load.asm"

.pc=* "spinner"
.import source "spinner.asm"

.pc=* "keyboard handler"
keyboard:
.import source "keyboard.asm"

.pc=* "Music Functions"
.import source "music.asm"

.pc=* "Input Handlers"
press_space:
    jsr keyboard
    bcs press_space
    cmp #$20
    beq !finish+
    jmp press_space
!finish:
    rts

.pc=* "Utilities"

/*
----------------------------------------
Fill: 
x = fill char
y = fill color

*/
fill:
    //note: trying to balance size and speed with this, 
    //and can't use kernel as this whacks zeropage...
    stx fill_char
    sty fill_color
    ldx #$00
!loop:
    lda fill_char: #$20
    .for(var i=0;i<25;i++){
        sta $0400+(i*40),x
    }
    lda fill_color: #$00
    .for(var i=0;i<25;i++){
        sta $d800+(i*40),x
    }
    inx
    cpx #$28
    beq !+
    jmp !loop-
!:
    rts

/*
----------------------------------------
Pause:
y = number of iterations to pause
*/
pause:
    stx tmpx
    ldx #$00
!:
    nop
mini_pause:
    dex
    bne !-
    dey
    bne !-
    ldx tmpx: #$00
    rts

/*
----------------------------------------
MAIN
----------------------------------------
*/
.pc = * "Main DEMO"
start:
    lda #$00
    sta $d020
    sta $d021
    lda #$00
    sta $d020
    sta $d021
    ldx #$20
    ldy #$00
    jsr fill
    lda #$15
    sta $d018	
    lda#$80
    sta $0291
    //have to init scroller after clearing the screen!
    sei              
    lda #$7f       // Disable CIA
    sta $dc0d
    lda $d01a      // Enable raster interrupts
    ora #$01
    sta $d01a
    lda $d011      // High bit of raster line cleared, we're
    and #$7f       // only working within single byte ranges
    sta $d011
    lda #$01    // We want an interrupt at the top line
    sta $d012
    lda #<irq_loader 
    sta $0314    
    lda #>irq_loader
    sta $0315
    lda #$36
    sta $01
    cli  
    jmp timeline

/*
----------------------------------------
Interrupt Management
----------------------------------------

*/
.pc=* "irq"

//IRQ state machine
irq_state:
    lda demo_state
    cmp current_state: #$00
    bne !zero+
    rts

!zero:  
    sta current_state
    cmp #$00
    bne !one+

    // 0 = loader irq
    lda #$00
    sta $d012
    lda #>irq_loader
    sta $0315
    lda #<irq_loader
    sta $0314
    rts

!one:  
    cmp #$01
    beq !+
    jmp !two+
!:
    // 1 = intro irq a
    lda #$20
    sta $d012
    lda #>irq_intro_a
    sta $0315
    lda #<irq_intro_a
    sta $0314
    ldaStaMany($28,$07f8,$08,$01) //sprite ptr
    ldaStaMany($ae,$d001,$10,$02) // set y
    ldaStaMany($00,$d027,$08,$01) //fg color
    .var base=0
    .for(var i=0;i<8;i++){
        lda #<(base + (i*3*8*2))
        sta $d000 + (i*2)
    }
    lda #%11000000
    sta $d010
    lda #$00
    sta $d01c
    sta $d017
    sta $d01b
    lda #$ff
    sta $d015
    sta $d01d
    rts


!two:  
    cmp #$02
    bne !nope+
    // 2 = main irq
    lda #$00
    sta $d012
    lda #>irq_a
    sta $0315
    lda #<irq_a
    sta $0314
!nope:
    rts

//Actual IRQs
irq_loader:
    lda enable_effect
    beq !+
    jsr spinner_run
!:
    jsr irq_state
    lda #$ff 
    sta $d019
    jmp $ea81  


irq_intro_a:
    //inc $d020
    lda #$99
    sta $d012
    lda enable_effect
    beq !+
    jsr xys
    jsr s_scroll
    jsr m_play
!:
    jsr irq_state
    lda #$ff 
    sta $d019
    jmp $ea81  

//standard main irq
irq_a:
    lda enable_effect
    beq !+
    inc $d020
    jsr menu_irq_handler
    dec $d020
!:
    lda enable_music
    beq !+
    inc $d020
    jsr m_play
    dec $d020
!:
    lda #$a0
    sta $d012
    lda #>irq_b
    sta $0315
    lda #<irq_b
    sta $0314
    jsr irq_state
    lda #$ff 
    sta $d019
    jmp $ea81  

//multispeed irq
irq_b:
    lda enable_effect
    beq !+
    lda enable_music
    beq !+
    lda music_speed
    cmp #$ff //multispeed flag from SID
    bne !+
    inc $d020
    jsr m_play
    dec $d020
!: 
    lda #$ec
    sta $d012
    lda #>irq_a
    sta $0315
    lda #<irq_a
    sta $0314
    lda #$ff 
    sta $d019
    jmp $ea81  

/* 
----------------------------------------
timeline:
----------------------------------------
*/
.pc = * "Internal timeline"
timeline:
    inc enable_effect
    jsr loader_init

//jmp debug_skip_intro

/*
START INTRO
*/
    //fast ram clear for logo
    lda #$85
    sta dzp_hi
    tax
    lda #$00
    sta dzp_lo
    ldy #$00
    lda #$20
!:
    sta (dzp_lo),y
    inc dzp_lo
    bne !-
    inc dzp_hi
    inx
    cpx #$b8
    bne !- 

    load('0','7',$c000) //01.prg
    jsr m_disable
    jsr exo_exo
    jsr m_reset

    // //this is how we load screens - todo - load the data
    // load(70,70,$c000) //ff.prg
    // jsr exo_exo

    //load scroller-xyswinger merged template
    load('A','B',$b800) 
    jsr exo_exo

    //load scroller-xyswinger merged template
    load('A','D',$b800) 
    jsr exo_exo

    //load mega logo template
    load('A','C',$b800) 

    //disable spinner
    lda #$00
    sta enable_effect
    // clear screen
    ldx #$20
    ldy #$00
    jsr fill
    //init scroller
    jsr s_init
    // set up color for startup
    jsr s_switch_alt
    lda #$00
    sta intro_scroller_bg
    //transition IRQ to next state 
    //and enable effects in the IRQ
    inc demo_state
    inc enable_effect
    //fade in scroller
    ldy #$40
    jsr pause
    lda #$0b
    sta intro_scroller_bg
    ldy #$02
    jsr pause
    lda #$0b
    sta intro_scroller_bg
    ldy #$02
    jsr pause
    lda #$0c
    sta intro_scroller_bg
    ldy #$02
    jsr pause
    lda #$03
    sta intro_scroller_bg
    ldy #$02
    jsr pause
    lda #$0f
    sta intro_scroller_bg
    ldy #$02
    jsr pause
    lda #$01
    sta intro_scroller_bg
    ldy #$02
    jsr pause
    lda #$0f
    sta intro_scroller_bg
    ldy #$02
    jsr pause
    lda #$03
    sta intro_scroller_bg
    ldy #$02
    jsr pause
    lda #$0c
    sta intro_scroller_bg
    ldy #$02
    jsr pause
    lda #$0b
    sta intro_scroller_bg
    // switch to color in scroller
    ldy #$10
    jsr pause
    jsr s_switch_main
    //decompress logo as a buildup
    jsr exo_exo
    //switch to colorful scroller

    jsr press_space

    /*
    Fade out music and logo
    */
    lda #$0c
    sta intro_scroller_bg
    ldy #$04
    jsr pause
    lda #$0f
    sta intro_scroller_bg
    ldy #$04
    jsr pause
    lda #$03
    sta intro_scroller_bg
    ldy #$04
    jsr pause
    lda #$01
    sta intro_scroller_bg
    ldy #$04
    jsr pause
    lda #$03
    sta intro_scroller_bg
    ldy #$04
    jsr pause
    lda #$0f
    sta intro_scroller_bg
    ldy #$04
    jsr pause
    lda #$0c
    sta intro_scroller_bg
    ldy #$04
    jsr pause
    lda #$0b
    sta intro_scroller_bg
    ldy #$04
    jsr pause
    lda #$00
    sta intro_scroller_bg
    ldy #$04
    jsr pause
    jsr s_switch_alt
    jsr xys_fadeout
    jsr m_disable

/*
END INTRO
*/
debug_skip_intro:

    // disable effects
    lda #$00
    sta enable_effect 
    //switch to spinner IRQ
    lda #$00
    sta demo_state
    // clear screen
    ldx #$20
    ldy #$00
    jsr fill
    lda #$00
    sta $d015
    //disable music
    sta enable_music
    //enable spinner
    inc enable_effect
    //preload menu core ($a000-$c000)
    load('B','A',$c000) 
    jsr exo_exo
    //load timeline 1
    load('T','1',$c000) 
    jsr exo_exo
    //timeline 1
    jsr $7000
    //timeline 2 (player)
    load('T','2',$c000) 
    jsr exo_exo
    jsr $7000


!:
    jmp !-

/*
----------------------------------------
Template code that can be overwritten
----------------------------------------
*/
.pc=$7000 "Template code that is replaced"
template_base:





/*
Timeline templates
*/
.segment timeline1 [outPrg="t1.prg"]
*=$7000
.pc = * "Timeline 1"
.import source "timeline1.asm"

.segment timeline2 [outPrg="t2.prg"]
*=$7000
.pc = * "Timeline 2"
.import source "timeline2.asm"

