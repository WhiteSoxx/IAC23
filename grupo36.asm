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
TEC_2      EQU 00014H  ; tecla 2
TEC_3      EQU 00018H  ; tecla 3
TEC_4      EQU 00021H  ; tecla 4
TEC_5      EQU 00022H  ; tecla 5
TEC_6      EQU 00024H  ; tecla 6
TEC_7      EQU 00028H  ; tecla 7
TEC_8      EQU 00041H  ; tecla 8
TEC_9      EQU 00042H  ; tecla 9
TEC_A      EQU 00044H  ; tecla A
TEC_B      EQU 00048H  ; tecla B
TEC_C      EQU 00081H  ; tecla C
TEC_D      EQU 00082H  ; tecla D
TEC_E      EQU 00084H  ; tecla E
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

LARGURA_AST		EQU	5			; largura do asteroide
CAST_ESC		EQU	0F442H		; cor do pixel: contorno do asteroide em ARGB 
CAST_CLR		EQU	0F985H		; cor do pixel: preenchimento do asteroide em ARGB
VERMELHO       	EQU	0FF00H		; cor do pixel: ponta da nave em ARGB 
CINZ_ESC		EQU	0F666H		; cor do pixel: contorno da nave em ARGB
CINZENTO		EQU	0F888H		; cor do pixel: preenchimento da nave em ARGB 
CINZ_CLR		EQU	0F999H		; cor do pixel: preenchimento da nave em ARGB
AZUL_CLR		EQU	0F79CH		; cor do pixel: preenchimento da nave em ARGB 
AZUL_ESC		EQU	0F58AH		; cor do pixel: preenchimento da nave em ARGB
ROXO	     	EQU	0F827H		; cor do pixel: preenchimento da nave em ARGB

NAVE_X     EQU  26
NAVE_Y     EQU  22
LARGURA_NAVE EQU 13
ALTURA_NAVE EQU 10

COLISAO_ASTEROIDE EQU 25       ; altura máxima que o asteroide deve atingir

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H

	STACK 100H			; espaçco reservado para a pilha (200H bytes, ou 100H words)
SP_inicial:				; Stack pointer do programa inicial

imagem_hexa:
	BYTE	00H			; imagem em memória dos displays hexadecimais 
						; (inicializada a zero, mas podia ser outro valor qualquer).

VAR_LINHA:  WORD 0            ; variável para guardar a linha atual
VAR_COLUNA: WORD 0            ; variável para guardar a coluna atual
VAR_TECCOUNT: WORD -1         ; variável para guardar o contador para conversão de teclas
VAR_ENERGIA: WORD 000FFEH     ; variável para guardar a energia (ver constante ENERGIA_BASE)

VAR_COR_PIXEL: WORD COR_PIXEL ; variável para guardar a cor do pixel, default é vermelho
VAR_PROX_SOM: WORD 0          ; variável para guardar o próximo som a tocar, default é 0

VAR_COR_SONDA: WORD 0FFC0H    ; variável para guardar a cor da sonda, default é amarelo
VAR_MSONDA_POS: WORD NAVE_Y-1 ; variável para guardar a posição da sonda do meio (default é NAVE_Y+1)

VAR_AST_POS_V_0: WORD 1   ; variável para guardar a posição vertical do asteroide 0
VAR_AST_POS_V_1: WORD 2   ; variável para guardar a posição vertical do asteroide 1
VAR_AST_POS_V_2: WORD 2   ; variável para guardar a posição vertical do asteroide 2
VAR_AST_POS_V_3: WORD 2   ; variável para guardar a posição vertical do asteroide 3
VAR_AST_POS_V_4: WORD 2   ; variável para guardar a posição vertical do asteroide 4

VAR_AST_POS_H_0: WORD 1   ; variável para guardar a posição horizontal do asteroide 0
VAR_AST_POS_H_1: WORD 2   ; variável para guardar a posição horizontal do asteroide 1
VAR_AST_POS_H_2: WORD 2   ; variável para guardar a posição horizontal do asteroide 2
VAR_AST_POS_H_3: WORD 2   ; variável para guardar a posição horizontal do asteroide 3
VAR_AST_POS_H_4: WORD 3   ; variável para guardar a posição horizontal do asteroide 4

VAR_POS_H_ALVO: WORD 0    ; variável para guardar a posição horizontal do objeto a desenhar
VAR_POS_V_ALVO: WORD 0    ; variável para guardar a posição vertical do objeto a desenhar

VAR_STATUS: WORD 0        ; variável para guardar o estado do jogo (0 - jogo não iniciado, 1 - jogo iniciado)

DEF_ASTEROIDE:					; tabela que define o asteroide (cor, largura, pixels)
	WORD		LARGURA_AST     ; [DEF_AST + 0] largura do asteroide 1228
    WORD        LARGURA_AST     ; [DEF_AST + 2] altura do asteroide, igual a largura 122A
    WORD		       0, CAST_ESC, CAST_ESC, CAST_ESC, 0		    ; [DEF_AST + 4 + 2*col + 2*col*lin] 
	WORD		CAST_ESC, CAST_CLR, CAST_CLR, CAST_CLR, CAST_ESC	;
    WORD		CAST_ESC, CAST_CLR, CAST_CLR, CAST_CLR, CAST_ESC	;
    WORD		CAST_ESC, CAST_CLR, CAST_CLR, CAST_CLR, CAST_ESC    ;
    WORD		       0, CAST_ESC, CAST_ESC, CAST_ESC, 0		    ;

DEF_CLEAR_AST:				; tabela que define o asteroide (cor, largura, pixels)
    WORD		LARGURA_AST
    WORD        LARGURA_AST
    WORD		0, 0, 0, 0, 0		;
    WORD		0, 0, 0, 0, 0		;
    WORD		0, 0, 0, 0, 0		;
    WORD		0, 0, 0, 0, 0		;
    WORD		0, 0, 0, 0, 0		;

DEF_NAVE: 
    WORD LARGURA_NAVE
    WORD ALTURA_NAVE
    WORD 0, 0, 0, 0, 0, 0, VERMELHO, 0, 0, 0, 0, 0, 0          
    WORD 0, 0, 0, 0, 0, CINZ_ESC, CINZ_ESC, CINZ_ESC, 0, 0, 0, 0, 0          
    WORD 0, 0, 0, 0, CINZ_ESC, CINZ_CLR, CINZENTO, CINZ_CLR, CINZ_ESC, 0, 0, 0, 0          
    WORD 0, 0, CINZ_ESC, 0, CINZ_ESC, AZUL_CLR, AZUL_CLR, AZUL_CLR, CINZ_ESC, 0, CINZ_ESC, 0, 0
    WORD 0, CINZ_ESC, CINZ_CLR, CINZ_ESC, CINZ_ESC, AZUL_ESC, AZUL_ESC, AZUL_ESC, CINZ_ESC, CINZ_ESC, CINZ_CLR, CINZ_ESC, 0         
    WORD CINZ_ESC, ROXO, CINZ_CLR, ROXO, CINZ_ESC, CINZENTO, CINZENTO, CINZENTO, CINZ_ESC, ROXO, CINZ_CLR, ROXO, CINZ_ESC           
    WORD CINZ_ESC, CINZ_CLR, CINZ_CLR, CINZ_CLR, CINZ_ESC, CINZENTO, CINZENTO, CINZENTO, CINZ_ESC, CINZ_CLR, CINZ_CLR, CINZ_CLR, CINZ_ESC         
    WORD CINZ_ESC, ROXO, CINZ_CLR, ROXO, CINZ_ESC, CINZENTO, CINZENTO, CINZENTO, CINZ_ESC, ROXO, CINZ_CLR, ROXO, CINZ_ESC 
    WORD 0, CINZ_ESC, CINZ_CLR, CINZ_ESC, CINZ_CLR, CINZENTO, CINZENTO, CINZENTO, CINZ_CLR, CINZ_ESC, CINZ_CLR, CINZ_ESC, 0         
    WORD 0, 0, CINZ_ESC, 0, 0, CINZ_CLR, CINZ_CLR, CINZ_CLR, 0, 0, CINZ_ESC, 0, 0                   

; ******************************************************************************
; * Tabela de interrupções
; ******************************************************************************

tab: 
    WORD 0
    WORD 0
    WORD 0
    WORD 0

; ******************************************************************************
; * Código
; ******************************************************************************
    PLACE       0
inicio:		
; inicializações
    MOV  SP, SP_inicial; inicializa Stack Pointer
    
    MOV R1, 1                
    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV [SELECIONA_CENARIO], R1 ; seleciona o cenário 1 (Splash Screen)

    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R7, LINHA_MAX ; "teto" para linha maxima a testar (4ª linha, 1000b) 

    JMP tec_ciclo     ; ciclo de detecção de teclas


inicio_jogo:
    MOV R1, 0
    MOV [SELECIONA_CENARIO], R1 ; seleciona o cenário 1 (Splash Screen)
    
    CALL desenha_nave
    
    MOV  R10, ENERGIA_BASE   ; inicializa a energia
    MOV  [VAR_ENERGIA], R10  ; inicializa a energia
    CALL hex_para_dec        ; converte o valor da energia para decimal
    MOV  [R4], R10           ; inicializa o valor do display da energia

    MOV R1, [VAR_STATUS]     ; coloca a variável de estado do jogo em R1
    MOV R1, 1                ; coloca o valor 1 em R1, para indicar que o jogo está iniciado
    MOV [VAR_STATUS], R1     ; atualiza o valor da variável de estado do jogo

    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R7, LINHA_MAX ; "teto" para linha maxima a testar (4ª linha, 1000b) 
    ; ^^^^ SUBSTITUIR POR POPS???????
    JMP tec_ciclo     ; ciclo de detecção de teclas

; *********************************************************************************
; Ciclo de detecção de teclas
; *********************************************************************************
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
    PUSH R1            ; guarda a linha e coluna na pilha

    PUSH R10
    MOV  R10, [VAR_STATUS]        ; guarda o ID da tecla premida em R8
    CMP  R10, 0                   ; se o jogo não estiver iniciado
    JZ testa_start

testa_tecla:
    POP R10
    POP R1             ; retira da pilha a linha e coluna da tecla premida

    MOV R8, TEC_0      ; coloca o ID da tecla 0 em R8
    PUSH R0            ; guarda o valor de R0
    MOV R0, -1
    CMP R1, R8
    JZ  sum_display
    POP R0

    MOV R8, TEC_1      ; coloca o ID da tecla 1 em R8
    PUSH R0
    MOV R0, 1
    CMP R1, R8         
    JZ  sum_display
    POP R0

    MOV R8, TEC_2      ; coloca o ID da tecla 2 em R8
    PUSH R0
    MOV R0, 19H
    CMP R1, R8         
    JZ  sum_display
    POP R0

    MOV R8, TEC_C      ; coloca o ID da tecla C em R8
    CMP R1, R8         
    JZ  sobe_sonda

    MOV R8, TEC_F      ; coloca o ID da tecla F em R8
    CMP R1, R8         
    JZ debug_asteroide

    JMP ha_tecla       ; testa se a tecla permanece premida

testa_start:
    POP R10
    POP R1             ; retira da pilha a linha e coluna da tecla premida

    MOV R8, TEC_C      ; coloca o ID da tecla 0 em R8
    CMP R1, R8
    JZ  inicio_jogo

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

;*********************************************************************************
; Ações do teclado
;*********************************************************************************

debug_asteroide:        ; TEMP! - Hardcoded de forma que o asteroide 0 se mova para a direita de forma obrigatória  

    PUSH R0
    PUSH R1
    PUSH R2
    MOV R0, VAR_AST_POS_V_0
    MOV R1, VAR_AST_POS_H_0
    MOV R2, 1 ; direção do asteroide, esquerda para a direita
    CALL atualiza_asteroide
    POP R2
    POP R1
    POP R0
    JMP ha_tecla


atualiza_asteroide:           ; TEMP - assume R0, R1 e R2 como os endreços das coordenadas e a direcção do asteroide
    PUSH R10
    PUSH R11
    PUSH R4

    PUSH R5
    PUSH R0
    MOV R0, 1
    MOV [VAR_PROX_SOM], R0    ; coloca o numero do som (1), whilhelm.wav
    CALL toca_som             ; toca o som
    POP R0

    MOV R10, [R0]             ; coloca a posição vertical do asteroide em R10
    MOV R11, [R1]             ; coloca a posição horizontal do asteroide em R11
    MOV R4, DEF_CLEAR_AST     ; coloca o endereço da tabela do asteroide em R4
    CALL desenha_asteroide    ; apaga o asteroide na posição atual
    ADD R10, 1                ; incrementa a posição vertical do asteroide
    ADD R11, R2               ; incrementa a posição horizontal do asteroide
    MOV R4, DEF_ASTEROIDE     ; coloca o endereço da tabela do asteroide em R4
    MOV R5, COLISAO_ASTEROIDE ; coloca a altura máxima que o asteroide deve atingir em R5
    CMP R11, R5               ; se o asteroide já estiver no fundo
    JZ reset_asteroide
    CALL desenha_asteroide    ; caso contrário, desenha o asteroide na nova posição
    MOV [R0], R10             ; atualiza a posição vertical do asteroide
    MOV [R1], R11             ; atualiza a posição horizontal do asteroide
    POP R5
    POP R4
    POP R11
    POP R10
    RET

reset_asteroide:              ; TEMP!! Assume ainda o asteroide 0 - De futuro, definir variáveis é necessário
    MOV R10, 1                ; coloca a posição vertical default do asteroide em R10
    MOV R11, 1                ; coloca a posição horizontal default do asteroide em R11
    MOV [R0], R10             ; coloca a posição vertical do asteroide em R1
    MOV [R1], R11             ; coloca a posição horizontal do asteroide em R2
    POP R5
    POP R4
    POP R11
    POP R10
    RET

sobe_sonda:                   ; TEMP!
    PUSH R0
    MOV R0, 0
    MOV [VAR_PROX_SOM], R0    ; coloca o numero do som (0) em R0, probe.wav 
    CALL toca_som             ; toca o som
    POP R0
    MOV R10, [VAR_MSONDA_POS] ; coloca a posição da sonda do meio em R10 
    
    PUSH R10
    SUB R10, 1                ; decrementa a posição vertical da sonda do meio (sobe)
    MOV [VAR_MSONDA_POS], R10 ; atualiza a posição da sonda do meio
    CALL desenha_sonda        ; desenha a sonda do meio na posição atual
    
    POP R10
    CMP R10, 0                ; se a sonda já estiver no topo
    JZ reset_sonda

    JMP ha_tecla              ; ação efetuada, não testar teclado novamente

reset_sonda:
    
    MOV R10, NAVE_Y-2         ; coloca a posição da sonda do meio em R10 
    MOV [VAR_MSONDA_POS], R10 ; atualiza a posição da sonda do meio
    CALL desenha_sonda        ; desenha a sonda do meio na posição atual
    JMP ha_tecla              ; ação efetuada, não testar teclado novamente

sum_display:                  ; TEMP!

    MOV R10, [VAR_ENERGIA]    ; coloca o valor da energia em R10
    ADD R10, R0               ; altera o valor da energia
    MOV [VAR_ENERGIA], R10    ; atualiza o valor da energia

    CALL hex_para_dec         ; Altera o valor em R10 para "decimal"

    MOV [R4], R10             ; atualiza o valor do display

    POP R0                    ; foi dado push antes do salto, R9 é o incremento/decremento

    JMP ha_tecla              ; ação efetuada, não testar teclado novamente

hex_para_dec:
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    MOV R4, R10               ; coloca o valor a converter em R4
    MOV R3, 0                 ; coloca o valor 0 em R3
    MOV R1, 10                ; coloca a constante 10 em r1
    MOV R0, 1000              ; coloca o valor 1000 em R0, para tratar 3 digitos
    CALL conversao_rec        ; converte o valor da energia para decimal

    POP R4
    POP R3
    POP R1
    POP R0
    RET

conversao_rec:
    MOD R4, R0                ; coloca em R10 o resto da divisão pelo fator R0
    DIV R0, R1                ; Divide R0 por 10

    CMP R0, 0
    JZ fim_conversao          ; se R0 for maior que 1, continua a conversão

    PUSH R4
    DIV R4, R0
    SHL R3, 4
    OR R3, R4
    POP R4
    JMP conversao_rec

fim_conversao:
    MOV R10, R3
    RET

; *********************************************************************************
; Graficos e Sprites
; *********************************************************************************

desenha_nave:
    PUSH R0
    PUSH R1
    PUSH R4
    PUSH R10
    PUSH R11
    MOV R10, NAVE_Y  ; coloca a posição vertical do canto do sprite da nave em R10
    MOV R11, NAVE_X  ; coloca a posição horizontal do canto do sprite da nave em R11
    MOV R4, DEF_NAVE ; coloca o endereço da tabela do sprite da nave em R4
    CALL desenha_sprite 
    POP R11
    POP R10
    POP R4
    POP R1
    POP R0
    RET

desenha_sonda: 
    PUSH R0                 ; guarda o valor de R0
    PUSH R1                 ; guarda o valor de R1
    PUSH R2                 ; guarda o valor de R2
    PUSH R3

    MOV R1, [VAR_MSONDA_POS]; coloca a posição vertical da sonda do meio em R1
    MOV R2, 32              ; coloca a posição horizontal da sonda do meio em R2 (constante 32)
    MOV R3, [VAR_COR_SONDA] ; coloca a cor da sonda do meio em R3

    CALL escreve_pixel      ; escreve o pixel na posição da sonda do meio
    ADD R1, 1               ; coloca em R2 a posição da sonda a apagar 
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
    PUSH R4                 ; guarda o valor de R4
    PUSH R5
    PUSH R6
    PUSH R10
    PUSH R11
    SUB R10, 2              ; R10 contem a coordenada vertical do canto do asteroide
    SUB R11, 2              ; R11 contem a coordenada horizontal do canto do asteroide
    MOV R0, 0               ; O sprite é desenhado a a partir da sua primeira linha  
    CALL desenha_sprite     ; MODIFICA R1 e R0, R5 e R6, FAZER POP APÓS CHAMADA
    POP R11
    POP R10
    POP R6
    POP R5
    POP R4                  ; recupera o valor de R4
    POP R1
    POP R0                  ; recupera o valor de R0
    RET    



; **********************************************************************
; DESENHA_BONECO - Desenha um sprite a partir do canto superior 
;                  esquerdo dado, como definido na tabela indicada.
;                   
; Argumentos:   R10 - linha
;               R11 - coluna
;               R4 - tabela que define o sprite
; **********************************************************************
desenha_sprite:       
    MOV R1, 0         ; R1 contem a coordenada vertical atual, ou a linha
    MOV R5, [R4]      ; coloca a largura do sprite em R5
    ADD R4, 2         ; R4+2 contem o endereço da altura do sprite
    MOV R6, [R4]      ; coloca a altura do sprite em R6   
    SUB R4, 2         ; R4 contem o endereço da largura do sprite
    CMP R0, R6        ; Se não se desenhou a ultima linha do sprite
    JNZ desenha_linha ; avança para a próxima linha
    RET

desenha_linha:              ; Desenha uma linha arbitrária, usada por desenha_sprite
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    SHL R1, 1               
    PUSH R0                 ; guarda o valor de R0
    PUSH R1
    MOV R1, 2

    MUL R0, R5              ; multiplica a linha atual por 2*col
    MUL R0, R1
    POP R1

    ADD R4, R1             
    ADD R4, R0
    ADD R4, 4              
    MOV R3, [R4]            ; coloca a cor do pixel em R3

    SHR R1, 1               ; retorna o contador ao normal
    POP R0                  ; recupera o valor de R0
    MOV R2, R11             ; coloca a posição horizontal do pixel referência em R2
    ADD R2, R1              ; "aponta" para a coluna atual

    MOV R1, R10             ; coloca a posição vertical do pixel em R1
    ADD R1, R0              ; "aponta" para a linha atualS

    CALL escreve_pixel      ; R1 altura R2 largura R3 cor

    POP R4
    POP R3
    POP R2
    POP R1

    ADD R1, 1
    CMP R1, R5
    JNZ desenha_linha      ; Continua a desenhar a linha

    ADD R0, 1
    JMP desenha_sprite     ; Desenha a linha seguinte

escreve_pixel:              
    PUSH R0
    MOV R0, MEMORIA_ECRA

    PUSH R1                ; guarda o valor de R1
    PUSH R2                ; guarda o valor de R2
    PUSH R3                ; guarda o valor de R3
                           ; É assumido presente em R1 a linha e em R2 a coluna, em R3 a cor
	SHL	R1, 6		       ; linha * 64
    ADD  R1, R2		       ; linha * 64 + coluna
    SHL  R1, 1		   	   ; * 2, para ter o endereço da palavra
	ADD	R0, R1		       ; MEMORIA_ECRA + 2 * (linha * 64 + coluna)
	MOV	[R0], R3		   ; escreve cor no pixel
    
    POP R3
    POP R2
    POP R1
    POP R0                  
    RET

; **********************************************************************
; TOCA_SOM - Toca um som a partir do endereço indicado numa variável.
; **********************************************************************
toca_som:
    PUSH R0
    MOV R0, [VAR_PROX_SOM]   ; coloca o próximo som a tocar em R0
    MOV [SELECIONA_VID], R0  ; seleciona o som
    MOV [PLAY_VID], R0       ; toca o som
    POP R0
    RET

