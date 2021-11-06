#! /bin/bash

wget \
 --recursive \
 --no-clobber \
 --page-requisites \
 --html-extension \
 --convert-links \
 --restrict-file-names=unix \
 --domains pkg.go.dev \
 --no-parent \
https://pkg.go.dev/9fans.net/go@v0.0.4/acme
