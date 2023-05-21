#!/bin/bash
if [ "$1" == "" ]; then
  echo "No argument is provided!"
  exit
fi
dirname=$1

cryptkey=$HOME/software_profile/linux/ccrypt.key
cryptbin=$HOME/Softwares/ccrypt/ccrypt
baidupcs=$HOME/Softwares/BaiduPCS-Go/BaiduPCS-Go
datestr=$(date +%Y-%m-%d)
dirdate=${dirname}_${datestr}
tmpbase=/tmp/jcshi
baidudirbase=/PicturesVideos

mkdir -p ${tmpbase}/${dirdate}
mv $HOME/${dirname}/* ${tmpbase}/${dirdate}/
cd ${tmpbase}
tar -acf ${dirdate}.tar ${dirdate}
${cryptbin} -k ${cryptkey} -e ${dirdate}.tar
${baidupcs} upload ${tmpbase}/${dirdate}.tar.cpt ${baidudirbase}/
rm ${tmpbase}/${dirdate}.tar.cpt
rm ${tmpbase}/${dirdate}/*
rmdir ${tmpbase}/${dirdate}
