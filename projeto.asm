; ******************************************************************************
; * IST-UL
; * Modulo:    projeto.asm
; * Descrição:
; *
; * Grupo:     36
; * Alunos:    106537 - Francisco Fernandes
; *            106326 - Guilherme Filipe
; *            106507 - Martim Afonso
; ******************************************************************************

; ******************************************************************************
; * Constantes
; ******************************************************************************
; ATENÇÃO: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto não altera o valor de 16 bits e permite distinguir números de identificadores
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA_MAX  EQU 00010H  ; "teto" para a linha maxima a testar (4ª linha, 1000b)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
ENERGIA_BASE EQU 100   ; energia inicial
; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaçco reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.ÿ end. de retorno será
						; armazenado em 11FEH (1200H-2)
imagem_hexa:
	BYTE	00H			; imagem em memória dos displays hexadecimais 
						; (inicializada a zero, mas podia ser outro valor qualquer).

VAR_LINHA:  WORD 0      ; variável para guardar a linha atual
VAR_COLUNA: WORD 0      ; variável para guardar a coluna atual
VAR_LOGCOUNT: WORD -1   ; variável para guardar o logaritmo do contador
VAR_ENERGIA: WORD 100   ; variável para guardar a energia

; ******************************************************************************
; * Código
; ******************************************************************************
    PLACE       0
inicio:		
; inicializações
    MOV  SP, SP_inicial ; inicializa SP
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R7, LINHA_MAX ; "teto" para linha maxima a testar (4ª linha, 1000b) 
    
    MOV  [VAR_ENERGIA], ENERGIA_BASE ; inicializa a energia
    MOV  [R4], VAR_ENERGIA ; inicializa o valor do display da energia

fim :                  ; fim do programa (ciclo infinito)
    JMP   fim
; corpo principal do programa

; ciclo de detecção de teclas
tec_ciclo:
    MOV  R1, 1         ; para guardar o valor da linha a ser testada
    MOV  R6, 0         ; registo temporário da linha testada (linha anterior),

espera_tecla:          ; neste ciclo espera-se até uma tecla ser premida
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R1, R7        ; se já testou as 4 linhas 
    JZ   tec_ciclo     ; volta à primeira
    ROL  R1, 1         ; incrementa, apos testada, a linha atual
    CMP  R0, 0         ; há tecla premida?
    JZ   espera_tecla  ; se nenhuma tecla premida, repete
                       ; vai mostrar a linha e a coluna da tecla
    ROR  R1, 1         ; regressa à linha testada
    MOV  R6, R1        ; coloca coluna em R6, temporariamente
;    SHL  R1, 4         ; coloca linha no nibble high
;    OR   R1, R0        ; junta coluna (nibble low)
;    MOVB [R4], R1      ; escreve linha e coluna nos displays
    
ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    MOV  R1, R6        ; testar a linha atual  (R1 tinha sido alterado)
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JNZ  testa_tecla   ; se ainda houver uma tecla premida, espera até não haver
    JMP  tec_ciclo     ; repete ciclo

testa_tecla:
    SHL  R1, 1         ; multiplica por 2 (desloca 1 bit para a esquerda)
    SHL R1, 2          ; multiplica por 4 (desloca 2 bits para a esquerda)
    ADD R1, R0         ; soma coluna 
    CMP R1, 0          ; se R1=0, não há tecla premida
    JZ   tec_ciclo     ; volta a testar teclas
                       ; "else if"
    CMP R1, 4          ; se R1=4, tecla 1 premida
    JZ dec_display

    CMP R1, 5          ; se R1=5, tecla 2 premida
    JZ inc_display 

    CMP R1, 6          ; se R1=6, tecla 3 premida
    JZ sobe_sonda

    CMP R1, 7          ; se R1=7, tecla 4 premida
    JZ move_asteroide 

    JMP ha_tecla       ; volta a testar teclas


; ações do teclado

move_asteroide:         ; TEMP!
    JMP tec_ciclo       ; ação efetuada, testar teclado novamente

sobe_sonda:             ; TEMP!
    JMP tec_ciclo       ; ação efetuada, testar teclado novamente

inc_display:            ; TEMP!
    MOV R1, [R4]        ; coloca o valor do display em R1
    ADD R1, 1           ; incrementa o valor do display
    MOV [R4], R1        ; atualiza o valor do display
    JMP tec_ciclo       ; ação efetuada, testar teclado novamente

dec_display:            ; TEMP!
    MOV R1, [R4]        ; coloca o valor do display em R1
    SUB R1, 1           ; decrementa o valor do display
    MOV [R4], R1        ; atualiza o valor do display
    JMP tec_ciclo       ; ação efetuada, testar teclado novamente

; ******************************************************************************
; * Interrupções
; ******************************************************************************