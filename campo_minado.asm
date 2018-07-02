name "campo_minado"

.data
    matsize equ 5

.code
;mov ax, 3     ; Modo de texto 80x25
;int 10h       ; Interrupção para abrir console

;jmp d_campo_minado

;d_campo_minado:
;mov ax, 0b800h ; Seta o valor 800h no registrador ax para acessar o dipositivo VGA
;mov ds, ax ; Seta o ax no registrador de segmento de dados

;CALL INITMAT
;add bx, 120 ; Pula 150 (75 * 2) bytes para quebrar a linha da tela
;pop cx
;fim:
;ret

CALL INITMATTELA
CALL MOSTRAMAT
CALL SCANF
;CALL INITMAT
;CALL RANDNUMB
.exit

INITMAT PROC
	pusha
    mov ax, @data
    mov ds, ax
    mov di, 0d ; Seta o DI como 0 posicao inicial da primeira matriz

    mov cx, matsize ; Inicializa registrador para laço
    laco_linha:
    push cx ; Empilha valor armazenado no cx do laco linha

    mov cx, matsize
    laco_coluna:
    mov ds:[di], 0 ; Adiciona o valor 0 indicando a posicao inicial da primeira matriz
    add di, 1 ; Avanca 1 posicao no acesso a matriz
    loop laco_coluna

    pop cx ; Desempilha valor armazenado do laço linha

    loop laco_linha
    popa

    ret
INITMAT endp

INITMATTELA PROC
	pusha
	mov ax, @data ; Move o endereco do segmento de dados para AX
    mov ds, ax ; Inicializa o DS com o valor de AX
    mov di, 25d ; Seta o valor 25 indicando a posicao inicial da segunda matriz

    mov cx, matsize ; Inicializa registrador para laço
    laco_linha2:
    push cx ; Empilha valor armazenado no cx do laço linha

    mov cx, matsize
    laco_coluna2:
    mov ds:[di], '?' ; Adiciona o valor ? na posicao de memoria alocada para a matriz
    add di, 1 ; Avanca 1 posicao no acesso a matriz
    loop laco_coluna2

    pop cx ; Desempilha valor armazenado do laço linha
    loop laco_linha2
    popa

    ret
INITMATTELA endp

MOSTRAMAT PROC
	pusha
	mov ax, @data ; Move o endereco do segmento de dados para AX
    mov ds, ax ; Inicializa o DS com o valor de AX
    mov di, 25d ; Seta o valor 25 indicando a posicao inicial da segunda matriz

    mov cx, matsize ; Inicializa registrador para laço
    laco_linha3:
    mov dh, matsize ; Seta o tamanho da matriz do DH
    sub dh, cl ; Diminui o valor pelo tamanho da matriz para se obter a linha correta (Ex: estado inicial cx=5,dh=0)
    push cx ; Empilha valor armazenado no cx do laço linha

    mov cx, matsize
    laco_coluna3:
    mov dl, matsize ; Seta o tamanho da matriz do DH
    sub dl, cl ; Diminui o valor pelo tamanho da matriz para se obter a coluna correta (Ex: estado inicial cx=5,dh=0)
    mov al, ds:[di] ; Adiciona o caractere da matriz tela no registrador para impressao

    CALL PRINTFA ; Chama procedimento de impressao na tela

    add di, 1 ; Avanca 1 posicao no acesso a matriz
    loop laco_coluna3

    pop cx ; Desempilha valor armazenado do laço linha
    loop laco_linha3
	popa

	ret
MOSTRAMAT endp

SCANF PROC
mov dl, 10
mov bl, 0

scanNum:
	mov ah, 01h ; Aciona modo de leitura de caracteres resultado sera armazenado no AL
	int 21h ; Realiza a interrupcao para a leitura dos caracteres
	cmp al, 13 ; Compara o valor digitado no input com o cod do ENTER(13)
	je  f ; Se for ENTER pula para o label f
	mov ah, 0
	sub al, 48 ; Subtrai o cod ASCII digitado por 48 que representa 0 na tabela ASCII
	mov cl, al ; Move o resultado da subtracao para CL
	mov al, bl ; Move o resultado anterior para AL
	mul dl ; Realiza a multiplicacao por 10 pois uma nova casa decimal foi adicionada no numero
	add al, cl ; Soma o resultado anterior com o novo digito
	mov bl, al ; Move o valor final para BL
	jmp scanNum
	f:
	mov ax, 2h ; Move 2h para limpar a tela
	int 10h ; Realiza interrupcao
	mov al, bl ; Move o resultado lido para AL
	mov ah, 0

	ret
SCANF endp

;PRINTF PROC
;	mov dx, 0
;	mov ah, 0
;	cmp ax, 0
;	jne print_ax_r
;	push ax
;	mov al, '0'
;	mov ah, 0Eh
;	int 10h
;	pop ax
;
;	ret
;
;	print_ax_r:
;	pusha
;	mov dx, 0
;	cmp ax, 0
;	je pn_done
;	mov bx, 10
;	div bx
;	call print_ax_r
;	mov ax, dx
;	add al, 30h
;	mov ah, 0eh
;	int 10h
;	jmp pn_done
;	pn_done:
;	popa
;
;	ret
;PRINTF endp

PRINTFA PROC ; Imprime na tela caracteres da tabela ASCII (AL identifica o caractere DH linha da tela e DL coluna)
	pusha
	mov ah, 2h ; Move o 2h para o AH para setar a posicao do cursor na tela
	int 10h ; Realiza a interrupcao

	mov ah, 0eh ; Move o 0eh para AH para realizar a impressao do caractere ASCII
	int 10h ; Realiza a interrupcao
	popa

	ret
PRINTFA endp

RANDNUMB PROC
    mov ah, 2ch ; Move o valor 2CH para o registrador AH para pegar a hora do sistema
    int 21h ; Realiza a interrupcao
    mov al, dl ; Move o valor DL correspondente a 1/100 segundos para o AL
    mov dx, 0 ; Zera o DX que recebera o resultado do resto da divisao
    mov bx, 25d ; Move o 25 para o BX que sera utilizado como denominador da divisao
    div bx ; Realiza a divisao pelo valor em BX o numero pseudo aleatorio ficara no registrador DX

    ret
RANDNUMB endp