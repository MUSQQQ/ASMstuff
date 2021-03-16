	org 100h	; PRZESUNIECIE

	CALL	enter	

	MOV	DX,wiad1	;wyswietlenie prosby o podanie tekstu
	MOV	AH,9
	INT	21h

	CALL	enter

	MOV	DX,bufor	;pobranie tekstu max 25 znakow
	MOV	AH,0Ah
	INT	21h	
	
	CALL	enter
	
	MOV	DX,wiad2	;prosba o podanie przesuniecia
	MOV	AH,9
	INT	21h
	
	CALL	enter

	MOV	AH,1	;pobranie przesuniecia
	INT	21h
	MOV	[przes],AL	;zapisanie do zmiennej
	
	CALL	enter

	CALL	cezar	;wywolanie funkcji szyfrujacej

	MOV	DX,wiad3	;wyswietlenie wiadomosci "wynik"
	MOV	AH,9
	INT	21h
	
	CALL	enter	
	
	MOV	DX,bufor	;wyswietlenie zaszyforwanego tekstu
	MOV	AH,9
	INT	21h
	
	
		
	MOV	AX, 4C00h	; KONIEC PROGRAMU
	INT	21h

;wiadomosci
wiad1	db	'P','o','d','a','j',' ','l','a','n','c','u','c','h',' ','z','n','a','k','o','w','$'
wiad2	db	'P','o','d','a','j',' ','p','r','z','e','s','u','n','i','e','c','i','e','$'
wiad3	db	'W','y','n','i','k',':','$'

;przesuniecie
przes	db	0

;zmienna do ktorej zapisywany jest pobrany tekst
bufor	db	25
	db	0
dane:	TIMES	27	db	"$"

;Funkcja do wypisywania entera
enter:
	MOV	AH,2
	MOV	DL,10
	INT	21h
	MOV	AH,2
	MOV	DL,13
	INT	21h
ret

;Funkcja szyfrujaca
cezar:
	XOR	BX,BX
	MOV	BL,[bufor+1]	;ile znakow pobrano do stringa
	ADD	BL,2	;dodanie dwoch pierwszych pozycji ze stringa
	XOR	DI,DI	
	MOV	DH,[przes]	;zapisanie przesuniecia do rejestru
petla:
	MOV	CL,[bufor+DI]	;zapisanie znaku do rejestru
	CMP	CL,36	;czy dolar
	JE	koniec

	;sprawdzanie czy litera
	CMP	CL,'z'
	JA	nielit
	CMP	CL,'A'
	JB	nielit
	
	;sprawdzanie czy mala
	CMP	CL,'Z'
	JBE	mala
	
	;dalsza czesc petli
powrot:	
	ADD	CL,DH	;szyfrowanie 1
	CMP	CL,'z'
	JBE	wstaw	;jesli nadal litera to idz do kolejnego etapu

	XOR	AX,AX
	
	MOV	AL,CL
	SUB	AL,97
	MOV	CH,26
	DIV	CH	;dzielenie otrzymanego wyniku przez 26
	XOR	CH,CH
	MOV	CL,'a'	;"wyzerowanie" znaku
	ADD	CL,AH	;zaszyforwanie o wartosc reszty z dzielenia
	JMP	wstaw

	;zamiana z wielkiej na mala
mala:
	ADD	CL,32
	JMP	powrot

	;zamiana na spacje jesli nie litera
nielit:
	MOV	CL,32
	JMP	wstaw


	;koncowka petli, wstawienie zaszyfrowanego znaku do bufora
wstaw:
	
	MOV	[bufor+DI],CL
	INC	DI
	
	JMP	petla
koniec:
ret