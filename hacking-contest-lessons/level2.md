## Level 1: avoid the "system" call

## Level 2:

https://github.com/janosgyerik/ctf-o-matic/blob/master/ctf1/code/levels/level02/level02.py
The vulnerability: using a browser cookie and without validation
to read files on the server The exploit: a cookie can be crafted
with a relative path to reveal the content of sensitive files The
lesson: Always validate user input properly


