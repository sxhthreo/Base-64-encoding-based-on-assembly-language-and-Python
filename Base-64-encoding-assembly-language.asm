data segment
	;�����ļ����ļ���,���ļ��洢��ϵͳ��D:\ASM\1.txt�У���ǰDosbox������mount c: d:\asm
	file db 'c:\1.txt',0
	buf1 db 256 dup(0)    			;��ʼ�ļ������ݴ���
	buf1length dw ?					;��ȡbuf1���ַ�����
	buf2 db 256 dup(0)              ;base64��ʽ�ַ����ݴ���
	buf2length dw ?
	xunhuancishu dw ?
	recentcx dw ?
	;s db 'ZYXABCDEFGHIJKLMNOPQRSTUVWzyxabcdefghijklmnopqrstuvw0123456789+/'
	s db 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	error_message db 'Some of your actions are wrong!',0dh,0ah,'$';����ʱ����ʾ
	handle dw ?              	    ;�����ļ���
data ends
code segment
	main proc far
		assume cs:code,ds:data
	start:                  
		push  ds
		sub  ax,ax
		push  ax
		mov  ax,data
		mov  ds,ax
;----------------------------��ȡ�ļ�-------------------------------------
		mov dx,offset file	 	;dx��ȡfile��ƫ�Ƶ�ַ
        mov al,0				
	    mov ah,3dh				
		int 21h                 ;���ļ���ֻ��
		jc erro1                ;���򿪳���תerro1������ʾ��
		mov handle,ax           ;�����ļ����
		mov bx,ax				;�ļ������ֵ��bx
		mov cx,255				;��ȡ255�ֽ�
		mov dx,offset buf1		;��ȡbuf1��ƫ�Ƶ�ַ
		mov ah,3fh				
		int 21h                 ;���ļ��ж�255�ֽڵ�buf1
		jc erro1                ;��������תerro1������ʾ��               
		mov bx,ax				;ʵ�ʶ������ַ�������bx
		mov buf1length,bx		;��ʵ���ַ����洢��buf1length
		mov buf1[bx],'$'        ;���ļ�����������һ'$'��
		jmp base
	erro1:
	    mov dx,offset error_message	
		mov ah,9
		int 21h                 ;��ʾerror_message
		mov ah,4ch
		int 21h
;----------------------------base64����--------------------------------
	base:
		mov ax,buf1length
		mov bl,3
		div bl					;�̷���al�У���������ah��
		cmp ah,0
		je next					;����������˵��Ҫ��+1
		add al,1				;����ѭ������Ϊbuf1�ĳ���/3��������ȡ��
	next:
	    mov ah,0
		mov cx,ax				;����ѭ������
		mov xunhuancishu,cx
		mov bx,0				;��Ϊָ�룬��ʼָ��buf2�ĵ�һ���ַ�
	lop:
		;��һ���ַ�
		mov recentcx,cx
		mov si,xunhuancishu
		sub si,cx
		neg si
		mov al,buf1[bx+si]
		mov cl,2
		shr al,cl				;8086��������֧�ִ���1�Ĳ�����
		and al,3fh				;0x3f�����ax����ǰ��λ
		push bx
		mov bx,ax
		mov cl,s[bx]			;��ȡbase64�������ַ�
		pop bx
		mov buf2[bx],cl
		inc bx
		;�ڶ����ַ�
		mov si,xunhuancishu
		sub si,recentcx
		inc si
		neg si
		mov al,buf1[bx+si]
		mov cl,4				;Ϊԭʼ��һ���ַ�������4λ
		shl al,cl
		and al,30h				;0x30����ȡԭʼ��һ���ַ��������λ
		push bx
		inc si
		add bx,si
		cmp bx,word ptr buf1length
		pop bx
		je aa					;���bx����buf1��˵���Ѿ�����ĩβ
		push ax					;��ԭʼ�����λ������ջ
		mov al,buf1[bx+si]		;��ȡ�����ǵڶ����ַ���ǰ��si�Ѿ�+1��
		mov cl,4
		shr al,cl
		and al,0fh				;��õڶ����ַ���ǰ��λ
		pop cx					;��ԭʼ�����λ���ݳ�ջ��������cx
		or al,cl				;ִ�л����㣬������浽ax��
	aa:
		push bx
		mov bl,al
		mov cl,s[bx]			;��ȡbase64�������ַ�
		pop bx
		mov buf2[bx],cl
		push bx
		add bx,si		
		cmp bx,word ptr buf1length	;�ж��Ƿ�����ת��aaִ������
		pop bx
		inc bx
	    jb third
		mov al,'='
		mov buf2[bx],al
		inc bx
		mov buf2[bx],al
		jmp write
	third:
		;�������ַ�
		dec si
		mov al,buf1[bx+si]
		mov cl,2
		shl al,cl				;Ϊԭʼ�ڶ����ַ�������2λ
		and al,3ch				;0x3c����ȡԭʼ�ڶ����ַ��ĺ���λ
		push bx
		inc si
		add bx,si
		cmp bx,word ptr buf1length
		pop bx
		je bb					;���bx����buf1��˵���Ѿ�����ĩβ
		push ax
		mov al,buf1[bx+si]		;Ϊԭʼ�������ַ�������6λ
		mov cl,6
		shr al,cl
		and al,03h				;��õ������ַ���ǰ��λ
		pop cx
		or al,cl				;ִ�л����㣬������浽ax��
	bb:
		push bx
		mov bx,ax
		mov cl,s[bx]			;��ȡbase64�������ַ�
		pop bx
		mov buf2[bx],cl
		push bx
		add bx,si
		cmp bx,word ptr buf1length
		pop bx
	    je denghao
		inc bx
		;���ĸ��ַ�
		mov si,xunhuancishu
		sub si,recentcx
		inc si
		neg si
		mov al,buf1[bx+si]
		and al,3fh				;��õ������ַ��ĺ���λ
		push bx
		mov bl,al
		mov bh,0
		mov cl,s[bx]			;��ȡbase64�������ַ�
		pop bx
		mov buf2[bx],cl
		inc bx
		mov cx,recentcx
		dec cx					;����ѭ�����ڲ��ϳ������ø÷���
		mov recentcx,cx
		jz write
		jmp far ptr lop
	denghao:
		inc bx
		mov al,'='
		mov buf2[bx],al
		jmp write
;----------------------------д���ļ�----------------------------------
	write:
		cmp cx,0
		je noinc
		inc bx					;buf2length����Ϊ����׶εõ���bx��1
	noinc:
		mov buf2length,bx
		mov dx,offset file
		mov cx,0
		mov ah,3ch
		int 21h                 ;�����ļ�����������ԭ�д��ļ����򸲸�
		jc erro2                ;��������תerro2��
		mov handle,ax           ;�����ļ���
		mov bx,ax
		mov cx,buf2length 		;���ļ���д��buf2length���ֽ�����
		mov dx,offset buf2
		mov ah,40h
		int 21h
		jnc finish              ;д��ɹ��������������
	erro2:
	    mov dx,offset error_message	
		mov ah,9
		int 21h                 ;��ʾerror_message
		mov ah,4ch
		int 21h
;----------------------------��������----------------------------------
	finish:
		mov bx,handle			;�ļ����
		mov ah,3eh						
		int 21h                 ;�ر��ļ�
        mov ah,4ch
        int 21h
	main endp
code   ends
end  start