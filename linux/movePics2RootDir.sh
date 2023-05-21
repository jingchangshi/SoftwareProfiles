#!/bin/bash
if [ "$1" == "" ]; then
  echo "You must provide the directory!"
  exit 1
elif [ "$1" == "$HOME/" ]; then
  echo "The directory is not allowed to be $HOME/"
  exit 1
fi
root_dir=$1
cd $root_dir
find . -name "*.jpg" | while read f; do mv $f ./; done
find . -name "*.jpeg" | while read f; do mv $f ./; done
find . -name "*.png" | while read f; do mv $f ./; done
ls -d */ | while read d; do echo $d && rmdir -p $d; done

