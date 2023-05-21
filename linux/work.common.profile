SOFT=$HOME/Softwares
SFPF=$HOME/software_profile

PATH=$HOME/.local/bin:$PATH
# Infrastructures
PATH=$SOFT/zsh/bin:$PATH
PATH=$SOFT/vim/bin:$PATH
PATH=$SOFT/tmux/bin:$PATH
# Programming
PATH=$SOFT/Python/bin:$PATH
# PATH=$SOFT/git/bin:$PATH
# PATH=$SOFT/gdb/bin:$PATH
# PATH=$SOFT/cmake/bin:$PATH
PATH=$SOFT/ctags/bin:$PATH
# Utilities
PATH=$SOFT/ghostscript:$PATH
PATH=$SOFT/pandoc/bin:$PATH
# PATH=$SOFT/texlive/2019/bin/x86_64-linux:$PATH
PATH=$SOFT/node/bin:$PATH
PATH=$SOFT/BaiduPCS-Go:$PATH
PATH=$SOFT/ccrypt:$PATH
PATH=$SOFT/mupdf/bin:$PATH
PATH=$SOFT/syncthing:$PATH
PATH=$SOFT/ffmpeg:$PATH
PATH=$SOFT/julia/bin:$PATH
PATH=$HOME/bin:$PATH
# CFD
PATH=$SOFT/gmsh/bin:$PATH
# PATH=$SOFT/ParaView/bin:$PATH
# PATH=$SOFT/gnuplot/bin:$PATH

PATH=/home/data/tecplot/360ex_2017r3/bin:$PATH

export PATH

LD_LIBRARY_PATH=$SOFT/libevent/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH

PYTHONPATH=${SFPF}/python:$PYTHONPATH
export PYTHONPATH

export NODE_PATH=$NODE_PATH:`npm root -g`

# For WSL2
# Reset PATH variable to remove those appended by Mobaxterm
# export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# PATH=/opt/MATLAB/R2018b/bin:$PATH
# PATH=$SOFT/ffmpeg:$PATH
# PATH=$SOFT/hugo:$PATH
# PATH=$SFPF/ssh:$PATH
# PATH=$SFPF/jabref:$PATH
# PATH=$SFPF/shadowsocksR:$PATH
# PATH=$SOFT/BibRef/:$PATH
# PATH=$SOFT/GitAhead:$PATH


