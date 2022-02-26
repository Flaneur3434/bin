 #! /bin/bash

#  TODO 2022-01-13: Add an argument option to switch between downloading
#                   whole websites and just pictures
wget \
 --recursive \
 --no-clobber \
 --page-requisites \
 --html-extension \
 --convert-links \
 --restrict-file-names=unix \
 --domains www.catb.org \
 --no-parent \
http://www.catb.org/~esr/faqs/hacker-howto.html#basic_skills


# wget \
# 	-r \
# 	-P \
# 	-A jpg,jpeg,gif,png \
# 	http://img.stanleylieber.com/
