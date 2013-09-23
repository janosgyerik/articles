## Level 1: avoid the "system" call

## Level 3:

https://github.com/janosgyerik/ctf-o-matic/blob/master/ctf1/code/levels/level03/level03.c
The vulnerability: using command line arguments without
validation and without checking array bounds The exploit:
a command line argument can be crafted to trick the program into
doing something unintended The lesson: always validate command
line arguments properly, and always check array bounds


