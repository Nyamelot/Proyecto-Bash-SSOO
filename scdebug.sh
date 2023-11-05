#!/bin/bash

#scdebug - An script that trace processes

#### Constants

UUID=$(uuidgen)
TRACE_NAME="trace_$UUID.txt"
TRACE_PATH="$HOME/.scdebug/$program"
CURRENT_TRACE_PATH="$HOME/.scdebug/$program/$TRACE_NAME"


#### Functions
help_text() {
  echo ""
}
error_text() {
  echo ""
}
usage() {
  echo ""
}
options() {
  while [[ $1 != "" ]]; do
    case $1 in
      -sto )
        shift
        echo "$1"
        ;;
      -h | --help)
        shift
        echo "$1"
        # comprobar si hay un valor, si no lo hay -> error
        # comprabar si el valor continue un "-", si lo continue es que
        # tampoco hay un valor
        pepe+="$1 "
        ;;
      * )
        # argumento desconocido - error
        shift
        ;;
    esac
  done
}

#### Main Program


options $@

