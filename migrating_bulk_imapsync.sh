#!/bin/bash
echo Looping on account credentials found in file.txt
echo

{ while IFS=';' read  h1 u1 p1 h2 u2 p2 fake
    do
        { echo "$h1" | tr -d '\r' | egrep '^#|^ *$' ; } > /dev/null && continue # this skip commented lines in file.txt
        echo "==== Starting imapsync from host1 $h1 user1 $u1 to host2 $h2 user2 $u2 ===="
        imapsync --automap --noauthmd5 --authmech1 PLAIN --authmech2 LOGIN --debugimap --host1 "$h1" --user1 "$u1" --password1 "$p1" --nossl1 --tls1 \
                 --host2 "$h2" --user2 "$u2" --password2 "$p2" --nossl2 --tls2 \
                 "$@"
        echo "==== Ended imapsync from host1 $h1 user1 $u1 to host2 $h2 user2 $u2 ===="
        echo
    done
} < file.txt
