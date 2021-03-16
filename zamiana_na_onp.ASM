	org 100h	; PRZESUNIECIE

	CALL	enter	

	MOV	DX,wiad1	;wyswietlenie prosby o podanie wyrazenia
	MOV	AH,9
	INT	21h

	CALL	enter

	MOV	DX,bufor	;pobranie max 25 znakow
	MOV	AH,0Ah
	INT	21h	
	
	CALL	enter
	
	
	

	CALL	onp	;wywolanie funkcji szyfrujacej

	MOV	DX,wiad3	;wyswietlenie wiadomosci "wynik"
	MOV	AH,9
	INT	21h
	
	CALL	enter	
	
	MOV	DX,wynik	;wyswietlenie wyrazenia w onp
	MOV	AH,9
	INT	21h
	
	CALL	enter	
	
	MOV	DX,wiad3	;wyswietlenie wiadomosci "wynik"
	MOV	AH,9
	INT	21h
	
	CALL	enter	
	
	CALL	oblicz	;funkcja obliczajaca wartosc wyrazenia
	
	CALL	wypis	;wypisanie wartosci
	
	MOV	AX, 4C00h	; KONIEC PROGRAMU
	INT	21h

;wiadomosci
wiad1	db	'P','o','d','a','j',' ','w','y','r','a','z','e','n','i','e','$'

wiad3	db	'W','y','n','i','k',':','$'

wartosc	dw	0

;zmienna do ktorej zapisywany jest pobrany tekst
bufor	db	25
	db	0
dane1:	TIMES	27	db	"$"

;wersja dla onp
wynik	db	25
	db	0
dane2:	TIMES	27	db	"$"

;Funkcja do wypisywania entera
enter:
	MOV	AH,2
	MOV	DL,10
	INT	21h
	MOV	AH,2
	MOV	DL,13
	INT	21h
ret

;Funkcja zamieniajaca na onp
onp:
	POP	CX	;adres powrotu
	XOR	DX,DX
	XOR	DI,DI
	MOV	DI,2	;indeksator
	XOR	SI,SI	;licznik dla wyniku
	
	XOR	BP,BP	;licznik znakow na stosie
petla:
	
	
	MOV	AL,[bufor+DI]
	CMP	AL,36	;jesli $ to koniec
	JE koniec
	;porownywanie i ocenianie ktora sytuacja zachodzi
	CMP	AL,41	
	JE nawiask
	CMP	AL,40
	JE	inne
	CMP	AL,'+'
	JE	inne
	CMP	AL,'*'
	JE	inne
	JMP	cyfry
	
nawiask:	;gdy prawy nawias
	
petla2:
	
	
	CMP	BP,0
	JE	skok
	POP	BX
	
	MOV	[wynik+SI],BL
	INC	SI
	DEC	BP
	
	JMP	petla2
	
	JMP	skok
	
inne:	;gdy inny znak poza cyframi i )

	CMP	AL,40	;gdy ( to nic sie nie dzieje
	JE	skok
	
	CMP	AL,'+'	; gdy nie + to po prostu dodanie na stos
	JNE	kont2
	
	;gdy + to sprawdzam czy wczesniej sa znaki * by zachowac kolejnosc dzialan
petlax:
	POP	BX
	CMP	BL,'*'
	JNE	kont1
	
	MOV	[wynik+SI],BL
	INC	SI	
	DEC	BP	;zmniejszenie ilosci znakow na stosie
	JMP	petlax
kont1:
	PUSH	BX
kont2:
	MOV	BX,[bufor+DI]
	
	XOR	DH,DH
	PUSH	BX	
	INC	BP
	JMP	skok
	
	;cyfry dodaje do zmiennej wynik
cyfry:
	MOV	BH,[bufor+DI]
	MOV	[wynik+SI],BH
	INC	SI
	JMP	skok

skok:	INC DI
		JMP petla
koniec:
	
	
	;gdy dojdzie do konca to przenosi pozostale znaki ze stosu do wyniku
	
	DEC	SI		;?
	
	petla3:
	CMP	BP,0
	JE	koniec2
	POP	BX
	
	
	MOV	[wynik+SI],BL
	INC	SI
	DEC	BP
	JMP	petla3
koniec2:	
	PUSH CX	;adres powrotu na stos
ret	

;OBLICZANIE WARTOSCI WYRAZENIA

oblicz:
	POP	CX	;adres powrotu
	MOV	SI,0
	
	XOR	BX,BX
	
petla5:
	
	MOV	BL,[wynik+SI]
	
	CMP	BL,36	;jesli $ to koniec
	JE	koniec3
	;sprawdzenie jaka operacja
	CMP	BL,'+'
	JE	dod
	CMP	BL,'*'
	JE	mnoz
	SUB	BX,48	;zeby wypisalo w systemie dziesietnym
	PUSH	BX	;jesli cyfra to wloz na stos
	INC	SI
	JMP	petla5
	;dodanie dwoch kolejnych liczb ze stosu
dod:
	POP	BX	
	POP	AX
	ADD	AX,BX
	
	PUSH	AX	;dodanie wyniku na stos
	INC	SI
	JMP	petla5
	;mnozenie dwoch kolejnych liczb ze stosu
mnoz:
	POP	BX
	POP	AX
	MUL	BX
	PUSH	AX	;dodanie wyniku na stos
	INC	SI
	JMP	petla5
koniec3:
	POP	AX
	
	MOV	[wartosc],AX
	PUSH	CX	;adres powrotu
ret

wypis:
	
	
	
	MOV	CX,100	;dzielnik 1
	XOR	DX,DX
	
	MOV	BX,[wartosc]
	MOV	AX,BX
	DIV	CX
	
	MOV	BX,DX	;przeniesienie reszty bo inaczej zostanie stracoa podczas wypisywania
	
	ADD	AL,48
	MOV	AH,2
	MOV	DL,AL
	INT	21h
	
	XOR	DX,DX
	
	
	MOV	AX,BX	;przeniesienie reszty do ax w celu kolejnego dzielenia
	
	MOV	CX,10	;dzielnik 2
	DIV	CX
	
	MOV	BX,DX	;przeniesienie
	
	ADD	AL,48
	MOV	AH,2
	MOV	DL,AL
	INT	21h
	
	XOR	DX,DX
	
	MOV	AX,BX	;przeniesienie
	
	ADD	AL,48
	MOV	AH,2
	MOV	DL,AL
	INT	21h
	
	
	
ret