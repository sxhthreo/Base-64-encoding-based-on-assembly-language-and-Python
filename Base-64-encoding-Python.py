import string
s="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
#s = "ZYXABCDEFGHIJKLMNOPQRSTUVWzyxabcdefghijklmnopqrstuvw0123456789+/"
def Base64_encode(st):
    list1 = []
    newlist = []
    #将输入的字符串转换为二进制,format为格式化，'{:0>8}'意为数字补零 (填充左边, 宽度为2)
    #bin函数返回字符的二进制表示，replace函数将bin生成的带'0b'前缀去除
    list1 = ['{:0>8}'.format(str(bin(b)).replace('0b', '')) for b in st]
    m=0
    while 1:
        #取三个字符的二进制
        list2=list1[0:3]
        #若最后list2长度小于3，则需要补充0
        if len(list2)!=3:
            if len(list2)==1:
                list2.extend(['00000000','00000000'])
                m=2
            elif len(list2)==2:
                list2.append('00000000')
                m=1
        strr=''.join(list2)
        for i in range(4-m):        #不能直接看到word是0就输出"="，因为可能是解码时字母本身某几位是0
            word = int(strr[i * 6:i * 6 + 6], 2)
            newlist.append(s[word])
        if m==1:
            newlist.append("=")
        elif m==2:
            newlist.append("==")
        del list1[0:3]
        if list1==[]:
            break
    print(''.join(newlist))
def Base64_decode(st):
    list1=[]
    newlist = bytearray()       #定义可变的字节数组
    for i in st:
        p=s.find(i)
        if p==-1:
            list1.append('000000')
        else:
            x = str(bin(p)).replace('0b', '')
            list1.append(x.zfill(6))
    while 1:
        # 取四个字符的二进制
        list2 = list1[0:4]
        strr = "".join(list2)
        for i in range(3):
            word = int(strr[i*8:i*8+8], 2)  # 切片操作
            if word != 0:
                newlist.append(word)
        del list1[0:4]
        if list1 == []:
            break
    print(newlist.decode())             #将字节数组解码，即解码字符串

if __name__ == '__main__':
    text1=input("Please enter the action you want: encrypt(1) or decrypt(2):")
    if text1=="1":
        text2=input("Please enter the string you want to encrypt:")
        Base64_encode(text2.encode())   #encode函数以encoding指定的编码格式编码字符串（这里为默认）
    else:
        text2 = input("Please enter the string you want to decrypt:")
        Base64_decode(text2)            #base64解码