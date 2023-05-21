#!/bin/bash
if [ "$1" == "" ]; then
  echo "A directory is required!"
  exit
fi
dest_dir=$HOME/Sync
src_abs_dir=$(readlink -f $1)
src_parent_dir=$(dirname $src_abs_dir)
l1=${#src_abs_dir}
l2=${#src_parent_dir}+1
src_dirname=${src_abs_dir:$l2:$l1}
tar -acf ${src_dirname}.tar $src_abs_dir
mv ${src_dirname}.tar $dest_dir/
