## Level 6: be careful with time sensitive methods

This is the last and hardest level in the challenge.
Let's look for suspicious elements in the code:

- Calling `fork` to call `execl` to call `/bin/echo` just to taunt us,
  is strange.

- The program prints a dot on `stderr` for each character in our guess,
  but prints the taunting message on `stdout`.

The solution involves both of these hints.
To figure out the next step,
we need to take a closer look at the main loop:
```
    for (i = 0; i < strlen(guess); i++) {
		guess_char = char_at(guess, i);
		true_char = char_at(correct, i);
		fprintf(stderr, ".");
		if (!known_incorrect && (guess_char != true_char)) {
			known_incorrect = 1;
			taunt();
		}
	}
```

In every iteration,
the program first prints a dot on `stderr`,
and after that it checks if the guess is correct so far or not.
If not correct,
the `taunt` method will spawn a child process to print a message on `stdout`,
and the loop will continue printing a dot on `stderr` until the end of our guess string.

At this point it's difficult to give more hints without divulging the solution:

- The temporal order of printing the dot and the checking the current character.

- The fact that dots and the taunt messge are printed on different filehandles (`stderr`, `stdout`) is relevant.

- What will happen if `stderr` is blocked?

Let's suppose that we can tweak `stderr` in a way that the program won't be able to print more than one dot.
Consider what will happen on `stdout` when we run the program with parameter `cx`,
where `c` is our guess for the first character,
and `x` is just a padding to keep the loop running for one more step.

- If `c` is incorrect,
  the program will print a dot on `stderr`,
  followed by the taunting message on `stdout`.

- If `c` is correct,
  the program will print a dot on `stderr`,
  and then wait until it can write the next dot on `stderr`,
  which we blocked.

If this works,
then we can evaluate the correctness of `c` by checking if we can read from `stdout` or not.
Once we have the first correct character,
we can continue applying the same logic to the rest of the password,
at each step setting up `stderr` to block after it received the right number of dots.

The question is, of course,
how to block the output pipe of `stderr` of a process?
This is a big challenge in itself,
but it should doable in any modern programming language.
I would rather not spoil the live CD 100%,
and leave the implementation to You, dear reader.
I invite you to take your favorite programming language and figure out how to create a child process with a tweaked `stderr` filehandle.
There are many solutions already on the internet,
I recommend the elegant Ruby script by Matt Page[7].
