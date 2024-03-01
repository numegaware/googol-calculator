;     include files

WM_INITDIALOG 		equ 110h
WM_COMMAND 			equ 111h
WM_SETTEXT 			equ 0Ch
WM_HOTKEY 			equ 312h
WM_TIMER			equ 113h
WM_SETICON			equ 80h
WM_GETTEXT			equ 0Dh
WM_VKEYTOITEM 		equ 2Eh
WM_VSCROLL			equ 115h
WM_HSCROLL			equ 114h

WM_CLOSE 			equ 10h
WM_DESTROY			equ 2;сообщение приходит при закрытии окна
WM_CREATE			equ 1;сообщение приходит при создании окна

EN_SETFOCUS 		equ 100h
EN_KILLFOCUS 		equ 200h

LBN_DBLCLK 			equ 2
LB_ADDSTRING 		equ 180h
LB_GETCURSEL 		equ 188h
LB_GETTEXT 			equ 189h
LB_FINDSTRING		equ 18Fh

;LB_SETTOPINDEX
;LB_GETTOPINDEX
;SB_PAGEDOWN
SB_LINEDOWN 		equ 1


VK_DOWN 			equ 28h
VK_INSERT 			equ 2Dh

ERROR_ALREADY_EXISTS EQU 183


EXTERN	SetScrollPos@16:NEAR ;[hwnd],SB_HORZ,[nHorizPosition],TRUE
;EXTERN	SetScrollRange@:NEAR
EXTERN	GetScrollInfo@12:NEAR


EXTERN GetLastError@0:NEAR
EXTERN CreateMutexA@12:NEAR
EXTERN ExitProcess@4:NEAR
;EXTERN GetStdHandle@4:NEAR
;EXTERN CloseHandle@4:NEAR


EXTERN UnregisterHotKey@8:NEAR
EXTERN RegisterHotKey@16:NEAR
EXTERN MessageBoxA@16:NEAR
EXTERN ExitProcess@4:NEAR
EXTERN GetModuleHandleA@4:NEAR
EXTERN DialogBoxParamA@20:NEAR
EXTERN EndDialog@8:NEAR
EXTERN SendMessageA@16:NEAR
EXTERN GetDlgItem@8:NEAR
EXTERN MessageBoxA@16:NEAR
EXTERN SendDlgItemMessageA@20:NEAR
EXTERN wsprintfA:NEAR
EXTERN LoadIconA@8:NEAR
EXTERN GetComputerNameA@8:NEAR
EXTERN InitCommonControls@0:NEAR
EXTERN SetFocus@4:near

;EXTERN  GetLocalTime@4:NEAR
;EXTERN SetTimer@16:NEAR
;EXTERN KillTimer@8:NEAR


;for menu
EXTERN EndDialog@8 :NEAR
EXTERN LoadStringA@16 :NEAR
EXTERN LoadMenuA@8 :NEAR
EXTERN SetMenu@8 :NEAR
;for menu end
MSGSTRUCT STRUC
	MSHWND DD ? ; ID окна принимающего сообщение
	MSMESSAGE DD ? ;ID сообщения
	MSWPARAM DD ? ;допинфа сообщения
	MSLPARAM DD ? ;допинфа сообщения
	MSTIME DD ? ;время посылки сообщения
	MSPT DD ? ;положение курсора во время отправки сообщения
MSGSTRUCT ENDS

;структура данных дата-время
;DAT STRUC
;	year	DW ?
;	month DW ?
;	dayweek DW ?
;	day DW ?
;	hour DW ?
;	min DW ?
;	sec DW ?
;	msec DW ?
;DAT ENDS

SCROLLINFO STRUC
 	cbSize DD ? 	;  размер самой структуры
 	fMask DD ? 		;  маска для параметров
 	nMin DD ? 		;  нижняя граница диапазона
 	nMax DD ? 		;  верхняя граница диапазона
 	nPage DD ? 		;  размер страницы
 	nPos DD ? 		;  позиция ползунка
 	nTrackPos DD ? 	;  позиция ползунка во время перемещения
SCROLLINFO ENDS