#!/bin/bash

# This script creates ftp user and generates password

# Sanity check
# UID_TO_CHECK_FOR='0'
DOM="type_suffix_if_necessary"

# Accepts first provided argument as user name
USER_NAME="${1}" 
DIRECTORY="/path/to/ftp/dir/${USER_NAME}"
FTPUID="user_name"
FTPGID="group_name"
if [[ 0 != "$UID" ]]
then
  echo 'Please run with sudo or as root.' >&2
  exit 1
fi

# If no arguments provided print help
if [[ "$#" -ne 1 ]]
then  
  echo
  echo "USAGE: $0 [USER_NAME]" >&2
  echo
  exit 1
fi

# Accept first argument as username

echo "Creating ${USER_NAME}'s ftp account." > /dev/null



# Creating folder
mkdir -p "${DIRECTORY}" &> /dev/null

# Checking mkdir exit status
if [[ ${?} -ne 0 ]]
then
	echo "Failed to create ${DIRECTORY}"
	exit 1
fi

chown -R "${FTPUID}:${FTPGID}" ${DIRECTORY} &> /dev/null
if [[ ${?} -ne 0 ]]
then
        echo "Failed to change directory owner"
        exit 1
fi

chmod 775 "${DIRECTORY}"
if [[ ${?} -ne 0 ]]
then
        echo "Failed to chmod"
        exit 1
fi


# Generate a password
PASSWORD=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c18)
echo 'Generating password' > /dev/null

# Creating an account
echo ${PASSWORD} | ftpasswd --passwd --stdin --name=${USER_NAME}${DOM} --uid=$(id -u ${FTPUID}) --gid=$(id -u ${FTPGID}) --home="${DIRECTORY}" --shell=/bin/false --file=/etc/ftpd.passwd &> /dev/null
# Checking exit status
if [[ $? -ne 0 ]]
then
  echo 'Account creation failed.' >&2
  exit 1
fi

chmod 444 "/etc/ftpd.passwd" &> /dev/null
if [[ $? -ne 0 ]]
then
  echo 'Failed to set premissions for /etc/ftpd.passwd' >&2
fi

service proftpd reload &> /dev/null

# Printing all information for further use.
echo "login: ${USER_NAME}${DOM}"
echo "pass: ${PASSWORD}"
echo "dir: ${USER_NAME}"
echo "USER CREATION DONE" > /dev/null
exit
