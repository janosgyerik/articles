# Programming security lessons from a hacking contest

*Careless security mistakes you don't want to repeat!*

I'm a programmer, not a security expert.
But when I discovered the online hacking contest organized by stripe.com,
I couldn't resist to have a quick look.
The first level got me interested.
The second got me completely hooked.
A few long, but exciting nights followed,
and I ended up learning much more than I had originally intended.
Most importantly,
I came to realize how innocent-looking programs can be abused to do unintended things.

The online hacking contest is now over,
and of course the server was taken offline.
After all,
who would want to keep a server full of security holes running in the wild?
As a substitute,
I built a modified version of the original contest into an ultra-light,
bootable Linux Live CD, in less than 30 megabytes.

In this article,
we will go through the 6 levels of the security wargame one by one.
The goal is not to give you the solutions on a silver platter,
but to explain the thought process of finding security holes.
By applying the same kind of critical thinking to your own programs,
you can make them better,
and protect them better against attackers.
The bottom line is this:
you have to write your programs extremely carefully,
as simple mistakes can have grave consequences.
