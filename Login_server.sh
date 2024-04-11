#!/bin/bash

# Function to check failed login attempts history
check_failed_login_attempts() {
    local os_type="$1"
    local log_file

    if [ "$os_type" == "Ubuntu" ]; then
        log_file="/var/log/auth.log"
    elif [ "$os_type" == "Red Hat" ]; then
        log_file="/var/log/secure"
    else
        echo "Unsupported OS type: $os_type"
        return 1
    fi

    echo "Failed login attempts history for $os_type:"
    grep -E 'Failed|invalid user' "$log_file" | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}' | while read -r line; do
        echo "$line"
    done
}
#Detect the server Type
if [ -f "/etc/redhat-release" ]; then
        SERVER_TYPE="Red Hat"
elif [ -f "/etc/lsb-release" ]; then
        SERVER_TYPE="Ubuntu"
else
        SERVER_TYPE="Unknown"
fi

# Check failed login attempts history for Ubuntu
case "$SERVER_TYPE" in
        "Red hat")
                check_failed_login_attempts "$SERVER_TYPE"
                ;;
        "Ubuntu")
                check_failed_login_attempts "$SERVER_TYPE"
                ;;
        *)
                echo "Unable to determine the server."
                ;;
esac
