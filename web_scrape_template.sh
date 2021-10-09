#! /bin/bash

wget \
 --recursive \
 --no-clobber \
 --page-requisites \
 --html-extension \
 --convert-links \
 --restrict-file-names=unix \
 --domains 9lab.org \
 --no-parent \
https://9lab.org/
