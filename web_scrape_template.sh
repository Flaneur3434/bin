#! /bin/bash

wget \
 --recursive \
 --no-clobber \
 --page-requisites \
 --html-extension \
 --convert-links \
 --restrict-file-names=unix \
 --domains 9p.io \
 --no-parent \
https://9p.io/sys/man/index.html
