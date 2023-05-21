SOFT=$HOME/Softwares
SFPF=$HOME/software_profile
#
PATH=$HOME/.local/bin:$PATH
# Infrastructures
PATH=$SOFT/tmux/bin:$PATH
# Programming
PATH=$SOFT/gdb/bin:$PATH
# Utilities
# CFD
#
export PATH

#
# PYTHONPATH=${SFPF}/python:$PYTHONPATH
# export PYTHONPATH

export LD_LIBRARY_PATH=$SOFT/gdb/lib:$LD_LIBRARY_PATH
export LD_RUN_PATH=$SOFT/gdb/lib:$LD_RUN_PATH
