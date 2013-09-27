## Level 2: always validate all forms of user input

As we login with `level01` user,
the explanation of the next challenge appears.
Like before,
the password of user `level02`--the next level,
is in the file `/home/level02/.password`.
We don't have any permissions on `/home/level02`,
so the file is not easy to access.
On the other hand,
there seems to be a web-based vulnerability
running on `http://localhost:8002/` as the user `level02`.

Let's start by opening the URL to see what the page does.
Replace `localhost` with the IP address you gave your VM.
Or, you can get the page using `curl` on the VM itself:

    curl localhost:8002

Ok so the page has a simple form with two input fields:
name and age.
Let's play with it a little bit,
especially by entering invalid values to see what happens,
either using a browser or `curl`, for example:

    curl localhost:8002 -d name=jack
    curl localhost:8002 -d name=jack -d age=3
    curl localhost:8002 -d name=jack -d age=x
    curl localhost:8002 -d age=3
    curl localhost:8002 -d name="';select * from users" -d age=x

What can we deduce about the service so far?

- It requires both name and age
- It responds with a greeting with the name and age
- It doesn't seem to validate input

So far none of this really helps us.
But we haven't checked all kinds of user input.
Consider for example cookies.
Most websites store some data in cookies,
for example a session id,
so that users don't need to login repeatedly.

How do cookies work?
Cookies are usually set by the server,
by adding a `Set-Cookie` in the header of an HTTP response.
When the browser receives such header,
it stores this cookie data given by the server,
and will resend it to the server in every future request,
by setting the exact same value in the `Cookie` header.
A well-behaving browser sends back exactly what it was told.
But nothing prevents you from setting something else in the `Cookie` header.
In essence, cookies are just another kind of user input,
and the web programmer must validate them just as cautiously as regular inputs sent by `GET` and `POST` requests.

Enough speculation,
let's see if this website uses cookies.
One way to do that is adding the `-v` flag to see detailed output.
A cleaner way is to save the header in a file using the `--dump-header` or its shorter alias `-D`, like this:

    $ curl localhost:8002 -D header.txt
    $ cat header.txt 
    HTTP/1.0 200 OK
    Content-Type: text/html; charset=utf-8
    Content-Length: 462
    Set-Cookie: user_details=amzyYydipxZeZoVg.txt; Path=/
    Server: Werkzeug/0.9-dev Python/2.7.3
    Date: Thu, 26 Sep 2013 05:49:09 GMT

Evidently, the website does use cookies:
it sets a cookie with name "user_details",
with a seemingly random value.
Let's send the cookie back and see what happens:

    curl localhost:8002 --cookie user_details=amzyYydipxZeZoVg.txt

Notice in the response an extra line above the input form:

    <p>127.0.0.1 is using curl/7.21.7 (i686-pc-linux-gnu) libcurl/7.21.7 OpenSSL/1.0.0d zlib/1.2.5 libssh2/1.2.7</p>

Actually this is an information about us, the client:
127.0.0.1 is our IP address and the text after "is using" is User-Agent string of our "browser" (curl).

What happens if we are not a well-behaving client and set the cookie to something different?

    curl localhost:8002 --cookie user_details=x

We get a `500 Internal Server Error`,
which doesn't help us much.
But we can do better than setting random values.
Notice that the value set by the server looks suspiciously like a filename,
with its `.txt` extension.
What if we set the value to a valid file that exists in the filesystem?

    echo hello > /tmp/hello
    curl localhost:8002 --cookie user_details=/tmp/hello

the `.txt` extension makes it look like a filename.
to a seemingly random value,
though the `.txt` suggests it is a filename.


Cookies are stored by the user's browser,
and the browser resends them to the server in every single request.
Notice the problem here:
the server may set some values in the cookie,
but the client can send back whatever he wants.

Visit the page 
If you have setup your virtual machine with an IP address
that you can access from your PC
You could use a 

```python
    user_details = request.cookies.get('user_details')
    if not user_details:
        params['out'] = 'Looks like a first time user. Hello, there!'
        filename = random_string(16) + '.txt'
        path = os.path.join(wwwdata_dir, filename)
        f = open(path, 'w')
        f.write('%s is using %s\n' % (request.remote_addr, request.user_agent))
        resp = make_response(render_template('index.html', **params))
        resp.set_cookie('user_details', filename)
    else:
        filename = user_details
        path = os.path.join(wwwdata_dir, filename)
        params['out'] = open(path).read()
        resp = make_response(render_template('index.html', **params))
```

On the next level

https://github.com/janosgyerik/ctf-o-matic/blob/master/ctf1/code/levels/level02/level02.py
The vulnerability: using a browser cookie and without validation
to read files on the server The exploit: a cookie can be crafted
with a relative path to reveal the content of sensitive files The
lesson: Always validate user input properly

Remember, the point is not about these specific challenges or their solution.
The point is the process.
Put your own programs to the test.
Have you ever made a simple website that stores data in temporary files and shows their content to the user later?
Or photos? Or videos?
Are you sure you validate the inputs correctly?
Are you sure one cannot enter values as a path prefix like `/path/to/somewhere` or `../../../path/to/somewhere` to read something they were not supposed to?
