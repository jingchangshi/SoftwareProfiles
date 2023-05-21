#!/bin/bash
if [[ "$3" = "" ]]; then
  echo "Require 3 arguments!"
  exit
fi
dirbase=$1
dirname=$2
crypted=$3
# Do not crypt the large file. Just upload it.
# crypted=0
# Crypt the tar file
# crypted=1

cryptkey=$HOME/software_profile/linux/ccrypt.key
cryptbin=$HOME/Softwares/ccrypt/ccrypt
baidupcs=$HOME/Softwares/BaiduPCS-Go/BaiduPCS-Go
tmpbase=/tmp/jcshi
baidudirbase=/Work

tar_thres_unit="G"
tar_thres_val=2

mkdir -p ${tmpbase}
cd ${dirbase}
dir_is_large=0
dir_size=$(du -sh ${dirname} | awk '{print $1}')
if [[ "$dir_size" = *"$tar_thres_unit" ]]; then
  dir_size_val=$(echo $dir_size | sed 's/[^0-9.]*//g')
  if [[ "$(echo "$dir_size_val > $tar_thres_val" | bc)" = "1" ]]; then
    dir_is_large=1
  fi
fi
# Create tarball
if [[ "$dir_is_large" = "0" ]]; then
  tar -acf ${dirname}.tar ${dirname}
else
  7za a -ttar -v${tar_thres_val}${tar_thres_unit} ${dirname}.tar ${dirname}
fi
#
if [ "${crypted}" = 0 ]; then
  mv ${dirname}.tar* ${tmpbase}/
else
  # Crypt the tarball
  if [[ "$dir_is_large" = 0 ]]; then
    ${cryptbin} -k ${cryptkey} -e ${dirname}.tar
  else
    ls ${dirname}.tar* | while read f; do ${cryptbin} -k ${cryptkey} -e $f; done
  fi
  mv ${dirname}.tar*cpt ${tmpbase}/
fi
#
cd $tmpbase
# Rename to append the date
dirname_date=${dirname}_$(date +%Y-%m-%d)
dirname_strlen=${#dirname}
#
if [ "${crypted}" = 0 ]; then
  #
  ls ${dirname}.tar* | while read f; do mv $f ${dirname_date}${f:$dirname_strlen:15}; done
  # Upload
  ${baidupcs} upload ${dirname_date}.tar* ${baidudirbase}/
  # Rename back
  ls ${dirname_date}.tar* | while read f; do mv $f ${dirname}.${f#*.}; done
  #
else
  #
  ls ${dirname}.tar*cpt | while read f; do mv $f ${dirname_date}${f:$dirname_strlen:15}; done
  # Upload
  ${baidupcs} upload ${dirname_date}.tar*cpt ${baidudirbase}/
  # Rename back
  ls ${dirname_date}.tar*cpt | while read f; do mv $f ${dirname}.${f#*.}; done
  #
fi
