alias ll='ls -lhF'
alias l='ls -CF'
alias grep='grep --color --line-number'

# alias setshellproxy='service polipo status && export http_proxy=http://localhost:8123 && export https_proxy=https://localhost:8123 && curl cip.cc'

alias sftp2gzbatch='sftp -oBatchMode=no -b ~/sftp.batch -a cs'
# alias pappssh='papp_cloud ssh gz'
# alias pappsftp='papp_cloud sftp gz'
# alias pappsftp='/home/jcshi/softwares/papp_cloud/papp_cloud_linux64 sftp -i /home/jcshi/softwares/papp_cloud/pp233.id pp233@gz'

alias gdbnfs='gdb --args ~/NFS_project/NFS/debug/bin/nfs_dbg nfs.json'
alias gdbref='gdb --args ~/REF_project/REF/debug/bin/REF_debug proj.in'

matlabbg() {
  mfile=${1%.*}
  nohup matlab -nosplash -nodisplay -nodesktop -r "try; $mfile; catch; end; quit" > output.log &
}
