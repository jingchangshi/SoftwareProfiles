#!/bin/bash
host=jcshi@129.237.112.108
# It must establish the ssh tunnel in master mode before executing this script.
# Check the content in ~/.ssh/config as follows,
# host *
#   controlmaster auto
#   controlpath /tmp/ssh-%r@%h:%p
# ssh $host
infile_info_dir=$1
# Read in input file to extract all folders the user wants to sync.
while IFS='' read -r source || [[ -n "$source" ]]; do
  if [[ -z $source ]]; then
    echo "Empty line encountered. Exit."
    exit
  fi
  dest=$source
  echo "You want to sync: $host:$source"
  echo "              to: $dest"
  source_dir=${source%\**}
  dest_dir=${dest%\**}
  if [[ $(expr index "$source" '*') -eq '0' ]]; then
    mkdir -p $dest_dir
    rsync -auv $host:$source_dir/ $dest_dir/
  else
    regex=${source##*\*}
    mkdir -p $dest_dir
    rsync -auv -m --include=*$regex --include='*/' --exclude='*' $host:$source_dir $dest_dir
  fi
done < $infile_info_dir

