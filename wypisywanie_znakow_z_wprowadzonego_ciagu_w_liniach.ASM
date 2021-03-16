	org 100h	; PRZESUNIECIE
	
	;Autor Jan Walczak nr indeksu 200903
	;program realizujacy zadanie 3
	
	CALL	enter	

	MOV	DX,wiad0	;wyswietlenie wiadomosci poczatkowej
	MOV	AH,9
	INT	21h
	
program:
	CALL	enter	

	MOV	DX,wiad1	;wyswietlenie prosby o podanie wyrazenia
	MOV	AH,9
	INT	21h
	CALL	enter

	MOV	DX,bufor	;pobranie max 100 znakow
	MOV	AH,0Ah
	INT	21h
	CALL	enter
	
	MOV	DX,wiad4	;"wynik"
	MOV	AH,9
	INT	21h
	CALL	enter
	
	CALL	enter
	
	CALL	wypisz	;wypisanie po jednym znaku zwielokrotnionym
	
	MOV	DX,wiad5	;wyswietlenie wiadomosci o wypisywaniu od konca
	MOV	AH,9
	INT	21h
	CALL	enter
	
	MOV	DX,wiad6	
	MOV	AH,9
	INT	21h
	CALL	enter
	
	MOV	AH,1	;pobranie znaku
	INT	21h
maley:	
	CMP	AL,'y'	;sprawdzenie czy y i ewentualne przejscie do dalszej czesci programu
	JNE	duzeY
	JMP	wykon
duzeY:	
	CMP	AL,'Y'	;sprawdzenie czy y byl wpisany z duzej litery(Wyjatek)
	JNE	dalej
wykon:	
	CALL	enter
	
	MOV	DX,wiad4	;"wynik"
	MOV	AH,9
	INT	21h
	CALL	enter
	
	CALL	wypod	;funkcja wypisujaca odwrotnie
	CALL	enter
	
dalej:
	CALL	enter
	
	MOV	DX,wiad2	;wyswietlenie wiadomosci o ewentualnym konczeniu programu
	MOV	AH,9
	INT	21h
	CALL	enter
	
	MOV	DX,wiad3	
	MOV	AH,9
	INT	21h
	CALL	enter
	
	MOV	AH,1	;pobranie znaku
	INT	21h
	CMP	AL,13	;sprawdzenie czy enter i ewentualne przejscie do konca programu
	JE	koniec
	
	CALL czysc	;wywolanie fukncji zamieniajacej wczesniej uzywane teksty na dolary
	
	JMP program	;skok do poczatku programu

koniec:	
	MOV	AX, 4C00h	; KONIEC PROGRAMU
	INT	21h

;wiadomosci
wiad0	db	'T','o',' ','p','r','o','g','r','a','m',' ','w','y','p','i','s','u','j','a','c','y',' ','p','o',' ','j','e','d','n','y','m',' ','z','n','a','k','u',',',10,13,'z',' ','c','i','a','g','u',',',' ','z','w','i','e','l','o','k','r','o','t','n','i','o','n','y','m',' ','n','u','m','e','r','e','m',' ','l','i','n','i','i','$'
wiad1	db	'P','o','d','a','j',' ','w','y','r','a','z','e','n','i','e','$'
wiad2	db	'J','e','s','l','i',' ','c','h','c','e','s','z',' ','s','k','o','n','c','z','y','c',' ','w','c','i','s','n','i','j',' ','E','n','t','e','r','$'
wiad3	db	'J','e','s','l','i',' ','n','i','e',' ','t','o',' ','w','c','i','s','n','i','j',' ','i','n','n','y',' ','p','r','z','y','c','i','s','k','$'
wiad4	db	'W','y','n','i','k',':','$'
wiad5	db	'J','e','s','l','i',' ','c','h','c','e','s','z',' ','w','y','p','i','s','a','c',' ','t','e','k','s','t',' ','o','d',' ','k','o','n','c','a',' ','w','c','i','s','n','i','j',' ','"','y','"','$'
wiad6	db	'J','e','s','l','i',' ','n','i','e',' ','t','o',' ','w','c','i','s','n','i','j',' ','i','n','n','y',' ','p','r','z','y','c','i','s','k','$'


adres	dw	0	;zmienna do przechowywanie adresu powrotu procedur

;bufor do ktorego zapisywany jest pobrany tekst
bufor	db	100
	db	0
dane1:	TIMES	102	db	"$"

;Funkcja do wypisywania entera
enter:
	MOV	AH,2
	MOV	DL,10
	INT	21h
	MOV	AH,2
	MOV	DL,13
	INT	21h
ret

;Funkcja wypelniajaca "tablice" dolarami po zakonczeniu jednego cyklu programu
czysc:
	MOV	DI,2 ;ustawiam na 2 bo pierwsze dwie lokacje odpowiadaja za rozmiar i aktualna ilosc elementow
	MOV	Bl,0	
	MOV	[bufor+1],BL	;ustawiam wartosc aktualnej ilosci znakow na zero
	MOV	BL,36	;BL=$
	
petla1:
	CMP	DI,26
	JE	koniec1	;jesli przejdzie cala "tablice" to koniec
	MOV	[bufor+DI],BL	;wypelniam dolarami bufor
	INC	DI
	JMP	petla1
koniec1:
ret

;Glowna funkcja wypisujaca po jednym znaku zwielokrotnionym o tyle ile wynosi numner linii
wypisz:
	POP	DX	;pobranie adresu powrotu
	MOV	[adres],DX
	MOV	DI,2	;perwsze dwa miejsca zajeta na dane dotyczace "tablicy"
	XOR	CX,CX	;wyzerowanie licznika wykorzystywanego w wypisywanie w jednej linii
	
petla2:
	MOV	BL,[bufor+DI]	;jesli dojdzie do pierwszego dolara to koniec
	CMP	BL,36
	JE	koniec2
	XOR	SI,SI	;zerowanie indeksu ktory wykorzystuje do wypisywania wielu znakow w tej samej linii
	
petla3:
	CMP	SI,CX	;jesli wypisana odpowiednia ilosc znakow to przejdz do wypisania entera
	JG	polinii
	MOV	AH,2
	MOV	DL,BL
	INT	21h
	INC	SI
	JMP	petla3
	
polinii:
	INC	DI
	INC	CX
	CALL	enter
	
	JMP	petla2

koniec2:
	PUSH	DI	;wrzucenie na stos wartosci oznaczajacej pozycje pierwszego dolara w pobranym tekscie
	MOV	DX,[adres]
	PUSH	DX
ret

;Funkcja wypisujaca "piramide" odwrotnie
wypod:	
	POP	DX	;pobranie adresu powrotu i zapisanie go w zmiennej
	MOV	[adres],DX
	POP	DI	;pobranie ze stosu wartosci oznaczajacej poozycje pierwszeg dolara w pobranym tekscie
	DEC	DI	;DI-- zeby miec pozycje znaku ktory chce wypisac
	MOV	CX,DI	;wyzerowanie licznika wykorzystywanego w wypisywanie w jednej linii
	SUB	CX,2
	
petla4:
	CMP	DI,1	;jesli dojdzie do pozycji ktora nie zawiera juz znaku wproadzonego przez uzytkownika to koniec
	JE	koniec4	
	MOV	BL,[bufor+DI]
	XOR	SI,SI	;zerowanie indeksu ktory wykorzystuje do wypisywania wielu znakow w tej samej linii
	
petla5:
	CMP	SI,CX	;jesli wypisana odpowiednia ilosc znakow to przejdz do wypisania entera
	JG	polin2
	MOV	AH,2
	MOV	DL,BL
	INT	21h
	INC	SI
	JMP	petla5
	
polin2:
	DEC	DI
	DEC	CX
	CALL	enter
	
	JMP	petla4

koniec4:
	
	MOV	DX,[adres]	;wrzucanie adresu powrotu do rejestru, potem na  stos
	PUSH	DX
ret