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
ENERGIA_BASE EQU 00064H   ; energia inicial

TEC_0      EQU 00011H  ; tecla 0
TEC_1      EQU 00012H  ; tecla 1
TEC_C      EQU 00081H  ; tecla C
TEC_F      EQU 00088H  ; tecla F

; ******************************************************************************
; * Media Center
; ******************************************************************************
COMANDOS			EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA   		EQU COMANDOS + 0AH	; endereço do comando para definir a linha
DEFINE_COLUNA  		EQU COMANDOS + 0CH	; endereço do comando para definir a coluna
DEFINE_PIXEL   		EQU COMANDOS + 12H	; endereço do comando para escrever um pixel
APAGA_AVISO     	EQU COMANDOS + 40H  ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU COMANDOS + 02H	; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO   EQU COMANDOS + 42H  ; endereço do comando para selecionar uma imagem de fundo
SELECIONA_VID       EQU COMANDOS + 48H  ; endereço do comando para selecionar um vídeo/som
PLAY_VID            EQU COMANDOS + 5AH  ; endereço do comando para começar a reproduzir o vídeo/som selecionado

; ******************************************************************************
; * Gráficos
; ******************************************************************************

MEMORIA_ECRA	EQU	8000H		; endereço de base da memória do ecrã

N_LINHAS        EQU  32        ; número de linhas do ecrã (altura)
N_COLUNAS       EQU  64        ; número de colunas do ecrã (largura)

COR_PIXEL       EQU 0FF00H     ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

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

VAR_COR_PIXEL: WORD COR_PIXEL ; variável para guardar a cor do pixel, default é vermelho

VAR_COR_SONDA: WORD 0FFC0H    ; variável para guardar a cor da sonda, default é amarelo
VAR_MSONDA_POS: WORD 25 ; variável para guardar a posição da sonda do meio (default é 25+1 (artefacto de desenha_sonda))

VAR_AST_POS_0: WORD 0   ; variável para guardar a posição do asteroide 0
VAR_AST_POS_1: WORD 0   ; variável para guardar a posição do asteroide 1
VAR_AST_POS_2: WORD 0   ; variável para guardar a posição do asteroide 2
VAR_AST_POS_3: WORD 0   ; variável para guardar a posição do asteroide 3
VAR_AST_POS_4: WORD 3   ; variável para guardar a posição do asteroide 4

VAR_POS_H_ALVO: WORD 0    ; variável para guardar a posição horizontal do objeto a desenhar
VAR_POS_V_ALVO: WORD 0    ; variável para guardar a posição vertical do objeto a desenhar
; ******************************************************************************
; * Código
; ******************************************************************************
    PLACE       0
inicio:		
; inicializações
    MOV  SP, SP_inicial; inicializa Stack Pointer

    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

    MOV  R7, LINHA_MAX ; "teto" para linha maxima a testar (4ª linha, 1000b) 

    MOV  R1, ENERGIA_BASE  ; inicializa a energia
    MOV  [VAR_ENERGIA], R1 ; inicializa a energia
    MOV  [R4], R1          ; inicializa o valor do display da energia
    MOV R1, 0              ; inicializa a linha atual
    MOV [SELECIONA_CENARIO], R1 ; seleciona o cenário 1



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
    ;MOV [R4], R1       ; escreve linha e coluna nos displays
    PUSH R1            ; guarda a linha e coluna na pilha

testa_tecla:

    POP R1             ; retira da pilha a linha e coluna da tecla premida

    MOV R8, TEC_0      ; coloca o ID da tecla 0 em R8
    CMP R1, R8         
    JZ  dec_display

    MOV R8, TEC_1      ; coloca o ID da tecla 1 em R8
    CMP R1, R8         
    JZ  inc_display 

    MOV R8, TEC_C      ; coloca o ID da tecla C em R8
    CMP R1, R8         
    JZ  sobe_sonda

    MOV R8, TEC_F      ; coloca o ID da tecla F em R8
    CMP R1, R8         
    JZ  move_asteroide_4

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
move_asteroide_4:       ; TEMP!
    MOV R10, [VAR_AST_POS_4]  ; coloca a posição do asteroide sup. direito em R10 
    ADD R10, 1                ; incrementa a posição vertical do objeto (desce)
    MOV [VAR_AST_POS_4], R10  ; atualiza a posição da objeto
    

    SUB R10, 2
    MOV [VAR_POS_V_ALVO], R10 ; atualiza a posição vertical do objeto a desenhar
    PUSH R11                  ; guarda R11
    PUSH R10                  ; guarda a posição vertical do objeto a desenhar na pilha
    MOV R10, 63               ; coloca a largura em R10
    POP R11                   ; recupera a posição vertical do objeto a desenhar da pilha
    SUB R10, R11              ; atualiza a posição horizontal do objeto a desenhar
    MOV [VAR_POS_H_ALVO], R10 ; atualiza a posição horizontal do objeto a desenhar
    CALL apaga_asteroide      ; apaga o objeto na posição anterior

    ADD R11, 1
    MOV [VAR_POS_V_ALVO], R11 ; atualiza a posição vertical do objeto a desenhar
    SUB R10, 1                ; atualiza a posição horizontal do objeto a desenhar
    MOV [VAR_POS_H_ALVO], R10 ; atualiza a posição horizontal do objeto a desenhar
    CALL desenha_asteroide    ; desenha o objeto
    POP R11


    PUSH R0
    MOV R0, 0FF00H          ; coloca a cor do pixel em R0
    MOV [VAR_COR_PIXEL], R0 ; atualiza a cor do pixel
    CALL desenha_asteroide    ; desenha o objeto
    POP R0

    JMP ha_tecla              ; ação efetuada, testar teclado novamente

sobe_sonda:                   ; TEMP!
    MOV R10, 0                ; coloca o numero do som (0)
    MOV [SELECIONA_VID], R10  ; seleciona o som
    MOV [SELECIONA_VID], R10  ; toca o som
    MOV R10, [VAR_MSONDA_POS] ; coloca a posição da sonda do meio em R10 
    
    PUSH R10
    SUB R10, 2                ; decrementa a posição vertical da sonda do meio (sobe)
    MOV [VAR_MSONDA_POS], R10 ; atualiza a posição da sonda do meio
    CALL desenha_sonda        ; desenha a sonda do meio na posição atual
    
    POP R10
    CMP R10, 1               ; se a sonda já estiver no topo
    JZ reset_sonda

    JMP ha_tecla              ; ação efetuada, não testar teclado novamente

reset_sonda:
    
    MOV R10, 25               ; coloca a posição da sonda do meio em R10 
    MOV [VAR_MSONDA_POS], R10 ; atualiza a posição da sonda do meio
    CALL desenha_sonda        ; desenha a sonda do meio na posição atual
    JMP ha_tecla              ; ação efetuada, não testar teclado novamente

inc_display:                ; TEMP!
    MOV R10, [VAR_ENERGIA]  ; coloca o valor do display em R1
    ADD R10, 0001b          ; incrementa o valor do display
    MOV [R4], R10           ; atualiza o valor do display
    MOV [VAR_ENERGIA], R10  ; atualiza o valor da energia
    JMP ha_tecla            ; ação efetuada, não testar teclado novamente
  
dec_display:                ; TEMP!
    MOV R10, [VAR_ENERGIA]  ; coloca o valor do display em R1
    SUB R10, 0001b          ; decrementa o valor do display
    MOV [R4], R10           ; atualiza o valor do display
    MOV [VAR_ENERGIA], R10  ; atualiza o valor da energia
    JMP ha_tecla            ; ação efetuada, não testar teclado novamente

; graficos

desenha_sonda: 
    PUSH R0                 ; guarda o valor de R0
    PUSH R1                 ; guarda o valor de R1
    PUSH R2                 ; guarda o valor de R2
    PUSH R3

    MOV R1, [VAR_MSONDA_POS]; coloca a posição vertical da sonda do meio em R1
    MOV R2, 32              ; coloca a posição horizontal da sonda do meio em R2 (constante 32)
    MOV R3, [VAR_COR_SONDA] ; coloca a cor da sonda do meio em R3

    CALL escreve_pixel      ; escreve o pixel na posição da sonda do meio
;    ADD R1, 1               ; decrementa a posição a desenhar (cauda da sonda)
;    CALL escreve_pixel      ; escreve o pixel na posição da sonda do meio
;    SUB R1, 1               ; decrementa a posição a desenhar (cauda da sonda)
;    CALL escreve_pixel      ; escreve o pixel na posição da sonda do meio
    ADD R1, 2               ; coloca em R2 a posição da sonda a apagar 
    MOV R3, 00000H          ; coloca em R3 a cor transparente
    CALL escreve_pixel      ; apaga o pixel na posição anterior da sonda do meio
    POP R3
    POP R2
    POP R1                  ; recupera o valor de R1
    POP R0                  ; recupera o valor de R0
    RET

desenha_asteroide:
    PUSH R0                 ; guarda o valor de R0
    PUSH R1                 ; guarda o valor de R1
    PUSH R2                 ; guarda o valor de R2
    PUSH R3
    MOV R1, [VAR_POS_V_ALVO]; coloca a posição vertical do objeto em R1
    MOV R2, [VAR_POS_H_ALVO]
    MOV R3, [VAR_COR_PIXEL] ; coloca a cor do objeto em R3
    CALL escreve_pixel     
    SUB R1, 1               ; decrementa a posição a desenhar 
    SUB R2, 1               ; decrementa a posição a desenhar
    CALL escreve_pixel      
    ADD R2, 2               ; coloca em R2 a posição do objeto a apagar
    CALL escreve_pixel      ; apaga o pixel na posição anterior do objeto
    ADD R1, 2
    CALL escreve_pixel
    SUB R2, 2
    CALL escreve_pixel
;    ADD R1, 1               ; decrementa a posição a desenhar (cauda da sonda)
;    CALL escreve_pixel      ; escreve o pixel na posição da sonda do meio
;    SUB R1, 1               ; decrementa a posição a desenhar (cauda da sonda)
;    CALL escreve_pixel      ; escreve o pixel na posição da sonda do meioå
    POP R3
    POP R2
    POP R1                  ; recupera o valor de R1
    POP R0                  ; recupera o valor de R0
    RET    

apaga_asteroide:
    PUSH R0
    MOV R0, 00000H
    MOV [VAR_COR_PIXEL], R0
    CALL desenha_asteroide
    POP R0
    RET

escreve_pixel:              ; ROTINA ASSUME REGISTOS LIMPOS, NUNCA CHAMAR DE FORMA AUTONOMA
    MOV R0, MEMORIA_ECRA
    PUSH R1                 ; guarda o valor de R1
    PUSH R2                 ; guarda o valor de R2
    PUSH R3                 ; guarda o valor de R3
    ; É assumido presente em R1 a linha e em R2 a coluna, em R3 a cor
	SHL	R1, 6			    ; linha * 64
    ADD  R1, R2			    ; linha * 64 + coluna
    SHL  R1, 1		     	; * 2, para ter o endereço da palavra
	ADD	R0, R1		    	; MEMORIA_ECRA + 2 * (linha * 64 + coluna)
	MOV	[R0], R3		   	; escreve cor no pixel
    
    POP R3
    POP R2
    POP R1                  
    RET



fim :                  ; fim do programa (ciclo infinito)
    JMP   fim

; ******************************************************************************
; * Interrupções
; ******************************************************************************