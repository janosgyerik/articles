## Level 2: always validate all forms of user input

As we login with `level01` user we are presented the next challenge.
Again, the password to the next level is in `/home/level02/.password`,
well protected from our eyes,
except a web-based vulnerability running on `http://localhost:8002/`
as the user `level02`.

Let's start by opening the page to see what it does.
Replace `localhost` with the IP address you gave your VM.
Or, you can get the page using `curl` on the VM itself:

    curl localhost:8002

Ok so the form has a simple form with two input fields,
name and age.
You can play with it a little bit,
especially entering invalid values and see what happens,
using a browser or `curl`, for example:

    curl localhost:8002 -d name=jack
    curl localhost:8002 -d name=jack -d age=3
    curl localhost:8002 -d name=jack -d age=x
    curl localhost:8002 -d age=3
    curl localhost:8002 -d name="';select * from users" -d age=x

What can we deduce about the service so far?

- It requires both name and age
- It outputs a greeting with the name and age
- It does not seem to validate input

So far none of this really helps us.
But we haven't checked all kinds of user input.
For example cookies.
Most websites store some data in cookies,
for example a session id,
so that users don't need to login repeatedly.

How do cookies work?
Cookies are usually set by the server,
by adding a `Set-Cookie` in the header of an HTTP response.
When the user's browser receives such header,
it stores the given cookie data,
and will resend it to the server in every subsequent request,
by setting a `Cookie` header.

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


