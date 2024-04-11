#!/bin/bash

user="$1"
host="$2"
port="$3"
batch_file="$4"
current_date=$(date "+%Y-%m-%d")
output_file="/home/ubuntu/project1/output.log"
DBGLVL=2
STDOUTFLAG=0
LOGFIL="/home/ubuntu/project1/output.log"


msg() {
    local DBGLVL="$1"
    local message="$2"

    if [ $1 -le ${DBGLVL} ]; then
        DATIMSTMP=$(date "+%Y-%m-%d %H:%M:%S")
        if [ $STDOUTFLAG -ne 0 ]; then
            echo "$DATIMSTMP $message [$DBGLVL]"
        else
            echo "$DATIMSTMP $message [$DBGLVL]" >> "$LOGFIL"
        fi
    fi
}

sftp_cmd() {
    local user="$1"
    local host="$2"
    local port="$3"
    local batch_file="$4"
    local output_file="$5"

    # print a message indicating the attempt to establish the connection
    echo "------------------------------------------------------------------"

    msg 1 "Attempting to establish SFTP connection to $user@$host on port $port... "

    # Connect to the remote server and execute commands
    sftp -v -P "$port" -b "$batch_file" "$user"@"$host" > "$output_file" >$5 2>&1


    # Check the exit status of the previous command
    if [ $? -eq 0 ]; then
        msg 1 "SFTP connection successful."
    else
        msg 1 "Failed to establish SFTP connection."
    fi

    column -t -s $'\t' "$output_file"
    echo "--------------------------------------------------------------------"
}
msg
msg 1 "start the script......."
sftp_cmd "$user" "$host" "$port" "$batch_file" "$output_file"
