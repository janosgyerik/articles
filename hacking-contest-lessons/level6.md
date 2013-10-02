## Level 6

So what is suspicious in this code?

- Calling `fork` to call `execl` to call `/bin/echo` just to taunt us,
  is bizarre.

- Why compare the passwords character by character instead of using `strcmp`?
  And why not start by comparing the lengths first?

- Something else?
  Some mistake in using `fork`, `execl`, `malloc`, `fgets`, `fprintf`?

It seems many others solved this by a timing attack on the `fork` call.
But we seriously look into the string comparisons,
we find something more intuitive and satisfying solution.

Take a look at the loop in the middle.
In every iteration,
there is a call to `char_at`,
and then `strlen` on the `guess` string.
Consider that `guess` comes from the command line.
Let's assume we try to brute force the program by trying different password combinations using very long guess strings.
Let's assume the first k characters
Let's assume we make guesses like this:

```
PREFIX + 'a' + LONGTEXT
PREFIX + 'b' + LONGTEXT
...
PREFIX + 'Z' + LONGTEXT
...
PREFIX + '9' + LONGTEXT
```

Assuming PREFIX is a correct starting segment of the password,
one of the following characters will be correct,
and all the others will be wrong.
If the length of prefix is `k`,
then `strlen` will be called `k` times for wrong guesses,
and `k + 1` times for the correct guess.
This holds true for any PREFIX of size 0 or longer.
If there is a measurable difference between calling `strlen` on a guess string `k` or `k + 1` times,
then we can discover the letters one by one.
Of course,
the larger the `k`,
it becomes increasingly more difficult to discern the difference between `k` and `k + 1` calls.

TODO: implementation?

What can we learn from all this?

Do not use time sensitive methods to verify passwords.

