## Getting and using the live CD

You can get the ISO image of the live CD from SourceForge:
http://sourceforge.net/projects/ctfomatic/files/

The live CD is based on Tiny Core Linux,
and ultra-light Linux distribution.
It contains only the bare minimum software to accommodate the challenges,
and a few important debugging tools to aid you in your adventure,
all in less than 30 megabytes.
The scripts to build the CD are part of an open-source project,
available on GitHub:
https://github.com/janosgyerik/capture-the-flag/

The easiest way to use the live CD is with a virtualization software such as KVM, VirtualBox, or VMWare.
Create a virtual machine with the following parameters:

- Operating System: Linux
- Kernel type: 2.6 (or similar)
- Memory: 256MB
- Hard disk: no need for a disk
- CD: use the ISO file of the live CD

When you start the live CD,
you should see a boot screen.
Simply press enter to boot the operating system.
You will be automatically logged in as user `level00`,
and the message of the day explains what you must do to advance to the next level.

Inside the home directory of this user,
there is a file named `tools.txt` which contains useful information about available Linux tools that might help you,
and other helpful information about using the live CD.

Sometimes you might want to copy files between the VM and your host system.
For some of the challenges,
especially on higher levels,
it's probably more comfortable to develop your exploit scripts in your comfortable host environment first,
and copy to the VM when ready.
There is a built-in `ssh` server for this:
you can login with `ssh`,
or transfer files using `scp`, `sftp` or `rsync`.

To access the VM "remotely",
you must configure its network interface appropriately,
using one of the options provided by your virtualization software.
The exact steps depend largely on the software,
I find that in general the *bridged networking* option is the easiest to get started.
To connect and login,
you can find the IP address of the VM by running `ifconfig`,
and the password of `level00` in the `.password` file in its home directory.

Before you read on,
I strongly encourage you to first try to get through the levels by yourself.
The levels are explained one little step at a time,
so you can take a quick peek when you need a hint.
