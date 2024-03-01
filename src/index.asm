.386
.MODEL FLAT, stdcall
include c.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\comctl32.lib

_DATA SEGMENT
	STR1 		DB "ver8",0
	STR2 		DB "Version Of Program",0
	VRSCROLLMES 	DB "VSCROLL OK",0
	HRSCROLLMES 	DB "HSCROLL OK",0
	version		db 'ver8',0
	MSGSTRUCT <?>
	HINST 		DD 0						;дескриптор приложения
	PA 			DB 'DIAL1',0
	PD			DB 'DIAL2',0
	PMENU DB "MENUP",0
											;таблица для создания горячих клавиш
	 TAB	db 0,1,2,3,4,5,6,7				;8-backspace 9-capsLock
		 db 10,11,12,14,15,16,17,18,19,20	;13-enter
		db 21,22,23,24,25,26,27,28,29,30,31
		DB 32,33,34,35,36,37,38,39,40
		DB 41,42,43,45,47,58,59,60			;48 - нуль;   49 - единица;   44 - запятая;    46 - точка
		DB 61,62,63,64,65,66,67,68,69,70
		DB 71,72,73,74,75,76,77,78,79,80
		DB 81,82,83,84,85,86,87,88,89,90
		DB 91,92,93,94,95,96,97,98,99,100
		DB 101,102,103,104,105,106,107,108,109,110
		DB 111,112,113,114,115,116,117,118,119,120
		DB 121,122,123,124,125,126,127,128,129,130
		DB 131,132,133,134,135,136,137,138,139,140
		DB 141,142,143,144,145,146,147,148,149,150
		DB 151,152,153,154,155,156,157,158,159,160
		DB 161,162,163,164,165,166,167,168,169,170
		DB 171,172,173,174,175,176,177,178,179,180
		DB 181,182,183,184,185,186,187,188,189,190
		DB 191,192,193,194,195,196,197,198,199,200
		DB 201,202,203,204,205,206,207,208,209,210
		DB 211,212,213,214,215,216,217,218,219,220
		DB 221,222,223,224,225,226,227,228,229,230
		DB 231,232,233,234,235,236,237,238,239,240
		DB 241,242,243,244,245,246,247,248,249,250
		DB 251,252,253,254,255
		
											;флаги и проч...		
	id_buttom		dw 0
	keyboard_flag	dw 0
	keyboard_sign_flag	dw 0
	compare_flag	dd 0
	notznak		db ' ',0
	DIV0			DB 'недопустимая операция!',0
	NOL			DB '0',0
	podcherc		db '-----------------------------',0
	operac		db ' ',0
											;переменная размерности больших чисел
	h_variable_dimension	dd 0
											;постоянная для заменны данных
	zeroReg 		dq 0,0,0,0,0,0,0,0,0,0,0,0
											;HEXtoDECtoHEX преобразования ... группа переменных 
	hexbase		dq 1,0,0,0,0,0,0,0,0,0,0,0
	h64cf			dd 0					;carry flag
											;для вычисления группа переменных 
	kex64bit1		dq 0,0,0,0,0,0,0,0,0,0,0,0
	  hex64bit1znak	dd 0
	kex64bit2		dq 0,0,0,0,0,0,0,0,0,0,0,0
	  hex64bit2znak	dd 0
	kex64bitresult	dq 0,0,0,0,0,0,0,0,0,0,0,0
											;с плавающей точкой
	r1float		dq 0,0,0,0,0,0,0,0,0,0,0,0
	r2float		dq 0,0,0,0,0,0,0,0,0,0,0,0
	floatres		dq 0,0,0,0,0,0,0,0,0,0,0,0

	
											;для вычитания	группа переменных 
	kex64bit2v		dq 0,0,0,0,0,0,0,0,0,0,0,0
	zaem			dd 0
											;для умножегия	группа переменных 
	multex		dq 0,0,0,0,0,0,0,0,0,0,0,0
											;для деления группа переменных 
	rezult  		dq 0,0,0,0,0,0,0,0,0,0,0,0 	;- конечный результат
	ost 			dq 0,0,0,0,0,0,0,0,0,0,0,0 	;- предыдущий результат
	reg2  			dq 0,0,0,0,0,0,0,0,0,0,0,0  ; делитель
	eax_h			dq 0,0,0,0,0,0,0,0,0,0,0,0  ; вспомогательная перевенная
	ebx_h			dq 0,0,0,0,0,0,0,0,0,0,0,0	; вспомогательная перевенная
	ebx_10		dq 16,0,0,0,0,0,0,0,0,0,0,0 	;для домножения
	esi_h			dq 0,0,0,0,0,0,0,0,0,0,0,0 	; вспомогательная деления
	
	rez			dd 0						;количество вычитаний из ost значенияя reg2
	p_dek			dd 0					;предыдущий результ количества  раз домножений значения reg2 на 10
	dek			dd 0						;этот результат домножений на 10
	flag_ostZero		dd 0
											;---end

	TEXT			DB 300 DUP(0)
	TEXT_TWO		DB 300 DUP(0)
	RESULT			DB 300 DUP(0)
	stringlb		DB 300 DUP(0)
	
	
	HANDLE DD ?
	NMUTEX DB "mutex133",0
_DATA ENDS

_TEXT SEGMENT
	START:
	
	PUSH OFFSET NMUTEX
	PUSH 1
	PUSH 0
	CALL CreateMutexA@12					;создать объект mutex
	cmp eax,0								;проверка на ошибку
	jz _EXIT
	call GetLastError@0						;проверим, нет ли уже созданного объекта с таким именем
	cmp eax,ERROR_ALREADY_EXISTS
	JZ _EXIT
	
	CALL InitCommonControls@0
											;получить ID приложения
	PUSH 0
	CALL GetModuleHandleA@4
	MOV [HINST],EAX

	PUSH 0
	PUSH OFFSET WNDPROC
	PUSH 0
	PUSH OFFSET PA
	PUSH [HINST]
	CALL DialogBoxParamA@20
	CMP EAX,-1
	JNE KOL

	KOL:
	PUSH 0
	CALL ExitProcess@4
	

											;процедура окна
											; 014h - LPARAM   
											; 010h - WPARAM   
											; 0Ch - MES  
											; 08h - HWND
WNDPROC PROC
		PUSH EBP
		MOV EBP,ESP
		PUSH EBX
		PUSH ESI
		PUSH EDI

		CMP DWORD PTR [EBP+0CH], WM_COMMAND
		JNE WMCLOSE
											;menu->file->exit		
		CMP WORD PTR [EBP+10h], 107			;нажата ли подменю эксит
		JE closewin
											;menu->?	
		CMP WORD PTR [EBP+10h], 105;
		JnE notmenufix
		PUSH 0								;MB_OK
		PUSH OFFSET STR2
		PUSH OFFSET STR1
		PUSH 0
		CALL MessageBoxA@16
		notmenufix:



		



		
;---------  LAST MODIFIED AND MAY BE NOT WORK -------------------		
		; cmp     DWORD PTR [EBP+0CH], WM_VSCROLL
        ; JNE      notWmvScroll
		; PUSH 0								;MB_OK
		; PUSH OFFSET VRSCROLLMES
		; PUSH OFFSET VRSCROLLMES
		; PUSH 0
		; CALL MessageBoxA@16
        ; cmp     DWORD PTR [EBP+0CH], WM_HSCROLL
        ; JNE      notWmvScroll
		; PUSH 0								;MB_OK
		; PUSH OFFSET VRSCROLLMES
		; PUSH OFFSET VRSCROLLMES
		; PUSH 0
		; CALL MessageBoxA@16
		
		; notWmvScroll:
;---------   LAST MODIFIED AND MAY BE NOT WORK -------------------			









		; menu->?	
		CMP WORD PTR [EBP+10h], 109;
		JnE notmenufix2		
	PUSH 0
	PUSH OFFSET WNDPROC
	PUSH 0
	PUSH OFFSET PD
	PUSH [HINST]
	CALL DialogBoxParamA@20
	CMP EAX,-1
	JNE KOL2
	KOL2:
	PUSH 0
	CALL ExitProcess@4
	notmenufix2:
											;нажата ли кнопка '+'
		CMP WORD PTR [EBP+10h],6			;нажата ли кнопка?
		jne cp1
		mov ebx,2bh
		mov dword ptr[operac],ebx			; +
		mov word ptr[keyboard_flag],1
		cmp word ptr[keyboard_sign_flag],1 	;цифровая клавиши нажата...
		jne flag
		jmp pokaz
		cp1:
											;нажата ли кнопка '-'
		CMP WORD PTR [EBP+10h],10			;нажата ли кнопка?
		jne cp2
		mov ebx,2dh
		mov dword ptr[operac],ebx			; -
		mov word ptr[keyboard_flag],1
		cmp word ptr[keyboard_sign_flag],1 	;цифровая клавиши нажата...
		jne flag
		jmp pokaz
		cp2:
											;нажата ли кнопка 'X'  78h
		CMP WORD PTR [EBP+10h],11			;нажата ли кнопка?
		jne cp3
		mov ebx,78h
		mov dword ptr[operac],ebx			; x
		mov word ptr[keyboard_flag],1
		cmp word ptr[keyboard_sign_flag],1 	;цифровая клавиши нажата...
		jne flag
		jmp pokaz
		cp3:
											;нажата ли кнопка '/'   2fh
		CMP WORD PTR [EBP+10h],12			;нажата ли кнопка  /  ?
		jne cp4
		mov ebx,2fh
		mov dword ptr[operac],ebx	; /
		mov word ptr[keyboard_flag],1
		cmp word ptr[keyboard_sign_flag],1 	;цифровая клавиши нажата...
		jne flag
		jmp pokaz
		cp4:
	
											;нажата ли кнопка '='
		CMP WORD PTR [EBP+10h],17			;нажата ли кнопка =   ?
		JnE cp5;
		cmp word ptr[keyboard_sign_flag],1 	;цифровая клавиши нажата...
		je POKAZ
		jmp rauno
		cp5:
											;нажата ли кнопка '+/-'
		CMP WORD PTR [EBP+10h],18			;нажата ли кнопка +/-   ?
		JE znalplusminus					;POKAZ
											;нажата ли кнопка '1'
		CMP WORD PTR [EBP+10h],21			;нажата ли кнопка 1  ?
		JE button1		
											;нажата ли кнопка '2'
		CMP WORD PTR [EBP+10h],22			;нажата ли кнопка 2 ?
		JE button2	
											;нажата ли кнопка '3'
		CMP WORD PTR [EBP+10h],23			;нажата ли кнопка 3 ?
		JE button3
											;нажата ли кнопка '4'
		CMP WORD PTR [EBP+10h],24			;нажата ли кнопка 4?
		JE button4
											;нажата ли кнопка '5'
		CMP WORD PTR [EBP+10h],25			;нажата ли кнопка 5 ?
		JE button5
											;нажата ли кнопка '6
		CMP WORD PTR [EBP+10h],26			;нажата ли кнопка 6 ?
		JE button6
											;нажата ли кнопка '7'
		CMP WORD PTR [EBP+10h],27			;нажата ли кнопка 7 ?
		JE button7
											;нажата ли кнопка '8'
		CMP WORD PTR [EBP+10h],28			;нажата ли кнопка 8?
		JE button8
											;нажата ли кнопка '9'
		CMP WORD PTR [EBP+10h],29			;нажата ли кнопка 9 ?
		JE button9
											;нажата ли кнопка '0'
		CMP WORD PTR [EBP+10h],19			;нажата ли кнопка 0 ?
		JE button0
											;нажата ли кнопка ','
		CMP WORD PTR [EBP+10h],44			;нажата ли кнопка 0 ?
		JE button44

											;нажата ли кнопка 'bspase'
		CMP WORD PTR [EBP+10h],30			;нажата ли кнопка bs ?
		JE buttombspase
											;нажата ли кнопка buttomCE?
		CMP WORD PTR [EBP+10h],31
		je buttomCE
		
			CMP WORD PTR [EBP+10h],1
			JE hotclavishi
			CMP WORD PTR [EBP+10h],8
			JE hotclavishi
			JMP FINISH
			hotclavishi:
											;блок обработки сообщений первого окна редактирования
			CMP WORD PTR [EBP+12h],EN_KILLFOCUS
			JNE L4
											;окно редактирования с индексом 1 теряет фокус
			MOV EBX,0
											;снимаем все горячие клавиши
		L33:
			MOVZX EAX,BYTE PTR [TAB+EBX]
			PUSH EAX
			PUSH DWORD PTR [EBP+08h]
			CALL UnregisterHotKey@8
			INC EBX
			CMP EBX,214
			JNE L33
			MOV EAX,1
			JMP FINish
		L4:
			CMP WORD PTR [EBP+12h],EN_SETFOCUS
			JNE FINISH
											;окно редактирования с ID1получает фокус
			MOV EBX,0
											;устанавливаем горячие клавиши
		L44:
			MOVZX EAX, BYTE PTR [TAB+EBX]
			PUSH EAX
			PUSH 0
			PUSH EAX
			PUSH DWORD PTR [EBP+08h]
			CALL RegisterHotKey@16

			INC EBX
			CMP EBX,214
			JNE L44
			MOV EAX,1
			JMP FINish
		L5:
			CMP DWORD PTR [EBP+0Ch],WM_HOTKEY
			JNE FINISH
		
		JMP C1
	
POKAZ:
											; mov dword ptr[operac],ebx	; /
		mov word ptr[keyboard_flag],1
											;поймать строку2
		PUSH OFFSET TEXT_TWO
		PUSH 150
		PUSH WM_GETTEXT
		PUSH 8								;ид элемента
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		

lea eax,dword ptr[r2float]
push eax									;014h floatPart первой переменной
lea eax,dword ptr[hex64bit2znak]
push eax 									; 010h знак числа
lea ecx,dword ptr[kex64bit2]
push ecx									; 0ch	переменная куда записать результат
push offset[TEXT_TWO] 						; 08h текст со второго вводимого поля
CALL AsciiToHex

											;поймать строку1 - знак операции
		PUSH OFFSET TEXT
		PUSH 150
		PUSH WM_GETTEXT
		PUSH 14								;ид элемента поля знака операции
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		mov bx,word ptr[text]

cmp ebx,0 ;
 jne notfist
											;segment of code were fist run time
		lea eax,dword ptr[kex64bit1]
		push eax							;0ch - число, кот-e будет заменено destination data
		lea eax,dword ptr[kex64bit2]
		push eax							;08h - число, кот-м будет заменено - base data
		call API_Data						;функция пересылки данных
		 
		 
		mov edx,dword ptr[hex64bit2znak]
		 mov ecx,20h						;offset[operacFIST]  
	 jmp endcalc
 notfist:
											;cmp word ptr[keyboard_sign_flag],1 ;1 - цифравая клавиша нажата
jmp flag_sign_heare
flag:
											;поймать строку1 - знак операции
		PUSH OFFSET TEXT
		PUSH 150
		PUSH WM_GETTEXT
		PUSH 14								;ид элемента поля знака рперации
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		mov bx,word ptr[text]
cmp ebx,0 ;
je wmclose
											;цифровая клавиша не нажата
											;выводим знак в поле операции
		PUSH offset [operac]				;operac
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 14								;ид элемента
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20	
jmp wmclose
flag_sign_heare:

xor esi,esi



; - - - - - - - - - М О Д У Л Ь    С Л О Ж Е Н И Я - - - - - - - - 
slojit:
											;прелюдия...
	cmp ebx,2bh
	  jne vichest
	mov ecx,2bh								; operacplus +
	cmp dword ptr[hex64bit1znak],1			; знака нет в первом числе
	 je slogenie
	cmp dword ptr[hex64bit2znak],0 			; знак есть во втором числе
	  je znakest
	  mov esi,1
	  jmp slogenieOTRC
	  znakest:
	 mov esi,1
	 jmp OTRCslogenie
	  slogenie:
	cmp dword ptr[hex64bit2znak],0 			; знак есть во втором числе
	  je slogenieOTRC
	OTRCslogenie:
	

	lea eax,dword ptr[kex64bit1]
	push eax								;0ch - слогаемое-сумма целочисленное
	lea eax,dword ptr[kex64bit2]
	push eax								;08h - прибавить это целочисленное число 
	call API_add							;функция сложения h_чисел
	
	lea eax,dword ptr[r1float]
	push eax								;слогаемое-сумма	десятичное
	lea eax,dword ptr[r2float]
	push eax								;прибавить это десятичное число
	call API_add							;функция сложения h_чисел
jmp ovichest1
; - - - - - - - - -конец М О Д У Л Ь    С Л О Ж Е Н И Я - - - - - - - - 	
	

	
; - - - - - - - - - М О Д У Л Ь  В Ы Ч И Т А Н И Я - - - - - - - 
vichest:
	cmp ebx,2dh								; "-"
	jne umnojit
	mov ecx,2dh								;operacminus
	cmp dword ptr[hex64bit1znak],1  		; знака нет в первом числе
	 je vichitanie
	 cmp dword ptr[hex64bit2znak],0 		; знак есть во втором числе
	  jne znakest
	  mov esi,1
	  jmp slogenieOTRC
	vichitanie:
	cmp dword ptr[hex64bit2znak],0  		; знак есть во втором числе
	  je OTRCslogenie
	slogenieOTRC:


	lea eax,dword ptr[kex64bit1]
	push eax								;0ch - адрес уменьшаемое-разность
	lea eax,dword ptr[kex64bit2]
	push eax								;08h  - адрес вычитаемого
	CALL API_subtracter						;функция вычитания h_чисел
 
 
											; lea eax,dword ptr[r1float]
											; push eax				
											; lea eax,dword ptr[r2float]
											; push eax				
											; call API_subtracter			;функция вычитания h_чисел
 
mov esi,eax 								;возвращённые знаки...
jmp ovichest1
; - - - - - - - - -конец М О Д У Л Ь  В Ы Ч И Т А Н И Я - - - - - - - 

; - - - - - - - - - М О Д У Л Ь  У М Н О Ж Е Н И Я - - - - - - - - 
umnojit:
	cmp ebx,78h
	jne podelit
	mov ecx,78h								; x
	cmp dword ptr[hex64bit1znak],1  		; знака нет в первом числе
	 je umnogeniebezznaka
	 cmp dword ptr[hex64bit2znak],0 		; знак есть во втором числе
	  je umnogenie
	 mov esi,1
	 jmp umnogenie
	 umnogeniebezznaka:
	  cmp dword ptr[hex64bit2znak],1 		; знака нет  во втором числе
	  je umnogenie
	  mov esi,1
	umnogenie:
	
	lea eax,dword ptr[kex64bit1]
	push eax								;0ch - адрес умножаемого, произведенния(результата)
	lea eax,dword ptr[kex64bit2]
	push eax								;08h -адрес множителя
	call API_Multiplier						;функция умножения h_чисел
	
	lea eax,dword ptr[r1float]
	push eax				
	lea eax,dword ptr[r2float]
	push eax	
	call API_Multiplier						;функция умножения h_чисел
jmp ovichest1
; - - - - - - - - -конец М О Д У Л Ь  У М Н О Ж Е Н И Я - - - - - - - - 




; - - - - - - - - - М О Д У Л Ь  Д Е Л Е Н И Я - - - - - - - 
podelit:
	cmp ebx,2fh
	jne endcalc
	mov ecx,2fh	;  /
	cmp dword ptr[hex64bit1znak],1  		; знака нет в первом числе
	 je deleniebezznaka
	 cmp dword ptr[hex64bit2znak],0 		; знак есть во втором числе
	  je delenie
	 mov esi,1
	 jmp delenie
 deleniebezznaka:
	  cmp dword ptr[hex64bit2znak],1 		; знака нет  во втором числе
	  je delenie
	  mov esi,1
delenie:


	lea eax,dword ptr[kex64bit1]
	push eax								;адрес делимого, частное (результат)
	lea eax,dword ptr[kex64bit2]
	push eax								;адрес делителя
	call API_Divider						;функция деления h_чисел

	lea eax,dword ptr[r1float]
	push eax				
	lea eax,dword ptr[r2float]
	push eax
	call API_Divider						;функция деления h_чисел
	
jmp ovichest1
; - - - - - - - - - конец М О Д У Л Ь  Д Е Л Е Н И Я - - - - - - - 	


; - - - М О Д У Л Ь   К О Р Р Е К Ц И И   З Н А К А  - - - 	
ovichest1:
	cmp esi,0
	  je qqqqq
	mov edx,0
	  jmp endcalc
	  qqqqq:
	mov edx,1								;not_znak
jmp endcalc
	endcalc:
	mov word ptr[keyboard_sign_flag],0
; - - - конец М О Д У Л Ь   К О Р Р Е К Ц И И   З Н А К А  - - - 

push ecx									;операция
mov ebx,dword ptr[hex64bit2znak]
push ebx									; hex64bit2znak	знак
lea eax,qword ptr[kex64bit2]
push eax									;смещение где число для преобразования
push OFFSET[stringlb]						;адрес переменной, куда будет записан результат
call HexToAscii


lea eax,dword ptr[kex64bitresult]
push eax									;0ch - число, кот-e будет заменено destination data
lea eax,dword ptr[kex64bit1]
push eax									;08h - число, кот-м будет заменено
call API_Data


mov ebx,ecx
mov ecx,20h


push ecx									;операция
push edx									;знак
mov dword ptr[hex64bit1znak],edx
lea eax,qword ptr[kex64bitresult]
PUSH eax									;смещение где число для преобразования
push OFFSET[RESULT]							;адрес переменной, куда будет записан результат
call HexToAscii



											;отправить в строку ввода результат
		PUSH OFFSET RESULT
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 8								;2;ид элемента
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		
											;показывает знак следующей операции 
											; mov dword ptr[operacplus],ebx
		PUSH offset [operac]				;operac
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 14								;ид элемента
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
	
	C1:
											;вывод в листбокс последнего операнда
		PUSH OFFSET stringlb
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		jmp nearclose
		
	dnl:
											;выводит в строку ввода "делить на ноль нельзя!"
		PUSH OFFSET DIV0
		PUSH 0
		PUSH LB_ADDSTRING					; WM_SETTEXT
		PUSH 102							;ид элемента
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		
		nearclose:



											;нажата ли кнопка '='
	RAUNO:
		CMP WORD PTR [EBP+10h],17			;нажата ли кнопка = ?
		JNE vivodresult						;znalplusminus
		
	mov word ptr[keyboard_sign_flag],1
											;знаки и всё такое...
		mov ecx,3Dh							;offset[operacFIST]
		mov edx,dword ptr[hex64bit1znak]
		
		push ecx							;операция
		push edx 							;1знак
		  lea eax,qword ptr[kex64bit1]
		push eax							;смещение где число для преобразования
		push OFFSET[stringlb]				;адрес переменной, куда будет записан результат
		call HexToAscii
		
		xor edx,edx
		mov dword ptr[hex64bit1znak], edx

											;отправить в строку вводa ответ
		PUSH OFFSET stringlb
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 8								;2;ид элемента
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		
											;убрать  знак из поля операции
		PUSH 0								;offset [notznak]
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 14								;ид элемента
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
	
											;подчеркнуть для рультата в листбоксе
		PUSH OFFSET [podcherc]
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
	
											;сам результат выводится в листбоксе
		PUSH OFFSET stringlb
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20

											;пустая строка за результатом в листбоксе
		PUSH OFFSET [notznak]
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		
											;поднять скрол за результатом в листбоксе
											;SendMessage (hListbox, WM_VSCROLL, MAKEWPARAM (SB_BOTTOM, NULL), NULL);
											;
											; PUSH 0
											; PUSH 0
											; LB_GETTOPINDEX;LB_SETTOPINDEX 
											; PUSH 102
											; PUSH DWORD PTR[EBP+08h]
											; CALL SendDlgItemMessageA@20		
	 	
		jmp WMCLOSE
		
		
	vivodresult:	
		
	znalplusminus:
											;нажата ли кнопка '+/-'
		 CMP WORD PTR [EBP+10h],18			;нажата ли кнопка?
		 JNE button1
											;поймать строку2
			PUSH OFFSET TEXT_TWO
			PUSH 150
			PUSH WM_GETTEXT
			PUSH 8							;ид элемента
			PUSH DWORD PTR[EBP+08h]
			CALL SendDlgItemMessageA@20
			
			 lea eax,dword ptr[r2float]
			 push eax						;014h floatPart первой переменной
			 lea eax,dword ptr[hex64bit2znak]
			 push eax 						; 10h знак числа
			 lea ecx,qword ptr[kex64bit2]
			 push ecx						;0ch	переменная куда записать результат
			 push offset[TEXT_TWO] 			; 08h  текст со второго вводимого поля
			 CALL AsciiToHex
	
			CMP dword ptr[hex64bit2znak],0
			JE TET
			MOV ESI,0
			JMP TET1
			TET:
			MOV ESI,1
			TET1:
			
			push 20h						;операция
			push ESI						;знак
			  lea ecx,qword ptr[kex64bit2]
			PUSH ecx						;смещение где число для преобразования
			push OFFSET[TEXT_TWO]			;адрес переменной, куда будет записан результат
			call HexToAscii
			
											;отправить в строку ввода результат
			PUSH OFFSET [TEXT_TWO]
			PUSH 0
			PUSH WM_SETTEXT
			PUSH 8							;2;ид элемента
			PUSH DWORD PTR[EBP+08h]
			CALL SendDlgItemMessageA@20
			
											;установить фокус н lb
			push 8 							;ид поля ввода
			call SetFocus@4
											; нажата ли кнопка ' 1 '
	button1:
		 CMP WORD PTR [EBP+10h],21			;нажата ли кнопка 1 ?
		 JNE button2
		 mov word ptr[id_buttom],31h
		 jmp just_do_it
	button2:
		 CMP WORD PTR [EBP+10h],22			;нажата ли кнопка 2 ?
		 JNE button3
		 mov word ptr[id_buttom],32h	
		 jmp just_do_it
	button3:
		 CMP WORD PTR [EBP+10h],23			;нажата ли кнопка 3?
		 JNE button4
		 mov word ptr[id_buttom],33h	
		 jmp just_do_it
	button4:
		 CMP WORD PTR [EBP+10h],24			;нажата ли кнопка 4?
		 JNE button6
		 mov word ptr[id_buttom],34h	
		 jmp just_do_it
	button5:
		 CMP WORD PTR [EBP+10h],25			;нажата ли кнопка 5 ?
		 JNE button6
		 mov word ptr[id_buttom],35h	
		 jmp just_do_it
	 button6:
		 CMP WORD PTR [EBP+10h],26			;нажата ли кнопка 6 ?
		 JNE WMCLOSE
		 mov word ptr[id_buttom],36h
		 jmp just_do_it
	 button7:
		 CMP WORD PTR [EBP+10h],27			;нажата ли кнопка 7 ?
		 JNE button8
		 mov word ptr[id_buttom],37h	
		 jmp just_do_it
	 button8:
		 CMP WORD PTR [EBP+10h],28			;нажата ли кнопка 8 ?
		 JNE button9
		 mov word ptr[id_buttom],38h	
		 jmp just_do_it
	 button9:
		 CMP WORD PTR [EBP+10h],29			;нажата ли кнопка 9?
		 JNE button0						;button0
		 mov word ptr[id_buttom],39h	
		 jmp just_do_it
	 button0:
		 CMP WORD PTR [EBP+10h],19			;нажата ли кнопка 0 ?
		 JNE button44						;WMCLOSE;button0
		 mov word ptr[id_buttom],30h
		 jmp just_do_it
	 button44:
		 CMP WORD PTR [EBP+10h],20			;нажата ли кнопка точка/запятая ?
		 JNE buttombspase					;WMCLOSE;button0
		 mov word ptr[id_buttom],2ch
		 jmp just_do_it
	
	buttombspase:
		CMP WORD PTR [EBP+10h],30			;нажата ли кнопка buttombspase?
		 JNE buttomCE
		 mov word ptr[id_buttom],00h
		 jmp just_do_it
	 buttomCE:
		CMP WORD PTR [EBP+10h],31
		 JNE WMCLOSE						;button0
		mov word ptr[keyboard_flag],1		; mov word ptr[id_buttom],00h
		 
		 just_do_it:
		 mov word ptr[keyboard_sign_flag],1 ;цифровая клавиша нажата
											;поймать строку2
			PUSH OFFSET TEXT_TWO
			PUSH 150
			PUSH WM_GETTEXT
			PUSH 8							;ид элемента
			PUSH DWORD PTR[EBP+08h]
			CALL SendDlgItemMessageA@20
		cmp WORD PTR [EBP+10h],31
			jne notbuttomce
			mov byte ptr[TEXT_TWO],30h
			mov byte ptr[TEXT_TWO+1],2eh
			mov word ptr[keyboard_flag],0
		notbuttomce:	
		 cmp word ptr[keyboard_flag],0
		 je destroy_TEXT_TWO
		 mov dword ptr[TEXT_TWO],0			;dword ptr
		 mov word ptr[keyboard_flag],0
		 destroy_TEXT_TWO:
	CLD
	MOV EDI,OFFSET TEXT_TWO
	MOV EBX,EDI
	MOV ECX,0200h							;ограничить длинну строки
	XOR AL,AL
	REPNE SCASB								;найти символ "0"
	SUB EDI,EBX								;длинна строки включая "0"
	MOV EBX,EDI
	DEC EBX
	MOV EDI,OFFSET TEXT_TWO

	xor eax,eax
	mov ax,word ptr[id_buttom]

	CMP WORD PTR [EBP+10h],30				;нажата ли кнопка buttombspase?
	JNE adddigit
	cmp byte ptr[edi+ebx-3],20h  			;если пробел
	je zero
	cmp byte ptr[edi+ebx-3],2dh  			;если минус
	je zero
	mov byte ptr[edi+ebx-2],00h 			;если не пробел и не минус то ноль вместо последнего числа
	jmp adddigit
	zero:
	mov byte ptr[edi+ebx-2],30h
	mov byte ptr[edi+ebx-3],20h
	jmp adddigit
	adddigit:								;нажата ли клавиша 1,2,3...
	CMP BYTE PTR[edi+ebx],2ch
	je tochka
	cmp byte ptr[edi+ebx-1],2Eh
	je tochka
	mov word ptr[edi+ebx],ax
	jmp tochkanext
	tochka:
	mov word ptr[edi+ebx-1],ax 
	tochkanext:
	
			 lea eax,dword ptr[r2float]
			 push eax						;014h floatPart первой переменной
			 lea eax,dword ptr[hex64bit2znak]
			 push eax 						;010h знак числа
			 lea ecx,qword ptr[kex64bit2]
			 push ecx						;0ch	1-я переменная куда записать результат
			 push offset[TEXT_TWO] 			;08h  текст со второго вводимого поля
			 CALL AsciiToHex
	

			MOV ESI,dword ptr[hex64bit2znak]

			
			push 20h						;операция
			push ESI						;знак
			lea ecx,qword ptr[kex64bit2]
			PUSH ecx						;смещение где число для преобразования
			push OFFSET[TEXT_TWO]			;адрес переменной, куда будет записан результат
			call HexToAscii
			
											;отправить в строку ввода результат
			PUSH OFFSET [TEXT_TWO]
			PUSH 0
			PUSH WM_SETTEXT
			PUSH 8							;2;ид элемента
			PUSH DWORD PTR[EBP+08h]
			CALL SendDlgItemMessageA@20
			

		 
		 
	 WMCLOSE:
		CMP DWORD PTR [EBP+0Ch],WM_CLOSE
		JNE L1
	closewin:
											;здесь реакция на закрытие окна закрыть диалог
		PUSH 0
		PUSH DWORD PTR[EBP+08h]
		CALL EndDialog@8
		JMP FINISH
		
	L1:
		CMP DWORD PTR[EBP+0Ch],WM_INITDIALOG
		JNE FINISH
											;загрузить пиктограмму
		PUSH 100							;ID пиктограммы
		PUSH HINST							;ID прпоцесса
		CALL LoadIconA@8
											;установить пиктограмму
		PUSH EAX
		PUSH 0								;тип пикт - маленькая
		PUSH WM_SETICON
		PUSH DWORD PTR [EBP+08h] 			;ID окна
		CALL SendMessageA@16
		
											;ЗАГРУЗИТЬ МЕНЮ
	PUSH OFFSET PMENU
	PUSH HINST
	CALL LoadMenuA@8
	
											;УСТАНОВИТЬ МЕНЮ
	PUSH EAX
	PUSH DWORD PTR [EBP+08h]
	CALL SetMenu@8
	
											;version выводится в листбоксе
		PUSH OFFSET version
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20

		PUSH OFFSET operac
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
	FINISH:
		POP EDI
		POP ESI
		POP EBX
		POP EBP
		MOV EAX,0
		RET 16
WNDPROC ENDP




; - - - - -  H E X   T O   A S C I I   M O D U L E - - - - 
API_HexToAscii PROC
	PUSH EBP
	MOV EBP,ESP
	PUSH ESI
	PUSH EAX
	PUSH EBX
	push ecx

			  mov esi,dword ptr[ebp+08h]	;адрес входной переменной kex64bit
			  mov ebx,10					;decimalbase 0Ah
			  mov ecx,80					;h_variable_dimension
		; - - - - ц и к л - - - - -
		cicl_API_HexToAscii:
			  sub ecx,4
			  
			  mov eax,dword ptr[esi+ecx]	;значение входной переменной
			  div ebx						;делим eax на 10(ebx)
			  mov dword ptr[esi+ecx],eax	;результат деления
			  
			  cmp ecx,0
			  je exit_API_HexToAscii
			  jmp cicl_API_HexToAscii
		exit_API_HexToAscii:
		; - - - - / ц и к л - - - - -
	pop ecx
	POP EBX
	POP EAX
	POP ESI
	POP EBP
	RET 4
API_HexToAscii ENDP


	
HexToAscii PROC
											;014h операция
											;010h знак числа [hex64bitznak]
											;0ch смещение, где число для преобразования
											;08h адрес строковой переменной, куда будет записан результат
	push ebp
	mov ebp,esp
	push eax
	push edi
	push ecx
	push edx
	push ebx
			MOV esi,DWORD PTR[EBP+0ch]		;esi - входная переменная 
			xor ecx,ecx						;счётчик для восстановления числа из стека
			xor edi,edi						;счётчик по 3
		repeat6:
			;- - -  п е р е в о д   в   DEC - - - - - 
			  xor edx,edx					;сбрасываем остаток от деления!
			  PUSH[ebp+0Ch]
			  CALL API_HexToAscii
			;- - - - п е р е в о д  в   ASCII - - - - 
											;в DH в данный момент остаток от деления!!!!!
			  ADD DL,'0'					;подсовываем в младший (левый)байт нолик (3) и тем самым делаем его строкой
			 
			  ; - - - - р а з д е л е н и е   п р о б е л а м и   р е з у л ь т а т а  - - - 
				cmp edi,3					;количество знаков, разделённых пробелом
				jne potri
				inc ecx						;счётчик стека в любом случае
				push 20h					;прописываем пробел
				xor edi,edi					;если установлен пробел, сбрасываем edi
			  potri:
				inc edi						;если пробел не  установлен инкрементируем edi
			   ; - - - - / р а з д е л е н и е   п р о б е л а м и   р е з у л ь т а т а  - - - 
			
			;- - - - - З А П И С Ы В А Е М   Р Е З - Т   В   С Т Е К - - - - - - 
				PUSH EDX	
				inc ecx						;счётчик стека в любом случае
			  
		; - - - - - - -у с л о в и е  в ы х о д а  - - - - - 
			  mov esi,dword ptr[ebp+0ch]	;esi - входная переменная kex64bit сравнивается с нулём!
			 ; - - - - - - - с р а в н и в а е м   с   н у л е в о й   п е р е м е н н о й - - - - - - - - - - - - 	
			push esi						;адрес первого h_числа 0ch
			lea eax,dword ptr[zeroReg]
			push eax						;адрес второго числа 08h
			call API_cmp					;сравнить два числа [compare_flag],1 - 0ch меньше 08h иначе [compare_flag],0; eax,1 - флаг равенства чисел
			
			cmp eax,1						;если h_число равно 0...
			jne repeat6
		;/ - - - - - - / REPEAT6  - - - - - - - 
		
		; - - - - - - п о д г о т о в к а  с т р о к и   ( ш а п к а   с о   з н а к а м и   и   п р о б е л а м и ) - - - - - - - -
			mov edi,dword ptr[ebp+08h]		;адрес куда будет записан результат
			xor edx,edx
			  mov al,byte ptr[ebp+014h ]	;адрес знака операции =
			  mov byte ptr[EDI],al			;тут вписывается в строку знак операции =
			  inc edx
			  mov byte ptr[EDI+1],20h		;тут вписывается пробел
			  inc edx
			  mov byte ptr[EDI+2],20h		;тут следующий пробел
			  inc edx
			cmp byte ptr[ebp+10h],1			;знак h_числа
			je positiveascii
			; - - negativascii - - 
			mov byte ptr[EDI+3],2dh			;прописывается минус перед числом, если оно отрицательное
			inc edx
			positiveascii:
		; - - - - - - / п о д г о т о в к а  с т р о к и   ( ш а п к а   с о   з н а к а м и   и   п р о б е л а м и ) - - - - - - - -
		
		;- - - - Ф О Р М И Р У Е М   С Т Р О К У - - - -
		repeat8:		
			xor eax,eax
			; - - - - - б е р ё м   и з   с т е к а  ч и с л о  - - - - - - - 
			POP EAX				
			mov byte ptr[EDI+edx],al		;записываем с начала
			inc edx							;количество символов в строке
			dec ecx
		jnz repeat8
			mov byte ptr[EDI+edx],2eh		;добавить точку
			; - - - - - - -  д р о б н а я   ч а с т ь  + edi - - - - - - - - - - - - - 
			nop
			; - - - - - - - / д р о б н а я   ч а с т ь  + количество символов edi
			mov byte ptr[EDI+edx+1],0		;добавить ноль, как окончание строки
	pop ebx
	pop edx
	pop ecx
	POP EDI
	POP EAX
	POP EBP
RET 16										;32
HexToAscii ENDP
; - - - - -конец  H E X   T O   A S C I I   M O D U L E - - - - 

; - - - - - A S C I I   T O   H E X   M O D U L E - - - - 
API_AsciiToHex PROC
											;010h - прошлый перенос
											;0ch - осн-е с счисл	
											;08h - число
	push ebp
	mov ebp,esp
	push edi
	push ecx
			mov edi,dword ptr[ebp+08h]		;результат hex цифры
			xor esi,esi						;mov esi,dword ptr[ebp+010h]	;прошлое esi
			xor ecx,ecx
			cicl_API_AsciiToHex:
				  mov edx,dword ptr[ebp+0ch]	;adress hexbase
				  mov eax,dword ptr[edx+ecx]	;hexbase
			xor edx,edx
			mul ebx							;умножаeм hexbase на h_цифру , число в eax [EDX:EAX] 
			add eax,esi						;прибавляем все остальные переносы 
			jnc api3
				inc edx						; если перенос, то инкремент его
			api3:
			mov esi,edx						;сохраняем этот перенос в esi
			xor edx,edx						;обнуляем edx
			add eax,dword ptr[h64cf]		;прибавляем перенос
			jnc api31
				inc edx	; 
			api31:
				  add dword ptr[edi+ecx],eax	;сохраняем результат h_цифры
			jnc api64cf3
				inc edx
			api64cf3:
			mov dword ptr[h64cf],edx		;сохраняем перенос
			add ecx,4						;смещение
			cmp EcX,80						;h_variable_dimension (36)
		jne cicl_API_AsciiToHex
		mov eax,esi
	pop ecx		
	pop edi
	pop ebp
RET 8
API_AsciiToHex ENDP


API_HexBose PROC
	push ebp
	mov ebp,esp
	push edi
	push ecx
			xor edx,edx
			xor ecx,ecx
			hbl1:
			mov eax,dword ptr[hexbase+ecx]	; eax САМЫЙ старш результат
			push edx						;перенос
			mov  ebx,0ah					;осн с исчисл			
			mul ebx							;домнож осн с.исч. на 0Аh 
			pop ebx							;перенос из стека
			add eax,ebx						;приб. перенос к рез-ту
			   jnc hexbosenocarry	
				inc edx						;если оч много и перенос (он может быть только еденицей)
			   hexbosenocarry:
			mov dword ptr[hexbase+ecx],eax   ;сохр рез-т в оперативку
			 add EcX,4						;смещение
			 CMP EcX,80						;h_variable_dimension
			 JNE hbl1
	pop ecx
	pop edi
	pop ebp
ret 4
API_HexBose ENDP

AsciiToHex PROC
											; 4 294 967 295
											; 18 446 744 073 709 551 616
	PUSH EBP
	MOV EBP,ESP
	PUSH EDI
	push eax
			mov edi,dword ptr[ebp+08h]		;в edi - адрес TEXT
			xor edx,edx
			xor ecx,ecx
	; - - - - - - Ц И К Л  О С Н О В Н О Й - - - - - 
		CKL1:
			CMP BYTE PTR[edi+ECX],0    		;не конец ли строки введённого текста
			jne compare_fist
			cmp edx,0						;проверка есть ли вообще знак цифры (число)  в поле ввода?
			jne kexvoid
			inc edx
			push 0							; если нету ничего в поле ввода то ввести "0"
			jmp  kexvoid
		compare_fist:
			CMP BYTE PTR[edi+ecx],2ch		; 2ch - запятая в  ascii (american standart code for information interchange)
			JE kexvoid
											;mov dword ptr[flag_seporate_dec_float],1
											;mov dword ptr[dec_symbols],edx
											;xor edx,edx
											;jmp skipthis
			CMP BYTE PTR[edi+ecx],2Eh		; 2eh - точка в  ascii (american standart code for information interchange)
			JE kexvoid
			CMP BYTE PTR[edi+ecx],20h		; - пробел
			je skipthis	
			CMP BYTE PTR[edi+ecx],30h		; - числа
			Jb skipthis
			CMP BYTE PTR[edi+ecx],39h		; - числа
			jg skipthis
		;- - - - A S C I I   ->  U N P C K B C D - - - - 	
			 cmp edx,0200h					;ограничение на 100 цифр
			 je kexvoid
			xor eax,eax
			MOV AL,BYTE PTR [edi+ECX]   	;устанавливаем указатель в точку текста...
			SUB AL,'0' 						;ascii->unpck формат 01 02 03...
			push eax						;вставка в стек!!!!
			INC EDX 						;количество символов в одной из цифр (или целой или дробной)
		skipthis:
			INC ECX							;количество символов в TEXT (забранной строки)
		JMP CKL1
	; - - - - - -конец Ц И К Л  О С Н О В Н О Й - - - - - 		


	; - - - - -  П О Д Г О Т О В К А  П Р Е О Б Р А З О В А Н И Е  Ц И Ф Р Ы unpckBCD -> hex- - - - - - 		
		kexvoid:
											;обнуление hexbase
			lea eax,dword ptr[hexbase]
			push eax						;0ch - число, кот-e будет заменено destination data
			lea eax,dword ptr[zeroReg]
			push eax						;08h - число, кот-м будет заменено
			call API_Data					;функция пересылки данных

											;обнуление адреса куда будет записан рез-т
			push [ebp+0ch]					;0ch - число, кот-e будет заменено destination data
			lea eax,dword ptr[zeroReg]
			push eax						;08h - число, кот-м будет заменено
			call API_Data					;функция пересылки данных
			
			mov dword ptr[hexbase],1		; oсн сис счисл
			
			mov ecx,edx						;количество символов в kex64bit
	; - - - - -конец  П О Д Г О Т О В К А  П Р Е О Б Р А З О В А Н И Е  Ц И Ф Р Ы unpckBCD -> hex- - - - - - 			
			
	; - - - - -  П Р Е О Б Р А З О В А Н И Е  Ц И Ф Р Ы unpckBCD -> hex- - - - - - 		
		kex64bit:
			pop ebx							;число из стека
		; - - - - -  П Р Е О Б Р А З О В А Н И Е  С А М О Й  Ц И Ф Р Ы - - - - - - 
			lea eax,dword ptr[hexbase]
			push eax						;0ch - осн-е с счисл	
			push [ebp+0ch]					;08h - число
			call API_AsciiToHex

		;- - - - К О Р Р Е К Т И Р О В К А  П О Р Я Д К А  С И С   И С Ч И С Л - - - -
			push 0
			call API_HexBose
			dec ecx							;количество символов в kex64bit - -
		jne kex64bit
	; - - - - -конец  П Р Е О Б Р А З О В А Н И Е  Ц И Ф Р Ы unpckBCD -> hex- - - - - - 		
		
		;- - - - знак числа - - - - 
			mov edx,dword ptr[ebp+08h]
			 CMP BYTE PTR[edx+3],2Dh
			 jne R
			 mov eax,dword ptr[ebp+10h]
			 mov dword ptr[eax],0			;знак минус есть
			 jmp r2
		R:
			mov eax,dword ptr[ebp+10h]
			mov dword ptr[eax],1			;знакa минуса нет   -
		r2:
											;сделать зачистку двойного слова старого результата в памяти 
			mov edi,dword ptr[ebp+08h]
			mov dword ptr[edi],0
											;возобн.стек
	pop eax
	POP EDI
	POP EBP
RET 16;28
AsciiToHex ENDP
; - - - - - конец  A S C I I  T O   H E X   M O D U L E - - - - 


;- - - - - - - М О Д У Л Ь   С Р А В Н Е Н И Я - - - - - - 
;- - - - - сравнивание 2-х h_чисел  без определениея знака - - - - - - 	
											; [compare_flag],0 - 1-e число больше или равно 2-му
											; [compare_flag],1 - меньше! 
											; eax,1 - равны
											; eax,0 - не равны
API_cmp PROC
	PUSH EBP
	MOV EBP,ESP
	push ecx
	push edx
	push ebx
	push esi
	push edi
		mov dword ptr[compare_flag],0		;сбрасываем... 4 294 967 295
		mov esi,dword ptr[ebp+0ch]			;адрес bit1	18 446 744 073 709 551 615
		mov edi,dword ptr[ebp+08h]			;адрес bit2
		xor ecx,ecx
		mov edx,1							;флаг равенства 1-числа равны
	cicl_apicmp:	
		mov eax,dword ptr[esi+ecx]			; bit1
		mov ebx,dword ptr[edi+ecx]			; bit2	
		
		cmp eax,ebx							;равны ли числа между собой
		je bit_end							;если равно, то сохраняем прошлый флаг
		xor edx,edx	;
		cmp eax,-1							;сравнение связано с тем, что  0ffffffffh - это -1
		je bit_ge							;первое число больше или равно
		cmp ebx,-1
		je bit_b							;первое число меньше

		cmp eax,ebx
		ja bit_ge							;если перв число меньше меняем флаг на единицу 
											;если перв число  больше меняем на ноль флаг
	bit_b:
		mov dword ptr[compare_flag],1 		;первое число меньше
		jmp bit_end
	bit_ge:
		mov dword ptr[compare_flag],0 		;первое число больше или равно
	bit_end:
		add ecx,4
		cmp ecx,80;40
		jne cicl_apicmp
		mov eax,edx
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	POP EBP
	ret 8
API_cmp ENDP
;- - - - - - -конец М О Д У Л Ь   С Р А В Н Е Н И Я - - - - - -

; - - - - - -  М О Д У Л Ь  С Л О Ж Е Н И Я - - - - - - - - - - - - - - - - 
API_add PROC
	push ebp
	mov ebp,esp
	push edi
	push eax
	push ecx
	push ebx
	push esi
		mov esi,dword ptr[ebp+0ch]
		mov edi,dword ptr[ebp+08h]
		xor ecx,ecx
		xor ebx,ebx
	ciclSlojenia:
		mov eax,dword ptr[edi+ecx]			;mov eax,dword ptr[kex64bit2+ecx]
		add dword ptr[esi+ecx],eax
		jnc sslojit1
	slojitAgain:								
		add ebx,4							;тут необходимо ebx+ecx то есть  на 4 больше
		push esi
		add esi,ebx
		add dword ptr[esi+ecx],1			;4 294 967 295+1
		pop esi
		jnc sslojit2
		jmp slojitAgain
	sslojit2:
		xor ebx,ebx
	sslojit1:
		add ecx,4
		cmp ecx,80							;40
		je exitSlojenie
		jmp ciclSlojenia
	exitSlojenie:
	pop esi
	pop ebx
	pop ecx
	pop eax
	pop edi
	pop ebp
RET 8
API_add ENDP
; - - - - - - конец М О Д У Л Ь  С Л О Ж Е Н И Я - - - - - - - - - - - - - - - - 


; - - - - - -  М О Д У Л Ь  П Е Р Е С Ы Л К И   М А Т Е М - Х  Д А Н Н Ы Х  - - - 
;для обнуления регистра использовать 08h - zeroReg dq 0,0,0,0,0
API_Data PROC
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	push edx
	push edi
	push esi
		xor ecx,ecx
		xor ebx,ebx
		repeatData:
			mov edi,dword ptr[ebp+08h]		;адрес числа
			mov eax,dword ptr[edi+ecx]		;eax - число
			mov edi,dword ptr[ebp+0ch]		;адрес числа для замены
			mov dword ptr[edi+ecx],eax		;dword - число, кот. будет заменено
			add ecx,4
			cmp ecx,80						;на 4 больше чем задано
		jne repeatData

	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
RET 8
API_Data ENDP
; - - - - - -  конецМ О Д У Л Ь  П Е Р Е С Ы Л К И М А Т Е М - Х  Д А Н Н Ы Х  - - -

 ; - - - - - -  М О Д У Л Ь  У М Н О Ж Е Н И Я  - - - - - - - - - - - - - 

API_Multiplier PROC
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	push edx
	push edi
	push esi
	
	
	lea eax,dword ptr[multex]
	push eax								;0ch - число, кот-e будет заменено destination data
	lea eax,dword ptr[zeroReg]
	push eax								;08h - число, кот-м будет заменено
	call API_Data							;функция перессылки данных

	xor ecx,ecx
	multipl:
		mov esi,dword ptr[ebp+08h]			;bit2 должно начинаться 0 4 8 12
		mov ebx,dword ptr[esi+ecx]			;bit2 делитель первого действия
		xor esi,esi
		xor edx,edx
		xor edi,edi
		push ecx
	    multipl1:
		push ebx
		mov ebx,dword ptr[ebp+0ch]			;bit1 умножаемое,произведение- результат
		mov eax,dword ptr[ebx+esi]			;bit1 0 4 8 12 каждый раз
		pop ebx
		mul ebx
		add eax,edi							;в первом действии нули
		  jnc cmul							;в первом действии всегда переход
			inc edx							;в первом действии не наступает
		cmul:
		add eax,dword ptr[multex+ecx]		;должно начинаться 0 4 8 12
		jnc cmul2
			inc edx
		cmul2:
		mov edi,edx							;перенос
		mov  dword ptr[multex+ecx],eax		;должно начинаться 0 4 8 12
		add ecx,4
		add esi,4
											; изменять число при увеличении разрядности калькулятора
		cmp esi,030h						;затронет 4 байта по 4 регистра kex64bit1[0-12]
	    jne multipl1
	
		pop ecx
											; изменять число при увеличении разрядности калькулятора
		mov dword ptr[multex+ecx+030h],edx	;перенос
		add ecx,4
											; изменять число при увеличении разрядности калькулятора
		cmp ecx,030h
	jne multipl

											;пересылка данных	
	push [ebp+0ch]							;0ch - число, кот-e будет заменено destination data
	lea eax,dword ptr[multex]
	push eax								;08h - число, кот-м будет заменено
	call API_Data							;функция перессылки данных

	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
RET 8
API_Multiplier  ENDP
 ; - - - - - -конец  М О Д У Л Ь  У М Н О Ж Е Н И Я  - - - - - - - - - - - - - 
 
 
 ; - - - - - -М О Д У Л Ь   В Ы Ч И Т А Н И Я  - - - - - - - - - - - - -
 ;- - - - - -API   В Ы Ч И Т А Н И Я - - - - - 
											; 0ch-kex64bit1
											; 08h-kex64bit2
  	
 API_subtracter PROC
	PUSH EBP
	MOV EBP,ESP
	push ecx
	push edx
	push ebx
	push esi
	push edi
		mov esi,dword ptr[ebp+0ch]			;адрес первого числa  kex64bit1
		mov edi,dword ptr[ebp+08h]			;адрес второго числа  kex64bit2

		push esi							;адрес первого число
		push edi							;адрес второго числа
		call API_cmp						;сравнить два числа [compare_flag]=1 если 0ch меньше 08h иначе [compare_flag]=0
	;- - - сделано для сохранения оригинальной переменной - - - -
		lea eax,dword ptr[kex64bit2v]
		push eax							;0ch - адрес числа, кот-e будет заменено destination data
		push edi							;08h - адрес числа, кот-м будет заменено (второго числа)
		call API_Data						;функция пересылки данных
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	
	xor edi,edi
	 rData:
											;перевёрнуто ли вычитать
		cmp dword ptr[compare_flag],0		;compare_flag - флаг перевёрнутости
		jz nenaoborot
		mov ebx,dword ptr[esi+edi]			;0сh
		mov eax,dword ptr[kex64bit2v+edi]	;
		jmp naoborot
		nenaoborot:
		mov eax,dword ptr[esi+edi]			;0ch
		mov ebx,dword ptr[kex64bit2v+edi]	;
		naoborot:
	
	;- - - - - - - - - - - - - В  П Р Е Д Ы Д У Щ Е М   Ц И К Л Е   Б Ы Л   З А Ё М  - - - - - - - - - - - - - 	  
		cmp dword ptr[zaem],0					;маркер предыдущего заёма с нулём
		jz not_was_zaem
		
			cmp dword ptr[compare_flag],0		;compare_flag - флаг перевёрнутости операции
			jz  zaem_kex64bit1_4_4
			
			; - - - - - - - - ВЕТКА КОДА КОГДА compare_flag=1 - - - - - - - - - - - - - - - 
				mov ecx,dword ptr[kex64bit2v+edi+4]	; старший "десяток" 
				jmp api_sub
				
			; - - - - - - - - ВЕТКА КОДА КОГДА compare_flag=0 - - - - - - - - - - - - - - - 	
			 zaem_kex64bit1_4_4:
				mov ecx,dword ptr[esi+edi+4]	;старший "десяток" 
				
			api_sub:
				cmp ecx,0					;если старший десяток ноль (но в предыдущей операции был заём, а в этой нет)
				jnz starshi_desiatok_not_was_zero
				;- - - если старший десяток ноль - - - 
					mov ecx,0ffffffffh			;в edx записываем самое большое 32битное шестнадцатиричное число
					mov dword ptr[zaem],1		;устанавливаем маркер заёма
					jmp save_digit
				;- - - если старший десяток не ноль - - - 	
				starshi_desiatok_not_was_zero:
					dec ecx;dword ptr[kex64bit2v+4]	;из старшего регистра вычитаем единицу (заимствованный десяток) 
					mov dword ptr[zaem],0		;выключаем маркер заёма
					
			;- - - -  сохраняем старший регистр - - - - 
			save_digit:
			cmp dword ptr[compare_flag],0		;compare_flag - флаг перевёрнутости операции
			jz  jhkgg
				mov dword ptr[kex64bit2v+edi+4],ecx
				jmp not_was_zaem
			jhkgg:
				mov dword ptr[esi+edi+4],ecx
				
				

		 
		;- - - - - - - - - - - - - В  П Р Е Д Ы Д У Щ Е М   Ц И К Л Е  Н Е Б Ы Л О   З А Ё М А  - - - - - - - - - - - - - 
		; - - - - - - - - - - - - - - О С Н О В Н А Я   В Е Т К А  К О Д А  - - - - - - - - - - - - - 		
		 not_was_zaem:						;
		cmp eax,ebx							;cmp kex64bit1, kex64bit2v
		je tutaka							;если равны
		cmp eax,0ffffffffh					;cmp kex64bit1, [самое большое число оно же -1]
		je tutaka							;если равнo
		cmp ebx,0ffffffffh					;cmp kex64bit2v, [самое большое число]
		je zaem1							;если равнo
		cmp eax,ebx							;cmp kex64bit1, kex64bit2v
		jb zaem1 							;если  меньше и необх занимать десяток
		
		 ; - - - - - - - - - - - - -  В Ы Ч И Т А Н И Е  О С Н О В Н О Е  - - - - - - - - - - - - - -  
		tutaka:
		sub eax,ebx							;вычесть из первого второй регистр
		mov dword ptr[esi+edi],eax 			;записать значение разницы в первый регистр 
		jmp otric4							;to the end...

		
		
		; - - - - - - - - - - - - - - - В Е Т К А  Д Л Я  Р Е А Л И З А Ц И И  З А Ё М А - - - - - - - - - - - - 
		zaem1: 								;если 1 число меньше 2-го и необх занимать десяток
			xchg eax,ebx					;меняем местами числа
			sub eax,ebx						;вычетаем из второго числа первое и записываем его в eax
			cmp dword ptr[compare_flag],0	;compare_flag - флаг перевёрнутости
			jz  zaem_kex64bit1_4
				mov edx,dword ptr[kex64bit2v+edi+4]	;записываем в edx старший десяток  
				jmp zaem_kex64bit2_4
			zaem_kex64bit1_4:
				mov edx,dword ptr[esi+edi+4]		;записываем в edx старший десяток 
			zaem_kex64bit2_4:
				cmp edx,0 					;
				jz zaemzero					;если старший регистр состоит из нолей ...
				
				; - - - - - - - - - - - - - -ВЕТКА, ГДЕ СТАРШИЙ "ДЕСЯТОК" НЕ НОЛЬ - - - - - - - - - - - - - 
				mov ebx,0ffffffffh			;записываем самое большое 32битное шестнадцатиричное число
				sub ebx,eax					;разница между самым большим числом и результатом "перевёрнутой" разницы
				inc ebx						;прибавить к результату недостающую 1 и получим регистр
				mov dword ptr[esi+edi],ebx 	;записать значение разницы в первый регистр-РЕЗУЛЬТАТ
				dec edx						;из старшего регистра вычитаем единицу (заимствованный десяток)
				jmp  otric5					;to the end...
					
							; - - - - - - - - - - - - - - ВЕТКА ГДЕ СТАРШИЙ "ДЕСЯТОК" РАВЕН НУЛЮ- - - - - - - - - - - - - 
							zaemzero:
								mov ebx,0ffffffffh			; записываем самое большое 32битное шестнадцатиричное число
								sub ebx,eax					;разница между самым большим числом и результатом "перевёрнутой" разницы
								inc ebx						; прибавить к результату недостающую 1 и получим регистр-результат
								mov dword ptr[esi+edi],ebx 	;записать значение разницы в первый регистр-РЕЗУЛЬТАТ
								mov edx,0ffffffffh			;записываем в старший регистр самое большое число
								inc dword ptr[zaem]			;и записываем в переменную заёма  единицу
								
			; - - - - - - - - - - - - ПЕРЕЗАПИСЬ СТАРШЕГО НУЖНОГО ЧИСЛА- - - - - - - - - - - - - - - 	
			otric5:		
				cmp dword ptr[compare_flag],0	;
				jz  zaem_kex64bit1_4_3
				mov dword ptr[kex64bit2v+edi+4],edx			;перезаписываем старший регистр
				jmp zaem_kex64bit2_4_3
			zaem_kex64bit1_4_3:
				mov dword ptr[esi+edi+4],edx				;write greate digit
			zaem_kex64bit2_4_3:

			
			; - - - - - - - - - - - - - - - - - - - - - - - - - - - 
			otric4:							;end...
			
			 add edi,4
			 cmp edi,80						;можно 96 - 4 (12 двойных слов)=4х2х12=96
		 jne rData
			
			
			mov eax,dword ptr[compare_flag]
			
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	pop ebp
RET 8										;18 446 744 073 709 551 616 - 1
API_subtracter ENDP
; - - - - - -конец  API  В Ы Ч И Т А Н И Я  - - - - - - - - - - - - -



 ; - - - - - -М О Д У Л Ь   Д Е Л Е Н И Я  - - - - - - - - - - - - -
 ;- - - - - - API - - - - - 
											; 0ch-kex64bit1
											; 08h-kex64bit2
  	
 API_Divider PROC
	PUSH EBP
	MOV EBP,ESP
	push ecx
	push edx
	push ebx
	push esi
	push edi
		mov esi,dword ptr[ebp+0ch]			;адрес первого числa  kex64bit1
		mov edi,dword ptr[ebp+08h]			;адрес второго числа  kex64bit2
	;- - - - - п р о в е р к а   н а   б о л ь ш е   м е н ь ш е - - - - - - 
	push esi								;адрес первого число
	push edi								;адрес второго числа
	call API_cmp							;сравнить два числа [compare_flag]=1 если 0ch меньше 08h иначе [compare_flag]=0
	 cmp dword ptr[compare_flag],1 			;если  1 , то первое число меньше второго !
	 je divs_end
	; - - - - - - - с р а в н и в а е м   с   н у л е в о й   п е р е м е н н о й - - - - - - - - - - - - 	
	push edi								;адрес первого число 0ch[kex64bit2]
	lea eax,dword ptr[zeroReg]
	push eax								;адрес второго числа 08h
	call API_cmp							;сравнить два числа [compare_flag]=1 если 0ch меньше 08h иначе [compare_flag]=0; eax=1 - флаг равенства чисел
	cmp eax,1
	je divs_end								;на ноль делить нельзя DevideByZeroExctptin result=Quotient(Numerator,Denominator)
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	
; - - - - - - - - - - -  - - I N I T  V A R I A B L E - - - - - - - - - - - - -  
	;- - - - - - - делаем перессылку данных - - - - - - - - - - - - 
		lea eax,dword ptr[ost]
		push eax							;0ch - число, кот-e будет заменено destination data
											;lea eax,dword ptr[kex64bit1]
		push esi							;08h - число, кот-м будет заменено
		call API_Data						;функция пересылки данных
	;- - - - - - - rezult=0- - - - - - - -
		lea eax,dword ptr[rezult]
		push eax							;0ch - число, кот-e будет заменено destination data
		lea eax,dword ptr[zeroReg]
		push eax							;08h - число, кот-м будет заменено
		call API_Data						;функция пересылки данных
	;- - - - - - - - - - - - - - - - - - - - - - - -
		mov dword ptr[p_dek],0
	
	; - - - - - - - - - - - - - - - -   О С Н О В Н О Й  Ц И К Л  Д Е Л Е Н И Я - - - - - - - - - - - - - - - - - - - 
start_D:
	; - - - - - - - - - -подготовка к циклу "repeatsD_1"- - - - - - - - - - - - - 
	mov dword ptr[rez],0
	mov dword ptr[dek],0
	
											;делаем перессылку данных
		lea eax,dword ptr[reg2]
		push eax							;0ch - число, кот-e будет заменено destination data
											;lea eax,dword ptr[kex64bit2]
		push edi							;08h - число, кот-м будет заменено
		call API_Data						;функция пересылки данных
											;делаем перессылку данных
		lea eax,dword ptr[eax_h]
		push eax							;0ch - число, кот-e будет заменено destination data
											;lea eax,dword ptr[kex64bit2]
		push edi							;08h - число, кот-м будет заменено
		call API_Data	
											;будущий последний правильный результат регистра-деллителя, умноженного на 10
		lea eax,dword ptr[esi_h]
		push eax							;0ch - число, кот-e будет заменено destination data
		lea eax,dword ptr[reg2]
		push eax							;08h - число, кот-м будет заменено
		call API_Data						;функция пересылки данных	
	xor ecx,ecx								;количество домножений
	xor edx,edx
; - - - - - C I C L E 1  "repeatsD_1"- - - - - 
; - - - - ДОМНОЖЕНИЕ РЕГИСТРA-ДЕЛИТЕЛЯ НА 10 ПОКА ПЕРВОЕ ЧИСЛО (ДЕЛИМОЕ) НЕ СТАНЕТ МЕНЬШЕ ВТОРОГО- (ДЕЛИТЕЛЯ) - - - 
repeatsD_1:
											;умножаем РЕГИСТР-ДЕЛИТЕЛь НА 10
		lea eax,dword ptr[eax_h]			;kex64bit2
		push eax							;0ch - адрес умножаемого, произведенния(результата)
		lea eax,dword ptr[ebx_10]
		push eax							;08h -адрес множителя ebx_10h
		call API_Multiplier					;функция умножения сверхбольших чисел
											;сравниваем с предыдущим результатом
											;если меньше, то выходим без сохранения последнего неправильного результата
		lea eax,dword ptr[ost]				;kex64bit1
		push eax							;адрес первого число 0ch
		lea eax,dword ptr[eax_h]			;[Reg2]
		push eax							;адрес второго числа 08h
		call API_cmp						;[compare_flag],1 if [ost]< [eax_h];compare_flag],0 if 0ch>08h
		cmp dword ptr[compare_flag],1
		je exit_repeatsD_1
		
		inc ecx 							;inc количество домножений (dek)
											;сохраняем последний правильный результат регистра-деллителя, умноженного на 10 - - -
			lea eax,dword ptr[esi_h]		;правильный [reg2]
			push eax						;0ch - число, кот-e будет заменено destination data
			lea eax,dword ptr[eax_h]		;[reg2]
			push eax						;08h - число, кот-м будет заменено
			call API_Data					;function the change of data
; - - - - - - - - - - - - - - 
jmp repeatsD_1
exit_repeatsD_1:
; - - - конец C I C L E "repeatsD_1"- - - - - - 

mov dword ptr[dek],ecx						;записываем количество домножений (dek)
											;сохр перед домножением
			lea eax,dword ptr[reg2]			;right rezult
			push eax						;0ch - число, кот-e будет заменено destination data
			lea eax,dword ptr[esi_h]
			push eax						;08h - число, кот-м будет заменено
			call API_Data					;функция пересылки данных

; - - - - - C I C L E  "repeatsD_2"- - - - - 
; ---ВЫЧИТАЕМ ИЗ ДЕЛИМОГО ДЕЛИТЕЛЬ, ПОКА ДЕЛИТЕЛЬ НЕ СТАНЕТ БОЛЬШЕ ДЕЛИМОГО И ЗАПИСЫВАЕМ РЕЗУЛЬТАТ-ОСТАТОК(OST) И КОЛИЧЕСТВО ВЫЧИТАНИЙ (REZ)
xor ecx,ecx
    repeatsD_2:

		lea eax,dword ptr[ost]
		push eax							;0ch adress for fist digit
		lea eax,dword ptr[reg2]
		push eax							;08h adress for second digit 
		call API_cmp						;cmp [compare_flag],1 0ch<08h else [compare_flag],0
		cmp  dword ptr[compare_flag],1		;сравнить делимое-остаток и делитель
		je repeatsD_2_end					;перейти, если делимое-остаток неменее делителя-вычитателя 

		lea eax,dword ptr[ost]
		push eax							;0ch adress for fist digit
		lea eax,dword ptr[reg2]
		push eax							;08h adress for second digit 
		 CALL API_subtracter				;функция вычитания h_чисел
		 
		inc ecx								;[rez]	- количество раз вычитаний				

	jmp repeatsD_2
    repeatsD_2_end:
; - - - конец C I C L E "repeatsD_2"- - - - - - 

		lea eax,dword ptr[ost]				; остаток
		push eax							;адрес первого числa 0ch
		lea eax,dword ptr[zeroReg]			;ноль
		push eax							;адрес второго числа 08h
		call API_cmp						;сравнить два числа [compare_flag]=1 если 0ch меньше 08h иначе [compare_flag]=0
		cmp eax,1
		jne ostNotZero			

		mov dword ptr[flag_ostZero],1		;если остаток ноль то flag_ostZero == 1
ostNotZero:
		mov dword ptr[rez],ecx				;[rez]	- количество раз вычитаний	
	
 ;   -    -    -    -    -  Р А С Ч Ё Т   Р А З Н И Ц Ы   С Т Е П Е Н Е Й   P _ D E K   -   D E K :  -   -    -   -    -   -   -
 	mov eax,dword ptr[p_dek]
	cmp eax, 0
	jne stepenNenol
	mov eax,0								;dword ptr[dek]
	mov ebx,0								;mov dword ptr[p_dek],eax
	jmp stepenNenolDalee
stepenNenol:
	mov eax,dword ptr[p_dek]
	mov ebx,dword ptr[dek]
stepenNenolDalee:
	sub eax,ebx
											;результат разницы степеней в eax 	
	push 0
	push eax
	call stepenPRC_h
											;записываем значение dek в p_dek для след цикла
	mov ebx,dword ptr[dek]
	mov dword ptr[p_dek],ebx
											;18 446 744 073 709 551 616 - 1
	
; - - - - У М Н О Ж А Е М  Р Е З У Л Ь Т А  (rezult)   Н А  1 0 - К У  В  Н У Ж Н О Й   С Е П Е Н И - - - - - - 
; расчёт по формуле: rezult  =  [  rezult  * 10(в степени p_dek - dec)  ]   +  [ rez ]
		lea eax,dword ptr[rezult]			;главный результат предыдущего цикла
		push eax							;0ch - адрес умножаемого, произведенния(результата)
		lea eax,dword ptr[eax_h]			;
		push eax							;08h -адрес множителя;eax умножается на десятку в нужной степени
		call API_Multiplier					;функция умножения сверхбольших чисел
; - - - - П Р И П Л Ю С О В Ы В А Е М  К  Р Е З - Т У (rezult) П Р О М Е Ж У Т О Ч Н Ы Й (rez)
	;- - - - - - - eax_h=0- - - - - - - -
		lea eax,dword ptr[eax_h]
		push eax							;0ch - число, кот-e будет заменено destination data
		lea eax,dword ptr[zeroReg]
		push eax							;08h - число, кот-м будет заменено
		call API_Data						;функция пересылки данных

		mov eax, dword ptr[rez]
		mov dword ptr[eax_h],eax
		
		lea eax,dword ptr[rezult]
		push eax							;0ch - слогаемое-сумма
		lea eax,dword ptr[eax_h]
		push eax							;08h - прибавить это число
		call API_add						;функция сложения сверхбольших чисел

; - - - -    у с л о в и е  в ы х о д а  и  в ы в о д  р е з у л ь т а т а   - - - 
	cmp dword ptr[flag_ostZero],1
	je flag_ostZeroProc
	mov eax, dword ptr[dek]
	 cmp eax,0
 jne start_D
; -  -   -    -    К О Н Е Ц   M A I N  C I C L E    О С Н О В Н О Й    Ц И К Л     Д Е Л Е Н И Я -  -   -   -   -   -
	 jmp flag_ostZeroProcEnd

											; тут процедура домножение результата
 flag_ostZeroProc:
											;18 446 744 073 709 551 616 - 1
	push 0				 					; 0ch число, возводимое в степень
	push dword ptr[p_dek]					; 08h степень p_dek - dek
	call stepenPRC_h						; возведение десятки в степень p_dek :
											; расчёт по формуле:
; rezult  =  [  rezult  * 10(в степени p_dek - dec)  ]  		нету +  [ rez ]
	
		lea eax,dword ptr[rezult]			;главный результат предыдущего цикла
		push eax							;0ch - адрес умножаемого, произведенния(результата)
		lea eax,dword ptr[eax_h]			;
		push eax							;08h -адрес множителя;eax умножается на десятку в нужной степени
		call API_Multiplier					;функция умножения сверхбольших чисел

	mov dword ptr[flag_ostZero],0 			; сбрасываем флаг
 flag_ostZeroProcEnd:
											; вывод результата:
			push esi						;0ch - kex64bit1 число, кот-e будет заменено destination data
			lea eax,dword ptr[rezult]
			push eax						;08h - число, кот-м будет заменено
			call API_Data					;функция пересылки данных
divs_end:

	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	POP EBP
RET 8										;18 446 744 073 709 551 616 / 1
API_Divider ENDP

; - - - - - -  В О З В Е Д Е Н И Е   В  С Т Е П Е Н Ь - - - - - - 
stepenPRC_h PROC
	push ebp
	mov ebp,esp
	push ecx
	push edx
	push ebx
	push esi
	push edi
											; 0ch - число, возводимое в степень
											; 08h  - степень
		cmp dword ptr[ebp+08h],0
		je stepenNOL_h
		
			lea eax,dword ptr[eax_h]
			push eax						;адрес числа
			lea eax,dword ptr[zeroReg]
			push eax
			call API_Data
				
			mov 	dword ptr[eax_h],10h
		
		lea eax,dword ptr[ebx_h]
		push eax							;адрес числа
		lea eax,dword ptr[zeroReg]
		push eax
		call API_Data
		
											; mov esi,dword ptr[ebp+0ch];адрес числа
		lea eax,dword ptr[eax_h]
		lea edi,dword ptr[ebx_h]
		
		push edi							;адрес числа
		push eax							;адрес числа
		call API_Data
		
	repeatsStepen_h:
		cmp dword ptr[ebp+08h],1			;cmp [p_dek],0
		je end_repeatsStepen_h
		dec dword ptr[ebp+08h]				;dec[p_dek]
		
		push eax							;[eax_h]
		push edi							;[ebx_h]
		call API_Multiplier
		
		jmp repeatsStepen_h
	stepenNOL_h:
	
			lea eax,dword ptr[eax_h]
			push eax						;адрес числа
			lea eax,dword ptr[zeroReg]
			push eax
			call API_Data
		
			mov dword ptr[eax_h],1
			mov eax,1
	end_repeatsStepen_h:
			mov eax,dword ptr[eax_h]
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	pop ebp
RET 8
stepenPRC_h ENDP
; - - - - - - конец В О З В Е Д Е Н И Е   В  С Т Е П Е Н Ь - - - - - - 
;*********************************
;---===ПРОЦЕДУРА СОБСТВЕННОГО ОКНА===---
											;расположение параметров в стеке
											;ebp+014h - lparam
											;ebp+10h - wparam
											;ebp+0ch - mes
											;ebp+8 - hwnd
WNDPROCO PROC
		PUSH EBP
		MOV EBP, ESP
		PUSH EBX
		PUSH ESI
		PUSH EDI
											;CMP DWORD PTR [EBP+0CH], WM_DESTROY
											;JE WMDESTROY
		CMP DWORD PTR [EBP+0CH], WM_CREATE
		JE WMCREATE
		JMP DEFWNDPROCo
	WMCREATE:
		JMP FINISHo
	DEFWNDPROCo:
											; PUSH DWORD PTR [EBP+14H]
											; PUSH DWORD PTR [EBP+10H]
											; PUSH DWORD PTR [EBP+0CH]
											; PUSH DWORD PTR [EBP+08H]
											; CALL DefWindowProcA@16
		JMP FINISHo
											;WMDESTROY:
											;	PUSH 0;
											;	CALL PostQuitMessage@4;сOOбщение wm_quit
											;	MOV EAX,0
	FINISHo:
		POP EDI
		POP ESI
		POP EBX
		POP EBP
		RET 16
WNDPROCO ENDP


_EXIT:
CALL ExitProcess@4

_TEXT ENDS
END START
