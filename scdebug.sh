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
        shift
        ;;
      -h | --help)
        shift
        usage
        break
        ;;
        -nattch)
          nattch=true
          shift
          name_pid $@
        ;;
        -pattch)
          pattch=true
          shift
          pid_list $@
        ;;
        -v)
          if [ -n "$program" ]; then
            trace_file=$(basename $(find $HOME/.scdebug/$program/*.txt -type f -exec stat -c '%Y %n' {} + | sort -n | head -n 1 | awk '{print $2}'))
            file_time=$(stat $(find $HOME/.scdebug/$program/*.txt -type f -exec stat -c '%Y %n' {} + | sort -n | head -n 1 | awk '{print $2}') | grep Modify | sed 's/Modify: //')
            echo "===== Command: $program ====="
            echo "===== Trace File: $trace_file ====="
            echo "===== Time: $file_time ====="
          else 
            program=$2
            trace_file=$(basename $(find $HOME/.scdebug/$program/*.txt -type f -exec stat -c '%Y %n' {} + | sort -n | head -n 1 | awk '{print $2}'))
            file_time=$(stat $(find $HOME/.scdebug/$program/*.txt -type f -exec stat -c '%Y %n' {} + | sort -n | head -n 1 | awk '{print $2}') | grep Modify | sed 's/Modify: //')
            echo "===== Command: $program ====="
            echo "===== Trace File: $trace_file ====="
            echo "===== Time: $file_time ====="
          fi
          exit 0
        ;;
        -vall)
          if [ -n "$program" ]; then
            trace_files=($(find $HOME/.scdebug/$program -type f))
            for trace_file in "${trace_files[@]}"; do
              file_name=$(basename $trace_file)
              file_time=$(stat $trace_file | grep Modify | sed 's/Modify: //')
              echo "===== Command $program ====="
              echo "===== Trace File: $file_name ====="
              echo "===== Time: $file_time ====="
              echo ""
            done
          else
            program=$2
            trace_files=($(find $HOME/.scdebug/$program -type f))
            for trace_file in "${trace_files[@]}"; do
              file_name=$(basename $trace_file)
              file_time=$(stat $trace_file | grep Modify | sed 's/Modify: //')
              echo "===== Command $program ====="
              echo "===== Trace File: $file_name ====="
              echo "===== Time: $file_time ====="
              echo ""
            done
          fi
          exit 0
        ;;
      * )
        if command -v "$1" > /dev/null 2>&1; then
          program="$1"
          shift
          program_parameters=()
          while [ "$1" != "-sto" ] && [ "$1" != "-h" ] && [ "$1" != "--help" ] && [ "$1" != "-natcch" ]  && [ "$1" != "-pattch" ] && [ "$1" != "" ] && [ "$1" != "-v" ] && [ "$1" != "-vall" ]; do
            program_parameters+=($1)
            shift
          done
        elif [ $2 == "-v" ]; then
          program=$1
          shift
        else
          shift
        fi
        ;;
    esac
  done
  if [ -n "$nattch" ] || [ -n "$pattch" ]; then
    program_attach
  else
    program_tracing
  fi
}
program_tracing(){
  if [ -n "$sto_options" ]; then
    mkdir -p "$HOME/.scdebug/$program/"
    strace "$sto_options" -o "$HOME/.scdebug/$program/$TRACE_NAME" "$program" "${program_parameters[@]}" &
  else
    mkdir -p "$HOME/.scdebug/$program/"
    strace -o "$HOME/.scdebug/$program/$TRACE_NAME" "$program" "${program_parameters[@]}" &
  fi
}
program_attach(){
  if [ -n "$sto_options" ]; then
    for program in "${!programs_pid[@]}"; do
      mkdir -p "$HOME/.scdebug/${programs_pid[$program]}/"
      strace "$sto_options" -p "$program" -o "$HOME/.scdebug/${programs_pid[$program]}/$TRACE_NAME" &
    done
  else
    for program in "${!programs_pid[@]}"; do
      mkdir -p "$HOME/.scdebug/${programs_pid[$program]}/"
      strace -p "$program" -o "$HOME/.scdebug/${programs_pid[$program]}/$TRACE_NAME" &
    done
  fi
}
name_pid() {
  while [ "$1" != "-sto" ] && [ "$1" != "-h" ] && [ "$1" != "--help" ] &&  [ "$1" != "-pattch" ] && [ "$1" != "" ]; do
    programs_pid["$(pgrep $1 | tr ' ' '\n' | tail -n 1)"]="$1"
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
  




