//assumes spinner is running and we are preloading!

/*
TODO: load sound effect in here
*/
    load('S','X',$c000)
    jsr exo_exo
    jsr m_reset
    load('G','G',$c000) 
    jsr exo_exo
    load('H','H',$c000) 
    jsr exo_exo
    load('J','J',$c000) 
    jsr exo_exo
    load('B','B',$c000) 
    jsr exo_exo
    //preload timeline 2
    load('T','2',$c000) 

    // disable spinner
    lda #$00
    sta enable_effect 
    sta enable_music
    //reset borders
    lda #$1b
    sta $d011
    lda #$c8
    sta $d016 
    //switch to main IRQ
    lda #$02
    sta demo_state
    // clear screen
    ldx #$a0
    ldy #$00
    jsr fill

    ldy #$ff
    jsr pause
    ldy #$ff
    jsr pause
    ldy #$ff
    jsr pause

    .var interframe_delay = $00

    lda #$06
    sta $d021
    lda #$01
    sta enable_music
    ldy #$ff
    jsr pause
    petscii_animate(gg, false, $00, $00, $02)
    jsr !animation_loop+
    jsr !animation_loop+
    jsr !animation_loop+
    jsr !animation_loop+
    jsr !animation_loop+
    jsr !animation_loop+
    petscii_animate(jj, false, $00, $00, interframe_delay)
    petscii_animate(bb, false, $00, $00, interframe_delay)
    lda #$00
    sta enable_music
    rts

!animation_loop:
    petscii_animate(hh, false, $00, $00, interframe_delay)
    rts


.var sfx = LoadSid("../assets/manual_conversion/2021-11-15_patto_music_collection_sfx.sid")
.segment SFX [outPrg="../rsrc/sx.prg"]
*=$0f00 "Music Params"
.print "location=$"+toHexString(sfx.location)
.print "init=$"+toHexString(sfx.init)
.print "play=$"+toHexString(sfx.play)
.print "size=$"+toHexString(sfx.size)
.print "name="+sfx.name
.print "------------------------------"
.byte sfx.startSong - 1 
.byte sfx.speed
.word sfx.init
.word sfx.play
*=sfx.location "SFX"
.fill sfx.size, sfx.getData(i)
