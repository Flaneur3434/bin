#! /bin/bash

wget \
 --recursive \
 --no-clobber \
 --page-requisites \
 --html-extension \
 --convert-links \
 --restrict-file-names=unix \
 --domains granivo.re \
 --no-parent \
https://granivo.re/plan9/
