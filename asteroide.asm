; *********************************************************************************
; * IST-UL
; * Modulo:    proj_asteroide.asm
; * Descrição: Este programa ilustra o desenho de um asteroide, em que os pixels
; *            são definidos por uma tabela.
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo

LINHA        		EQU  0        	; linha do asteroide 
COLUNA			EQU  0        	; coluna do asteroide
ALTURA			EQU  5		; altura do asteroide

LARGURA			EQU	5			; largura do asteroide
COR_PIXEL1			EQU	0F442H		; cor do pixel: contorno do asteroide em ARGB 
COR_PIXEL2			EQU	0F985H		; cor do pixel: preenchimento do asteroide em ARGB

; #######################################################################
; * ZONA DE DADOS 
; #######################################################################
	PLACE		0100H				

DEF_ASTEROIDE:					; tabela que define o asteroide (cor, largura, pixels)
	WORD		LARGURA
	WORD		COR_PIXEL1, COR_PIXEL2, COR_PIXEL2, COR_PIXEL2, COR_PIXEL1		;
     

; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE   0				
inicio:
     MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
     MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
     MOV  R1, 0			; cenário de fundo número 0
     MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
     
definicoes_asteroide:
     MOV  R1, LINHA		; linha do asteroide
     MOV  R2, COLUNA		; coluna do asteroide
     MOV  R3, ALTURA		; altura do asteroide

desenha_linha_asteroide:       		; desenha o asteroide a partir da tabela
     MOV	R5, DEF_ASTEROIDE	; endereço da tabela que define o asteroide
     MOV	R6, [R5]	; obtém a largura do asteroide
     ADD	R5, 2		; endereço da cor do 1º pixel (2 porque a largura é uma word)
	
desenha_linha:       		; desenha os pixels do asteroide a partir da tabela
     MOV  R4, [R5]		; obtém a cor do próximo pixel do asteroide
     MOV  [DEFINE_LINHA], R1	; seleciona a linha
     MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
     MOV  [DEFINE_PIXEL], R4	; altera a cor do pixel na linha e coluna selecionadas
     ADD  R5, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1         	; próxima coluna
     SUB  R6, 1			; menos uma coluna para tratar
     JNZ  desenha_linha 	; continua até percorrer toda a largura do asteroide
     ADD  R1, 1			; incrementa uma linha
     SUB  R2, 5			; reseta a coluna do asteroide
     SUB  R3, 1			; menos uma linha para tratar
     JNZ  desenha_linha_asteroide ; continua até percorrer a altura do asteroide

fim:
     JMP  fim                 ; termina programa 