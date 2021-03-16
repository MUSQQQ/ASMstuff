	org 100h	; PRZESUNIECIE
	
	
	MOV	BX,1	;wstawiam dzielniki na stos
	PUSH	BX
	MOV	BX,10
	PUSH	BX
	MOV	BX,100
	PUSH	BX
	MOV	BX,1000
	PUSH	BX
	MOV	BX,10000
	PUSH	BX
	XOR	BX,BX
	
	CALL	enter

	MOV	AH,1	;pobieram cyfre
	INT	21h
	XOR	AH,AH	;wyzerowanie ah, zeby w ax zostala sama pobrana "cyfra"
	PUSH	AX	;wrzucam na stos
	XOR	AX,AX
	
	CALL	enter
	CALL	silnia	;"zawolanie" funkcji
	
	
	CALL	wypis
	CALL	wypis
	CALL	wypis
	CALL	wypis
	CALL	wypis
	
	MOV	AX, 4C00h	; KONIEC PROGRAMU
	INT	21h



enter:

	MOV	AH,2
	MOV	DL,10	;wypisanie entera
	INT	21h
	
	MOV	AH,2
	MOV	DL,10
	INT	21h
	
	XOR	AX,AX
ret

silnia:
	POP	CX	;adres powrotu (dla ret)
	XOR	AX,AX
	XOR	BX,BX
	POP	BX	;pobranie "cyfry" ze stosu
	SUB	BX,48	;trzeba odjac!!!
	
	MOV	AX,1

			;tutaj jest okej. pobiera dobre wartosci	
	petla:
	CMP	BX,0	;porownanie zeby uniknac mnozenia przez zero
	JE	koniec
	MUL	BX	;mnozenie(nie obchodzi mnie rejestr DX bo wartosc zmiesci sie w AX)
	SUB	BX,1	;zmniejszenie liczby prze ktora mnoze
	
	JMP	petla
	
	koniec:

	PUSH	AX	;wrzucenie na stos
	PUSH	CX	;wrzucenie na stos adresu powrotu
ret
wypis:
	POP	CX	;adres powrotu
	XOR	DX,DX	;rejestr dx jest potrzebny w przypadku dzielenia
	XOR	AX,AX
	POP	AX	;pobranie wyniku silni
	XOR	BX,BX
	POP	BX	;pobranie najwiekszego aktualnie dzielnika
	
		
	DIV	BX	;dzielenie
	PUSH	DX	;zapamietanie reszty(do pozniejszych dzielen)

	ADD	AL,48	;wypisanie otrzymanej reszty
	MOV	AH,2	
	MOV	DL,AL
	INT	21h
	PUSH	CX	;adres powrotu
ret