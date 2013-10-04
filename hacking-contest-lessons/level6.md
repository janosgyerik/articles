## Level 6: be careful with time sensitive functions

This is the last and hardest level.
Let's look for suspicious elements in the code:

- Calling `fork` to call `execl` to call `/bin/echo` just to taunt us,
  is strange.

- The program prints a dot to `stderr` for each character in our guess,
  but prints the taunting message to `stdout` in a forked child process.

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
and after that it checks if the guessed character is correct or not.
If not correct,
the `taunt` function will spawn a child process to print a message on `stdout`,
while the loop will continue printing a dot on `stderr` for each remaining character until the end of the input string.

At this point it's difficult to give more hints without divulging the solution:

- The timing of printing the dot and checking the current character is relevant.

- The fact that dots and the taunt message are printed on different filehandles (`stderr`, `stdout`) is relevant.

- What if we could prevent the program from writing one more character to `stderr` somehow?

Let's suppose we can control `stderr` in a way to prevent the program from writing beyond a single dot.
Consider what will happen when we run the program with parameter `cx`,
where `c` is our guess for the first character,
and `x` is to keep the loop running for one more step.

- If `c` is incorrect,
  the program will print a dot on `stderr`,
  followed by the taunting message on `stdout`,
  and then block in the loop as it cannot print any more dots.

- If `c` is correct,
  the program will print a dot on `stderr`,
  and then block in the loop as it cannot print any more dots.

That is,
if this works,
we can evaluate the correctness of `c` by checking if there is output on `stdout`.
Once we have the first correct character,
we can continue applying the same logic to the rest of the password,
at each step setting up `stderr` to block after it received the right number of dots.

The question is, of course,
how to block the output pipe of `stderr` of a process?
That is a challenge in itself,
but doable in any modern programming language.
I would rather not spoil the live CD completely,
and leave the implementation of this final hurdle to You, dear reader.
I invite you to take your favorite programming language and figure out how to implement the exploit outlined above.
There are many solutions on the internet,
see an elegant example in Ruby[7] by Matt Page in the resources.

## Lessons to learn

- Erm, don't do silly things?

- Be careful with time sensitive techniques.

- Never, ever store passwords in clear text.
  Encrypt the user input, and match it against the encrypted password.

