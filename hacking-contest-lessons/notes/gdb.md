info stack

info frame

x/60xw $sp  show the next 60 bytes as 4-byte words in hexa, starting from $sp (the stack pointer)

fns is at: 0xbfe2a248 ?

d br    # delete all breakpoints

info address <symbol>
info locals # prints local variables
<function>(<args>) # calls functions
p &<var> # prints address of variables
set <var>=<value>

