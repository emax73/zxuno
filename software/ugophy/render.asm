; SPDX-FileCopyrightText: Copyright (C) 2019 Alexander Sharikhin
;
; SPDX-License-Identifier: GPL-3.0-or-later

showPage:
    xor a : ld (show_offset), a
    inc a :ld (cursor_pos), a
backToPage:    
    xor a : call changeBank
    call renderScreen : call showCursor
showLp:
    xor a : call changeBank
controls:
    xor a : ld (s_show_flag), a

    call inkey 
    cp 0   : jr z, showLp 
    cp 'q' : jp z, pageCursorUp
    cp 'a' : jp z, pageCursorDown
    cp 13  : jp z, selectItem 
    cp 'b' : jp z, historyBack
    cp 'o' : jp z, pageScrollUp
    cp 'p' : jp z, pageScrollDn
    cp 'n' : jp z, openURI
    
    jp showLp

historyBack:
    ld hl, server : ld de, path : ld bc, port : call openPage
    jp showPage

pageCursorUp:
    ld a, (cursor_pos) 
    dec a 
    cp 0 : jp z, pageScrollUp

    push af : call hideCursor : pop af : ld (cursor_pos), a  : call showCursor
    jp showLp

pageCursorDown:
    ld a, (cursor_pos)
    inc a
    cp 21 : jp z, pageScrollDn

    push af : call hideCursor : pop af : ld (cursor_pos), a : call showCursor
    jp showLp

pageScrollDn:
    ld hl, (show_offset) : ld de, 20 : add hl, de : ld (show_offset), hl
    ld a, 1 : ld (cursor_pos), a
    
    jp backToPage

pageScrollUp:
    ld a, (show_offset) : and a : jp z, showLp
    ld hl, (show_offset) : ld de, 20 : sub hl, de : ld (show_offset), hl
    ld a, 20 : ld (cursor_pos), a

    jp backToPage

selectItem:
    ld a, (cursor_pos) : dec a : ld b, a : ld a, (show_offset) : add b : ld b, a 
    call findLine

    ld a, h : or l : jp z, showLp
    
    ld a, (hl)

    cp '1' : jr z, downPg
    cp '0' : jr z, downPg
    cp '9' : jp z, downFl
    cp '7' : jr z, userInput

    jp showLp  

userInput:
    call cleanIBuff : call input

    call extractInfo 
    ld hl, file_buffer : call findEnd : ld a, 9 : ld (hl), a : inc hl 
    ex hl, de : ld hl, iBuff : ld bc, 64 : ldir

    ld hl, hist : ld de, path : ld bc, 322 : ldir

    ld hl, server_buffer : ld de, file_buffer : ld bc, port_buffer : call openPage
    
    jp showPage

downPg:
    push af
    call extractInfo

    ld hl, hist : ld de, path : ld bc, 322 : ldir

    ld hl, server_buffer : ld de, file_buffer : ld bc, port_buffer : call openPage
   
    pop af

    cp '1' : jp z,showPage
    cp '0' : jp z, showText

    jp showLp

downFl:
    call extractInfo : call clearRing : call cleanIBuff

    ld hl, file_buffer : call findFnme : jp isOpenable
dfl:
    ld hl, file_buffer : call findFnme
    ld de, iBuff : ld bc, 65 : ldir

    call input

    ld hl, iBuff : call showTypePrint

    ld hl, server_buffer : ld de, file_buffer : ld bc, port_buffer : call makeRequest
    
    xor a : call changeBank

    ld hl, iBuff : call downloadData

    call hideCursor : call showCursor

    jp backToPage

isOpenable:
	ld a, (hl) : and a : jr z, checkFile
    push hl : call pushRing : pop hl
	inc hl
	jr isOpenable

imgExt	db ".scr", 0
imgExt2 db ".SCR", 0
pt3Ext  db ".pt3", 0
pt3Ext2 db ".PT3", 0
pt2Ext  db ".pt2", 0
pt2Ext2 db ".PT2", 0

checkFile:
;; Images
	ld hl, imgExt  : call searchRing : cp 1 : jr z, loadImage
	ld hl, imgExt2 : call searchRing : cp 1 : jr z, loadImage
;; Music
    xor a: ld (#400A), a

    ld hl, pt3Ext  : call searchRing : cp 1 : jr z, playMusic
    ld hl, pt3Ext2 : call searchRing : cp 1 : jr z, playMusic

    ld a, 2 : ld (#400A), a

    ld hl, pt2Ext2 : call searchRing : cp 1 : jr z, playMusic
    ld hl, pt2Ext  : call searchRing : cp 1 : jr z, playMusic

	jp dfl
loadImage:
	ld hl, server_buffer : ld de, file_buffer : ld bc, port_buffer : call makeRequest
	
    ld a, 7 : call changeBank
    ld hl, #c000 : call loadData


    xor a : out (#ff), a : out (#fe), a
    ld b, 255
wKey:	
    halt 
    ld a, (s_show_flag) : and a : jr z, wK2
    dec b  : jp z, startNext
wK2:    
    call inkey  
    or a   : jr z, wKey
    cp 's' : jr z, toggleSS
    xor a : call changeBank
	jp backToPage

toggleSS:
    ld a, (s_show_flag) : xor #ff : ld (s_show_flag), a 
    and a : jp nz, startNext
    jp backToPage

playMusic:
    ld hl, hist : ld de, path : ld bc, 322 : ldir

    ld hl, (show_offset) : ld (offset_tmp), hl

    xor a : call changeBank 
    ld hl, server_buffer : ld de, file_buffer : ld bc, port_buffer : call openPage

    ld hl, playing : call showTypePrint

    xor a : call changeBank

    call setNoTurboMode

    ld a, (#400A) : or 1 : ld  (#400A), a
    ld hl, page_buffer : call #4003
playLp:
    halt : di : call #4005 : ei
    xor a : in a, (#fe) : cpl : and 31 : jp nz, stopPlay
    ld a, (#400A) : rla : jr nc, playLp 
songEnded:
    call #4008 : call setTurbo4Mode
    ld hl, server : ld de, path : ld bc, port : call openPage
    
    ld hl, (offset_tmp) : ld (show_offset), hl
startNext:
    ld a, (cursor_pos) : inc a : cp 21 : jr z, playNxtPg : ld (cursor_pos), a

    jr playContinue
playNxtPg:
    ld a, (show_offset) : add 20 : ld (show_offset), a : ld a, 1 : ld (cursor_pos), a
playContinue:
    call renderScreen : call showCursor
    xor a : call changeBank
    jp selectItem

stopPlay:
    call #4008 : call setTurbo4Mode
    
    ld hl, server : ld de, path : ld bc, port : call openPage
    ld hl, (offset_tmp) : ld (show_offset), hl

    jp backToPage

findFnme:
    push hl : pop de
ffnmlp:
    ld a, (hl)
    
    cp 0 : jr z, ffnmend
    cp '/' : jr z, fslsh
    inc hl
    jp ffnmlp
fslsh:
    inc hl : push hl : pop de
    jp ffnmlp
ffnmend:
    push de : pop hl
    ret

showType:
    ld a, (cursor_pos) : dec a : ld b, a : ld a, (show_offset) : add b : ld b, a

    call findLine
    
    ld a, h : or l : jr z, showTypeUnknown

    ld a, (hl)
    
    cp 'i' : jr z, showTypeInfo
    cp '9' : jr z, showTypeDown
    cp '1' : jr z, showTypePage
    cp '0' : jr z, showTypeText
    cp '7' : jr z, showTypeInput

    jr showTypeUnknown

showTypeInput:
    ld hl, type_inpt : call showTypePrint : call showURI
    ret

showTypeText:
    ld hl, type_text : call showTypePrint : call showURI
    ret

showTypeInfo:
    ld hl, type_info : jp showTypePrint

showTypePage:
    ld hl, type_page : call showTypePrint : call showURI
    ret

showTypeDown:
    ld hl, type_down : call showTypePrint : call showURI
    ret

showURI:
    call extractInfo : ld hl, server_buffer : call printZ64
    ld hl, file_buffer : call printZ64 
    ret

showTypeUnknown:
    ld hl, type_unkn : jp showTypePrint

showTypePrint:
    push hl
    
    ld b, 21 : ld c, 0 : call gotoXY : ld hl, cleanLine : call printZ64
    ld b, 21 : ld c, 0 : call gotoXY : pop hl : jp printZ64

renderHeader:
    call clearScreen : ld bc, 0 : call gotoXY
    ld hl, head : call printZ64
    ld d, 0 : call inverseLine
    ret

renderScreen:
    call renderHeader 
    ld b, 20
renderLp:
    push bc
    ld a, 20 : sub b : ld b, a : ld a, (show_offset) : add b : ld b, a 
    call renderLine
    pop bc
    djnz renderLp
    ret

; b - line number
renderLine:
    call findLine
    ld a, h: or l: ret z 
    ld a, (hl) : and a : ret z
    inc hl
    call printT64 : call mvCR
    ret

; B - line number
; HL - pointer to line(or zero if doesn't find it)
findLine:
    ld hl, page_buffer
fndLnLp:
    ld a, b : and a : ret z 

    ld a, (hl)

    ; Buffer ends? 
    and a : jr z, fndEnd
    
    ; New line?
    cp 10 : jr z, fndLnNL 
    
    inc hl
    jp fndLnLp

fndLnNL:
    dec b : inc hl : jp fndLnLp
fndEnd:
    ld hl, 0 : ret

extractInfo:
    ld a, (cursor_pos) : dec a : ld b, a : ld a, (show_offset) : add b : ld b, a

    call findLine

    ld a, h : or l : ret z

    call findNextBlock 

    inc hl : ld de, file_buffer   : call extractCol
    inc hl : ld de, server_buffer : call extractCol
    inc hl : ld de, port_buffer   : call extractCol
    ret

extractCol:
    ld a, (hl)

    cp 0 : jr z, endExtract
    cp 09 : jr z, endExtract
    cp 13 : jr z, endExtract
    
    ld (de), a : inc de : inc hl
    jr extractCol

endExtract:
    xor a : ld (de), a
    ret

findNextBlock:
    ld a, (hl)

; TAB
    cp 09 : ret z
; New line
    cp 13 : ret z
; End of buffer
    cp 0 : ret z

    inc hl
    jp findNextBlock

s_show_flag     db  0
offset_tmp      dw  0
show_offset     db  0
cursor_pos      db  1

head      db "  UGophy - ZX-UNO Gopher client v. 0.9 (c) Alexander Sharikhin", 13,0

cleanLine db "                                                                ",0
playing   db "Playing... Hold <SPACE> to stop!", 0
type_inpt db "User input: ", 0
type_text db "Text file: ", 0
type_info db "Information ", 0
type_page db "Page: ", 0
type_down db "File to download: ", 0
type_unkn db "Unknown type ", 0 

    display $

file_buffer defs 255     ; URI path
server_buffer defs 70   ; Host name
port_buffer defs 7      ; Port

end_inf_buff equ $


        
