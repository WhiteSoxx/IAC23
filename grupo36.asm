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
TAMANHO_PILHA EQU 200H  ; tamanho da pilha

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
ROXO	     	EQU	0F60AH		; cor do pixel: preenchimento da nave em ARGB


; *********************************************************************************
; * Grandezas "físicas"
; *********************************************************************************
SONDA_BASE     EQU 21          ; posição vertical inicial da sonda do meio
SONDA_MAX       EQU 8           ; Altura max da sonda
LSONDA_BASE     EQU 21          ; posição vertical inicial da sonda do meio
RSONDA_BASE     EQU 21          ; posição vertical inicial da sonda do meio
LSONDA_OFFSET   EQU -4          ; offset da sonda da esquerda
RSONDA_OFFSET   EQU 4           ; offset da sonda da direita

ENERGIA_BASE EQU 00064H   ; energia inicial

NAVE_X       EQU  26
NAVE_Y       EQU  22
LARGURA_NAVE EQU 13
ALTURA_NAVE  EQU 10

COLISAO_MID_ASTEROIDE   EQU 20       ; altura máxima que os asteroides nao inocuos devem atingir
COLISAO_ASTEROIDE       EQU 24      ; altura maxima que os asteroides devem atingir
LIM_ASTEROIDE       EQU 29        ; altura maxima que os asteroides devem atingir

V_BASE_AST EQU 3
H_BASE_AST_1 EQU 3
H_BASE_AST_3 EQU 32
H_BASE_AST_5 EQU 61 

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H

	STACK TAMANHO_PILHA 			; espaçco reservado para a pilha (200H bytes, ou 100H words)
SP_inicial:				; Stack pointer do programa inicial
    STACK TAMANHO_PILHA          ; espaço reservado para a pilha (200H bytes, ou 100H words)
SP_teclado:      ; Stack pointer do programa do teclado
    STACK TAMANHO_PILHA          ; espaço reservado para a pilha (200H bytes, ou 100H words)
SP_nave:         ; Stack pointer do programa da nave
    STACK TAMANHO_PILHA * 3          ; espaço reservado para a pilha (200H bytes, ou 100H words)
SP_sonda:        ; Stack pointer do programa da sonda
    STACK TAMANHO_PILHA * 5          ; espaço reservado para a pilha (200H bytes, ou 100H words)
SP_asteroides:   ; Stack pointer do programa dos asteroides

imagem_hexa:
	BYTE	00H			; imagem em memória dos displays hexadecimais 
						; (inicializada a zero, mas podia ser outro valor qualquer).

VAR_LINHA:  WORD 0            ; variável para guardar a linha atual
VAR_COLUNA: WORD 0            ; variável para guardar a coluna atual
VAR_TECCOUNT: WORD -1         ; variável para guardar o contador para conversão de teclas
VAR_ENERGIA: WORD ENERGIA_BASE; variável para guardar a energia (ver constante ENERGIA_BASE)

VAR_COR_PIXEL: WORD COR_PIXEL ; variável para guardar a cor do pixel, default é vermelho
VAR_PROX_SOM:  WORD 0         ; variável para guardar o próximo som a tocar, default é 0

VAR_COR_SONDA:  WORD 0FFC0H      ; variável para guardar a cor da sonda, default é amarelo
VAR_SONDA_POS:  WORD SONDA_BASE  ; variável para guardar a posição da sonda da esquerda 
                WORD SONDA_BASE  ; variável para guardar a posição da sonda do meio
                WORD SONDA_BASE  ; variável para guardar a posição da sonda da direita

VAR_SONDA_ON:   WORD 0           ; variável para guardar o estado da sonda do meio (0 - desligada, 1 - ligada)
                WORD 0           ; variável para guardar o estado da sonda da esquerda (0 - desligada, 1 - ligada)
                WORD 0           ; variável para guardar o estado da sonda da direita (0 - desligada, 1 - ligada)

VAR_AST_ON:     WORD 0  
                WORD 0  
                WORD 0
                WORD 0
                WORD 0

VAR_AST_TIPO:   WORD 0
                WORD 0
                WORD 0
                WORD 0
                WORD 0

VAR_AST_NUM:  WORD 0  

VAR_AST_POS_V:  WORD V_BASE_AST   ; variável para guardar a posição vertical do asteroide 0
                WORD V_BASE_AST   ; variável para guardar a posição vertical do asteroide 1
                WORD V_BASE_AST   ; variável para guardar a posição vertical do asteroide 2
                WORD V_BASE_AST   ; variável para guardar a posição vertical do asteroide 3
                WORD V_BASE_AST   ; variável para guardar a posição vertical do asteroide 4

VAR_AST_POS_H:  WORD H_BASE_AST_1   ; variável para guardar a posição horizontal do asteroide 0
                WORD H_BASE_AST_3   ; variável para guardar a posição horizontal do asteroide 1
                WORD H_BASE_AST_3   ; variável para guardar a posição horizontal do asteroide 2
                WORD H_BASE_AST_3  ; variável para guardar a posição horizontal do asteroide 3
                WORD H_BASE_AST_5 ; variável para guardar a posição horizontal do asteroide 4

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

DEF_AST_NRG:					; tabela que define o asteroide (cor, largura, pixels)
	WORD		LARGURA_AST     ; [DEF_AST + 0] largura do asteroide 1228
    WORD        LARGURA_AST     ; [DEF_AST + 2] altura do asteroide, igual a largura 122A
    WORD		       0, CAST_ESC, CAST_ESC, CAST_ESC, 0		    ; [DEF_AST + 4 + 2*col + 2*col*lin] 
	WORD		CAST_ESC, ROXO, CAST_CLR, ROXO, CAST_ESC	;
    WORD		CAST_ESC, CAST_CLR, ROXO, CAST_CLR, CAST_ESC	;
    WORD		CAST_ESC, ROXO, CAST_CLR, ROXO, CAST_ESC    ;
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

AST_LOCK:    LOCK 0
SONDA_LOCK:  LOCK 0
NAVE_LOCK:   LOCK 0
START_LOCK:  LOCK 0

; ******************************************************************************
; * Tabela de interrupções
; ******************************************************************************

tab: WORD int_ast
     WORD int_sonda
     WORD 0
     WORD 0

; ******************************************************************************
; * Código
; ******************************************************************************

    PLACE       0

inicio:		                  ; inicializações
    MOV  SP, SP_inicial       ; inicializa Stack Pointer
    
    MOV BTE, tab              ; coloca o endereço da tabela de interrupções em BTE

    MOV R1, 1                
    MOV  [APAGA_AVISO], R1	  ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	  ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV  [SELECIONA_CENARIO], R1 ; seleciona o cenário 1 (Splash Screen)
    
    MOV  R1, 0
    MOV  R4, DISPLAYS         ; endereço do periférico dos displays
    MOV  [R4], R1             ; inicializa o valor do display da energia

    CALL teclado              ; inicia o processo do teclado
    CALL nave                 ; inicia o processo da nave

	MOV	R11, -2		          ; número de sondas a criar é 3 (-1, 0, 1)
loop_sondas:
	ADD	R11, 1			      ; próxima sonda
	CALL	init_sonda	      ; cria uma nova instância do processo sonda (o valor de R11 distingue-as)
						      ; Cada processo fica com uma cópia independente dos registos, R11 serve como offset
	CMP  R11, 1			      ; já criou as instâncias todas?
    JNZ	loop_sondas	          ; se não, continua

MOV R11, 0
loop_asteroides:
	ADD	R11, 1			      ; próxima sonda
	CALL	init_asteroides	      ; cria uma nova instância do processo sonda (o valor de R11 distingue-as)
						      ; Cada processo fica com uma cópia independente dos registos, R11 serve como offset
	CMP  R11, 5			      ; já criou as instâncias todas?
    JNZ	loop_asteroides          ; se não, continua

    MOV  R1, [START_LOCK]     ; Bloqueia o processo principal

sum_display:                  ; TEMP!

    MOV R10, [VAR_ENERGIA]    ; coloca o valor da energia em R10
    ADD R10, R0               ; altera o valor da energia
    MOV [VAR_ENERGIA], R10    ; atualiza o valor da energia

    CALL hex_para_dec         ; Altera o valor em R10 para "decimal"

    MOV [R4], R10             ; atualiza o valor do display

    POP R0                    ; foi dado push antes do salto, R9 é o incremento/decremento

    JMP ha_tecla              ; ação efetuada, não testar teclado novamente


; **********************************************************************
; HEX_PARA_DEC - Converte um valor hexadecimal para um valor pseudo-
;                -decimal para apresentar nos displays de 7 segmentos
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
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
; *********************************************************************************
; Desenha Asteroide - R10 coord. vertical, R11, coord HORIZONTAL
; *********************************************************************************

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
; DESENHA_SPRITE - Desenha um sprite a partir do canto superior 
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
; TOCA_SOM - Toca um som especificado em R0.
; **********************************************************************
toca_som:

    MOV [SELECIONA_VID], R0  ; seleciona o som
    MOV [PLAY_VID], R0       ; toca o som

    RET

int_sonda:
    PUSH R0
    MOV R0, 0
    MOV [SONDA_LOCK], R0      ; desbloqueia o processo da sonda
    POP R0
    RFE 
int_ast:
    PUSH R0
    MOV R0, 0
    MOV [AST_LOCK], R0        ; desbloqueia o processo da sonda
    POP R0
    RFE 

; *********************************************************************************
; Processo
;
; Teclado
; *********************************************************************************
PROCESS SP_teclado

teclado:
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R7, LINHA_MAX ; "teto" para linha maxima a testar (4ª linha, 1000b) 

tec_ciclo:
    YIELD              ; Ciclo potencialmente bloqueante, cede o processador

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
    POP R1               ; retira da pilha a linha e coluna da tecla premida

    MOV R8, TEC_D        ; coloca o ID da tecla D em R8
    PUSH R0
    MOV R0, VAR_SONDA_ON ; coloca o endreço do estado da sonda do meio em R0
    CMP R1, R8         
    JZ  dispara_sonda
    POP R0

    MOV R8, TEC_E        ; coloca o ID da tecla E em R8
    PUSH R0
    MOV R0, VAR_SONDA_ON ; coloca o endreço do estado da sonda do meio em R0
    ADD R0, 2
    CMP R1, R8         
    JZ  dispara_sonda
    POP R0

    MOV R8, TEC_F        ; coloca o ID da tecla E em R8
    PUSH R0
    MOV R0, VAR_SONDA_ON ; coloca o endreço do estado da sonda do meio em R0
    ADD R0, 4            ; coloca o endreço do estado da sonda da direita em R0
    CMP R1, R8         
    JZ  dispara_sonda
    POP R0

    JMP ha_tecla       ; testa se a tecla permanece premida

testa_start:
    POP R10
    POP R1             ; retira da pilha a linha e coluna da tecla premida

    MOV R8, TEC_C      ; coloca o ID da tecla 0 em R8
    CMP R1, R8
    JZ  inicio_jogo

    JMP ha_tecla       ; testa se a tecla permanece premida

ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    YIELD              ; Ciclo bloqueante, cede o processador

    POP R1             ; retira da pilha a linha atual
    PUSH R1

    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)

    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se houver uma tecla premida, espera até não haver
    POP R1             ; "limpa" da pilha a linha atual
    JMP  tec_ciclo     ; se não houver, repete-se o ciclo de teste do teclado

inicio_jogo:
    MOV R1, [VAR_STATUS]     ; coloca a variável de estado do jogo em R1
    MOV R1, 1                ; coloca o valor 1 em R1, para indicar que o jogo está iniciado
    MOV [VAR_STATUS], R1     ; atualiza o valor da variável de estado do jogo
    EI1
    EI
    JMP tec_ciclo            ; volta ao ciclo principal do teclado

dispara_sonda:    ; Ativa a sonda na posição R0
    PUSH R1
    PUSH R2

    MOV R1, [R0]  ; coloca o estado da sonda do meio em R1
    PUSH R1

    MOV R2, 1     ; coloca o valor 1 em R2
    OR R1, R2      ; liga a sonda do meio, mantem ligada
    MOV [R0], R1  ; atualiza o estado da sonda do meio

    POP R2
    CMP R1, R2     ; se a sonda do meio acaba de ligar
    JNZ som_disparo; salta para o código do som de disparo
    JMP som_cooldown;

som_disparo:
    MOV R0, 0    ; coloca o valor 1 em R0
    CALL toca_som ; toca o som da sonda
    JMP fim_disparo

som_cooldown:
    MOV R0, 2    ; coloca o valor 2 em R0
    CALL toca_som ; toca o som de cooldown da sonda

fim_disparo:
    POP R2  
    POP R1
    POP R0
    JMP ha_tecla

; *********************************************************************************
; Processo - Nave
; *********************************************************************************

PROCESS SP_nave

nave:

    MOV R1, [VAR_STATUS]
    CMP R1, 0
    JZ aguarda_inicio_n              

    EI
    MOV R1, 0
    MOV [SELECIONA_CENARIO], R1 ; seleciona o cenário 1 (Splash Screen)
    
    
    CALL desenha_nave
    
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R10, ENERGIA_BASE   ; inicializa a energia
    MOV  [VAR_ENERGIA], R10  ; inicializa a energia
    CALL hex_para_dec        ; converte o valor da energia para decimal
    MOV  [R4], R10           ; inicializa o valor do display da energia

    MOV  R4, DISPLAYS        ; endereço do periférico dos displays

    MOV  R10, [NAVE_LOCK] ; bloqueia o update da nave
aguarda_inicio_n:
    YIELD
    JMP nave

atualiza_nave_loop:
    YIELD
    JMP atualiza_nave_loop

; *********************************************************************************
; Processo - Sondas
; 
;
; *********************************************************************************
PROCESS SP_sonda

init_sonda:
	MOV	R1, TAMANHO_PILHA	; tamanho em palavras da pilha de cada processo
    MOV R10, R11            ;
    ADD R10, 1              ; R10 contem o offset para os endreços das variáveis da sonda
    MUL	R1, R10			    ; TAMANHO_PILHA vezes o nº da instância da sonda
	SUB	SP, R1		        ; inicializa SP desta sonda, relativo ao SP indicado inicalmente
    SHL R10, 1              ; multiplica o offset da instância por 2, R10 é agora o offset em bytes

sonda:
    
    MOV R1, [VAR_STATUS]
    CMP R1, 0
    JZ aguarda_inicio_s
    EI1
    EI

   
    JMP m_sonda_check

m_sonda_check:
    MOV R0, VAR_SONDA_ON     ; coloca o endreço do estado da sonda em R0
    MOV R1, [R0+R10]         ; coloca o estado da sonda  em R1
    CMP R1, 1                ; se a sonda do meio estiver ligada
    JZ m_sonda_on            ; salta para o código da sonda do meio ligada
     YIELD
    JMP sonda                ; caso contrário, verifica de novo  (TEMP, DEVE VERIFICAR RESTANTES SONDAS)

m_sonda_on:
    MOV R0, VAR_SONDA_POS    ; coloca o endreço da posição vertical da sonda em R0
    MOV R1, [R0+R10]         ; coloca a posição vertical da sonda do meio em R1

    MOV R2, SONDA_MAX        ; coloca a posição vertical máxima da sonda em R2
    CMP R1, R2               ; se a sonda do meio estiver na posição mais alta
    JZ m_sonda_off           ; salta para o código da sonda do meio desligada

    CALL desenha_sonda       ; desenha a sonda do meio na posição atual
    SUB R1, 1                ; decrementa a posição vertical da sonda
    MOV [R0+R10], R1         ; atualiza a posição vertical da sonda 
        MOV R1, [SONDA_LOCK]     ; pára o update da sonda lendo o lock

    JMP sonda                ; volta ao ciclo principal da sonda

m_sonda_off:
    MOV R0, VAR_SONDA_POS    ; coloca o endreço da posição vertical da sonda em R0
    MOV R1, [R0+R10]         ; coloca a posição vertical da sonda do meio em R1
    ADD R1, 1                ; aponta para a posição gráfica da sonda do meio
    CALL sonda_offset
    MOV R3, 0000H
    CALL escreve_pixel       ; apaga o pixel na posição da sonda

    MOV R1, 0            
    MOV R0, VAR_SONDA_ON    ; coloca o endreço do estado da sonda em R0
    MOV [R0+R10], R1        ; desliga a sonda do meio
    MOV R1, SONDA_BASE      ; coloca a posição vertical base da sonda do meio em R1
    MOV R0, VAR_SONDA_POS   ; coloca o endreço da posição vertical da sonda em R0
    MOV [R0+R10], R1        ; atualiza a posição vertical da sonda do meio
            MOV R1, [SONDA_LOCK]     ; pára o update da sonda lendo o lock

    JMP sonda               ; volta ao ciclo principal da sonda

desenha_sonda: 
    PUSH R0                 ; guarda o valor de R0
    PUSH R1                 ; guarda o valor de R1
    PUSH R2                 ; guarda o valor de R2
    PUSH R3
    MOV R0, VAR_SONDA_POS   ; coloca o endreço da posição vertical da sonda em R0
    MOV R1, [R0+R10]        ; coloca a posição vertical da sonda do meio em R1
    CALL sonda_offset       ; coloca em R2 a posição horizontal da sonda do meio

    MOV R3, [VAR_COR_SONDA] ; coloca a cor da sonda do meio em R3

    CALL escreve_pixel      ; escreve o pixel na posição da sonda do meio
    ADD R1, 1               ; aponta para a posição gráfica vertical da sonda a apagar
    SUB R2, R11             ; coloca em R2 a posição da sonda a apagar
    MOV R3, 00000H          ; coloca em R3 a cor transparente
    CALL escreve_pixel      ; apaga o pixel na posição anterior da sonda do meio
    POP R3
    POP R2
    POP R1                  ; recupera o valor de R1
    POP R0                  ; recupera o valor de R0
    RET

sonda_offset:               ; COLOCA EM R2 A POSIÇÃO HORIZONTAL DA SONDA
    PUSH R3
    MOV R2, 32              ; coloca a posição horizontal base da sonda do meio em R2 (constante 32)
    MOV R3, SONDA_BASE      ;
    SUB R3, R1              ;
    MUL R3, R11             ; multiplica a posição vertical da sonda do meio pelo offset da instância
    ADD R2, R3              ; coloca em R2 a posição horizontal da sonda do meio
    POP R3
    RET
aguarda_inicio_s:
    YIELD
    JMP sonda
; *********************************************************************************

; *********************************************************************************
; Processo - Asteroides
; *********************************************************************************
PROCESS SP_asteroides

init_asteroides:
    MOV	R1, TAMANHO_PILHA	; tamanho em palavras da pilha de cada processo
    MOV R0, R11
    SUB R11, 1
    MUL	R1, R11			    ; TAMANHO_PILHA vezes o nº da instância do asteroide
    SUB	SP, R1		        ; inicializa SP deste asteroide, relativo ao SP indicado inicalmente
    MOV R10, R11            ;
    MOV R11, R0
    SHL R10, 1              ; multiplica o offset da instância por 2, R10 é agora o offset em bytes

    MOV R1, VAR_AST_POS_V   ; coloca o endereço da posição vertical do asteroide em R1
    MOV R2, VAR_AST_POS_H   ; coloca o endereço da posição horizontal do asteroide em R2
    MOV R3, VAR_AST_ON      ; coloca o endereço do estado do asteroide em R3
    MOV R7, [R1+R10]        ; coloca a posição vertical ORIGINAL do asteroide em R7
    MOV R8, [R2+R10]        ; coloca a posição horizontal ORIGINAL do asteroide em R8
    MOV R9, COLISAO_ASTEROIDE; coloca o limite da colisão em r9

calc_offset_a:              ; calcula o offset horizontal a aplicar por ciclo com base na instância, GUARDA EM R0
    CMP R11, 5              ; se a instância for 5
    JZ asteroide_esq        ; salta para o código do asteroide da esquerda
    CMP R11, 4              ; se a instância for 4
    JZ asteroide_dir        ; salta para o código do asteroide do meio
    CMP R11, 3              ; se a instância for 3
    JZ asteroide_meio       ; salta para o código do asteroide do meio
    CMP R11, 2              ; se a instância for 2
    JZ asteroide_esq        ; salta para o código do asteroide da direita
    CMP R11, 1              ; se a instância for 1
    JZ asteroide_dir        ; salta para o código do asteroide da esquerda


inocuo:
    MOV R9, LIM_ASTEROIDE               ; coloca o limite da colisão do asteroide do meio em R9
    JMP asteroides          ; salta para o código que move o asteroide

asteroide_esq:              ; asteroides que se movem para a esquerda
    MOV R0, -1               ; coloca o offset horizontal do asteroide par em R0
    CMP R11, 2              ; se a instância for 4
    JZ  inocuo
    JMP asteroides          ; salta para o código que move o asteroide

asteroide_dir:              ; asteroides que se movem para a direita
    MOV R0, 1               ; coloca o offset horizontal do asteroide ímpar em R0
    CMP R11, 4              ; se a instância for 3
    JZ  inocuo
    JMP asteroides          ; salta para o código que move o asteroide
    
asteroide_meio:
    MOV R9, COLISAO_MID_ASTEROIDE              ; coloca o limite da colisão do asteroide do meio em R9
    MOV R0, 0               ; coloca o offset horizontal do asteroide do meio em R0
    JMP asteroides          ; salta para o código que move o asteroide

asteroides:
    MOV R5, [VAR_STATUS]
    CMP R5, 0
    JZ aguarda_inicio_a
    EI0
    EI1
    EI

    JMP asteroide_check

asteroide_check:
    YIELD  
    MOV R4, [R3+R10]        ; coloca o estado do asteroide em R1
    CMP R4, 1               ; se o asteroide estiver ligado
    JZ asteroide_on         ; salta para o código que move o asteroide
    JMP asteroide_spawn     ; salta para o código que verifica o spawn do asteroide

asteroide_on:

    PUSH R10                ; guarda o valor de R10
    PUSH R11                ; guarda o valor de R11

    MOV R4, [R2+R10]        ; coloca a posição horizontal do asteroide em R4
    ADD R4, R0              ; adiciona o offset horizontal do asteroide
    MOV [R2+R10], R4        ; atualiza a posição horizontal do asteroide
    MOV R11, R4             ; coloca a posição horizontal do asteroide em R11

    MOV R4, [R1+R10]        ; coloca a posição vertical do asteroide em R4
    ADD R4, 1               ; adiciona o offset vertical do asteroide
    MOV [R1+R10], R4        ; atualiza a posição vertical do asteroide
    MOV R10, R4             ; coloca a posição vertical do asteroide em R10
    PUSH R4                 ; guarda o valor de R4


    MOV R4, DEF_CLEAR_AST
    SUB R11, R0             ; Subs servem para apagar o asteroide na posição anterior
    SUB R10, 1
    CALL desenha_asteroide

    ADD R11, R0
    ADD R10, 1
    MOV R4, DEF_ASTEROIDE   ; coloca o endereço do desenho do asteroide em R4
    ADD R4, R6
    CALL desenha_asteroide  ; desenha o asteroide
    
    POP R4                  ; recupera o valor de R4 para verificar a pos. vertical
    CMP R4, R9              ; se o asteroide tiver excedido um limite
    JZ asteroide_reset      ; salta para o código que reinicia o asteroide


    POP R11                 ; recupera o valor de R11
    POP R10                 ; recupera o valor de R10

    JMP asteroide_check     ; volta a verificar o estado do asteroide

asteroide_reset:

    MOV R5, LIM_ASTEROIDE
    CMP R9, R5              ; se o limite for o limite para asteróides inócuos, desligar o asteroide
    JZ  asteroide_off       ; salta para o código que desliga o asteroide
    
    MOV R6, R10             ; BODGED!!!!
    POP R10                 ; recupera o valor de R11 para R10 (OFFSET DE MEMÓRIA)
    PUSH R6                 ; guarda o valor de R10 antigo (POSIÇÃO)
    SUB R10, 1              ; decrementa o offset de memória
    SHL R10, 1              ; multiplica o offset de memória por 2

    MOV R5, VAR_AST_ON
    MOV R5, [R5+R10];
    CMP R5, 0               ;
    JZ  asteroide_off       ; salta para o código que desliga o asteroide
    ;JMP asteroide_fim      ; salta para o código que acaba o jogo por colisão
    ;R10 e R11 possívelmente trocados neste ponto. Irrelevante,no fim de jogo o erro não é visível
    JMP asteroide_off       ; salta para o código que desliga o asteroide

asteroide_spawn:            
    MOV R4, [VAR_AST_NUM]   ; coloca o número de asteroides ativos em R4
    CMP R4, 4               ; se o número de asteroides ativos for 3
    JZ asteroide_check      ; Volta para o início do ciclo
    PUSH R0                 ; guarda o valor de R0
    CALL numero_aleatorio   ; coloca um número aleatório entre 0 e 15 em R0
    MOV R6, R0              ; coloca o número aleatório em R6
    POP R0

    SHR R6, 3               ; Isola o ultimo bit do número aleatório (0 ou 1)
    JZ  asteroide_check     ; 50% de chance de spawnar um asteroide POR PROCESSO,
    MOV R5, 1
    MOV [R3+R10], R5        ; atualiza o estado do asteroide
    MOV R6, [VAR_AST_NUM]
    ADD R6, R5              ; incrementa o número de asteroides ativos
    MOV [VAR_AST_NUM], R6   ; atualiza o número de asteroides ativos

    PUSH R0                 ; guarda o valor de R0
    CALL numero_aleatorio   ; coloca um número aleatório entre 0 e 15 em R0
    MOV R5, VAR_AST_TIPO
    SHR R0, 2               ; Isola os ultimos 2 bits do número aleatório (0 a 3)
    JNZ  fim_spawn          ; 25% de chance de spawnar um asteroide minerável
    MOV R6, 1
    MOV [R5+R10], R6         ; atualiza o tipo do asteroide

fim_spawn:
    MOV R6, [R5+R10]
    MOV R5, 2
    MUL R6, R5              ; multiplica o tipo do asteroide por 2
    MOV R5, 27
    MUL R6, R5             ; Numero de words no asteroide, contingente no mineravel estar definido seguidamente
    POP R0   
    JMP asteroide_on        ; começa a mover o asteroide


asteroide_off:              ; desliga o asteroide
    MOV R4, DEF_CLEAR_AST  
    CALL desenha_asteroide  ; apaga o asteroide
    POP R11
    POP R10
    MOV R4, 0               ; coloca o estado do asteroide em R4
    MOV [R3+R10], R4        ; atualiza o estado do asteroide
    MOV [R1+R10], R7        ; Reinicia a posição vertical do asteroide
    MOV [R2+R10], R8        ; Reinicia a posição horizontal do asteroide
    MOV R5, 1
    MOV R6, [VAR_AST_NUM]
    SUB R6, R5              ; incrementa o número de asteroides ativos
    MOV [VAR_AST_NUM], R6   ; atualiza o número de asteroides ativos

    MOV R5, VAR_AST_TIPO
    MOV R6, 0
    MOV [R5+R10], R6         ; atualiza o tipo do asteroide

    JMP asteroide_check     ; volta a verificar o estado do asteroide

asteroide_fim:              ; NOT FUCKING WORKING
    POP R11                 ; recupera o valor de R11
    POP R10                 ; recupera o valor de R10
    MOV R5, 0
    MOV [VAR_STATUS], R5
    JMP asteroides 
aguarda_inicio_a:
    YIELD
    JMP asteroides

; *********************************************************************************
; Gerador Pseudo-Aleatório - Faz uso dos bits "no ar" do periférico PIN para
;                            obter um valor de 4 bits aleatório entre 0 e 15
;                            OUTPUT - R0
; *********************************************************************************
numero_aleatorio:            
    PUSH R1
    MOV  R1, TEC_COL           ; Periférico PIN liga bits 0 a 3 ao teclado, restantes bits no ar
    MOV  R0, [R1]
    SHR  R0, 12                ; R0 possui um valor entre 0 e 15
    POP  R1
    RET
