#!/usr/bin/bash
touch text.txt
DIR="textfolder/"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Installing config files in ${DIR}..."
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Folder Not present we are creating another one"
  mkdir testfolder
  exit 1
fi

cd "/home/berean"
#cp text.txt $DIR
