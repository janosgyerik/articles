#!/bin/sh

format() {
    sed -e 's/: */: /' -e 's/$/\n/' | fmt -w 60 | sed -e 's/^ */        /'
}

for file; do
    test -f "$file" || continue
    echo '* checking file' $file ...

    is_by_count=$(grep -E 'is\s+\w+\s+by' "$file" | wc -l)
    echo '    "Do not use "is by"": '$is_by_count
    grep -nE 'is\s+\w+\s+by' "$file" | format

    starting_ing_count=$(grep -E '\<[A-Z]\w+ing\>.*\.' "$file" | wc -l)
    echo '    "Do not start sentences with gerund": '$starting_ing_count
    grep -nE '\<[A-Z]\w+ing\>.*\.' "$file" | format

    midsentence_ing_count=$(grep -E '\<[a-z]\w+ing\>.*\.' "$file" | wc -l)
    echo '    "Do not use gerund in sentences": '$midsentence_ing_count
    grep -nE '\<[a-z]\w+ing\>.*\.' "$file" | format

    etc_count=$(grep -E '\<etc\>' "$file" | wc -l)
    echo '    "Do not use "etc" and other latin": '$etc_count
    grep -nE '\<etc\>' "$file" | format

    echo
done
