## Level 2: validate all types of input

As the message of the day explains,
this challenge is a web-based vulnerability.
Let's start by opening the URL to see what the page does:
```
curl localhost:8002
```

The page has a simple form with two input fields:
name and age.
Let's play with that a little bit,
especially by entering invalid values,
and see what happens:
```
curl localhost:8002 -d name=jack
curl localhost:8002 -d name=jack -d age=3
curl localhost:8002 -d name=jack -d age=x
curl localhost:8002 -d age=3
curl localhost:8002 -d name="';select * from users" -d age=x
```

The page greets us back if we enter values in both fields.
That doesn't really help us.
But we haven't checked all possible types of user input.
What about cookies, for example?
Most websites store some data in cookies,
for example a session id,
so that users don't need to login repeatedly.

How do cookies really work?
Cookies are usually set by the server,
by adding a `Set-Cookie` value in the header of an HTTP response.
Once a browser received a cookie,
it will resend it to the server in every future request until it expires,
by setting the exact same value in the `Cookie` header.
That's what a well-behaving browser does.
But nothing prevents us from setting it to something else.

To see if the website uses cookies,
let's save the HTTP header to a file:
```
level01@box:~$ curl localhost:8002 -sD header.txt >/dev/null
level01@box:~$ cat header.txt 
HTTP/1.0 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 462
Set-Cookie: user_details=amzyYydipxZeZoVg.txt; Path=/
Server: Werkzeug/0.9-dev Python/2.7.3
Date: Thu, 26 Sep 2013 05:49:09 GMT
```

As the `Set-Cookie` line reveals,
the website sets a cookie named `user_details`,
with a seemingly random value.
Let's send the cookie back and see what happens:
```
curl localhost:8002 --cookie user_details=amzyYydipxZeZoVg.txt
```

There is an extra line above the input form:
```
<p>127.0.0.1 is using curl/7.21.7 (i686-pc-linux-gnu) libcurl/7.21.7 OpenSSL/1.0.0d zlib/1.2.5 libssh2/1.2.7</p>
```

This happens to be an information about us, the client:
`127.0.0.1` is our IP address and the text after "is using" is the `User-Agent` string of our "browser": `curl`.

What happens if we set the cookie to something else?
```
level01@box:~$ curl localhost:8002 --cookie user_details=x
...
<title>500 Internal Server Error</title>
...
```

Oops, a `500 Internal Server Error`.
That doesn't help us much,
but we can do better than shooting randomly.
Notice that the value "amzyYydipxZeZoVg.txt" looks suspiciously like a filename with a `.txt` extension.
What if we set the value to a real file that actually exists in the filesystem?
Such as the password file we're after?
```
curl localhost:8002 --cookie user_details=/home/level02/.password
```

Bingo!
We managed to trick the web service to reveal the content of a confidential file,
without even looking at the source code.

### Lessons to learn

- Don't trust user input.
  You have to validate all possible types of input:
  form fields, cookies, command line arguments,
  anything your programs might receive.

- Take a long hard look at web services you have ever written.
  What will happen if you feed them with invalid input?
  Are you sure there are no input fields or cookies that can be misused?

- Don't use techniques that divulge internal information,
  such as the cookie value that looked like a filename.

