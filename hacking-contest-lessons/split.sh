#!/bin/sh -x

cd $(dirname "$0")

out=out
prefix=security-lessons
mkdir -p $out

combine() {
    sed -e '/```/,/```/ s/^/    /' -e 's/^    ```//'
}

combine1() {
    cat intro.md setup.md level[1-3].md to-be-continued.md | combine
}

html1() {
    combine1 | markdown_py
}

text1() {
    combine1 | markdown_py | html2text -style pretty
}

combine2() {
    cat cont.md level[4-6].md conclusion.md | combine
}

html2() {
    combine2 | markdown_py
}

text2() {
    combine2 | markdown_py | html2text -style pretty
}

combine1 > $out/$prefix-part1.md
html1 > $out/$prefix-part1.html
text1 > $out/$prefix-part1.txt
combine2 > $out/$prefix-part2.md
html2 > $out/$prefix-part2.html
text2 > $out/$prefix-part2.txt
