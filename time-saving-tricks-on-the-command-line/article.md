# Time-saving tricks on the command line

*A few simple but very effective tips that will make you
lightning fast on the command line*

I remember the first time a friend of mine introduced me to
Linux, and showed me how I don't need to fully type commands
and path names: I can just start typing and use TAB to
complete the rest. That was so cool. I think everybody loves
tab completion because it's something you use pretty much
every single minute you spend in the shell. Over time
I discovered many more shortcuts and time saving tricks,
many of which I came to use almost as frequently as tab
completion.

In this article I highlight the minimum set of tricks in
common situations that make a huge difference for me:

* Working in screen sessions: core features that will get
  you a long way

* Editing the command line: moving around quickly and
  editing quickly
  
* Viewing files or man pages using "less"

* Emailing yourself relevant log snippets or as alerts
  triggered by events

While reading the article it's probably best to have
a terminal window open so you can try and start using the
tips right away. All the tips should work in Linux, UNIX,
and similar systems without any configuration.

## Working in screen sessions

Screen has been covered in Linux Journal before (see
Resources). To put it simply, screen lets you have multiple
"windows" within a single terminal application. The best
part is that you can detach and reattach to a running screen
session at any time, so that you can continue your previous
work exactly where you left off. This is most useful when
working on a remote server.

Luckily, you really don't need to master screen to benefit
from it greatly. You can already enjoy its greatest benefits
by using just a few key features, namely:

* `screen -R projectx`: Reattach to the screen session named
  "projectx" or create it fresh now

* `C-a c`: create a new window `C-a n`: switch to the next

* `C-a n`: switch to the next window

* `C-a p`: switch to the previous window

* `C-a 0`: switch to the first window, use `C-a 1` for the
  second, and so on

* `C-a w`: view the list of windows

* `C-a d`: detach from this screen session

* `screen -ls`: view the list of screen sessions

I will show all of these in the context of a realistic
example: debugging a Django website on my remote hosting
server, which usually involves the following activities:

* Editing the configuration file

* Running some commands (perform Django operations)

* Restarting the website

* Viewing the website logs

Of course I could do all these things one by one, but it's
a lot more practical to have multiple windows open for each.
I could use multiple real terminal windows, but reopening
them every time I need to do this kind of work would be
tedious and slow. Screen can make this much faster and
easier.

### Starting screen

Before you start screen, it's good to first navigate to the
directory where you expect to do most of your work. This is
because new windows within screen will all start in that
directory. In my example I first navigate to my Django
project's directory, so that when I open new screen windows,
the relevant files will be right there in front of me.

There are different ways of starting screen, I recommend
this one:

    screen -R mysite

When you run this for the first time, it will create
a screen session named "mysite". Later you can use this same
command to reconnect to this session again. (The `-R` flag
stands for "reattach".)

### Creating windows

Now that we are in screen, let's say I start editing the
configuration of the Django website:

    vim mysite/settings.py

Let's say I made some changes, and now I want to restart the
site. I could exit vim or put in the background in order to
run the command to restart the site, but I anticipate I will
need to make further changes right here. It's easier to just
create a new window now, using the screen command `C-a c`,
which means pressing the "Ctrl" and "a" keys at the same
time, followed by "c". "C-a" is called the "command key",
all screen commands start with this key sequence.

It's easy to create another window every time you start
doing something different from your current activity. This
is especially useful when you need to change the directory
between commands. For example if you have script files in
`/some/long/path/scripts` and log files in
`/other/long/path/logs`, then instead of jumping between
directories, just keep a separate window for each.

In this example, first I started looking at the
configuration files. Next, I wanted to restart the website.
Then I wanted to run some Django commands. Then I wanted to
look at the logs. All these are activities I tend to do many
times per debugging session, so it makes sense to create
a separate window for each activity.

The cost of creating a new window is so small, you can do it
without thinking. Don't interrupt your current activity:
fire up another window with `C-a c` and rock on.

### Switching between windows

The windows you create in screen are numbered starting from
zero. You can switch to a window by its number, for example
jump to the first window with `C-a 0`, the second window
with `C-a 1`, and so on. It's also very convenient to switch
to the next and previous windows with `C-a n` and `C-a p`,
respectively.

### Listing your windows

If you're starting to lose track of which window you are in,
check the list of windows with `C-a w` or `C-a "`. The
former shows the list of windows in the status line (at the
bottom) of the screen, showing the current window marked
with a "*". The latter shows the list of windows in a more
user-friendly format as a menu.

### Detaching from and reattaching to a session

The best time-saving feature of screen is reattaching to
existing sessions. You can detach cleanly from the current
screen session with `C-a d`. But you don't really need to.
You could just as well simply close the terminal window.

The great thing about screen sessions is that whatever way
you got disconnected from them, you can reattach later. At
the end of the day you can shut down your local PC without
closing a remote screen session, and come back to it
tomorrow by running the same command you used to start it,
as in this example with `screen -R mysite`.

You might have multiple screen sessions running for
different purposes. You can list them all with:

    screen -ls

If you got disconnected from screen abruptly, then sometimes
it may think you are still in an attached state, which will
prevent you from reattaching with the usual command `screen
-R label`. In that case you can append a `-D` flag to force
detaching any existing connections, for example:

    screen -R label -D

### Learning more about screen

If you want to learn more, see the man page and the links in
the Resources section. The built-in cheat sheet of shortcuts
also comes handy, you can view it with `C-a ?`.

I should also mention a competitor of screen: tmux. I chose
screen in this article because in my experience it is more
available in systems I cannot control. You can do
everything I covered above with tmux as well. Use whichever
is available in the remote system you find yourself in.

Finally, you can get the most out of screen when working on
a remote system, for example over an SSH session. When
working locally, it's probably more practical to use
a terminal application with tabs. That's not exactly the
same thing, but probably close enough.

## Editing the command line

There are many highly practical shortcuts that can make you
faster and more efficient on the command line in different
ways:

* Find and re-run or edit a long and complex command from
  the history

* Edit much quicker than just using the backspace key and
  re-typing text

* Move around much quicker than just using the left and
  right arrow keys

### Finding a command in the history

If you want to repeat a command you executed recently, it
may be easy enough to just press the up arrow key a few
times until you find it. If the command was more than just
a few steps ago, then this becomes unwieldy. Very often it's
much more practical to use the `C-r` shortcut instead, to
find a specific command by a fragment.

To search for a command in the past, press `C-r` and start
typing any fragment you remember from it. As you type, the
most recent matching line will appear on the command line.
This is an incremental search, which means you can keep
typing or deleting letters and the matched command will
change dynamically.

Let's try this with an example, and let's say I ran these
commands yesterday, which means they are still in my recent
history but too far away for using simply the up arrow:

    ...
    cd ~/dev/git/github/bashoneliners/
    . ~/virtualenv/bashoneliners/bin/activate
    ./run.sh pip install --upgrade django
    git push beta master:beta
    git push release master:release
    git status
    ...

Let's say I want to activate the virtualenv again. That's
a hassle to type again, because I have to type at least
a few characters at each path segment, even with tab
completion. Instead, it's a lot easier to press `C-r` and
start typing "activate".

For a slightly more complex example let's say I want to run
a "git push" command again but I don't remember exactly
which one. So I press `C-r` and start typing "push". This
will match the most recent command but I actually want the
one before that and I don't remember a better fragment to
type. The solution is to press `C-r` again, in the middle of
my current search, as that jumps to the next matching
command. [Screenshot-2] illustrates my keystrokes and what
this looks like on the command line.
[To editor: if the screenshot is not helping here, feel free
to omit. Actually this kind of thing would be best presented
as a video, with the keystrokes narrated or highlighted
somehow]

This is really extremely useful, saving not only the time of
typing, but often the time of thinking too. Imagine one of
those long one-liners where you processed a text file
through a long sequence of pipes with sed, awk, perl and
whatnot. Or an rsync command with many flags, filters,
exclusions. Or complex loops using "for" and "while". You
can quickly bring those back to your command line right now
using `C-r` and some fragment you remember from them.

Other notes:

* The search is case sensitive.

* You can abort the search with `C-c`

* To edit the line before running it, press any of the
  arrow keys

This trick can be even more useful if you pick up some new
habits. For example, when referring to a path you use very
often, prefer to type the absolute path rather than
a relative path. That way the command will be reusable later
form any directory.

### Moving around quickly and editing quickly

Basic editing of the command line involves moving around
with the arrow keys and deleting characters with backspace
or delete. When there are more than just a few characters
to move or delete, using these basic keys is just too slow.
You can do the same much faster by knowing just a handful of
interesting shortcuts:

* `C-w`: cut text backward until space

* `ESC-Backspace`: cut one word backward

* `ESC-Delete`: cut one word forward

* `C-k`: cut from current position until the end of the line

* `C-y`: paste the most recently cut text

Not only it is faster to delete portions of a line chunk by
chunk like this, an added bonus is that text deleted this
way is saved in a register so that you can paste later if
needed. Take for example the following sequence of
commands:

    git init --bare /path/to/repo.git
    git remote add origin /path/to/repo.git

Notice that the second command uses the same path at the
end. Instead of typing that path twice, you could copy and
paste it from the first command, using this sequence of
keystrokes:

1. Press `up`: bring back the previous command

2. Press `C-w`: cut the path argument `/path/to/repo.git`

3. Press `C-c`: cancel the current command

4. Type "git remote add origin" and press `C-y` to paste the
   path
   
[Screenshot-3] illustrates my keystrokes and what this looks
like on the command line.
[To editor: if the screenshot is not helping here, feel free
to omit. Actually this kind of thing would be best presented
as a video, with the keystrokes narrated or highlighted
somehow]

Some of the editing shortcuts are more useful in combination
with moving shortcuts:

* `C-a`: jump to the beginning of the line

* `C-e`: jump to the end of the line

* `ESC-b`: jump one word backward

* `ESC-f`: jump one word forward

Jumping to the beginning is very useful when you mistyped
the first words of a long command. You can jump to the
beginning much quicker than with the left arrow key.

Jumping forward and backward is very practical when editing
the middle part of a long command, such as the middle of
long path segments.

### Putting it all together

A good starting point to learn these little tricks is to
stop some old inefficient habits:

* Don't clear the command line with backspace. Use `C-c`
  instead.

* Don't delete long arguments with backspace. Use `C-w`
  instead.

* Don't move to the beginning or the end of the line using the
  left and right arrow keys. Jump with `C-a` and `C-e`
  instead.

* Don't move over long terms using the arrow keys. Jump over
  terms with `ESC-b` and `ESC-f` instead.

* Don't press the up arrow 20 times to find a not so recent
  previous command. Jump to it directly with `C-r` instead.

* Don't type anything twice on the same line. Copy it once
  with `C-w` and reuse it many times with `C-y` instead.

Once you get the hang of it, you will start to see more and
more situations where you can combine these shortcuts in
interesting ways and minimize your typing.

### Learning more about command line editing

If you want to learn more, see the man page of bash and
search for "READLINE", "Commands for Moving", and "Commands
for Changing Text".

## Viewing files or man pages with "less"

The "less" command is a very handy tool to view files, and
the default application to view man pages in many modern
systems. It has many highly practical shortcuts that can
make you faster and more efficient in different ways:

* Searching forward and backward

* Moving around quickly

* Placing markers and jumping to markers

### Searching forward and backward

You can search forward for some text by typing "/" followed
by the pattern to search for. To search backward use "?"
instead of "/". The search pattern can be a basic regular
expression. If your terminal supports it, the search results
are highlighted with inverted foreground and background
colors.

You can jump to the next result by pressing "n", and to the
previous result by pressing "N". The direction of "next" and
"previous" is relative to the direction of the search
itself. That is, when searching forward with "/", pressing
"n" will move you forward in the file, and when searching
backward with "?", then pressing "n" will move you backward
in the file.

If you use the vim editor, you should feel right at home, as
these shortcuts work the same way as in vim.

Searching is case sensitive by default, unless you specify
the `-i` flag when starting less. While reading a file, you
can toggle between case sensitive and insensitive modes by
typing "-i".

Moving around quickly There are a couple of shortcuts that
help you move around quickly:

* `g`: jump to the beginning of the file

* `G`: jump to the end of the file

* `space`: move forward by one window

* `b`: move backward by one window

* `d`: move down by half-window

* `u`: move up by half-window

### Using markers

Markers are extremely useful in situations where you need to
jump between two or more different parts within the same
file repeatedly.

For example, let's say you are viewing a server log with
initialization info near the beginning of the file, and some
errors somewhere in the middle. You need to switch between
the two parts while trying to figure out what's going on,
but using search repeatedly to find the relevant parts is
very inconvenient.

A good solution is to place markers at the two locations so
that you can jump to them directly. Markers work similarly
as in the vim editor: you can mark the current position by
pressing `m` followed by a lowercase letter, and you can
jump to a marker by pressing `'` followed by the same
letter. In our example I would mark the initialization part
with `mi`, and the part with the error with `me`, so that
I could jump to them easily with `'i` and `'e`. I chose the
letters as the initials of what the locations represent, so
that I can remember them easily.

### Learning more shortcuts

If you are interested in more, see the man page of the less
command. The built-in cheat sheet of shortcuts also comes
handy, you can view it by pressing `h`.

## Emailing yourself

When working on a remote server, getting data back to your
PC can be inconvenient sometimes. For example when your PC
is NAT-ed and the server cannot connect to it directly with
rsync or scp. A quick alternative can be sending data by
email instead.

Another interesting use case of emailing yourself is to use
as alerts triggered by something you were waiting for, such
as a crashed server coming back online, or other particular
system events.

### Emailing a log snippet

Let's say you found the log of errors crashing your remote
service, and you would like to copy it to your PC quickly.
Let's further assume the relevant log spans multiple pages
so it would be inconvenient to copy & paste from the
terminal window. Let's say you can extract the relevant part
using a combination of head, tail and grep commands. You
could save the log snippet in a file and run rsync on your
local PC to copy it, or you can just mail it to yourself by
simply piping it to this command:

    mailx -s 'error logs' me@example.com

Depending on your system, the `mailx` command might be
different, but the parameters are probably the same: `-s`
specifies the subject (optional), and the remaining
arguments are destination email addresses, and the standard
input is used as the message body.

### Triggering an email alert after a long task

When you run a long task such as copying a large file, it
can be annoying to wait and keep checking if it's finished
or not. It's better to arrange to trigger an email to
yourself when the copying is completed, for example:

    the_long_task; date | \
    mailx -s 'job done' me@example.com

That is, when the long task is completed, the email command
will run. In this example the message body will be simply
the output of the date command. In a real situation you
probably want to use something more interesting and relevant
as the message, for example "ls -lh" on the file that was
copied, or even multiple commands grouped together like
this:

    the_long_task; { df -h; tail some.log; } | \
    mailx -s 'job done' me@example.com

### Triggering an email alert by any kind of event

Have you ever been in one of these situations:

* You are waiting for a crashed serverX to come back online

* You are tailing a server log, waiting for a user to test
  your new evolution which will trigger a particular entry
  in the log

* You are waiting for another team to deploy an updated
  `.jar` file

Instead of staring at the screen or checking repeatedly
whether the event you are waiting for has happened or not,
you could use this kind of one-liner:

    while :; do date; CONDITION && break; sleep 300; \
    done; MAILME

This is essentially an infinite loop, with an appropriate
CONDITION in the middle to exit the loop and thus trigger
the email command. Inside the loop we print the date just so
that we can see the loop is alive, and sleep for 5 minutes
(300 seconds) in each cycle to avoid overloading the machine
we are on.

CONDITION can be any shell command, its exit code will
determine whether the loop should exit or not. For the
situations outlined above, we could write the CONDITION like
this:

* `ping -c1 serverX`: emit a single ping to serverX. If it
  responds, ping will exit with success, ending the loop.

* `grep pattern /path/to/log`: search for the expected pattern
  in the log. If the pattern is found, grep will exit with
  success, ending the loop.

* `find /path/to/jar -newer /path/to/jar.marker`: this
  assumes that before starting the infinite loop, you
  created a marker file like this: `touch -r /path/to/jar
  /path/to/jar.marker`, in order to save a copy of the exact
  same timestamp as the `.jar` file you want to monitor. The
  find command will exit with success after the `.jar` file has
  been updated.

In short: don't wait for a long-running task or some
external event. Set up an infinite loop and alert yourself
by email when there is something interesting to see.

## Conclusion

All the tips in this article are standard features and
should work in any Linux, UNIX, and similar systems. We have
only scratched the surface here, highlighting the minimal
set of features in each area that should get the biggest
bang for your buck. Once you get the hang of it, these
little tricks will make you a real ninja in the shell,
jumping around and getting things done lightning fast with
minimal typing.

## Resources

* `man screen`

* `man bash` and search for "READLINE", "Commands for Moving",
  "Commands for Changing Text"

* `man less`

* https://speakerdeck.com/janosgyerik/time-saving-tricks-on-the-command-line

* Power Sessions with Screen: http://www.linuxjournal.com/article/6340

* Status Messages in Screen: http://www.linuxjournal.com/article/10950

* Transfer Your Terminal with Screen:
  http://www.linuxjournal.com/video/transfer-your-terminal-screen
