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
	HINST 		DD 0						;���������� ����������
	PA 			DB 'DIAL1',0
	PD			DB 'DIAL2',0
	PMENU DB "MENUP",0
											;������� ��� �������� ������� ������
	 TAB	db 0,1,2,3,4,5,6,7				;8-backspace 9-capsLock
		 db 10,11,12,14,15,16,17,18,19,20	;13-enter
		db 21,22,23,24,25,26,27,28,29,30,31
		DB 32,33,34,35,36,37,38,39,40
		DB 41,42,43,45,47,58,59,60			;48 - ����;   49 - �������;   44 - �������;    46 - �����
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
		
											;����� � ����...		
	id_buttom		dw 0
	keyboard_flag	dw 0
	keyboard_sign_flag	dw 0
	compare_flag	dd 0
	notznak		db ' ',0
	DIV0			DB '������������ ��������!',0
	NOL			DB '0',0
	podcherc		db '-----------------------------',0
	operac		db ' ',0
											;���������� ����������� ������� �����
	h_variable_dimension	dd 0
											;���������� ��� ������� ������
	zeroReg 		dq 0,0,0,0,0,0,0,0,0,0,0,0
											;HEXtoDECtoHEX �������������� ... ������ ���������� 
	hexbase		dq 1,0,0,0,0,0,0,0,0,0,0,0
	h64cf			dd 0					;carry flag
											;��� ���������� ������ ���������� 
	kex64bit1		dq 0,0,0,0,0,0,0,0,0,0,0,0
	  hex64bit1znak	dd 0
	kex64bit2		dq 0,0,0,0,0,0,0,0,0,0,0,0
	  hex64bit2znak	dd 0
	kex64bitresult	dq 0,0,0,0,0,0,0,0,0,0,0,0
											;� ��������� ������
	r1float		dq 0,0,0,0,0,0,0,0,0,0,0,0
	r2float		dq 0,0,0,0,0,0,0,0,0,0,0,0
	floatres		dq 0,0,0,0,0,0,0,0,0,0,0,0

	
											;��� ���������	������ ���������� 
	kex64bit2v		dq 0,0,0,0,0,0,0,0,0,0,0,0
	zaem			dd 0
											;��� ���������	������ ���������� 
	multex		dq 0,0,0,0,0,0,0,0,0,0,0,0
											;��� ������� ������ ���������� 
	rezult  		dq 0,0,0,0,0,0,0,0,0,0,0,0 	;- �������� ���������
	ost 			dq 0,0,0,0,0,0,0,0,0,0,0,0 	;- ���������� ���������
	reg2  			dq 0,0,0,0,0,0,0,0,0,0,0,0  ; ��������
	eax_h			dq 0,0,0,0,0,0,0,0,0,0,0,0  ; ��������������� ����������
	ebx_h			dq 0,0,0,0,0,0,0,0,0,0,0,0	; ��������������� ����������
	ebx_10		dq 16,0,0,0,0,0,0,0,0,0,0,0 	;��� ����������
	esi_h			dq 0,0,0,0,0,0,0,0,0,0,0,0 	; ��������������� �������
	
	rez			dd 0						;���������� ��������� �� ost ��������� reg2
	p_dek			dd 0					;���������� ������� ����������  ��� ���������� �������� reg2 �� 10
	dek			dd 0						;���� ��������� ���������� �� 10
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
	CALL CreateMutexA@12					;������� ������ mutex
	cmp eax,0								;�������� �� ������
	jz _EXIT
	call GetLastError@0						;��������, ��� �� ��� ���������� ������� � ����� ������
	cmp eax,ERROR_ALREADY_EXISTS
	JZ _EXIT
	
	CALL InitCommonControls@0
											;�������� ID ����������
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
	

											;��������� ����
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
		CMP WORD PTR [EBP+10h], 107			;������ �� ������� �����
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
											;������ �� ������ '+'
		CMP WORD PTR [EBP+10h],6			;������ �� ������?
		jne cp1
		mov ebx,2bh
		mov dword ptr[operac],ebx			; +
		mov word ptr[keyboard_flag],1
		cmp word ptr[keyboard_sign_flag],1 	;�������� ������� ������...
		jne flag
		jmp pokaz
		cp1:
											;������ �� ������ '-'
		CMP WORD PTR [EBP+10h],10			;������ �� ������?
		jne cp2
		mov ebx,2dh
		mov dword ptr[operac],ebx			; -
		mov word ptr[keyboard_flag],1
		cmp word ptr[keyboard_sign_flag],1 	;�������� ������� ������...
		jne flag
		jmp pokaz
		cp2:
											;������ �� ������ 'X'  78h
		CMP WORD PTR [EBP+10h],11			;������ �� ������?
		jne cp3
		mov ebx,78h
		mov dword ptr[operac],ebx			; x
		mov word ptr[keyboard_flag],1
		cmp word ptr[keyboard_sign_flag],1 	;�������� ������� ������...
		jne flag
		jmp pokaz
		cp3:
											;������ �� ������ '/'   2fh
		CMP WORD PTR [EBP+10h],12			;������ �� ������  /  ?
		jne cp4
		mov ebx,2fh
		mov dword ptr[operac],ebx	; /
		mov word ptr[keyboard_flag],1
		cmp word ptr[keyboard_sign_flag],1 	;�������� ������� ������...
		jne flag
		jmp pokaz
		cp4:
	
											;������ �� ������ '='
		CMP WORD PTR [EBP+10h],17			;������ �� ������ =   ?
		JnE cp5;
		cmp word ptr[keyboard_sign_flag],1 	;�������� ������� ������...
		je POKAZ
		jmp rauno
		cp5:
											;������ �� ������ '+/-'
		CMP WORD PTR [EBP+10h],18			;������ �� ������ +/-   ?
		JE znalplusminus					;POKAZ
											;������ �� ������ '1'
		CMP WORD PTR [EBP+10h],21			;������ �� ������ 1  ?
		JE button1		
											;������ �� ������ '2'
		CMP WORD PTR [EBP+10h],22			;������ �� ������ 2 ?
		JE button2	
											;������ �� ������ '3'
		CMP WORD PTR [EBP+10h],23			;������ �� ������ 3 ?
		JE button3
											;������ �� ������ '4'
		CMP WORD PTR [EBP+10h],24			;������ �� ������ 4?
		JE button4
											;������ �� ������ '5'
		CMP WORD PTR [EBP+10h],25			;������ �� ������ 5 ?
		JE button5
											;������ �� ������ '6
		CMP WORD PTR [EBP+10h],26			;������ �� ������ 6 ?
		JE button6
											;������ �� ������ '7'
		CMP WORD PTR [EBP+10h],27			;������ �� ������ 7 ?
		JE button7
											;������ �� ������ '8'
		CMP WORD PTR [EBP+10h],28			;������ �� ������ 8?
		JE button8
											;������ �� ������ '9'
		CMP WORD PTR [EBP+10h],29			;������ �� ������ 9 ?
		JE button9
											;������ �� ������ '0'
		CMP WORD PTR [EBP+10h],19			;������ �� ������ 0 ?
		JE button0
											;������ �� ������ ','
		CMP WORD PTR [EBP+10h],44			;������ �� ������ 0 ?
		JE button44

											;������ �� ������ 'bspase'
		CMP WORD PTR [EBP+10h],30			;������ �� ������ bs ?
		JE buttombspase
											;������ �� ������ buttomCE?
		CMP WORD PTR [EBP+10h],31
		je buttomCE
		
			CMP WORD PTR [EBP+10h],1
			JE hotclavishi
			CMP WORD PTR [EBP+10h],8
			JE hotclavishi
			JMP FINISH
			hotclavishi:
											;���� ��������� ��������� ������� ���� ��������������
			CMP WORD PTR [EBP+12h],EN_KILLFOCUS
			JNE L4
											;���� �������������� � �������� 1 ������ �����
			MOV EBX,0
											;������� ��� ������� �������
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
											;���� �������������� � ID1�������� �����
			MOV EBX,0
											;������������� ������� �������
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
											;������� ������2
		PUSH OFFSET TEXT_TWO
		PUSH 150
		PUSH WM_GETTEXT
		PUSH 8								;�� ��������
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		

lea eax,dword ptr[r2float]
push eax									;014h floatPart ������ ����������
lea eax,dword ptr[hex64bit2znak]
push eax 									; 010h ���� �����
lea ecx,dword ptr[kex64bit2]
push ecx									; 0ch	���������� ���� �������� ���������
push offset[TEXT_TWO] 						; 08h ����� �� ������� ��������� ����
CALL AsciiToHex

											;������� ������1 - ���� ��������
		PUSH OFFSET TEXT
		PUSH 150
		PUSH WM_GETTEXT
		PUSH 14								;�� �������� ���� ����� ��������
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		mov bx,word ptr[text]

cmp ebx,0 ;
 jne notfist
											;segment of code were fist run time
		lea eax,dword ptr[kex64bit1]
		push eax							;0ch - �����, ���-e ����� �������� destination data
		lea eax,dword ptr[kex64bit2]
		push eax							;08h - �����, ���-� ����� �������� - base data
		call API_Data						;������� ��������� ������
		 
		 
		mov edx,dword ptr[hex64bit2znak]
		 mov ecx,20h						;offset[operacFIST]  
	 jmp endcalc
 notfist:
											;cmp word ptr[keyboard_sign_flag],1 ;1 - �������� ������� ������
jmp flag_sign_heare
flag:
											;������� ������1 - ���� ��������
		PUSH OFFSET TEXT
		PUSH 150
		PUSH WM_GETTEXT
		PUSH 14								;�� �������� ���� ����� ��������
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		mov bx,word ptr[text]
cmp ebx,0 ;
je wmclose
											;�������� ������� �� ������
											;������� ���� � ���� ��������
		PUSH offset [operac]				;operac
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 14								;�� ��������
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20	
jmp wmclose
flag_sign_heare:

xor esi,esi



; - - - - - - - - - � � � � � �    � � � � � � � � - - - - - - - - 
slojit:
											;��������...
	cmp ebx,2bh
	  jne vichest
	mov ecx,2bh								; operacplus +
	cmp dword ptr[hex64bit1znak],1			; ����� ��� � ������ �����
	 je slogenie
	cmp dword ptr[hex64bit2znak],0 			; ���� ���� �� ������ �����
	  je znakest
	  mov esi,1
	  jmp slogenieOTRC
	  znakest:
	 mov esi,1
	 jmp OTRCslogenie
	  slogenie:
	cmp dword ptr[hex64bit2znak],0 			; ���� ���� �� ������ �����
	  je slogenieOTRC
	OTRCslogenie:
	

	lea eax,dword ptr[kex64bit1]
	push eax								;0ch - ���������-����� �������������
	lea eax,dword ptr[kex64bit2]
	push eax								;08h - ��������� ��� ������������� ����� 
	call API_add							;������� �������� h_�����
	
	lea eax,dword ptr[r1float]
	push eax								;���������-�����	����������
	lea eax,dword ptr[r2float]
	push eax								;��������� ��� ���������� �����
	call API_add							;������� �������� h_�����
jmp ovichest1
; - - - - - - - - -����� � � � � � �    � � � � � � � � - - - - - - - - 	
	

	
; - - - - - - - - - � � � � � �  � � � � � � � � � - - - - - - - 
vichest:
	cmp ebx,2dh								; "-"
	jne umnojit
	mov ecx,2dh								;operacminus
	cmp dword ptr[hex64bit1znak],1  		; ����� ��� � ������ �����
	 je vichitanie
	 cmp dword ptr[hex64bit2znak],0 		; ���� ���� �� ������ �����
	  jne znakest
	  mov esi,1
	  jmp slogenieOTRC
	vichitanie:
	cmp dword ptr[hex64bit2znak],0  		; ���� ���� �� ������ �����
	  je OTRCslogenie
	slogenieOTRC:


	lea eax,dword ptr[kex64bit1]
	push eax								;0ch - ����� �����������-��������
	lea eax,dword ptr[kex64bit2]
	push eax								;08h  - ����� �����������
	CALL API_subtracter						;������� ��������� h_�����
 
 
											; lea eax,dword ptr[r1float]
											; push eax				
											; lea eax,dword ptr[r2float]
											; push eax				
											; call API_subtracter			;������� ��������� h_�����
 
mov esi,eax 								;������������ �����...
jmp ovichest1
; - - - - - - - - -����� � � � � � �  � � � � � � � � � - - - - - - - 

; - - - - - - - - - � � � � � �  � � � � � � � � � - - - - - - - - 
umnojit:
	cmp ebx,78h
	jne podelit
	mov ecx,78h								; x
	cmp dword ptr[hex64bit1znak],1  		; ����� ��� � ������ �����
	 je umnogeniebezznaka
	 cmp dword ptr[hex64bit2znak],0 		; ���� ���� �� ������ �����
	  je umnogenie
	 mov esi,1
	 jmp umnogenie
	 umnogeniebezznaka:
	  cmp dword ptr[hex64bit2znak],1 		; ����� ���  �� ������ �����
	  je umnogenie
	  mov esi,1
	umnogenie:
	
	lea eax,dword ptr[kex64bit1]
	push eax								;0ch - ����� �����������, �������������(����������)
	lea eax,dword ptr[kex64bit2]
	push eax								;08h -����� ���������
	call API_Multiplier						;������� ��������� h_�����
	
	lea eax,dword ptr[r1float]
	push eax				
	lea eax,dword ptr[r2float]
	push eax	
	call API_Multiplier						;������� ��������� h_�����
jmp ovichest1
; - - - - - - - - -����� � � � � � �  � � � � � � � � � - - - - - - - - 




; - - - - - - - - - � � � � � �  � � � � � � � - - - - - - - 
podelit:
	cmp ebx,2fh
	jne endcalc
	mov ecx,2fh	;  /
	cmp dword ptr[hex64bit1znak],1  		; ����� ��� � ������ �����
	 je deleniebezznaka
	 cmp dword ptr[hex64bit2znak],0 		; ���� ���� �� ������ �����
	  je delenie
	 mov esi,1
	 jmp delenie
 deleniebezznaka:
	  cmp dword ptr[hex64bit2znak],1 		; ����� ���  �� ������ �����
	  je delenie
	  mov esi,1
delenie:


	lea eax,dword ptr[kex64bit1]
	push eax								;����� ��������, ������� (���������)
	lea eax,dword ptr[kex64bit2]
	push eax								;����� ��������
	call API_Divider						;������� ������� h_�����

	lea eax,dword ptr[r1float]
	push eax				
	lea eax,dword ptr[r2float]
	push eax
	call API_Divider						;������� ������� h_�����
	
jmp ovichest1
; - - - - - - - - - ����� � � � � � �  � � � � � � � - - - - - - - 	


; - - - � � � � � �   � � � � � � � � �   � � � � �  - - - 	
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
; - - - ����� � � � � � �   � � � � � � � � �   � � � � �  - - - 

push ecx									;��������
mov ebx,dword ptr[hex64bit2znak]
push ebx									; hex64bit2znak	����
lea eax,qword ptr[kex64bit2]
push eax									;�������� ��� ����� ��� ��������������
push OFFSET[stringlb]						;����� ����������, ���� ����� ������� ���������
call HexToAscii


lea eax,dword ptr[kex64bitresult]
push eax									;0ch - �����, ���-e ����� �������� destination data
lea eax,dword ptr[kex64bit1]
push eax									;08h - �����, ���-� ����� ��������
call API_Data


mov ebx,ecx
mov ecx,20h


push ecx									;��������
push edx									;����
mov dword ptr[hex64bit1znak],edx
lea eax,qword ptr[kex64bitresult]
PUSH eax									;�������� ��� ����� ��� ��������������
push OFFSET[RESULT]							;����� ����������, ���� ����� ������� ���������
call HexToAscii



											;��������� � ������ ����� ���������
		PUSH OFFSET RESULT
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 8								;2;�� ��������
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		
											;���������� ���� ��������� �������� 
											; mov dword ptr[operacplus],ebx
		PUSH offset [operac]				;operac
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 14								;�� ��������
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
	
	C1:
											;����� � �������� ���������� ��������
		PUSH OFFSET stringlb
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		jmp nearclose
		
	dnl:
											;������� � ������ ����� "������ �� ���� ������!"
		PUSH OFFSET DIV0
		PUSH 0
		PUSH LB_ADDSTRING					; WM_SETTEXT
		PUSH 102							;�� ��������
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		
		nearclose:



											;������ �� ������ '='
	RAUNO:
		CMP WORD PTR [EBP+10h],17			;������ �� ������ = ?
		JNE vivodresult						;znalplusminus
		
	mov word ptr[keyboard_sign_flag],1
											;����� � �� �����...
		mov ecx,3Dh							;offset[operacFIST]
		mov edx,dword ptr[hex64bit1znak]
		
		push ecx							;��������
		push edx 							;1����
		  lea eax,qword ptr[kex64bit1]
		push eax							;�������� ��� ����� ��� ��������������
		push OFFSET[stringlb]				;����� ����������, ���� ����� ������� ���������
		call HexToAscii
		
		xor edx,edx
		mov dword ptr[hex64bit1znak], edx

											;��������� � ������ ����a �����
		PUSH OFFSET stringlb
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 8								;2;�� ��������
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		
											;������  ���� �� ���� ��������
		PUSH 0								;offset [notznak]
		PUSH 0
		PUSH WM_SETTEXT
		PUSH 14								;�� ��������
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
	
											;����������� ��� �������� � ���������
		PUSH OFFSET [podcherc]
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
	
											;��� ��������� ��������� � ���������
		PUSH OFFSET stringlb
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20

											;������ ������ �� ����������� � ���������
		PUSH OFFSET [notznak]
		PUSH 0
		PUSH LB_ADDSTRING
		PUSH 102
		PUSH DWORD PTR[EBP+08h]
		CALL SendDlgItemMessageA@20
		
											;������� ����� �� ����������� � ���������
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
											;������ �� ������ '+/-'
		 CMP WORD PTR [EBP+10h],18			;������ �� ������?
		 JNE button1
											;������� ������2
			PUSH OFFSET TEXT_TWO
			PUSH 150
			PUSH WM_GETTEXT
			PUSH 8							;�� ��������
			PUSH DWORD PTR[EBP+08h]
			CALL SendDlgItemMessageA@20
			
			 lea eax,dword ptr[r2float]
			 push eax						;014h floatPart ������ ����������
			 lea eax,dword ptr[hex64bit2znak]
			 push eax 						; 10h ���� �����
			 lea ecx,qword ptr[kex64bit2]
			 push ecx						;0ch	���������� ���� �������� ���������
			 push offset[TEXT_TWO] 			; 08h  ����� �� ������� ��������� ����
			 CALL AsciiToHex
	
			CMP dword ptr[hex64bit2znak],0
			JE TET
			MOV ESI,0
			JMP TET1
			TET:
			MOV ESI,1
			TET1:
			
			push 20h						;��������
			push ESI						;����
			  lea ecx,qword ptr[kex64bit2]
			PUSH ecx						;�������� ��� ����� ��� ��������������
			push OFFSET[TEXT_TWO]			;����� ����������, ���� ����� ������� ���������
			call HexToAscii
			
											;��������� � ������ ����� ���������
			PUSH OFFSET [TEXT_TWO]
			PUSH 0
			PUSH WM_SETTEXT
			PUSH 8							;2;�� ��������
			PUSH DWORD PTR[EBP+08h]
			CALL SendDlgItemMessageA@20
			
											;���������� ����� � lb
			push 8 							;�� ���� �����
			call SetFocus@4
											; ������ �� ������ ' 1 '
	button1:
		 CMP WORD PTR [EBP+10h],21			;������ �� ������ 1 ?
		 JNE button2
		 mov word ptr[id_buttom],31h
		 jmp just_do_it
	button2:
		 CMP WORD PTR [EBP+10h],22			;������ �� ������ 2 ?
		 JNE button3
		 mov word ptr[id_buttom],32h	
		 jmp just_do_it
	button3:
		 CMP WORD PTR [EBP+10h],23			;������ �� ������ 3?
		 JNE button4
		 mov word ptr[id_buttom],33h	
		 jmp just_do_it
	button4:
		 CMP WORD PTR [EBP+10h],24			;������ �� ������ 4?
		 JNE button6
		 mov word ptr[id_buttom],34h	
		 jmp just_do_it
	button5:
		 CMP WORD PTR [EBP+10h],25			;������ �� ������ 5 ?
		 JNE button6
		 mov word ptr[id_buttom],35h	
		 jmp just_do_it
	 button6:
		 CMP WORD PTR [EBP+10h],26			;������ �� ������ 6 ?
		 JNE WMCLOSE
		 mov word ptr[id_buttom],36h
		 jmp just_do_it
	 button7:
		 CMP WORD PTR [EBP+10h],27			;������ �� ������ 7 ?
		 JNE button8
		 mov word ptr[id_buttom],37h	
		 jmp just_do_it
	 button8:
		 CMP WORD PTR [EBP+10h],28			;������ �� ������ 8 ?
		 JNE button9
		 mov word ptr[id_buttom],38h	
		 jmp just_do_it
	 button9:
		 CMP WORD PTR [EBP+10h],29			;������ �� ������ 9?
		 JNE button0						;button0
		 mov word ptr[id_buttom],39h	
		 jmp just_do_it
	 button0:
		 CMP WORD PTR [EBP+10h],19			;������ �� ������ 0 ?
		 JNE button44						;WMCLOSE;button0
		 mov word ptr[id_buttom],30h
		 jmp just_do_it
	 button44:
		 CMP WORD PTR [EBP+10h],20			;������ �� ������ �����/������� ?
		 JNE buttombspase					;WMCLOSE;button0
		 mov word ptr[id_buttom],2ch
		 jmp just_do_it
	
	buttombspase:
		CMP WORD PTR [EBP+10h],30			;������ �� ������ buttombspase?
		 JNE buttomCE
		 mov word ptr[id_buttom],00h
		 jmp just_do_it
	 buttomCE:
		CMP WORD PTR [EBP+10h],31
		 JNE WMCLOSE						;button0
		mov word ptr[keyboard_flag],1		; mov word ptr[id_buttom],00h
		 
		 just_do_it:
		 mov word ptr[keyboard_sign_flag],1 ;�������� ������� ������
											;������� ������2
			PUSH OFFSET TEXT_TWO
			PUSH 150
			PUSH WM_GETTEXT
			PUSH 8							;�� ��������
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
	MOV ECX,0200h							;���������� ������ ������
	XOR AL,AL
	REPNE SCASB								;����� ������ "0"
	SUB EDI,EBX								;������ ������ ������� "0"
	MOV EBX,EDI
	DEC EBX
	MOV EDI,OFFSET TEXT_TWO

	xor eax,eax
	mov ax,word ptr[id_buttom]

	CMP WORD PTR [EBP+10h],30				;������ �� ������ buttombspase?
	JNE adddigit
	cmp byte ptr[edi+ebx-3],20h  			;���� ������
	je zero
	cmp byte ptr[edi+ebx-3],2dh  			;���� �����
	je zero
	mov byte ptr[edi+ebx-2],00h 			;���� �� ������ � �� ����� �� ���� ������ ���������� �����
	jmp adddigit
	zero:
	mov byte ptr[edi+ebx-2],30h
	mov byte ptr[edi+ebx-3],20h
	jmp adddigit
	adddigit:								;������ �� ������� 1,2,3...
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
			 push eax						;014h floatPart ������ ����������
			 lea eax,dword ptr[hex64bit2znak]
			 push eax 						;010h ���� �����
			 lea ecx,qword ptr[kex64bit2]
			 push ecx						;0ch	1-� ���������� ���� �������� ���������
			 push offset[TEXT_TWO] 			;08h  ����� �� ������� ��������� ����
			 CALL AsciiToHex
	

			MOV ESI,dword ptr[hex64bit2znak]

			
			push 20h						;��������
			push ESI						;����
			lea ecx,qword ptr[kex64bit2]
			PUSH ecx						;�������� ��� ����� ��� ��������������
			push OFFSET[TEXT_TWO]			;����� ����������, ���� ����� ������� ���������
			call HexToAscii
			
											;��������� � ������ ����� ���������
			PUSH OFFSET [TEXT_TWO]
			PUSH 0
			PUSH WM_SETTEXT
			PUSH 8							;2;�� ��������
			PUSH DWORD PTR[EBP+08h]
			CALL SendDlgItemMessageA@20
			

		 
		 
	 WMCLOSE:
		CMP DWORD PTR [EBP+0Ch],WM_CLOSE
		JNE L1
	closewin:
											;����� ������� �� �������� ���� ������� ������
		PUSH 0
		PUSH DWORD PTR[EBP+08h]
		CALL EndDialog@8
		JMP FINISH
		
	L1:
		CMP DWORD PTR[EBP+0Ch],WM_INITDIALOG
		JNE FINISH
											;��������� �����������
		PUSH 100							;ID �����������
		PUSH HINST							;ID ���������
		CALL LoadIconA@8
											;���������� �����������
		PUSH EAX
		PUSH 0								;��� ���� - ���������
		PUSH WM_SETICON
		PUSH DWORD PTR [EBP+08h] 			;ID ����
		CALL SendMessageA@16
		
											;��������� ����
	PUSH OFFSET PMENU
	PUSH HINST
	CALL LoadMenuA@8
	
											;���������� ����
	PUSH EAX
	PUSH DWORD PTR [EBP+08h]
	CALL SetMenu@8
	
											;version ��������� � ���������
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

			  mov esi,dword ptr[ebp+08h]	;����� ������� ���������� kex64bit
			  mov ebx,10					;decimalbase 0Ah
			  mov ecx,80					;h_variable_dimension
		; - - - - � � � � - - - - -
		cicl_API_HexToAscii:
			  sub ecx,4
			  
			  mov eax,dword ptr[esi+ecx]	;�������� ������� ����������
			  div ebx						;����� eax �� 10(ebx)
			  mov dword ptr[esi+ecx],eax	;��������� �������
			  
			  cmp ecx,0
			  je exit_API_HexToAscii
			  jmp cicl_API_HexToAscii
		exit_API_HexToAscii:
		; - - - - / � � � � - - - - -
	pop ecx
	POP EBX
	POP EAX
	POP ESI
	POP EBP
	RET 4
API_HexToAscii ENDP


	
HexToAscii PROC
											;014h ��������
											;010h ���� ����� [hex64bitznak]
											;0ch ��������, ��� ����� ��� ��������������
											;08h ����� ��������� ����������, ���� ����� ������� ���������
	push ebp
	mov ebp,esp
	push eax
	push edi
	push ecx
	push edx
	push ebx
			MOV esi,DWORD PTR[EBP+0ch]		;esi - ������� ���������� 
			xor ecx,ecx						;������� ��� �������������� ����� �� �����
			xor edi,edi						;������� �� 3
		repeat6:
			;- - -  � � � � � � �   �   DEC - - - - - 
			  xor edx,edx					;���������� ������� �� �������!
			  PUSH[ebp+0Ch]
			  CALL API_HexToAscii
			;- - - - � � � � � � �  �   ASCII - - - - 
											;� DH � ������ ������ ������� �� �������!!!!!
			  ADD DL,'0'					;����������� � ������� (�����)���� ����� (3) � ��� ����� ������ ��� �������
			 
			  ; - - - - � � � � � � � � � �   � � � � � � � � �   � � � � � � � � � �  - - - 
				cmp edi,3					;���������� ������, ���������� ��������
				jne potri
				inc ecx						;������� ����� � ����� ������
				push 20h					;����������� ������
				xor edi,edi					;���� ���������� ������, ���������� edi
			  potri:
				inc edi						;���� ������ ��  ���������� �������������� edi
			   ; - - - - / � � � � � � � � � �   � � � � � � � � �   � � � � � � � � � �  - - - 
			
			;- - - - - � � � � � � � � � �   � � � - �   �   � � � � - - - - - - 
				PUSH EDX	
				inc ecx						;������� ����� � ����� ������
			  
		; - - - - - - -� � � � � � �  � � � � � �  - - - - - 
			  mov esi,dword ptr[ebp+0ch]	;esi - ������� ���������� kex64bit ������������ � ����!
			 ; - - - - - - - � � � � � � � � � �   �   � � � � � � �   � � � � � � � � � � - - - - - - - - - - - - 	
			push esi						;����� ������� h_����� 0ch
			lea eax,dword ptr[zeroReg]
			push eax						;����� ������� ����� 08h
			call API_cmp					;�������� ��� ����� [compare_flag],1 - 0ch ������ 08h ����� [compare_flag],0; eax,1 - ���� ��������� �����
			
			cmp eax,1						;���� h_����� ����� 0...
			jne repeat6
		;/ - - - - - - / REPEAT6  - - - - - - - 
		
		; - - - - - - � � � � � � � � � �  � � � � � �   ( � � � � �   � �   � � � � � � �   �   � � � � � � � � � ) - - - - - - - -
			mov edi,dword ptr[ebp+08h]		;����� ���� ����� ������� ���������
			xor edx,edx
			  mov al,byte ptr[ebp+014h ]	;����� ����� �������� =
			  mov byte ptr[EDI],al			;��� ����������� � ������ ���� �������� =
			  inc edx
			  mov byte ptr[EDI+1],20h		;��� ����������� ������
			  inc edx
			  mov byte ptr[EDI+2],20h		;��� ��������� ������
			  inc edx
			cmp byte ptr[ebp+10h],1			;���� h_�����
			je positiveascii
			; - - negativascii - - 
			mov byte ptr[EDI+3],2dh			;������������� ����� ����� ������, ���� ��� �������������
			inc edx
			positiveascii:
		; - - - - - - / � � � � � � � � � �  � � � � � �   ( � � � � �   � �   � � � � � � �   �   � � � � � � � � � ) - - - - - - - -
		
		;- - - - � � � � � � � � �   � � � � � � - - - -
		repeat8:		
			xor eax,eax
			; - - - - - � � � � �   � �   � � � � �  � � � � �  - - - - - - - 
			POP EAX				
			mov byte ptr[EDI+edx],al		;���������� � ������
			inc edx							;���������� �������� � ������
			dec ecx
		jnz repeat8
			mov byte ptr[EDI+edx],2eh		;�������� �����
			; - - - - - - -  � � � � � � �   � � � � �  + edi - - - - - - - - - - - - - 
			nop
			; - - - - - - - / � � � � � � �   � � � � �  + ���������� �������� edi
			mov byte ptr[EDI+edx+1],0		;�������� ����, ��� ��������� ������
	pop ebx
	pop edx
	pop ecx
	POP EDI
	POP EAX
	POP EBP
RET 16										;32
HexToAscii ENDP
; - - - - -�����  H E X   T O   A S C I I   M O D U L E - - - - 

; - - - - - A S C I I   T O   H E X   M O D U L E - - - - 
API_AsciiToHex PROC
											;010h - ������� �������
											;0ch - ���-� � �����	
											;08h - �����
	push ebp
	mov ebp,esp
	push edi
	push ecx
			mov edi,dword ptr[ebp+08h]		;��������� hex �����
			xor esi,esi						;mov esi,dword ptr[ebp+010h]	;������� esi
			xor ecx,ecx
			cicl_API_AsciiToHex:
				  mov edx,dword ptr[ebp+0ch]	;adress hexbase
				  mov eax,dword ptr[edx+ecx]	;hexbase
			xor edx,edx
			mul ebx							;������e� hexbase �� h_����� , ����� � eax [EDX:EAX] 
			add eax,esi						;���������� ��� ��������� �������� 
			jnc api3
				inc edx						; ���� �������, �� ��������� ���
			api3:
			mov esi,edx						;��������� ���� ������� � esi
			xor edx,edx						;�������� edx
			add eax,dword ptr[h64cf]		;���������� �������
			jnc api31
				inc edx	; 
			api31:
				  add dword ptr[edi+ecx],eax	;��������� ��������� h_�����
			jnc api64cf3
				inc edx
			api64cf3:
			mov dword ptr[h64cf],edx		;��������� �������
			add ecx,4						;��������
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
			mov eax,dword ptr[hexbase+ecx]	; eax ����� ����� ���������
			push edx						;�������
			mov  ebx,0ah					;��� � ������			
			mul ebx							;������ ��� �.���. �� 0�h 
			pop ebx							;������� �� �����
			add eax,ebx						;����. ������� � ���-��
			   jnc hexbosenocarry	
				inc edx						;���� �� ����� � ������� (�� ����� ���� ������ ��������)
			   hexbosenocarry:
			mov dword ptr[hexbase+ecx],eax   ;���� ���-� � ����������
			 add EcX,4						;��������
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
			mov edi,dword ptr[ebp+08h]		;� edi - ����� TEXT
			xor edx,edx
			xor ecx,ecx
	; - - - - - - � � � �  � � � � � � � � - - - - - 
		CKL1:
			CMP BYTE PTR[edi+ECX],0    		;�� ����� �� ������ ��������� ������
			jne compare_fist
			cmp edx,0						;�������� ���� �� ������ ���� ����� (�����)  � ���� �����?
			jne kexvoid
			inc edx
			push 0							; ���� ���� ������ � ���� ����� �� ������ "0"
			jmp  kexvoid
		compare_fist:
			CMP BYTE PTR[edi+ecx],2ch		; 2ch - ������� �  ascii (american standart code for information interchange)
			JE kexvoid
											;mov dword ptr[flag_seporate_dec_float],1
											;mov dword ptr[dec_symbols],edx
											;xor edx,edx
											;jmp skipthis
			CMP BYTE PTR[edi+ecx],2Eh		; 2eh - ����� �  ascii (american standart code for information interchange)
			JE kexvoid
			CMP BYTE PTR[edi+ecx],20h		; - ������
			je skipthis	
			CMP BYTE PTR[edi+ecx],30h		; - �����
			Jb skipthis
			CMP BYTE PTR[edi+ecx],39h		; - �����
			jg skipthis
		;- - - - A S C I I   ->  U N P C K B C D - - - - 	
			 cmp edx,0200h					;����������� �� 100 ����
			 je kexvoid
			xor eax,eax
			MOV AL,BYTE PTR [edi+ECX]   	;������������� ��������� � ����� ������...
			SUB AL,'0' 						;ascii->unpck ������ 01 02 03...
			push eax						;������� � ����!!!!
			INC EDX 						;���������� �������� � ����� �� ���� (��� ����� ��� �������)
		skipthis:
			INC ECX							;���������� �������� � TEXT (��������� ������)
		JMP CKL1
	; - - - - - -����� � � � �  � � � � � � � � - - - - - 		


	; - - - - -  � � � � � � � � � �  � � � � � � � � � � � � � �  � � � � � unpckBCD -> hex- - - - - - 		
		kexvoid:
											;��������� hexbase
			lea eax,dword ptr[hexbase]
			push eax						;0ch - �����, ���-e ����� �������� destination data
			lea eax,dword ptr[zeroReg]
			push eax						;08h - �����, ���-� ����� ��������
			call API_Data					;������� ��������� ������

											;��������� ������ ���� ����� ������� ���-�
			push [ebp+0ch]					;0ch - �����, ���-e ����� �������� destination data
			lea eax,dword ptr[zeroReg]
			push eax						;08h - �����, ���-� ����� ��������
			call API_Data					;������� ��������� ������
			
			mov dword ptr[hexbase],1		; o�� ��� �����
			
			mov ecx,edx						;���������� �������� � kex64bit
	; - - - - -�����  � � � � � � � � � �  � � � � � � � � � � � � � �  � � � � � unpckBCD -> hex- - - - - - 			
			
	; - - - - -  � � � � � � � � � � � � � �  � � � � � unpckBCD -> hex- - - - - - 		
		kex64bit:
			pop ebx							;����� �� �����
		; - - - - -  � � � � � � � � � � � � � �  � � � � �  � � � � � - - - - - - 
			lea eax,dword ptr[hexbase]
			push eax						;0ch - ���-� � �����	
			push [ebp+0ch]					;08h - �����
			call API_AsciiToHex

		;- - - - � � � � � � � � � � � � �  � � � � � � �  � � �   � � � � � � - - - -
			push 0
			call API_HexBose
			dec ecx							;���������� �������� � kex64bit - -
		jne kex64bit
	; - - - - -�����  � � � � � � � � � � � � � �  � � � � � unpckBCD -> hex- - - - - - 		
		
		;- - - - ���� ����� - - - - 
			mov edx,dword ptr[ebp+08h]
			 CMP BYTE PTR[edx+3],2Dh
			 jne R
			 mov eax,dword ptr[ebp+10h]
			 mov dword ptr[eax],0			;���� ����� ����
			 jmp r2
		R:
			mov eax,dword ptr[ebp+10h]
			mov dword ptr[eax],1			;����a ������ ���   -
		r2:
											;������� �������� �������� ����� ������� ���������� � ������ 
			mov edi,dword ptr[ebp+08h]
			mov dword ptr[edi],0
											;������.����
	pop eax
	POP EDI
	POP EBP
RET 16;28
AsciiToHex ENDP
; - - - - - �����  A S C I I  T O   H E X   M O D U L E - - - - 


;- - - - - - - � � � � � �   � � � � � � � � � - - - - - - 
;- - - - - ����������� 2-� h_�����  ��� ������������ ����� - - - - - - 	
											; [compare_flag],0 - 1-e ����� ������ ��� ����� 2-��
											; [compare_flag],1 - ������! 
											; eax,1 - �����
											; eax,0 - �� �����
API_cmp PROC
	PUSH EBP
	MOV EBP,ESP
	push ecx
	push edx
	push ebx
	push esi
	push edi
		mov dword ptr[compare_flag],0		;����������... 4 294 967 295
		mov esi,dword ptr[ebp+0ch]			;����� bit1	18 446 744 073 709 551 615
		mov edi,dword ptr[ebp+08h]			;����� bit2
		xor ecx,ecx
		mov edx,1							;���� ��������� 1-����� �����
	cicl_apicmp:	
		mov eax,dword ptr[esi+ecx]			; bit1
		mov ebx,dword ptr[edi+ecx]			; bit2	
		
		cmp eax,ebx							;����� �� ����� ����� �����
		je bit_end							;���� �����, �� ��������� ������� ����
		xor edx,edx	;
		cmp eax,-1							;��������� ������� � ���, ���  0ffffffffh - ��� -1
		je bit_ge							;������ ����� ������ ��� �����
		cmp ebx,-1
		je bit_b							;������ ����� ������

		cmp eax,ebx
		ja bit_ge							;���� ���� ����� ������ ������ ���� �� ������� 
											;���� ���� �����  ������ ������ �� ���� ����
	bit_b:
		mov dword ptr[compare_flag],1 		;������ ����� ������
		jmp bit_end
	bit_ge:
		mov dword ptr[compare_flag],0 		;������ ����� ������ ��� �����
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
;- - - - - - -����� � � � � � �   � � � � � � � � � - - - - - -

; - - - - - -  � � � � � �  � � � � � � � � - - - - - - - - - - - - - - - - 
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
		add ebx,4							;��� ���������� ebx+ecx �� ����  �� 4 ������
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
; - - - - - - ����� � � � � � �  � � � � � � � � - - - - - - - - - - - - - - - - 


; - - - - - -  � � � � � �  � � � � � � � � �   � � � � � - �  � � � � � �  - - - 
;��� ��������� �������� ������������ 08h - zeroReg dq 0,0,0,0,0
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
			mov edi,dword ptr[ebp+08h]		;����� �����
			mov eax,dword ptr[edi+ecx]		;eax - �����
			mov edi,dword ptr[ebp+0ch]		;����� ����� ��� ������
			mov dword ptr[edi+ecx],eax		;dword - �����, ���. ����� ��������
			add ecx,4
			cmp ecx,80						;�� 4 ������ ��� ������
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
; - - - - - -  ������ � � � � �  � � � � � � � � � � � � � � - �  � � � � � �  - - -

 ; - - - - - -  � � � � � �  � � � � � � � � �  - - - - - - - - - - - - - 

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
	push eax								;0ch - �����, ���-e ����� �������� destination data
	lea eax,dword ptr[zeroReg]
	push eax								;08h - �����, ���-� ����� ��������
	call API_Data							;������� ���������� ������

	xor ecx,ecx
	multipl:
		mov esi,dword ptr[ebp+08h]			;bit2 ������ ���������� 0 4 8 12
		mov ebx,dword ptr[esi+ecx]			;bit2 �������� ������� ��������
		xor esi,esi
		xor edx,edx
		xor edi,edi
		push ecx
	    multipl1:
		push ebx
		mov ebx,dword ptr[ebp+0ch]			;bit1 ����������,������������- ���������
		mov eax,dword ptr[ebx+esi]			;bit1 0 4 8 12 ������ ���
		pop ebx
		mul ebx
		add eax,edi							;� ������ �������� ����
		  jnc cmul							;� ������ �������� ������ �������
			inc edx							;� ������ �������� �� ���������
		cmul:
		add eax,dword ptr[multex+ecx]		;������ ���������� 0 4 8 12
		jnc cmul2
			inc edx
		cmul2:
		mov edi,edx							;�������
		mov  dword ptr[multex+ecx],eax		;������ ���������� 0 4 8 12
		add ecx,4
		add esi,4
											; �������� ����� ��� ���������� ����������� ������������
		cmp esi,030h						;�������� 4 ����� �� 4 �������� kex64bit1[0-12]
	    jne multipl1
	
		pop ecx
											; �������� ����� ��� ���������� ����������� ������������
		mov dword ptr[multex+ecx+030h],edx	;�������
		add ecx,4
											; �������� ����� ��� ���������� ����������� ������������
		cmp ecx,030h
	jne multipl

											;��������� ������	
	push [ebp+0ch]							;0ch - �����, ���-e ����� �������� destination data
	lea eax,dword ptr[multex]
	push eax								;08h - �����, ���-� ����� ��������
	call API_Data							;������� ���������� ������

	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
RET 8
API_Multiplier  ENDP
 ; - - - - - -�����  � � � � � �  � � � � � � � � �  - - - - - - - - - - - - - 
 
 
 ; - - - - - -� � � � � �   � � � � � � � � �  - - - - - - - - - - - - -
 ;- - - - - -API   � � � � � � � � � - - - - - 
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
		mov esi,dword ptr[ebp+0ch]			;����� ������� ����a  kex64bit1
		mov edi,dword ptr[ebp+08h]			;����� ������� �����  kex64bit2

		push esi							;����� ������� �����
		push edi							;����� ������� �����
		call API_cmp						;�������� ��� ����� [compare_flag]=1 ���� 0ch ������ 08h ����� [compare_flag]=0
	;- - - ������� ��� ���������� ������������ ���������� - - - -
		lea eax,dword ptr[kex64bit2v]
		push eax							;0ch - ����� �����, ���-e ����� �������� destination data
		push edi							;08h - ����� �����, ���-� ����� �������� (������� �����)
		call API_Data						;������� ��������� ������
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	
	xor edi,edi
	 rData:
											;���������� �� ��������
		cmp dword ptr[compare_flag],0		;compare_flag - ���� �������������
		jz nenaoborot
		mov ebx,dword ptr[esi+edi]			;0�h
		mov eax,dword ptr[kex64bit2v+edi]	;
		jmp naoborot
		nenaoborot:
		mov eax,dword ptr[esi+edi]			;0ch
		mov ebx,dword ptr[kex64bit2v+edi]	;
		naoborot:
	
	;- - - - - - - - - - - - - �  � � � � � � � � � �   � � � � �   � � �   � � � �  - - - - - - - - - - - - - 	  
		cmp dword ptr[zaem],0					;������ ����������� ���� � ����
		jz not_was_zaem
		
			cmp dword ptr[compare_flag],0		;compare_flag - ���� ������������� ��������
			jz  zaem_kex64bit1_4_4
			
			; - - - - - - - - ����� ���� ����� compare_flag=1 - - - - - - - - - - - - - - - 
				mov ecx,dword ptr[kex64bit2v+edi+4]	; ������� "�������" 
				jmp api_sub
				
			; - - - - - - - - ����� ���� ����� compare_flag=0 - - - - - - - - - - - - - - - 	
			 zaem_kex64bit1_4_4:
				mov ecx,dword ptr[esi+edi+4]	;������� "�������" 
				
			api_sub:
				cmp ecx,0					;���� ������� ������� ���� (�� � ���������� �������� ��� ���, � � ���� ���)
				jnz starshi_desiatok_not_was_zero
				;- - - ���� ������� ������� ���� - - - 
					mov ecx,0ffffffffh			;� edx ���������� ����� ������� 32������ ����������������� �����
					mov dword ptr[zaem],1		;������������� ������ ����
					jmp save_digit
				;- - - ���� ������� ������� �� ���� - - - 	
				starshi_desiatok_not_was_zero:
					dec ecx;dword ptr[kex64bit2v+4]	;�� �������� �������� �������� ������� (�������������� �������) 
					mov dword ptr[zaem],0		;��������� ������ ����
					
			;- - - -  ��������� ������� ������� - - - - 
			save_digit:
			cmp dword ptr[compare_flag],0		;compare_flag - ���� ������������� ��������
			jz  jhkgg
				mov dword ptr[kex64bit2v+edi+4],ecx
				jmp not_was_zaem
			jhkgg:
				mov dword ptr[esi+edi+4],ecx
				
				

		 
		;- - - - - - - - - - - - - �  � � � � � � � � � �   � � � � �  � � � � � �   � � � � �  - - - - - - - - - - - - - 
		; - - - - - - - - - - - - - - � � � � � � � �   � � � � �  � � � �  - - - - - - - - - - - - - 		
		 not_was_zaem:						;
		cmp eax,ebx							;cmp kex64bit1, kex64bit2v
		je tutaka							;���� �����
		cmp eax,0ffffffffh					;cmp kex64bit1, [����� ������� ����� ��� �� -1]
		je tutaka							;���� ����o
		cmp ebx,0ffffffffh					;cmp kex64bit2v, [����� ������� �����]
		je zaem1							;���� ����o
		cmp eax,ebx							;cmp kex64bit1, kex64bit2v
		jb zaem1 							;����  ������ � ����� �������� �������
		
		 ; - - - - - - - - - - - - -  � � � � � � � � �  � � � � � � � �  - - - - - - - - - - - - - -  
		tutaka:
		sub eax,ebx							;������� �� ������� ������ �������
		mov dword ptr[esi+edi],eax 			;�������� �������� ������� � ������ ������� 
		jmp otric4							;to the end...

		
		
		; - - - - - - - - - - - - - - - � � � � �  � � �  � � � � � � � � � �  � � � � � - - - - - - - - - - - - 
		zaem1: 								;���� 1 ����� ������ 2-�� � ����� �������� �������
			xchg eax,ebx					;������ ������� �����
			sub eax,ebx						;�������� �� ������� ����� ������ � ���������� ��� � eax
			cmp dword ptr[compare_flag],0	;compare_flag - ���� �������������
			jz  zaem_kex64bit1_4
				mov edx,dword ptr[kex64bit2v+edi+4]	;���������� � edx ������� �������  
				jmp zaem_kex64bit2_4
			zaem_kex64bit1_4:
				mov edx,dword ptr[esi+edi+4]		;���������� � edx ������� ������� 
			zaem_kex64bit2_4:
				cmp edx,0 					;
				jz zaemzero					;���� ������� ������� ������� �� ����� ...
				
				; - - - - - - - - - - - - - -�����, ��� ������� "�������" �� ���� - - - - - - - - - - - - - 
				mov ebx,0ffffffffh			;���������� ����� ������� 32������ ����������������� �����
				sub ebx,eax					;������� ����� ����� ������� ������ � ����������� "�����������" �������
				inc ebx						;��������� � ���������� ����������� 1 � ������� �������
				mov dword ptr[esi+edi],ebx 	;�������� �������� ������� � ������ �������-���������
				dec edx						;�� �������� �������� �������� ������� (�������������� �������)
				jmp  otric5					;to the end...
					
							; - - - - - - - - - - - - - - ����� ��� ������� "�������" ����� ����- - - - - - - - - - - - - 
							zaemzero:
								mov ebx,0ffffffffh			; ���������� ����� ������� 32������ ����������������� �����
								sub ebx,eax					;������� ����� ����� ������� ������ � ����������� "�����������" �������
								inc ebx						; ��������� � ���������� ����������� 1 � ������� �������-���������
								mov dword ptr[esi+edi],ebx 	;�������� �������� ������� � ������ �������-���������
								mov edx,0ffffffffh			;���������� � ������� ������� ����� ������� �����
								inc dword ptr[zaem]			;� ���������� � ���������� ����  �������
								
			; - - - - - - - - - - - - ���������� �������� ������� �����- - - - - - - - - - - - - - - 	
			otric5:		
				cmp dword ptr[compare_flag],0	;
				jz  zaem_kex64bit1_4_3
				mov dword ptr[kex64bit2v+edi+4],edx			;�������������� ������� �������
				jmp zaem_kex64bit2_4_3
			zaem_kex64bit1_4_3:
				mov dword ptr[esi+edi+4],edx				;write greate digit
			zaem_kex64bit2_4_3:

			
			; - - - - - - - - - - - - - - - - - - - - - - - - - - - 
			otric4:							;end...
			
			 add edi,4
			 cmp edi,80						;����� 96 - 4 (12 ������� ����)=4�2�12=96
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
; - - - - - -�����  API  � � � � � � � � �  - - - - - - - - - - - - -



 ; - - - - - -� � � � � �   � � � � � � �  - - - - - - - - - - - - -
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
		mov esi,dword ptr[ebp+0ch]			;����� ������� ����a  kex64bit1
		mov edi,dword ptr[ebp+08h]			;����� ������� �����  kex64bit2
	;- - - - - � � � � � � � �   � �   � � � � � �   � � � � � � - - - - - - 
	push esi								;����� ������� �����
	push edi								;����� ������� �����
	call API_cmp							;�������� ��� ����� [compare_flag]=1 ���� 0ch ������ 08h ����� [compare_flag]=0
	 cmp dword ptr[compare_flag],1 			;����  1 , �� ������ ����� ������ ������� !
	 je divs_end
	; - - - - - - - � � � � � � � � � �   �   � � � � � � �   � � � � � � � � � � - - - - - - - - - - - - 	
	push edi								;����� ������� ����� 0ch[kex64bit2]
	lea eax,dword ptr[zeroReg]
	push eax								;����� ������� ����� 08h
	call API_cmp							;�������� ��� ����� [compare_flag]=1 ���� 0ch ������ 08h ����� [compare_flag]=0; eax=1 - ���� ��������� �����
	cmp eax,1
	je divs_end								;�� ���� ������ ������ DevideByZeroExctptin result=Quotient(Numerator,Denominator)
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	
; - - - - - - - - - - -  - - I N I T  V A R I A B L E - - - - - - - - - - - - -  
	;- - - - - - - ������ ���������� ������ - - - - - - - - - - - - 
		lea eax,dword ptr[ost]
		push eax							;0ch - �����, ���-e ����� �������� destination data
											;lea eax,dword ptr[kex64bit1]
		push esi							;08h - �����, ���-� ����� ��������
		call API_Data						;������� ��������� ������
	;- - - - - - - rezult=0- - - - - - - -
		lea eax,dword ptr[rezult]
		push eax							;0ch - �����, ���-e ����� �������� destination data
		lea eax,dword ptr[zeroReg]
		push eax							;08h - �����, ���-� ����� ��������
		call API_Data						;������� ��������� ������
	;- - - - - - - - - - - - - - - - - - - - - - - -
		mov dword ptr[p_dek],0
	
	; - - - - - - - - - - - - - - - -   � � � � � � � �  � � � �  � � � � � � � - - - - - - - - - - - - - - - - - - - 
start_D:
	; - - - - - - - - - -���������� � ����� "repeatsD_1"- - - - - - - - - - - - - 
	mov dword ptr[rez],0
	mov dword ptr[dek],0
	
											;������ ���������� ������
		lea eax,dword ptr[reg2]
		push eax							;0ch - �����, ���-e ����� �������� destination data
											;lea eax,dword ptr[kex64bit2]
		push edi							;08h - �����, ���-� ����� ��������
		call API_Data						;������� ��������� ������
											;������ ���������� ������
		lea eax,dword ptr[eax_h]
		push eax							;0ch - �����, ���-e ����� �������� destination data
											;lea eax,dword ptr[kex64bit2]
		push edi							;08h - �����, ���-� ����� ��������
		call API_Data	
											;������� ��������� ���������� ��������� ��������-���������, ����������� �� 10
		lea eax,dword ptr[esi_h]
		push eax							;0ch - �����, ���-e ����� �������� destination data
		lea eax,dword ptr[reg2]
		push eax							;08h - �����, ���-� ����� ��������
		call API_Data						;������� ��������� ������	
	xor ecx,ecx								;���������� ����������
	xor edx,edx
; - - - - - C I C L E 1  "repeatsD_1"- - - - - 
; - - - - ���������� �������A-�������� �� 10 ���� ������ ����� (�������) �� ������ ������ �������- (��������) - - - 
repeatsD_1:
											;�������� �������-�������� �� 10
		lea eax,dword ptr[eax_h]			;kex64bit2
		push eax							;0ch - ����� �����������, �������������(����������)
		lea eax,dword ptr[ebx_10]
		push eax							;08h -����� ��������� ebx_10h
		call API_Multiplier					;������� ��������� ������������ �����
											;���������� � ���������� �����������
											;���� ������, �� ������� ��� ���������� ���������� ������������� ����������
		lea eax,dword ptr[ost]				;kex64bit1
		push eax							;����� ������� ����� 0ch
		lea eax,dword ptr[eax_h]			;[Reg2]
		push eax							;����� ������� ����� 08h
		call API_cmp						;[compare_flag],1 if [ost]< [eax_h];compare_flag],0 if 0ch>08h
		cmp dword ptr[compare_flag],1
		je exit_repeatsD_1
		
		inc ecx 							;inc ���������� ���������� (dek)
											;��������� ��������� ���������� ��������� ��������-���������, ����������� �� 10 - - -
			lea eax,dword ptr[esi_h]		;���������� [reg2]
			push eax						;0ch - �����, ���-e ����� �������� destination data
			lea eax,dword ptr[eax_h]		;[reg2]
			push eax						;08h - �����, ���-� ����� ��������
			call API_Data					;function the change of data
; - - - - - - - - - - - - - - 
jmp repeatsD_1
exit_repeatsD_1:
; - - - ����� C I C L E "repeatsD_1"- - - - - - 

mov dword ptr[dek],ecx						;���������� ���������� ���������� (dek)
											;���� ����� �����������
			lea eax,dword ptr[reg2]			;right rezult
			push eax						;0ch - �����, ���-e ����� �������� destination data
			lea eax,dword ptr[esi_h]
			push eax						;08h - �����, ���-� ����� ��������
			call API_Data					;������� ��������� ������

; - - - - - C I C L E  "repeatsD_2"- - - - - 
; ---�������� �� �������� ��������, ���� �������� �� ������ ������ �������� � ���������� ���������-�������(OST) � ���������� ��������� (REZ)
xor ecx,ecx
    repeatsD_2:

		lea eax,dword ptr[ost]
		push eax							;0ch adress for fist digit
		lea eax,dword ptr[reg2]
		push eax							;08h adress for second digit 
		call API_cmp						;cmp [compare_flag],1 0ch<08h else [compare_flag],0
		cmp  dword ptr[compare_flag],1		;�������� �������-������� � ��������
		je repeatsD_2_end					;�������, ���� �������-������� ������� ��������-���������� 

		lea eax,dword ptr[ost]
		push eax							;0ch adress for fist digit
		lea eax,dword ptr[reg2]
		push eax							;08h adress for second digit 
		 CALL API_subtracter				;������� ��������� h_�����
		 
		inc ecx								;[rez]	- ���������� ��� ���������				

	jmp repeatsD_2
    repeatsD_2_end:
; - - - ����� C I C L E "repeatsD_2"- - - - - - 

		lea eax,dword ptr[ost]				; �������
		push eax							;����� ������� ����a 0ch
		lea eax,dword ptr[zeroReg]			;����
		push eax							;����� ������� ����� 08h
		call API_cmp						;�������� ��� ����� [compare_flag]=1 ���� 0ch ������ 08h ����� [compare_flag]=0
		cmp eax,1
		jne ostNotZero			

		mov dword ptr[flag_ostZero],1		;���� ������� ���� �� flag_ostZero == 1
ostNotZero:
		mov dword ptr[rez],ecx				;[rez]	- ���������� ��� ���������	
	
 ;   -    -    -    -    -  � � � � � �   � � � � � � �   � � � � � � � �   P _ D E K   -   D E K :  -   -    -   -    -   -   -
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
											;��������� ������� �������� � eax 	
	push 0
	push eax
	call stepenPRC_h
											;���������� �������� dek � p_dek ��� ���� �����
	mov ebx,dword ptr[dek]
	mov dword ptr[p_dek],ebx
											;18 446 744 073 709 551 616 - 1
	
; - - - - � � � � � � � �  � � � � � � � �  (rezult)   � �  1 0 - � �  �  � � � � � �   � � � � � � - - - - - - 
; ������ �� �������: rezult  =  [  rezult  * 10(� ������� p_dek - dec)  ]   +  [ rez ]
		lea eax,dword ptr[rezult]			;������� ��������� ����������� �����
		push eax							;0ch - ����� �����������, �������������(����������)
		lea eax,dword ptr[eax_h]			;
		push eax							;08h -����� ���������;eax ���������� �� ������� � ������ �������
		call API_Multiplier					;������� ��������� ������������ �����
; - - - - � � � � � � � � � � � � � �  �  � � � - � � (rezult) � � � � � � � � � � � � � (rez)
	;- - - - - - - eax_h=0- - - - - - - -
		lea eax,dword ptr[eax_h]
		push eax							;0ch - �����, ���-e ����� �������� destination data
		lea eax,dword ptr[zeroReg]
		push eax							;08h - �����, ���-� ����� ��������
		call API_Data						;������� ��������� ������

		mov eax, dword ptr[rez]
		mov dword ptr[eax_h],eax
		
		lea eax,dword ptr[rezult]
		push eax							;0ch - ���������-�����
		lea eax,dword ptr[eax_h]
		push eax							;08h - ��������� ��� �����
		call API_add						;������� �������� ������������ �����

; - - - -    � � � � � � �  � � � � � �  �  � � � � �  � � � � � � � � � �   - - - 
	cmp dword ptr[flag_ostZero],1
	je flag_ostZeroProc
	mov eax, dword ptr[dek]
	 cmp eax,0
 jne start_D
; -  -   -    -    � � � � �   M A I N  C I C L E    � � � � � � � �    � � � �     � � � � � � � -  -   -   -   -   -
	 jmp flag_ostZeroProcEnd

											; ��� ��������� ���������� ����������
 flag_ostZeroProc:
											;18 446 744 073 709 551 616 - 1
	push 0				 					; 0ch �����, ���������� � �������
	push dword ptr[p_dek]					; 08h ������� p_dek - dek
	call stepenPRC_h						; ���������� ������� � ������� p_dek :
											; ������ �� �������:
; rezult  =  [  rezult  * 10(� ������� p_dek - dec)  ]  		���� +  [ rez ]
	
		lea eax,dword ptr[rezult]			;������� ��������� ����������� �����
		push eax							;0ch - ����� �����������, �������������(����������)
		lea eax,dword ptr[eax_h]			;
		push eax							;08h -����� ���������;eax ���������� �� ������� � ������ �������
		call API_Multiplier					;������� ��������� ������������ �����

	mov dword ptr[flag_ostZero],0 			; ���������� ����
 flag_ostZeroProcEnd:
											; ����� ����������:
			push esi						;0ch - kex64bit1 �����, ���-e ����� �������� destination data
			lea eax,dword ptr[rezult]
			push eax						;08h - �����, ���-� ����� ��������
			call API_Data					;������� ��������� ������
divs_end:

	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	POP EBP
RET 8										;18 446 744 073 709 551 616 / 1
API_Divider ENDP

; - - - - - -  � � � � � � � � � �   �  � � � � � � � - - - - - - 
stepenPRC_h PROC
	push ebp
	mov ebp,esp
	push ecx
	push edx
	push ebx
	push esi
	push edi
											; 0ch - �����, ���������� � �������
											; 08h  - �������
		cmp dword ptr[ebp+08h],0
		je stepenNOL_h
		
			lea eax,dword ptr[eax_h]
			push eax						;����� �����
			lea eax,dword ptr[zeroReg]
			push eax
			call API_Data
				
			mov 	dword ptr[eax_h],10h
		
		lea eax,dword ptr[ebx_h]
		push eax							;����� �����
		lea eax,dword ptr[zeroReg]
		push eax
		call API_Data
		
											; mov esi,dword ptr[ebp+0ch];����� �����
		lea eax,dword ptr[eax_h]
		lea edi,dword ptr[ebx_h]
		
		push edi							;����� �����
		push eax							;����� �����
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
			push eax						;����� �����
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
; - - - - - - ����� � � � � � � � � � �   �  � � � � � � � - - - - - - 
;*********************************
;---===��������� ������������ ����===---
											;������������ ���������� � �����
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
											;	CALL PostQuitMessage@4;�OO������ wm_quit
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
