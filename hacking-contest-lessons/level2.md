## Level 2: always validate all sorts of user input

As we login with `level01` user,
the explanation of the next challenge appears.
Like before,
the password for the next level is in `/home/level02/.password`.
We don't have any permissions on `/home/level02`,
so the file is not easy to access.
On the other hand,
the message of the day tell us about a web-based vulnerability
running on `http://localhost:8002/`.

Let's start by opening the URL to see what the page does.
Replace `localhost` with the IP address you gave your VM.
Or, you can get the page using `curl` on the VM itself:

    curl localhost:8002

Ok so the page has a simple form with two input fields:
name and age.
Let's play with that a little bit,
especially by entering invalid values and see what happens.
You can use a browser or `curl`,
for example:

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

Ask yourself, how do cookies really work?
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

    echo hello > /tmp/x
    curl localhost:8002 --cookie user_details=/tmp/x

Sweet! The page prints the contents of the file!
The next move is of course:

    curl localhost:8002 --cookie user_details=/home/level02/.password

Bingo!
We managed to misuse the web service to do something it was clearly not intended for:
print the contents of a file that's supposed to be private to the owner of the process,
user `level02`.
And we didn't even need to look at the source code!

Of course, we got a bit lucky here.
I've seen similar vulnerabilities in real life,
and in most cases absolute paths would not work,
due to the way the web service was written.
Relative paths are more likely to work.
Not a problem,
in that case we could try prefixing the absolute path with multiple `../` strings,
until we reach the filesystem root so that the path becomes a valid relative path to the file we're looking for,
like this:

    curl localhost:8002 --cookie user_details=../home/level02/.password
    curl localhost:8002 --cookie user_details=../../home/level02/.password
    curl localhost:8002 --cookie user_details=../../../home/level02/.password

What can we learn from all this?

- Don't trust user input.
  You have to validate all possible kinds of external input:
  form fields, cookies, or other parameters your programs might use.

- Take a long hard look at web services you have written.
  What will happen if you feed it invalid values?
  Are you sure there are no input fields that can be misused
  to read or write to unauthorized files on your server?

A realistic example is uploading a profile picture.
Most users will upload regular image files,
which you can simply display in `<img>` tags.
But a malicious user might upload a script instead of a real image.
Once the script is on the server,
he may be able to run it and do nasty things.
Even worse,
after doing nasty things,
the script may output image data,
so that when other users view his profile page they would see a picture,
but in fact the script would get access to the session cookie of the user that was included in the header of his http request,
and potentially steal the session of other users.

The bottom line is: you have to validate all sorts of user inputs carefully,
especially on your public web services that are accessible by everyone.
