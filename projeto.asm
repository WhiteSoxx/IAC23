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
ENERGIA_BASE EQU 000FFEH   ; energia inicial

TEC_0      EQU 00011H  ; tecla 0
TEC_1      EQU 00012H  ; tecla 1
TEC_C      EQU 00081H  ; tecla C
TEC_F      EQU 00088H  ; tecla F
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
VAR_TECCOUNT: WORD -1   ; variável para guardar o contador para conversão de teclas
VAR_ENERGIA: WORD 000FFEH   ; variável para guardar a energia (ver constante ENERGIA_BASE)

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
    MOV  R1, ENERGIA_BASE  ; inicializa a energia
    MOV  [VAR_ENERGIA], R1 ; inicializa a energia
    MOV  [R4], R1      ; inicializa o valor do display da energia

; corpo principal do programa

; ciclo de detecção de teclas
tec_ciclo:
    MOV  R1, 1         ; para guardar o valor da linha a ser testada
    MOV  R8, 0         ; registo de ID de teclas

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
    ROR  R1, 1         ; regressa à linha 
    PUSH R1            ; guarda a linha atual na pilha
    SHL  R1, 4         ; coloca linha no nibble high
    OR   R1, R0        ; junta coluna (nibble low)
    MOV [R4], R1       ; escreve linha e coluna nos displays
    PUSH R1            ; guarda a linha e coluna na pilha

testa_tecla:

    POP R1             ; retira da pilha a linha e coluna da tecla premida

    MOV R8, TEC_0      ; coloca o ID da tecla 0 em R8
    CMP R1, R8         ; se R1=4, tecla 1 premida
    JZ  dec_display

    MOV R8, TEC_1      ; coloca o ID da tecla 1 em R8
    CMP R1, R8         ; se R1=5, tecla 2 premida
    JZ  inc_display 

    MOV R8, TEC_C      ; coloca o ID da tecla C em R8
    CMP R1, R8         ; se R1=6, tecla 3 premida
    JZ  sobe_sonda

    MOV R8, TEC_F      ; coloca o ID da tecla F em R8
    CMP R1, R8         ; se R1=7, tecla 4 premida
    JZ  move_asteroide 

    JMP ha_tecla       ; testa se a tecla permanece premida

ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    POP R1             ; retira da pilha a linha atual
    PUSH R1

    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)

    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se houver uma tecla premida, espera até não haver
    POP R1             ; "limpa" da pilha a linha atual
    JMP  tec_ciclo     ; se não houver, repete-se o ciclo de teste do teclado

; ações do teclado
; CUIDADO C PUSH E POPS AQUI, DOIS BUÉ FRAGEIS NAS TRES TAGS ACIMA!!!
move_asteroide:         ; TEMP!
    JMP ha_tecla        ; ação efetuada, testar teclado novamente

sobe_sonda:             ; TEMP!
    JMP ha_tecla        ; ação efetuada, testar teclado novamente

inc_display:            ; TEMP!
    MOV R10, [VAR_ENERGIA] ; coloca o valor do display em R1
    ADD R10, 0001b           ; incrementa o valor do display
    MOV [R4], R10        ; atualiza o valor do display
    MOV [VAR_ENERGIA], R10 ; atualiza o valor da energia
    JMP ha_tecla        ; ação efetuada, testar teclado novamente

dec_display:            ; TEMP!
    MOV R10, [VAR_ENERGIA] ; coloca o valor do display em R1
    SUB R10, 0001b           ; decrementa o valor do display
    MOV [R4], R10        ; atualiza o valor do display
    MOV [VAR_ENERGIA], R10 ; atualiza o valor da energia
    JMP ha_tecla        ; ação efetuada, testar teclado novamente

fim :                  ; fim do programa (ciclo infinito)
    JMP   fim

; ******************************************************************************
; * Interrupções
; ******************************************************************************