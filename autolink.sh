#!/bin/bash
# -e  Exit immediately if a command exits with a non-zero status.
set -e

platform="$1"
if [ "$platform" != "laptop" ] && [ "$platform" != "work" ]; then
  echo "Current platform:" $platform
  echo "Please specify platform flag: laptop or work."
  exit 1
fi

function create_dir()
{
  in_dir_name=$1
  if [ -d "$in_dir_name" ]; then
    flag_dest_dir=1
  else
    flag_dest_dir=0
    mkdir -p $in_dir_name
    flag_dest_dir=1
  fi
}

function create_link()
{
  in_src_file=$1
  in_dest_file=$2
  if [ -f "$in_dest_file" ]; then
    flag_dest_file=1
    mv $in_dest_file ${in_dest_file}.backup
    ln -s $in_src_file $in_dest_file
  else
    if [ -e "$in_dest_file" ]; then
      rm $in_dest_file
    fi
    flag_dest_file=0
    ln -s $in_src_file $in_dest_file
    flag_dest_file=1
  fi
}

spd=$(dirname $(readlink -f $0))

# Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Windows: ~\vimfiles\autoload\plug.vim
create_link ${spd}/vim/vimrc $HOME/.vimrc
read -n 1 -p "Open another terminal, open Vim, execute PlugInstall and then press any key here to continue... "
# Open Vim do PlugInstall, then do the following things.
create_link ${spd}/vim/vim-snippets/markdown.snippets $HOME/.vim/plugged/vim-snippets/snippets/markdown.snippets
create_link ${spd}/vim/vim-snippets/tex.snippets $HOME/.vim/plugged/vim-snippets/snippets/tex.snippets
create_link ${spd}/vim/nerdtree/autoload/nerdtree/ui_glue.vim $HOME/.vim/plugged/nerdtree/autoload/nerdtree/ui_glue.vim
create_dir $HOME/.vim/spell
create_link ${spd}/vim/spell/en.utf-8.add $HOME/.vim/spell/en.utf-8.add
create_link ${spd}/vim/spell/en.utf-8.add.spl $HOME/.vim/spell/en.utf-8.add.spl
# Patch taglist
# Ref link: http://www.voidcn.com/article/p-mqvxddtw-brm.html
patch -p0 ${HOME}/.vim/plugged/taglist.vim/plugin/taglist.vim ${spd}/vim/taglist/taglist.diff

# bashrc
create_link ${spd}/linux/${platform}.bashrc $HOME/.bashrc
create_link ${spd}/linux/${platform}.bash_aliases $HOME/.bash_aliases
create_link ${spd}/linux/${platform}.common.profile $HOME/.common.profile
# zsh
# 1. Install zsh
# 2. Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 3. Postprocess
rm ~/.zshrc
create_link ${spd}/zsh/${platform}.zshrc $HOME/.zshrc

# ssh
# if [ "$platform" == "laptop" ]; then
#   create_link ${spd}/ssh/laptop.config $HOME/.ssh/config
# elif [ "$platform" == "work" ]; then
#   create_link ${spd}/ssh/work.config $HOME/.ssh/config
#   # sudo cp ${spd}/ssh/vpnc_gz.conf /etc/vpnc/default.conf
# fi

# gdb
create_link ${spd}/gdb/gdbinit $HOME/.gdbinit

# kde
# if [ "$platform" == "work" ]; then
#   create_link ${spd}/kde/Dracula.colorscheme $HOME/.local/share/konsole/Dracula.colorscheme
#   create_link ${spd}/kde/Default.profile $HOME/.local/share/konsole/Default.profile
# fi

# # i3
# create_dir $HOME/.config/i3
# if [ $platform == "laptop" ]; then
#   create_link $(spd)/i3/i3config.laptop $HOME/.config/i3/config
# elif [ $platform == "work" ]; then
#   create_link $(spd)/i3/i3config.work $HOME/.config/i3/config
# else
#   echo "Error: platform flag!"
# fi
# create_link $(spd)/i3/i3status.conf $HOME/.i3status.conf

# Xorg
# create_link $(spd)/xorg/xinitrc $HOME/.xinitrc
create_link ${spd}/xorg/.Xresources $HOME/.Xresources

# ranger
create_dir $HOME/.config/ranger
create_link ${spd}/ranger/rifle.conf $HOME/.config/ranger/rifle.conf
create_link ${spd}/ranger/rc.conf $HOME/.config/ranger/rc.conf
create_link ${spd}/ranger/scope.sh $HOME/.config/ranger/scope.sh

# pip
create_dir $HOME/.config/pip
create_link ${spd}/python/pip.conf $HOME/.config/pip/pip.conf

# matplotlib
create_dir $HOME/.config/matplotlib
create_dir $HOME/.config/matplotlib/stylelib
create_link ${spd}/python/matplotlib/stylelib/sjc.mplstyle $HOME/.config/matplotlib/stylelib/sjc.mplstyle

# tmux
create_link ${spd}/tmux/tmux.conf $HOME/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# git
create_link ${spd}/git/gitconfig $HOME/.gitconfig
create_link ${spd}/git/gitignore $HOME/.gitignore

# fprettify
create_link ${spd}/fprettify/fprettify.rc $HOME/.fprettify.rc


# npm
# Currently I use commitizen to lint the git commit messages.
# Download npm from https://nodejs.org/dist/v12.14.1/node-v12.14.1-linux-x64.tar.xz or higher version.
# npm install -g commitizen cz-conventional-changelog
# run `git cz` instead of `git commit` to commit messages.
create_link ${spd}/npm/npmrc $HOME/.npmrc
create_link ${spd}/npm/czrc $HOME/.czrc

# freeplane
# create_link $(spd)/freeplane/templates/sjc.mm $HOME/.config/freeplane/1.5.x/templates/sjc.mm
# create_link $(spd)/freeplane/sjc.freeplaneoptions $HOME/.config/freeplane/1.5.x/sjc.freeplaneoptions
# create_link $(spd)/freeplane/accelerators/default.properties $HOME/.config/freeplane/1.5.x/accelerators/default.properties

# +x
chmod +x ${spd}/ranger/scope.sh
# chmod +x ${spd}/pandoc/md2article
# chmod +x ${spd}/pandoc/md2article_githubdoc
# chmod +x ${spd}/pandoc/md2article_online
# chmod +x ${spd}/pandoc/md2journal
# chmod +x ${spd}/pandoc/html2pdf
# chmod +x ${spd}/pandoc/md2revealjs

# chmod +x $(spd)/linux/touchpad_disable.sh
# chmod +x $(spd)/feh/feh.sh
