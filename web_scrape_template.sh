#! /bin/bash

#  TODO 2022-01-13: Add an argument option to switch between downloading
#                   whole websites and just pictures
# wget \
#  --recursive \
#  --no-clobber \
#  --page-requisites \
#  --html-extension \
#  --convert-links \
#  --restrict-file-names=unix \
#  --domains maw.gay \
#  --no-parent \
# http://maw.gay/


wget \
	-r \
	-P \
	-A jpg,jpeg,gif,png \
	http://img.stanleylieber.com/
