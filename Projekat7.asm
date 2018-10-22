INCLUDE Irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 255

.data
buffer BYTE BUFFER_SIZE DUP(? )
filename    BYTE 80 DUP(0)
fileHandle  HANDLE ?
outHandle   HANDLE 0
bytesWritten DWORD ?
endl EQU <0dh, 0ah>;//end of line
novired LABEL BYTE
BYTE endl
msize DWORD($ - novired)
var DWORD 0;  //pomoc za sabiranje vremena 

.code
main PROC

;//UCITAVANJE FILE-a
;// Let user input a filename.
mWrite "Unesite ime file-a: "
mov	edx, OFFSET filename
mov	ecx, SIZEOF filename
call	ReadString

;// Open the file for input.
mov	edx, OFFSET filename
call	OpenInputFile
mov	fileHandle, eax

;// Check for errors.
cmp	eax, INVALID_HANDLE_VALUE; error opening file ?
jne	file_ok; no: skip
mWrite <"Cannot open file", 0dh, 0ah>
jmp	quit; and quit
file_ok :

;// Read the file into a buffer.
mov	edx, OFFSET buffer
mov	ecx, BUFFER_SIZE
call	ReadFromFile
jnc	check_buffer_size; error reading ?
mWrite "Error reading file. "; yes: show error message
call	WriteWindowsMsg
jmp	close_file

check_buffer_size :
cmp	eax, BUFFER_SIZE; buffer large enough ?
jb	buf_size_ok; yes
mWrite <"Error: Buffer too small for the file", 0dh, 0ah>
jmp	quit; and quit

;//Isipisuje broj karaktera
buf_size_ok:
; mov	buffer[eax], 0; insert null terminator
; mWrite "File size: "
; call	WriteDec; display file size
; call	Crlf

;//Ispis buffer-a
; Display the buffer.
mWrite <"  ", 0dh, 0ah>
; mov	edx, OFFSET buffer; display the buffer
; call	WriteString
; call	Crlf


mov ebx, 0;//brojac za buffer
ponovo:
;//provera boje
mov al, [buffer + ebx];//ucitava prvo slovo
add ebx, 2;//preskace razmak

cmp al, 'g'; //zeleno?
jz zeleno

cmp al, 'b'; //plavo?
jz plavo

crveno :
mov al, [buffer + ebx];// ucitava char
cmp al, ' ';//razmak?
jz novi_red;//ako jeste, izadji
;//ako nije ispisi slovo
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov outHandle, eax
mov eax, red	  
call settextcolor ;//postavlja boju
INVOKE WriteConsole,
outHandle, ADDR[buffer + ebx], 1, ADDR bytesWritten, 0
add ebx, 1; ;// pokazivac na sledece slovo
jmp crveno

zeleno :
mov al, [buffer + ebx];// ucitava slovo  
cmp al, ' ';// razmak?
jz novi_red;// ako jeste, izadji
;//ako nije ispisi slovo
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov outHandle, eax
mov eax, green
call settextcolor ;//postavlja boju
INVOKE WriteConsole,
outHandle, ADDR[buffer + ebx], 1, ADDR bytesWritten, 0
add ebx, 1; ;// pokazivac na sledece slovo
jmp zeleno

plavo :
mov al, [buffer + ebx];// ucitava slovo  
cmp al, ' ';//razmak?
jz novi_red;//ako jeste, izadji
;//ako nije ispisi slovo
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov outHandle, eax
mov eax, blue
call settextcolor ;//postavlja boju
INVOKE WriteConsole,
outHandle, ADDR[buffer + ebx], 1, ADDR bytesWritten, 0
add ebx, 1; // pokazivac na sledece slovo
jmp plavo

;//Pomera pointer za ispis u novi red
novi_red:
INVOKE GetStdHandle, STD_OUTPUT_HANDLE;
mov outHandle, eax
INVOKE WriteConsole, outHandle, ADDR novired, msize, ADDR bytesWritten, 0

;//citanje broja
mov edi, 0;//BR CEKANJE [ms] 
broj:
add ebx, 1;//pokazuje na trenutni
mov al, [buffer + ebx];//cita ga
cmp al, 0; // EOF
jz  close_file
cmp al, 0dh;// EOL 
jz kraj_linije

imul edi, 10;
sub  al, 48;
add  edi, eax

jmp broj

kraj_linije :
add ebx, 2
INVOKE Sleep, edi
jmp ponovo;//obrada sedeceg reda


close_file:
INVOKE Sleep, edi;// cekanje pre izlaza 
mov	eax, fileHandle
call	CloseFile

quit :
invoke ExitProcess, 0
main ENDP

END main