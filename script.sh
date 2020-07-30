#!/usr/bin/php

<?php
$user="root";
$pass="";
$db="vmail";
$table_mbox="mailbox";
$table_alias="alias";
$file="exported.sh";
echo "This script generates a bash script called: $file
The script contains the commands to re-create the mboxes and
aliases on zimbra server.\n\n
";

$mydb = mysql_connect('localhost',$user, $pass) or die ('Error connecting to server');
mysql_select_db($db);
mysql_query("SET CHARACTER SET utf8");
mysql_query("SET NAMES utf8");

$query = "SELECT username,password,name,maildir,quota,domain FROM mailbox where domain='";
$dane = mysql_query($query) or die ('Error during query for '.mysql_error());

echo "Writing to $file ...\n";
$fh = fopen($file, "w");

fwrite($fh, "#!/bin/sh -x\n\n");

while ($row = mysql_fetch_array($dane, MYSQL_NUM))
{
    $data_mbox = "zmprov ca ".$row[0]." dsfs123hsdyfgbsdgfbsd displayName '".$row[2]."'\n";
    $data_mbox .= "zmprov ma ".$row[0]." userPassword '{crypt}".$row[1]."'"."\n";
    fwrite($fh, $data_mbox);
}
// skip domain aliases, aliases that forward to themselves and aliases
// for which a mbox exists
$query = "SELECT address, trim(trailing ',' from goto) AS dest
                FROM ".$table_alias." where domain='develop.co.ke' WHERE address NOT LIKE '@%'
                        AND address NOT IN (SELECT username FROM $table_mbox)
                HAVING address != dest";
$dane = mysql_query($query) or die ('Error during query for '.mysql_error());
while ($row = mysql_fetch_array($dane, MYSQL_NUM)) {
        // multiple dests
        unset($rawdest_r);
        unset($dest_r);
        $rawdest_r = preg_split('/,/', $row[1]);
        foreach ($rawdest_r as $dest) {
                if ($dest != $row[0]) {
               
                        $dest_r[] = $dest;
                }
        }
        if (count($dest_r) > 1) {
                // distribution list
                $data_list .= "zmprov cdl $row[0]\n";
                foreach ($dest_r as $dest) {
                        $data_list .= "zmprov adlm $row[0] $dest\n";
                }
        }
        if (count($dest_r) == 1) {
                preg_match('/@(.*)$/', $row[0], $matches);
                $acct_domain = $matches[0];
                preg_match('/@(.*)$/', $dest_r[0], $matches);
                $alias_domain = $matches[0];
                if ($acct_domain == $alias_domain) {
                        // we are adding an alias, not a forward
                        // try to create alias both for a normal
                        // account and for a distribution list. One of the
                        // commands will fail, pity.
                        $data_alias .= "zmprov aaa $dest_r[0] $row[0]\n";
                        $data_alias .= "zmprov adla $dest_r[0] $row[0]\n";
                } else {
                        // we are adding a forward
                        $data_alias .= "zmprov ca $row[0] " . rand_str(11) . "\n";
                        $data_alias .= "zmprov ma $row[0] zimbraprefmailforwardingaddress $dest_r[0]\n";
                }
        }
}

// first create all distribution lists, last all aliases
// We cannot create aliases for distribution lists that do not
// exist yet
fwrite($fh, $data_list . $data_alias);
fclose($fh);


echo "Done.

Now copy exported.sh to zimbra server and run:
# su - zimbra
$ sh ./$file
";


function rand_str($length = 32, $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890')
{
    // Length of character list
    $chars_length = (strlen($chars) - 1);

    // Start our string
    $string = $chars{rand(0, $chars_length)};

    // Generate random string
    for ($i = 1; $i < $length; $i = strlen($string))
    {
        // Grab a random character from our list
        $r = $chars{rand(0, $chars_length)};

        // Make sure the same two characters dont appear next to each
        // other
        if ($r != $string{$i - 1}) $string .=  $r;
    }

    // Return the string
    return $string;
}
?>

