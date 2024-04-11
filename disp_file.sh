#!/bin/bash

# Define the dispfile function
function dispfile {
  if [ "$1" -le "${DBGLVL}" ]; then
    local msg="---$2: ($(hostname )) ----"

    # Print the message to stdout or log file
    if [ "$STDOUTFLAG" -ne 0 ]; then
      echo "$msg"
    else
      echo "$msg" >> "$LOGFIL"
    fi

    # Log the file contents
    if [ "$STDOUTFLAG" -ne 1 ]; then
      cat "$3" >> "$LOGFIL"
    fi
  fi
}

# Set your log file path
LOGFIL="/home/ubuntu/project1/output.log"

# Set the debug level
DBGLVL=1

# Set the flag to print to standard output
STDOUTFLAG=1

# Call the dispfile function with appropriate parameters
dispfile 1 "Logging" "/home/ubuntu/project1/output.log"
