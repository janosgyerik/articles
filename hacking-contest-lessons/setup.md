## Getting and using the live CD

You can download the latest ISO image from SourceForge:
http://sourceforge.net/projects/ctfomatic/files/

The live CD is based on Tiny Core Linux,
an ultra-light Linux distro.
It contains only the bare minimum software to accommodate the security challenges,
and a few important debugging tools to aid you in your adventure,
all in less than 30 megabytes.
The scripts to build the CD are open-source,
available on GitHub:
https://github.com/janosgyerik/capture-the-flag/

The easiest way to use the live CD is with a virtualization software such as KVM, VirtualBox, or VMWare.
Create a virtual machine with the following parameters:

- Operating System: Linux
- Kernel type: 2.6 (or similar)
- Memory: 256MB
- Hard disk: no need for a disk
- CD: use the ISO file

When you start the VM,
the boot screen should appear,
where you can simply press enter,
or enter boot parameters,
for example `fr`, `jp` or `hu` to use French, Japanese, or Hungarian keyboard mapping instead of the default US.

When the operating system starts,
you are automatically logged in as user `level00`.
The "message of the day" explains what you must do to advance to the next level.

Inside the home directory of this user,
there is a file named `tools.txt`,
with helpful information about using the live CD.

Sometimes you might want to copy files between the VM and your host system.
For some of the challenges,
especially on higher levels,
it's probably more comfortable to develop your exploit scripts in your comfortable host environment first,
and copy to the VM when ready.
There is a built-in `ssh` server,
so that you can transfer files using `scp`, `sftp` or `rsync`.
To access the VM "remotely",
you must configure its network interface appropriately.
The exact steps depend largely on your virtualization software,
I find that in general the *bridged networking* option is the easiest to get started.
To connect and login,
you can find the IP address of the VM with `ifconfig`,
and the password of `level00` in the `.password` file in its home directory.

Before you read on,
I strongly encourage you to first try to get through the levels by yourself.
Trust me, it's fun.
The levels are explained one little step at a time,
so you can take a quick peek in case you need a hint.
