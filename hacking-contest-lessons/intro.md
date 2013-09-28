# Lessons in programming security through a hacking contest

*Careless programming security mistakes you don't want to repeat!*

From https://stripe.com/blog/capture-the-flag

> The hardest part of writing secure code is learning to think like an attacker.
> For example, every programmer is told to watch out for SQL injections,
> but it's hard to appreciate just how exploitable they are until you've written a SQL injection of your own.

Although there are no SQL injections in this challenge, you get the idea.

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

- the thought process
- what could possibly go wrong?

The purpose of the article is not to give you the solutions on a silver platter.
It is to train you to think like an attacker,
so that you can protect your own programs and scripts better.
