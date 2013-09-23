TODO: cut the crap. it's obvious what is what:
the source of the vulnerable program is /at/some/path,
the vulnerable program is setuid,
the password file is only readable by the owner
-> our task is to bend the setuid program to our will

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
