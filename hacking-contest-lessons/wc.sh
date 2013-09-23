#!/bin/sh

cd $(dirname "$0")
wc -w intro.md setup.md level?.md conclusion.md
