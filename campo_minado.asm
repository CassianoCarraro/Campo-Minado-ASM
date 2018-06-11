name "campo_minado"

main:
	mov ax, 3     ; Modo de texto 80x25
	int 10h       ; Interrupção para abrir console

jmp d_campo_minado
jmp fim

d_campo_minado: 
	mov ax, 0b800h ; Seta o valor 800h no registrador ax para acessar o dipositivo VGA
	mov ds, ax ; Seta o ax no registrador de segmento de dados
	
	mov cx, 5 ; Inicializa registrador para laço
	laco_linha:
		push cx ; Empilha valor armazenado no cx do laço linha

		mov cx, 5
		mov ax, 0f31h
		laco_coluna:
			mov [bx], ax
			add bx, 8
			add al, 1
		loop laco_coluna
		
		add bx, 120 ; Pula 150 (75 * 2) bytes para quebrar a linha da tela
		pop cx ; Desempilha valor armazenado do laço linha

	loop laco_linha

fim:
ret