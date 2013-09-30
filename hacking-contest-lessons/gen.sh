#!/bin/sh -x

cd $(dirname "$0")

out=out
prefix=security-lessons
mkdir -p $out

combine() {
    cat intro.md setup.md level?.md conclusion.md | sed -e '/```/,/```/ s/^/    /' -e 's/^    ```//'
}

html() {
    combine | markdown_py
}

text() {
    combine | markdown_py | html2text -style pretty
}

combine > $out/$prefix.md
html > $out/$prefix.html
text > $out/$prefix.txt
