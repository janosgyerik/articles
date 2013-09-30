# Programming security lessons from a hacking contest

*Careless security mistakes you don't want to repeat!*

I'm a programmer, not a security expert.
When I discovered the online "security wargame" organized by stripe.com,
I wasn't too excited, but I decided to give it a quick look anyway.
The first level got me interested.
The second got me completely hooked.
The "quick look" turned into long nights,
but in the end I came out enlightened.
Having experienced seemingly harmless programs bent to do harmful things made me much more aware of potential issues in my own work.
Knowing how to detect and exploit weaknesses is not something "good to know",
it's essential to protecting your programs.

The online security contest is now over,
and of course the contest server was taken offline.
After all,
who would want to keep a server with security holes running in the wild?
As a substitute,
I built a modified version of the original contest into an ultra-light,
bootable Linux Live CD, in less than 30 megabytes.

In this article,
we will go through the 6 levels of the security wargame one by one.
The goal is not to give you the solutions on a silver platter,
but to explain the thought process of finding security holes.
By applying the same kind of critical thinking to your own programs,
you can protect them better against attackers.
