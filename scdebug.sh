#!/bin/bash

#scdebug - An script that trace processes

#### Constants

UUID=$(uuidgen)
TRACE_NAME="trace_$UUID.txt"
TRACE_PATH="$HOME/.scdebug/$program"
CURRENT_TRACE_PATH="-o $HOME/.scdebug/$program/$TRACE_NAME"
declare -A programs_pid


#### Functions
error_text() {
  echo ""
}
usage() {
  echo "How to use: scdebug [parameters]"
  echo "✦ -sto [argument]: write -sto and a set of arguments to for strace command"
  echo "✦ -pattch [list of arguments]: write -pattch to trace processes in the background giving a list of pids"
  echo "✦ -nattch [list of arguments]: write -nattch to trace processes in the background giving a list of names"
}
options() {
  program=""
  program_parameters=""
  sto_options=""
  while [[ $1 != "" ]]; do
    case $1 in
      -sto )
        shift
        sto_options=$1
        echo $sto_options
        shift
        ;;
      -h | --help)
        shift
        usage
        break
        ;;
        -nattch)
          echo $1
          name_pid
          shift
        ;;
        -pattch)
          pid_list
        ;;
      * )
        if command -v "$1" > /dev/null 2>&1; then
          program="$1"
          shift
          program_parameters=()
          while [ "$1" != "-sto" ] && [ "$1" != "-h" ] && [ "$1" != "--help" ] && [ "$1" != "-natcch" ] && [ "$1" != "-pattch" ] && [ "$1" != "" ]; do
            program_parameters+=($1)
            shift
          done
        else
          shift
        fi
        ;;
    esac
  done
  program_attach
}
program_tracing(){
  if [ -n "$sto_options" ]; then
    mkdir -p "$HOME/.scdebug/$program/"
    echo "${program_parameters[@]}"
    echo "$sto_options"
    strace "$sto_options" -o "$HOME/.scdebug/$program/$TRACE_NAME" "$program" "${program_parameters[@]}"
  else
    mkdir -p "$HOME/.scdebug/$program/"
    strace -o "$HOME/.scdebug/$program/$TRACE_NAME" "$program" "${program_parameters[@]}"
  fi
}
program_attach(){
  if [ -n "$sto_options" ]; then
    for program in "${!programs_pid[@]}"; do
      mkdir -p "$HOME/.scdebug/${programs_pid[$program]}/"
      strace "$sto_options" -p "$program" -o "$HOME/.scdebug/${programs_pid[$program]}/$TRACE_NAME"
    done
  else
    for program in "${!programs_pid[@]}"; do
      mkdir -p "$HOME/.scdebug/${programs_pid[$program]}/"
      strace -p "$program" -o "$HOME/.scdebug/${programs_pid[$program]}/$TRACE_NAME"
    done
  fi
}
name_pid() {
  echo "hola"
  echo "$1"
  while [ "$1" != "-sto" ] && [ "$1" != "-h" ] && [ "$1" != "--help" ] &&  [ "$1" != "-pattch" ] && [ "$1" != "" ]; do
    programs_pid["$(pgrep $1 | tr ' ' '\n' | tail -n 1)"]="$1"
    echo $1
    shift
  done
}
pid_list(){
  while [ "$1" != "-sto" ] && [ "$1" != "-h" ] && [ "$1" != "--help" ] &&  [ "$1" != "-nattch" ] && [ "$1" != "" ]; do
    programs_pid["$1"]=$(ps -p "$1" -o comm=)
    shift
  done
}


#### Main Program
  options $@




