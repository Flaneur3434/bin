#! /bin/bash

wget \
 --recursive \
 --no-clobber \
 --page-requisites \
 --html-extension \
 --convert-links \
 --restrict-file-names=unix \
 --domains ueber.net \
 --no-parent \
https://www.ueber.net/who/mjl/plan9/plan9-obsd.html
