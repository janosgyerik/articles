## Getting and using the live CD

You can get the ISO image of the live CD from SourceForge:
http://sourceforge.net/projects/ctfomatic/files/

The easiest way to use the CD is with a virtualization software such as KVM, VirtualBox, or VMWare.
Create a virtual machine with the following parameters:

- Kernel type: Linux, 2.6
- Memory: 256MB
- Hard disk: no need for a disk
- CD: use the ISO file of the live CD

When you start the live CD,
you should see a boot screen.
You can enter boot options if you want,
or simply press enter to book the operating system.
When the system starts up,
you are automatically logged in as user `level00`,
and the message of the day explains what you must do to advance to the next level.

Inside the home directory of this user,
there is a file named `tools.txt` which contains useful information about available Linux tools that might help you,
and other helpful information about the live CD itself.

For some of the challenges,
especially on higher levels,
it might be easier to work on the solutions "offline" (on your host system),
and upload them to the running live CD when ready to run.
To make that easy there is a built-in `ssh` server that you connect with `ssh`, `scp`, `sftp` or `rsync`.
To be able to connect,
you will need 
you can find the
You can find the password of the `level00` user in the `.password` file in its home directory.
This is actually true for all other users.


The scripts to build the 
The live 
Download the
The hacking contest itself is implemented as a bootable ISO
image: an ultra-light Linux live CD, in less than 30 megabytes.
Readers can download the ISO image from SourceForge and play with
it on their own computers. The scripts to build the live CD is
itself an open-source project:
https://github.com/janosgyerik/ctf-o-matic/

- setup network access
- using ssh and scp
- try first by yourself
