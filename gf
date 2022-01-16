#!/bin/bash

if [[ $# == 0 ]]; then
  tree -fxh -L 1 | sed '/^[0-9].*/d' 
else
    while [[ ! $# == 0 ]]
    do
        case "$1" in
            -a)
                tree -fxha -L 1 | sed '/^[0-9].*/d' 
                ;;
            *)
                echo "Enter correct flags"
                ;;
        esac
        shift
    done
fi

exit 0
