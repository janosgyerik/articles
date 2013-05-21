# Practical tips & tricks in the Linux shell

I put together this simple presentation about a few practical tips in
the Linux/UNIX/BSD/etc shell. I use most of these literally every
minute when I work in the shell, and I’m always surprised to see
friends and colleagues not using them. I hope I will get to present
this someday, somewhere.

keywords: practical, fast, effective, efficient



## screen

### Create windows

Example: todo

### Switch between windows

Example: todo

### Detach/reattach to screen

Example: todo

### Want more handy shortcuts?

## Emacs commands in the shell aka line editing tricks

This  is  the library that handles reading input when using an interac‐
       tive shell, unless the --noediting option is given at shell invocation.
       Line editing is also used when using the -e option to the read builtin.
       By default, the line editing commands are similar to those of Emacs.  A
       vi-style line editing interface is also available.  Line editing can be
       enabled at any time using the -o emacs or -o  vi  options  to  the  set
       builtin  (see  SHELL BUILTIN COMMANDS below).  To turn off line editing
       after the shell is running, use the +o emacs or +o vi  options  to  the
       set builtin.

By default -o emacs is set
-o vi exclude each other
+o emacs/vi to unset


### Backward search history with ctrl-r

Example: todo

### Editing quickly

Example: todo

### Moving quickly

Example: todo

### Want more handy shortcuts?



## vi shortcuts in less

### Searching forward and backward

Example: todo

### Navigating quickly

Example: todo

### Using markers

Example: todo

### Want more handy shortcuts?



## Mail it to me!

### Mail me a log snippet

Example: todo

### Mail me an entire log file

Example: todo

### Mail me when ready

Example: todo



## Conclusion



## Resources

* `man screen`
* `man bash` and search for `READLINE`
*  https://docs.google.com/presentation/d/13N06QfsemvTFiQLF5nC-eatlktmj5DMFAzxexwJ8TgA/pub?start=false&loop=false
