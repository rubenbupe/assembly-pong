; Programa para imprimir en pantalla.

AppFilename             equ "S4_char_position"          ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst                    ; Start of application

AppEntry                ld a, 2                         ; Abrir el canal 2
                        call CHANOPEN                   ;

; Inicializa el juego al principio de cada partida, poniendo la barra superior
; e inferior, los contadores y los mensajes en pantalla
Inicializar             LD de,partedeabajo              ;
                        ld bc, 35                       ;
                        CALL PRINT                      ;
                        LD A, (partedearriba+3)         ;
                        LD (partedearriba+3), A         ;
                        LD de,partedearriba             ;
                        ld bc, 35                       ;
                        CALL PRINT                      ;
                        LD A, (partedearriba+34)        ;
                        LD (partedearriba+34), A        ;
                        LD de,partedearriba             ;
                        ld bc, 35                       ;
                        CALL PRINT                      ;
                        ld de,pressdifficulty           ;
                        ld bc, 35                       ;
                        CALL PRINT                      ;
                        call LeerTeclado                ;

; Actualiza la posicion de la pelota para que se mueva
MovPelots               ld a,(pelotica+1)               ;
                        ld (Blanco+1),a                 ;
                        ld a,(pelotica+2)               ;
                        ld (Blanco+2),a                 ;
                        call MovPelotsX                 ;
                        call MovPelotsY                 ;
                        ld de,pelotica                  ;
                        ld bc,4                         ;
                        call PRINT                      ;
                        ld de,Blanco                    ;
                        ld bc, 4                        ;
                        CALL PRINT                      ;
                        ret                             ;

; Actualiza la posicion de la pelota en el eje vertical
MovPelotsY              ld a,(direcy)                   ;
                        cp 1                            ;
                        jp z, Arriba                    ;
                        jp Abajo                        ;
                        ret                             ;

; Actualiza la posicion de la pelota en el eje horizontal
MovPelotsX              ld a,(direcx)                   ;
                        cp 1                            ;
                        jp z, Izquierda                 ;
                        jp Derecha                      ;
                        ret                             ;

; Cuando la pelota choca con el muro izquierdo, comprueba si lo hace en la pala o no,
; entonces actualiza el movimiento de la pelota de acuerdo con lo que ocurriera
MuroIzquierda           ld a, (pelotica+1)              ;
                        ld bc, (PalaIzq+1)              ;
                        cp c                            ;
                        jp z, RebotePala                ;
                        ld bc, (MangoIzq+1)             ;
                        cp c                            ;
                        jp z, ReboteMango               ;
                        jp AumentarDer                  ;
                        ret                             ;

; Equivalente a MuroIzquierda pero para el muro de la derecha
MuroDerecha             ld a, (pelotica+1)              ;
                        ld bc, (PalaDer+1)              ;
                        cp c                            ;
                        jp z, RebotePala                ;
                        ld bc, (MangoDer+1)             ;
                        cp c                            ;
                        jp z, ReboteMango               ;
                        jp AumentarIzq                  ;
                        ret                             ;

; Actualiza la direccion de la pelota hacia arriba si rebota en la cabeza de la pala
RebotePala              ld a, 1                         ;
                        ld (direcy), a                  ;
                        ld a, (direcx)                  ;
                        cp 1                            ;
                        jp z, Derecha                   ;
                        jp Izquierda                    ;
                        ret                             ;

; Actualiza la direccion de la pelota hacia abajo si rebota en el mango de la pala
ReboteMango             ld a, 0                         ;
                        ld (direcy), a                  ;
                        ld a, (direcx)                  ;
                        cp 1                            ;
                        jp z, Derecha                   ;
                        jp Izquierda                    ;
                        ret                             ;

; Mueve la pelota una casilla a la izquierda
Izquierda               ld a,1                          ;
                        ld (direcx),a                   ;
                        ld a, (pelotica+2)              ;
                        add -1                          ;
                        cp 0                            ;
                        jp z, MuroIzquierda             ;
                        ld (pelotica+2),a               ;
                        ret                             ;

; Mueve la pelota una casilla a la derecha
Derecha                 ld a,0                          ;
                        ld (direcx),a                   ;
                        ld a, (pelotica+2)              ;
                        add 1                           ;
                        cp 31                           ;
                        jp z, MuroDerecha               ;
                        ld (pelotica+2),a               ;
                        ret                             ;

; Mueve la pelota una casilla hacia arriba
Arriba                  ld a,1                          ;
                        ld (direcy),a                   ;
                        ld a, (pelotica+1)              ;
                        add -1                          ;
                        cp 0                            ;
                        jp z, Abajo                     ;
                        ld (pelotica+1),a               ;
                        ret                             ;

; Mueve la pelota una casilla hacia abajo
Abajo                   ld a,0                          ;
                        ld (direcy),a                   ;
                        ld a, (pelotica+1)              ;
                        add 1                           ;
                        cp 21                           ;
                        jp z, Arriba                    ;
                        ld (pelotica+1),a               ;
                        ret                             ;

; AÒade un punto al contador izquierdo
AumentarIzq             LD A, (partedearriba+3)         ;
                        add 1                           ;
                        LD (partedearriba+3), A         ;
                        LD de,partedearriba             ;
                        ld bc, 35                       ;
                        CALL PRINT                      ;
                        ld a, 1                         ;
                        ld (direcx), a                  ;
                        jp NuevoPunto                   ;
                        ret                             ;

; AÒade un punto al contador derecho
AumentarDer             LD A, (partedearriba+34)        ;
                        add 1                           ;
                        LD (partedearriba+34), A        ;
                        LD de,partedearriba             ;
                        ld bc, 35                       ;
                        CALL PRINT                      ;
                        ld a, 0                         ;
                        ld (direcx), a                  ;
                        jp NuevoPunto                   ;
                        ret                             ;

; Pinta las palas en pantalla cada vez que se actualizan, borr·ndola de la posicion anterior
PintarPalas             LD DE, PalaIzq                  ;
                        LD bc, 4                        ;
                        CALL PRINT                      ;
                        LD DE, PalaDer                  ;
                        LD bc, 4                        ;
                        CALL PRINT                      ;
                        LD DE, MangoIzq                 ;
                        LD bc, 4                        ;
                        CALL PRINT                      ;
                        LD DE, MangoDer                 ;
                        LD bc, 4                        ;
                        CALL PRINT                      ;
                        ret                             ;

; Mueve la pala de la izquierda hacia arriba
MoverPalaIzqArriba      ld a, (PalaIzq+1)               ;
                        cp 1                            ;
                        jp z, LeerTeclado               ;
                        add -1                          ;
                        ld (PalaIzq+1), a               ;
                        ld a, (MangoIzq+1)              ;
                        add -1                          ;
                        ld (MangoIzq+1), a              ;
                        call PintarPalas                ;
                        ld a, (MangoIzq+1)              ;
                        add 1                           ;
                        ld (Blanco+1), a                ;
                        ld a, (MangoIzq+2)              ;
                        ld (Blanco+2), a                ;
                        ld de, Blanco                   ;
                        LD bc, 4                        ;
                        CALL PRINT                      ;
                        ret                             ;

; Mueve la pala de la derecha hacia arriba
MoverPalaDerArriba      ld a, (PalaDer+1)               ;
                        cp 1                            ;
                        jp z, LeerTeclado               ;
                        add -1                          ;
                        ld (PalaDer+1), a               ;
                        ld a, (MangoDer+1)              ;
                        add -1                          ;
                        ld (MangoDer+1), a              ;
                        call PintarPalas                ;
                        ld a, (MangoDer+1)              ;
                        add 1                           ;
                        ld (Blanco+1), a                ;
                        ld a, (MangoDer+2)              ;
                        ld (Blanco+2), a                ;
                        ld de, Blanco                   ;
                        LD bc, 4                        ;
                        CALL PRINT                      ;
                        ret                             ;

; Mueve la pala de la izquierda hacia abajo
MoverPalaIzqAbajo       ld a, (MangoIzq+1)              ;
                        cp 20                           ;
                        jp z, LeerTeclado               ;
                        add 1                           ;
                        ld (MangoIzq+1), a              ;
                        ld a, (PalaIzq+1)               ;
                        add 1                           ;
                        ld (PalaIzq+1), a               ;
                        call PintarPalas                ;
                        ld a, (PalaIzq+1)               ;
                        add -1                          ;
                        ld (Blanco+1), a                ;
                        ld a, (MangoIzq+2)              ;
                        ld (Blanco+2), a                ;
                        ld de, Blanco                   ;
                        LD bc, 4                        ;
                        CALL PRINT                      ;
                        ret                             ;

; Mueve la pala de la derecha hacia abajo
MoverPalaDerAbajo       ld a, (MangoDer+1)              ;
                        cp 20                           ;
                        jp z, LeerTeclado               ;
                        add 1                           ;
                        ld (MangoDer+1), a              ;
                        ld a, (PalaDer+1)               ;
                        add 1                           ;
                        ld (PalaDer+1), a               ;
                        call PintarPalas                ;
                        ld a, (PalaDer+1)               ;
                        add -1                          ;
                        ld (Blanco+1), a                ;
                        ld a, (MangoDer+2)              ;
                        ld (Blanco+2), a                ;
                        ld de, Blanco                   ;
                        LD bc, 4                        ;
                        CALL PRINT                      ;
                        ret                             ;

; Bucle que lee el teclado y llama a MovPelots y MoverPala
LeerTeclado             ld bc,0F7FEh                    ;
                        in a,(c)                        ;
                        rra                             ; b1 'Z'
                        push af                         ;
                        call nc, SetDifficulty1         ;
                        pop af                          ;
                        rra                             ; b2 'X'
                        push af                         ;
                        call nc, SetDifficulty2         ;
                        pop af                          ;
                        rra                             ;
                        call nc, SetDifficulty3         ;
                        ld bc,7FFEH                     ;
                        in a,(c)                        ;
                        rra                             ;
                        jp nc, EmpezarJuego             ;
                        ld a, (JuegoEmpezado)           ;
                        cp 2                            ;
                        jp nz, LeerTeclado              ;
                        call MovPelots                  ;
                        ld bc,0FEFEh                    ;
                        in a,(c)                        ;
                        call Delay                      ;
                        rra                             ; Salta el Shift
                        rra                             ; Z
                        push af                         ;
                        call nc,MoverPalaIzqArriba      ;
                        pop af                          ;
                        rra                             ; X
                        push af                         ;
                        call nc,MoverPalaIzqAbajo       ;
                        pop af                          ;
                        rra                             ; C
                        push af                         ;
                        call nc,MoverPalaDerArriba      ;
                        pop af                          ;
                        rra                             ; V
                        push af                         ;
                        call nc,MoverPalaDerAbajo       ;
                        pop af                          ;
                        ld a,32                         ;
                        jp LeerTeclado                  ;
                        ret                             ;

;Pone la velocidad en lento(modificando el delay entre movimientos)
SetDifficulty1          ld a, (JuegoEmpezado)           ;
                        cp 0                            ;
                        ret nz                          ;
                        ld a, 1                         ;
                        ld (JuegoEmpezado), a           ;
                        ld a, 6                         ;
                        ld (difficulty), a              ;
                        ld de, press2start              ;
                        ld bc, 35                       ;
                        call PRINT                      ;
                        ret                             ;

;Pone la velocidad en normal(modificando el delay entre movimientos)
SetDifficulty2          ld a, (JuegoEmpezado)           ;
                        cp 0                            ;
                        ret nz                          ;
                        ld a, 1                         ;
                        ld (JuegoEmpezado), a           ;
                        ld a, 5                         ;
                        ld (difficulty), a              ;
                        ld de, press2start              ;
                        ld bc, 35                       ;
                        call PRINT                      ;
                        ret                             ;

;Pone la velocidad en r·pido(modificando el delay entre movimientos)
SetDifficulty3          ld a, (JuegoEmpezado)           ;
                        cp 0                            ;
                        ret nz                          ;
                        ld a, 1                         ;
                        ld (JuegoEmpezado), a           ;
                        ld a, 3                         ;
                        ld (difficulty), a              ;
                        ld de, press2start              ;
                        ld bc, 35                       ;
                        call PRINT                      ;
                        ret                             ;

;Empieza el juego(el bucle de LeerTeclado) una vez se haya seleccionado
;la dificultad y pulsado espacio
EmpezarJuego            ld a, (JuegoEmpezado)           ;
                        cp 1                            ;
                        jp nz, LeerTeclado              ;
                        ld a, 2                         ;
                        ld (JuegoEmpezado), a           ;
                        ld de,press2blank               ;
                        ld bc, 35                       ;
                        CALL PRINT                      ;
                        ld de, gameoverblank            ;
                        ld bc, 35                       ;
                        call PRINT                      ;
                        call PintarPalas                ;
                        ld a, "0"                       ;
                        ld (partedearriba+3), a         ;
                        ld (partedearriba+34), a        ;
                        ld de, partedearriba            ;
                        ld bc, 35                       ;
                        call PRINT                      ;
                        jp LeerTeclado                  ;

;Resetea la posiciÛn de la pelota para empezar un nuevo punto
NuevoPunto              ld a, (partedearriba+3)         ;
                        cp "5"                          ;
                        jp z, GameOver                  ;
                        ld a, (partedearriba+34)        ;
                        cp "5"                          ;
                        jp z, GameOver                  ;
                        ld a, 15                        ;
                        ld (pelotica+2), a              ;
                        ret                             ;

;Resetea todo una vez se acabe la partida para que pueda volver a empezar
GameOver                ld de, gameover                 ;
                        ld bc, 35                       ;
                        call PRINT                      ;
                        ld a, 0                         ;
                        ld (JuegoEmpezado), a           ;
                        ld a, (pelotica+1)              ;
                        ld (Blanco+1), a                ;
                        ld a, (pelotica+2)              ;
                        ld (Blanco+2), a                ;
                        ld de, Blanco                   ;
                        ld bc, 4                        ;
                        call PRINT                      ;
                        ld a, (PalaIzq+1)               ;
                        ld (Blanco+1), a                ;
                        ld a, (PalaIzq+2)               ;
                        ld (Blanco+2), a                ;
                        ld de, Blanco                   ;
                        ld bc, 4                        ;
                        call PRINT                      ;
                        ld a, (PalaDer+1)               ;
                        ld (Blanco+1), a                ;
                        ld a, (PalaDer+2)               ;
                        ld (Blanco+2), a                ;
                        ld de, Blanco                   ;
                        ld bc, 4                        ;
                        call PRINT                      ;
                        ld a, (MangoIzq+1)              ;
                        ld (Blanco+1), a                ;
                        ld a, (MangoIzq+2)              ;
                        ld (Blanco+2), a                ;
                        ld de, Blanco                   ;
                        ld bc, 4                        ;
                        call PRINT                      ;
                        ld a, (MangoDer+1)              ;
                        ld (Blanco+1), a                ;
                        ld a, (MangoDer+2)              ;
                        ld (Blanco+2), a                ;
                        ld de, Blanco                   ;
                        ld bc, 4                        ;
                        call PRINT                      ;
                        ld a, 10                        ;
                        ld (pelotica+1), a              ;
                        ld a, 15                        ;
                        ld (pelotica+2), a              ;
                        ld a, 10                        ;
                        ld (PalaIzq+1), a               ;
                        ld (PalaDer+1), a               ;
                        ld a, 11                        ;
                        ld (MangoIzq+1), a              ;
                        ld (MangoDer+1), a              ;
                        jp Inicializar                  ;

;Establece el Delay entre movimientos de palas y pelota
Delay                   PUSH BC                         ;
                        ld h, a                         ;
                        ld a, (difficulty)              ;
                        ld b, a                         ;
                        ld a, h                         ;
Espera                  HALT                            ;
                        DJNZ Espera                     ;
                        pop bc                          ;
                        RET                             ;

Para                    halt                            ;
                        jp Para                         ;


CHANOPEN                equ 5633                        ;
PRINT                   equ 8252                        ;
partedearriba           defb 22,0,0, "0______________________________0";
partedeabajo            defb 22,21,0,"_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ ";
press2start             defb 22,10,0,"______Press space to start______";
pressdifficulty         defb 22,10,0,"   Set Difficulty: 1, 2 or 3    ";
press2blank             defb 22,10,0,"                                ";
gameover                defb 22, 9,0,"           GAME  OVER           ";
gameoverblank           defb 22, 9,0,"                                ";
PalaIzq                 defb 22,10,0,"O"                ;
MangoIzq                defb 22,11,0,"|"                ;
PalaDer                 defb 22,10,31,"O"               ;
MangoDer                defb 22,11,31,"|"               ;
Blanco                  defb 22,0,0," "                 ;
JuegoEmpezado           defb 0                          ;
pelotica                defb 22,11,15,"o"               ;
direcx                  defb 1                          ;
direcy                  defb 1                          ;
difficulty              defb 5                          ;


; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 equ *-1                         ; The last used byte's

; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1 ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 equ AppEntry                    ; Tell the emulator where to start
Zeus_SP                 equ $FF40                       ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
;                        import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader



