# Lessons in programming security through a hacking contest

*Careless programming security mistakes you don't want to repeat!*

I'm a programmer, not a security expert.
But I joined the hacking contest organized by Stripe anyway,
out of curiosity.
They provided a Linux user account over ssh,
the path and source code to a program with a huge security hole,
leading to the password of another user account.
That was too tempting, even for me!
The first level got me interested.
The second level got me completely hooked.
Some long nights followed,
and I ended up learning far more than I had originally intended.
Most importantly,
I learned how seemingly innocent programs can be bent to do unintended things.

The hacking contest is long over,
and they took down the ssh account.
After all,
who in his right mind would want to keep a server with vulnerable accounts running?
I wouldn’t,
and you don’t have to.
I recreated a modified version of the original contest,
in the form of a bootable Linux Live CD.
You can download the ISO and play it on your own computer,
or in your favorite virtualization tool.
Pick the latest version from this page:
http://sourceforge.net/projects/ctfomatic/files/

Before I go on and spoil all the surprises,
I suggest to try to get through the levels first without reading
this article.

The article will explain the thought process of solving 6 levels
of a hacking contest, and the important lessons to learn from it.
Each level presents a program that looks harmless at first
glance, but having hidden problems that can lead to serious
security breaches. The article will explain the logic of
detecting problems, and demonstrate how they can be exploited.
The focus is on the lesson to learn: you have to be extremely
careful when writing programs, as simple mistakes can have grave
consequences.

The hacking contest itself is implemented as a bootable ISO
image: an ultra-light Linux live CD, in less than 30 megabytes.
Readers can download the ISO image from SourceForge and play with
it on their own computers. The scripts to build the live CD is
itself an open-source project:
https://github.com/janosgyerik/ctf-o-matic/

- the thought process
- what could possible go wrong?

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

TODO: cut the crap. it's obvious what is what:
the source of the vulnerable program is /at/some/path,
the vulnerable program is setuid,
the password file is only readable by the owner
-> our task is to bend the setuid program to our will

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

The most suspicious line here is of course `system("date")`.
What does it really do?
We can look that up in `man system`: it executes the specified command by calling `/bin/sh -c`.
And since the specified command is not an absolute path,
the shell will search for it in the list of paths defined in `$PATH`,
and use the first one it finds.

Therein lies our exploit:

1. Create a script named "date" in a directory readable by user `level01`,
   and make it print the content of `/home/level01/.password`

        $ cat > /tmp/date
        #!/bin/cat /home/level01/.password
        ^D  # press Control-D to stop editing

2. Make it executable

        $ chmod +x /tmp/date

3. Prepend the directory of the script to `PATH`,
   so that our script is found before the real `date` program.

        $ PATH=/tmp:$PATH

Now if we run the `level01` command again:

    $ /levels/level01/level01
    Current time: aepeefoo
    #!/bin/cat /home/level01/.password

Bingo! Now we can login as user `level01` using the revealed password.

What can we learn from all this?

- Make sure you have read and understood the documentation of library methods you use:
  `man system` explains that it should not be used in setuid programs.
- If you must use `system()`,
  be careful with relative paths,
  as the user can easily subvert the intended behavior by manipulating the `PATH`.
  The `level01` program would have been a lot safer if had used the full path `/bin/date` instead of just `date`.

Level 2:
https://github.com/janosgyerik/ctf-o-matic/blob/master/ctf1/code/levels/level02/level02.py
The vulnerability: using a browser cookie and without validation
to read files on the server The exploit: a cookie can be crafted
with a relative path to reveal the content of sensitive files The
lesson: Always validate user input properly

Level 3:
https://github.com/janosgyerik/ctf-o-matic/blob/master/ctf1/code/levels/level03/level03.c
The vulnerability: using command line arguments without
validation and without checking array bounds The exploit:
a command line argument can be crafted to trick the program into
doing something unintended The lesson: always validate command
line arguments properly, and always check array bounds

Level 4:
https://github.com/janosgyerik/ctf-o-matic/blob/master/ctf1/code/levels/level04/level04.c
a variation on Level 3 that is harder to exploit, but with more
tragic consequences, allowing the attacker to execute arbitrary
code

Level 5:
https://github.com/janosgyerik/ctf-o-matic/blob/master/ctf1/code/levels/level05/level05.py
The vulnerability: using weakly validated form input as
parameters for pickle loading in Python The exploit: an HTTP POST
can be crafted that passes the weak validation and tricks the
program into running the injected pickle The lesson: make sure
your input validation is strong enough, especially if it is used
to unpickle pickles in Python

Level 6:
https://github.com/janosgyerik/ctf-o-matic/blob/master/ctf1/code/levels/level06/level06.c
The vulnerability: using time sensitive methods in password
validation The exploit: a script can be crafted to determine the
password by measuring the execution time of validating wrong
passwords The lesson: be careful with potentially time sensitive
methods

The article will spoil the hacking contest. The solutions have
not been published before. But I think it's worth it. Ideally
programmers should go through the levels all by themselves, as it
would train their investigative thinking to detect better the
security holes in their own programs. As an alternative, the
article will provide the explanations and lessons to learn,
increasing the awareness of common mistakes and vulnerabilities,
hopefully leading to more careful coding.

Disclaimer: I am just a regular programmer, not a security
expert. Going through the original online hacking contest
(https://stripe.com/blog/capture-the-flag-wrap-up) was an
eye-opening experience for me, witnessing how seemingly innocent
programs can be abused. I had a wonderful time and came out
enlightened. I think the lessons are extremely important for all
professional programmers, and partly relevant for system
administrators too.

