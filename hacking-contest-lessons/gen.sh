#!/bin/sh -x

cd $(dirname "$0")

out=out
prefix=security-lessons
mkdir -p $out

cat intro.md setup.md level?.md conclusion.md > $out/$prefix.md
cat intro.md setup.md level?.md conclusion.md | sed -e '/```/,/```/ s/^/    /' -e 's/^    ```//' | markdown_py > $out/$prefix.html
html2text -style pretty $out/$prefix.html > $out/$prefix.txt
