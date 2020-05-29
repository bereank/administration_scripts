

#!/bin/bash

# Source and destination mail server setting
SERVER1=mail.example.co.ke
SERVER2=mail2.example.co.ke

# Select appropriate auth mechanism.
#AUTHMECH1=""
#AUTHMECH2="--authmech2 LOGIN"

# Uncomment if you want to start test/dryrun only. No emails will be transfered!
#TESTONLY="--dry"

# Path to imapsync
#imapsync=/usr/bin/imapsync

# Users file
if [ -z "$1" ]
then
echo "No users text file given."
exit
fi

if [ ! -f "$1" ]
then
echo "Given users text file \"$1\" does not exist"
exit
fi

# start loop
{ while IFS=';' read  u1; do
        imapsync --host1 ${SERVER1} --user1 "$u1" --authuser1 admin --password1 letmein --tls2 --host2 ${SERVER2} --user2 "$u1" --authuser2 admin --password2  letmein --syncinternaldates --subscribe
done ; } < $1
