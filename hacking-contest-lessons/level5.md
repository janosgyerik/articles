## Level 1: avoid the "system" call

## Level 5:

https://github.com/janosgyerik/ctf-o-matic/blob/master/ctf1/code/levels/level05/level05.py
The vulnerability: using weakly validated form input as
parameters for pickle loading in Python The exploit: an HTTP POST
can be crafted that passes the weak validation and tricks the
program into running the injected pickle The lesson: make sure
your input validation is strong enough, especially if it is used
to unpickle pickles in Python


