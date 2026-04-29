#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
NVIM_SRC="$SCRIPT_DIR/nvim"
NVIM_DEST="$HOME/.config/nvim"

mkdir -p "$HOME/.config"

if [ -d "$NVIM_DEST" ] || [ -L "$NVIM_DEST" ]; then
    read -p "目标目录 $NVIM_DEST 已存在，是否删除并替换？(y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$NVIM_DEST"
    else
        echo "操作已取消"
        exit 0
    fi
fi

ln -s "$NVIM_SRC" "$NVIM_DEST"
echo "已成功创建符号链接: $NVIM_DEST -> $NVIM_SRC"
echo "nvim 配置已完成设置"