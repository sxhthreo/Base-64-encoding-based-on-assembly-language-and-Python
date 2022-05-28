data segment
	;创建文件的文件名,该文件存储在系统的D:\ASM\1.txt中，此前Dosbox设置有mount c: d:\asm
	file db 'c:\1.txt',0
	buf1 db 256 dup(0)    			;初始文件内容暂存区
	buf1length dw ?					;获取buf1的字符长度
	buf2 db 256 dup(0)              ;base64格式字符串暂存区
	buf2length dw ?
	xunhuancishu dw ?
	recentcx dw ?
	;s db 'ZYXABCDEFGHIJKLMNOPQRSTUVWzyxabcdefghijklmnopqrstuvw0123456789+/'
	s db 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	error_message db 'Some of your actions are wrong!',0dh,0ah,'$';出错时的提示
	handle dw ?              	    ;保存文件号
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
;----------------------------读取文件-------------------------------------
		mov dx,offset file	 	;dx获取file的偏移地址
        mov al,0				
	    mov ah,3dh				
		int 21h                 ;打开文件，只读
		jc erro1                ;若打开出错，转erro1错误提示区
		mov handle,ax           ;保存文件句柄
		mov bx,ax				;文件句柄赋值给bx
		mov cx,255				;读取255字节
		mov dx,offset buf1		;获取buf1的偏移地址
		mov ah,3fh				
		int 21h                 ;从文件中读255字节到buf1
		jc erro1                ;若读出错，转erro1错误提示区               
		mov bx,ax				;实际读到的字符数送入bx
		mov buf1length,bx		;把实际字符数存储到buf1length
		mov buf1[bx],'$'        ;在文件结束处放置一'$'符
		jmp base
	erro1:
	    mov dx,offset error_message	
		mov ah,9
		int 21h                 ;显示error_message
		mov ah,4ch
		int 21h
;----------------------------base64编码--------------------------------
	base:
		mov ax,buf1length
		mov bl,3
		div bl					;商放在al中，余数放在ah中
		cmp ah,0
		je next					;若有余数，说明要多+1
		add al,1				;设置循环次数为buf1的长度/3，并向上取整
	next:
	    mov ah,0
		mov cx,ax				;设置循环次数
		mov xunhuancishu,cx
		mov bx,0				;此为指针，初始指向buf2的第一个字符
	lop:
		;第一个字符
		mov recentcx,cx
		mov si,xunhuancishu
		sub si,cx
		neg si
		mov al,buf1[bx+si]
		mov cl,2
		shr al,cl				;8086处理器不支持大于1的操作数
		and al,3fh				;0x3f，清除ax的最前两位
		push bx
		mov bx,ax
		mov cl,s[bx]			;获取base64编码后的字符
		pop bx
		mov buf2[bx],cl
		inc bx
		;第二个字符
		mov si,xunhuancishu
		sub si,recentcx
		inc si
		neg si
		mov al,buf1[bx+si]
		mov cl,4				;为原始第一个字符往左移4位
		shl al,cl
		and al,30h				;0x30，获取原始第一个字符的最后两位
		push bx
		inc si
		add bx,si
		cmp bx,word ptr buf1length
		pop bx
		je aa					;如果bx等于buf1，说明已经到达末尾
		push ax					;将原始最后两位数据入栈
		mov al,buf1[bx+si]		;获取到的是第二个字符（前面si已经+1）
		mov cl,4
		shr al,cl
		and al,0fh				;获得第二个字符的前四位
		pop cx					;将原始最后两位数据出栈，并赋给cx
		or al,cl				;执行或运算，结果储存到ax中
	aa:
		push bx
		mov bl,al
		mov cl,s[bx]			;获取base64编码后的字符
		pop bx
		mov buf2[bx],cl
		push bx
		add bx,si		
		cmp bx,word ptr buf1length	;判断是否是跳转到aa执行至此
		pop bx
		inc bx
	    jb third
		mov al,'='
		mov buf2[bx],al
		inc bx
		mov buf2[bx],al
		jmp write
	third:
		;第三个字符
		dec si
		mov al,buf1[bx+si]
		mov cl,2
		shl al,cl				;为原始第二个字符往左移2位
		and al,3ch				;0x3c，获取原始第二个字符的后四位
		push bx
		inc si
		add bx,si
		cmp bx,word ptr buf1length
		pop bx
		je bb					;如果bx等于buf1，说明已经到达末尾
		push ax
		mov al,buf1[bx+si]		;为原始第三个字符往右移6位
		mov cl,6
		shr al,cl
		and al,03h				;获得第三个字符的前二位
		pop cx
		or al,cl				;执行或运算，结果储存到ax中
	bb:
		push bx
		mov bx,ax
		mov cl,s[bx]			;获取base64编码后的字符
		pop bx
		mov buf2[bx],cl
		push bx
		add bx,si
		cmp bx,word ptr buf1length
		pop bx
	    je denghao
		inc bx
		;第四个字符
		mov si,xunhuancishu
		sub si,recentcx
		inc si
		neg si
		mov al,buf1[bx+si]
		and al,3fh				;获得第三个字符的后六位
		push bx
		mov bl,al
		mov bh,0
		mov cl,s[bx]			;获取base64编码后的字符
		pop bx
		mov buf2[bx],cl
		inc bx
		mov cx,recentcx
		dec cx					;由于循环体内部较长，采用该方法
		mov recentcx,cx
		jz write
		jmp far ptr lop
	denghao:
		inc bx
		mov al,'='
		mov buf2[bx],al
		jmp write
;----------------------------写入文件----------------------------------
	write:
		cmp cx,0
		je noinc
		inc bx					;buf2length长度为编码阶段得到的bx加1
	noinc:
		mov buf2length,bx
		mov dx,offset file
		mov cx,0
		mov ah,3ch
		int 21h                 ;创建文件，若磁盘上原有此文件，则覆盖
		jc erro2                ;创建出错，转erro2处
		mov handle,ax           ;保存文件号
		mov bx,ax
		mov cx,buf2length 		;向文件中写入buf2length个字节内容
		mov dx,offset buf2
		mov ah,40h
		int 21h
		jnc finish              ;写入成功，进入结束环节
	erro2:
	    mov dx,offset error_message	
		mov ah,9
		int 21h                 ;显示error_message
		mov ah,4ch
		int 21h
;----------------------------结束环节----------------------------------
	finish:
		mov bx,handle			;文件句柄
		mov ah,3eh						
		int 21h                 ;关闭文件
        mov ah,4ch
        int 21h
	main endp
code   ends
end  start