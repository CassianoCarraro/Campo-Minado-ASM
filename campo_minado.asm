name "campo_minado"
.model small

.data
	matsize equ 5
	msg_nivel db "Selecione o nivel desejado",10,13,"1-Facil",10,13,"2-Dificil",10,13,"$"
	msg_linha db "Linha:",10,13,"$"
	msg_coluna db 10,13,"Coluna:",10,13,"$"
	msg_parabens db "PARABENS!$"
	msg_perdeu db "PERDEU!$"
	mat db 25 dup('0')
	mat_tela db 25 dup('?')
	dificuldade db 0
.code
mov ax, @data ; Move o endereco do segmento de dados para AX
mov ds, ax ; Seta o segmento de dados do programa no DS

mov dx, offset msg_nivel ; Move o endereco inicial da mensagem para escolha de nivel
call PRINTFDB
call SCANFDIF
call GERARBOMB

laco_jogo:
lea di, mat_tela ; Seta o DI com a posicao inicial do endereco da matriz de tela
call MOSTRAMAT

mov dx, offset msg_linha ; Move o endereco inicial da mensagem para informar a linha
call PRINTFDB
call SCANF
push ax

mov dx, offset msg_coluna ; Move o endereco inicial da mensagem para informar a coluna
call PRINTFDB
call SCANF
push ax

pop bx ; Desimpilha o valor lido para coluna no BX
pop ax ; Desempilha o valor lido para linha no AX
mov ah, bl ; Valor adiciona o valor da coluna no AH, AL tera o valor da linha

call LIBERACAMPO
cmp dl, 1 ; Verifica se bomba foi encontrada
je bomba_encontrada ; Se bomba foi encontrada jogo e finalizado com mensagem de derrota

call VERFIMJOGO
cmp dl, 1 ; Verifica se todos os campos livres ja foram descobertos
je fim_jogo ; Se todos os campos foram descobertos jogo e finalizado com mensagem de vitoria

jmp laco_jogo ; Laco principal do jogo que voltar a solicitar para o usuario digitar linha e coluna ate que o jogo seja finalizado

bomba_encontrada:
call FIMJOGOBOMBA
jmp fim

fim_jogo:
call FIMJOGO
jmp fim

fim:
.exit

LIBERACAMPO PROC ; AL = linha, AH = coluna, DL = retorno se uma bomba foi encontrada
	pusha

	dec al ; Descrementa 1 em AL para realizar o calculo de deslocamento
	mov bh, ah ; Move o valor da coluna AH para BH, pois a multiplicacao modificara o valor
	mov bl, matsize ; Move o valor do tamanho da matriz para bl para a multiplocacao
	mul bl
	dec bh ; Decrementa 1 em BH para realizar o calculo de deslocamento
	add al, bh ; Obtem o deslocamento pelo valor da coluna - 1 adicionado ao valor da linha - 1 multiplicado pelo tamanho da matriz
	mov ah, 0

	lea di, mat
	add di, ax ; Deslocamento
	cmp ds:[di], '1' ; Verifica se ha bomba na posicao indicada
	je encontrou_bomba ; Se encontrou bomba retorna
	lea di, mat_tela ; Seta o endereco da matriz de tela no DI
	add di, ax ; Realiza calculo de deslocamento
	mov ds:[di], '0' ; Seta 0 no local livre
	jmp fim_liberacampo
	encontrou_bomba:
	popa
	mov dl, 1 ; Retorno identificando que foi encontrado uma bomba
	ret
	fim_liberacampo:
	popa
	mov dl, 0 ; Retorno identificando que nao foi encontrado uma bomba
	ret
LIBERACAMPO endp

VERFIMJOGO PROC ; Procedimento verifica se todos os campos livres foram descobertos um booleano e retornado no registrador DL
	pusha

	mov dx, 0 ; Inicializa dx com 0 para ser utilizado como deslocamento
	mov cx, matsize ; Inicializa registrador para laço

	laco_linha_ver:
	push cx ; Empilha valor armazenado no cx do laço linha

	mov cx, matsize ; Inicializa registrador para laço
	laco_coluna_ver:

	lea di, mat ; Seta o DI com o endereco da matriz
	add di, dx ; Realiza o calculo de deslocamento
	mov al, ds:[di] ; Move o valor da matriz para AL
	lea di, mat_tela ; Seta o DI com o endereco da matriz da tela
	add di, dx ; Realiza o calculo de deslocamento
	mov bl, ds:[di] ; Move o valor da matriz para BL

	cmp al, '0' ; Verifica se o campo e livre
	jne continua ; Se nao for livre pula a verificacao

	cmp al, bl ; Se for livre compara se o valor da tela e igual a matriz original
	jne campo_livre_n_revelado ; Se nao for igual ha campos livres que ainda nao foram descobertos

	continua:
	add dl, 1 ; Avanca 1 posicao no acesso a matriz
	loop laco_coluna_ver

	pop cx ; Desempilha valor armazenado do laço linha
	loop laco_linha_ver

	popa
	mov dl, 1 ; Seta DL como 1 indicando que todos os campos livres foram descobertos
	ret

	campo_livre_n_revelado:
	pop cx ; Desempilha o cx
	popa
	mov dl, 0 ; Seta DL como 0 indicando que ha campos a serem descobertos
	ret
VERFIMJOGO endp

FIMJOGO PROC
	call CLS

	lea di, mat ; Seta o DI com a posicao inicial do endereco da matriz
	call MOSTRAMAT

	mov dx, offset msg_parabens
	call PRINTFDB

	ret
FIMJOGO endp

FIMJOGOBOMBA PROC
	call CLS

	lea di, mat ; Seta o DI com a posicao inicial do endereco da matriz
	call MOSTRAMAT

	mov dx, offset msg_perdeu
	call PRINTFDB

	ret
FIMJOGOBOMBA endp

MOSTRAMAT PROC ; Adicionar o endereco da matriz no DI para impressao
	pusha

	mov cx, matsize ; Inicializa registrador para laço

	laco_linha:
	mov dh, matsize ; Seta o tamanho da matriz do DH
	inc dh ; Incrementa 1 na linha para cabecalho
	sub dh, cl ; Diminui o valor pelo tamanho da matriz para se obter a linha correta para impressao (Ex: estado inicial cx=5,dh=0)

	mov dl, 0 ; Move a coluna para pos 0 para impressao do cabecalho
	mov al, dh ; Move a lina atual para AL para ser impressa na tela
	add al, 48d ; Adiciona 48 inicio dos caracteres da tabela ASCII
	call PRINTFA

	push cx ; Empilha valor armazenado no cx do laço linha

	mov cx, matsize
	laco_coluna:
	mov dl, matsize ; Seta o tamanho da matriz do DH
	inc dl
	sub dl, cl ; Diminui o valor pelo tamanho da matriz para se obter a coluna correta para impressao (Ex: estado inicial cx=5,dh=0)

	push dx ; Empilha o valor de dx pois sera alterado para impressao do cabecalho
	mov dh, 0 ; Move o DH (linha) para 0
	mov al, dl ; Move a coluna atual para AL para ser impressa na tela
	add al, 48d ; Adiciona 48 inicio dos caracteres da tabela ASCII
	call PRINTFA
	pop dx

	mov al, ds:[di] ; Adiciona o caractere da matriz tela no registrador para impressao

	call PRINTFA ; Chama procedimento de impressao na tela

	add di, 1 ; Avanca 1 posicao no acesso a matriz
	loop laco_coluna

	pop cx ; Desempilha valor armazenado do laço linha
	loop laco_linha

	inc dh
	call QUEBRALINHA

	popa

	ret
MOSTRAMAT endp

SCANF PROC ; Le um inteiro e armazena o valor no AL
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
	mov al, bl ; Move o resultado lido para AL
	mov ah, 0

	ret
SCANF endp

PRINTFA PROC ; Imprime na tela caracteres da tabela ASCII (AL identifica o caractere DH linha da tela e DL coluna)
	pusha
	mov ah, 2h ; Move o 2h para o AH para setar a posicao do cursor na tela
	int 10h ; Realiza a interrupcao

	mov ah, 0eh ; Move o 0eh para AH para realizar a impressao do caractere ASCII
	int 10h ; Realiza a interrupcao
	popa

	ret
PRINTFA endp

PRINTFDB PROC ; Imprime na tela mensagens declaradas no segmento de dados (DX deve ser o endereco inicial da msg)
	pusha

	mov ah, 9
	int 21h
	popa

	ret
PRINTFDB endp

RANDNUMB PROC
	pusha

	mov ah, 2ch ; Move o valor 2CH para o registrador AH para pegar a hora do sistema
	int 21h ; Realiza a interrupcao
	mov al, dl ; Move o valor DL correspondente a 1/100 segundos para o AL
	mov dx, 0 ; Zera o DX que recebera o resultado do resto da divisao
	mov bx, 25d ; Move o 25 para o BX que sera utilizado como denominador da divisao
	div bx ; Realiza a divisao pelo valor em BX o numero pseudo aleatorio ficara no registrador DX
	mov di, dx ; Move a posição aleatoria gerada para DI
	lea ax, mat ; Carrega o endereco para ax
	add di, ax ; Deslocamento
	mov ds:[di], '1' ; Seta 1 indicando que existe bomba nessa posicao por meio do deslocamento do endereco efetivo da mat + posicao aleatoria gerada
	popa

	ret
RANDNUMB endp

SCANFDIF PROC
	pusha
	mov dl, 10
	mov bl, 0

	scanDig:
		mov ah, 01h ; Aciona modo de leitura de caracteres resultado sera armazenado no AL
		int 21h ; Realiza a interrupcao para a leitura dos caracteres
		cmp al, 49 ; Compara o valor digitado no input com o cod do modo facil(1)
		je  scanDig ;  Pula para a rotina de guardar a dificuldade facil
		cmp al, 50 ; Compara o valor digitado no input com o cod do modo dificil(2)
		je  dif_dificil ; Pula para a rotina de guardar a dificuldade dificil
		cmp al, 13 ; Compara o valor digitado no input com o ENTER
		je  limpa_tela ; Se for ENTER pula para o label f
		jmp scanDig
		dif_dificil:
		mov dificuldade, 1
		jmp scanDig
		limpa_tela:
		call CLS
		popa
		ret
SCANFDIF endp

CLS PROC
	mov ax, 2h ; Move 2h para limpar a tela
	int 10h ; Realiza interrupcao

	ret
CLS endp

QUEBRALINHA PROC ; Bloco de comandos para impressao da quebra de linha
	mov al, 10
	call PRINTFA
	mov al, 13
	call PRINTFA

	ret
QUEBRALINHA endp

GERARBOMB PROC
	pusha
	cmp dificuldade, 0 ; Verifica se e o modo facil
	je facil
	cmp dificuldade, 1 ; Verifica se e o modo dificil
	je dificil
	facil:
		mov cx,5
	dificil:
		mov cx,15
	push cx
	gera_numero:
		call RANDNUMB ; Realiza o procedimento de numero pseudo aleatorio e coloca na matriz nao visivel
		loop gera_numero
	pop cx
	popa
	ret
GERARBOMB endp