###########
# root
###########
# CentOS-Base(aliyun)
cd /etc/yum.repos.d/
mv CentOS-Base.repo CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo
yum makecache
# epel(aliyun)
yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm
sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*
# Setup host name
hostname T470-CentOS8
# Install required packages
yum install python2 patch zsh ctags ntfs-3g -y
yum install gcc gcc-c++ gcc-gfortran make gdb cmake -y
yum install ghostscript gnuplot -y
# for compiling tmux
yum install libevent libevent-devel ncurses ncurses-devel ncurses-libs -y
# HP printer and scanner
yum install hplip -y

###########
# jcshi
###########
# Setup SSR
ln -s /usr/bin/python2 python
chmod +x electron-ssr-0.2.6.AppImage
# generate ssh-key
ssh-keygen
# google-chrome

# KeePassXC

chmod +x KeePassXC-2.6.0-x86_64.AppImage

# software_profile
git clone git@e.coding.net:desperadoshi/software_profile.git
cd software_profile
./autolink.sh


# python
pip3 install numpy scipy matplotlib ranger-fm jupyter --user

# pandoc
# Download and move to the specific location

# tmux
tar -xf tmux.tar.gz
cd tmux
./configure --prefix=/home/jcshi/Softwares/tmux
make -j 2
make install

# gmsh
# https://gmsh.info/bin/Linux/gmsh-3.0.6-Linux64.tgz

# wps

# zoom

# fonts
mkdir ~/.local/share/fonts
mv FZFWZhuZGDLMCJW.TTF ~/.local/share/fonts
# Cascadia
# After reboot, gnome-terminal sees Cascadia fonts

# wechat
# 1. docker


