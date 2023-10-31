#!/bin/bash

#scdebug - An script that trace processes

#### Constants


TRACE_NAME="trace_"$(uuidgen)".txt"


#### Functions
help_text() {}
error_text() {}
just_program() {
  program="$1"
  shift
  strace -o .scdebug/"$program"/$TRACE_NAME "$program $@"
}

#### Main Program
cat << _EOF_
if [ -n "$1" ]; then
    if command -v "$1" &>/dev/null; then
        just_program()
    else if ["$1" == "--help" ] || ["$1" == "-h"]; then

    else if ["$1" == "sto"]
      
fi
_EOF_