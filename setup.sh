#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ALL_COMPONENTS=(nvim tmux git)
SELECTED_COMPONENTS=()
ONLY_COMPONENTS=""
SKIP_COMPONENTS=""
DRY_RUN=false
ASSUME_YES=false
BACKUP_DIR=""

CREATED=0
UNCHANGED=0
BACKED_UP=0
SKIPPED=0
WARNINGS=0

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Install the nvim, tmux, and Git configurations from this repository.

Options:
  --only LIST        install only comma-separated components
  --skip LIST        skip comma-separated components
  --backup-dir DIR   move conflicting files into DIR
  --dry-run          print the planned changes without writing files
  -y, --yes          back up conflicts and install tmux plugins without asking
  -h, --help         show this help

Components: nvim, tmux, git
EOF
}

die() {
  echo "错误: $*" >&2
  exit 1
}

warn() {
  echo "警告: $*" >&2
  WARNINGS=$((WARNINGS + 1))
}

confirm() {
  local prompt=$1
  local reply=""

  if $ASSUME_YES; then
    return 0
  fi
  if [ ! -t 0 ]; then
    return 1
  fi

  read -r -p "$prompt (y/N) " reply || true
  [[ $reply =~ ^[Yy]$ ]]
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --only)
        [ "$#" -ge 2 ] || die "--only 需要一个参数"
        ONLY_COMPONENTS=$2
        shift 2
        ;;
      --skip)
        [ "$#" -ge 2 ] || die "--skip 需要一个参数"
        SKIP_COMPONENTS=$2
        shift 2
        ;;
      --backup-dir)
        [ "$#" -ge 2 ] || die "--backup-dir 需要一个参数"
        BACKUP_DIR=$2
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      -y | --yes)
        ASSUME_YES=true
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      --)
        shift
        [ "$#" -eq 0 ] || die "不支持位置参数: $*"
        ;;
      -* ) die "未知选项: $1" ;;
      *) die "不支持位置参数: $1" ;;
    esac
  done
}

is_known_component() {
  local candidate=$1
  local component

  for component in "${ALL_COMPONENTS[@]}"; do
    [ "$candidate" = "$component" ] && return 0
  done
  return 1
}

list_contains() {
  local list=$1
  local candidate=$2
  local item
  local items=()

  [ -n "$list" ] || return 1
  IFS=',' read -r -a items <<<"$list"
  for item in "${items[@]}"; do
    [ "$item" = "$candidate" ] && return 0
  done
  return 1
}

validate_component_list() {
  local option=$1
  local list=$2
  local item
  local items=()

  [ -n "$list" ] || return 0
  IFS=',' read -r -a items <<<"$list"
  for item in "${items[@]}"; do
    [ -n "$item" ] || die "$option 包含空的组件名"
    is_known_component "$item" || die "$option 包含未知组件: $item"
  done
}

select_components() {
  local component

  validate_component_list "--only" "$ONLY_COMPONENTS"
  validate_component_list "--skip" "$SKIP_COMPONENTS"

  for component in "${ALL_COMPONENTS[@]}"; do
    if [ -n "$ONLY_COMPONENTS" ] && ! list_contains "$ONLY_COMPONENTS" "$component"; then
      continue
    fi
    if list_contains "$SKIP_COMPONENTS" "$component"; then
      continue
    fi
    SELECTED_COMPONENTS+=("$component")
  done

  [ "${#SELECTED_COMPONENTS[@]}" -gt 0 ] || die "没有需要安装的组件"
}

component_selected() {
  local candidate=$1
  local component

  for component in "${SELECTED_COMPONENTS[@]}"; do
    [ "$candidate" = "$component" ] && return 0
  done
  return 1
}

require_source() {
  local path=$1
  [ -e "$path" ] || [ -L "$path" ] || die "安装源不存在: $path"
}

check_command() {
  local command_name=$1
  local component=$2
  command -v "$command_name" >/dev/null 2>&1 || warn "$component 配置可以安装，但未找到命令: $command_name"
}

preflight() {
  if component_selected nvim; then
    require_source "$SCRIPT_DIR/nvim"
    check_command nvim nvim
    check_command git nvim
  fi

  if component_selected tmux; then
    require_source "$SCRIPT_DIR/tmux/tmux.conf"
    require_source "$SCRIPT_DIR/tmux/update_display.sh"
    check_command tmux tmux
    check_command tar tmux
    if [ -f "$SCRIPT_DIR/tmux/tmux_plugins.tar.gz" ] \
      && ! tar -tzf "$SCRIPT_DIR/tmux/tmux_plugins.tar.gz" >/dev/null; then
      die "tmux 插件包无法读取"
    fi
  fi

  if component_selected git; then
    require_source "$SCRIPT_DIR/git/gitconfig"
    require_source "$SCRIPT_DIR/git/gitignore"
    check_command git git
  fi
}

default_backup_dir() {
  printf '%s/software-profiles/backups/%s-%s' \
    "${XDG_STATE_HOME:-$HOME/.local/state}" "$(date +%Y%m%d-%H%M%S)" "$$"
}

backup_item() {
  local dest=$1
  local relative_dest
  local backup_dest

  if [ -z "$BACKUP_DIR" ]; then
    BACKUP_DIR=$(default_backup_dir)
  fi

  case "$dest" in
    "$HOME"/*) relative_dest=${dest#"$HOME"/} ;;
    *) relative_dest=$(basename "$dest") ;;
  esac
  backup_dest="$BACKUP_DIR/$relative_dest"

  if $DRY_RUN; then
    echo "计划备份: $dest -> $backup_dest"
  else
    mkdir -p "$(dirname "$backup_dest")"
    [ ! -e "$backup_dest" ] && [ ! -L "$backup_dest" ] \
      || die "备份目标已存在: $backup_dest"
    mv -- "$dest" "$backup_dest"
    echo "已备份: $dest -> $backup_dest"
  fi
  BACKED_UP=$((BACKED_UP + 1))
}

link_item() {
  local src=$1
  local dest=$2

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "未变化: $dest -> $src"
    UNCHANGED=$((UNCHANGED + 1))
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if ! confirm "目标 $dest 已存在，是否备份并替换？"; then
      echo "已跳过: $dest"
      SKIPPED=$((SKIPPED + 1))
      return
    fi
    backup_item "$dest"
  fi

  if $DRY_RUN; then
    echo "计划创建: $dest -> $src"
  else
    mkdir -p "$(dirname "$dest")"
    ln -s -- "$src" "$dest"
    echo "已创建: $dest -> $src"
  fi
  CREATED=$((CREATED + 1))
}

install_nvim() {
  link_item "$SCRIPT_DIR/nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
}

install_tmux_plugins() {
  local archive="$SCRIPT_DIR/tmux/tmux_plugins.tar.gz"
  local plugin_dir="$HOME/.tmux/plugins"
  local temp_dir

  if [ -e "$plugin_dir" ] || [ -L "$plugin_dir" ]; then
    echo "未变化: $plugin_dir"
    UNCHANGED=$((UNCHANGED + 1))
    return
  fi
  if [ ! -f "$archive" ]; then
    warn "未找到 tmux 插件包: $archive"
    return
  fi
  if ! confirm "是否安装仓库内附带的 tmux 插件？"; then
    echo "已跳过: $plugin_dir"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  if $DRY_RUN; then
    echo "计划解压: $archive -> $plugin_dir"
    CREATED=$((CREATED + 1))
    return
  fi

  mkdir -p "$HOME/.tmux"
  temp_dir=$(mktemp -d "$HOME/.tmux/.plugins.tmp.XXXXXX")
  if ! tar -xzf "$archive" -C "$temp_dir"; then
    rm -rf -- "$temp_dir"
    die "tmux 插件包解压失败"
  fi
  if [ ! -x "$temp_dir/tmux_plugins/tpm/tpm" ]; then
    rm -rf -- "$temp_dir"
    die "tmux 插件包结构无效"
  fi
  mv -- "$temp_dir/tmux_plugins" "$plugin_dir"
  rmdir "$temp_dir"
  echo "已安装: $plugin_dir"
  CREATED=$((CREATED + 1))
}

install_tmux() {
  link_item "$SCRIPT_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
  link_item "$SCRIPT_DIR/tmux/update_display.sh" "$HOME/.tmux/update_display.sh"
  install_tmux_plugins
}

install_git() {
  link_item "$SCRIPT_DIR/git/gitconfig" "$HOME/.gitconfig"
  link_item "$SCRIPT_DIR/git/gitignore" "$HOME/.gitignore"

  if command -v git >/dev/null 2>&1 \
    && { [ -z "$(git config --global --get user.name 2>/dev/null || true)" ] \
      || [ -z "$(git config --global --get user.email 2>/dev/null || true)" ]; }; then
    warn "Git 用户身份未完整配置，请写入 ~/.gitconfig.local"
  fi
}

print_summary() {
  echo
  if $DRY_RUN; then
    echo "演练完成，未写入任何文件。"
  else
    echo "配置完成。"
  fi
  echo "组件: ${SELECTED_COMPONENTS[*]}"
  echo "创建/计划: $CREATED，未变化: $UNCHANGED，已备份/计划: $BACKED_UP，跳过: $SKIPPED，警告: $WARNINGS"
  if [ "$BACKED_UP" -gt 0 ]; then
    echo "备份目录: $BACKUP_DIR"
  fi
}

main() {
  local component

  parse_args "$@"
  select_components
  preflight

  for component in "${SELECTED_COMPONENTS[@]}"; do
    case "$component" in
      nvim) install_nvim ;;
      tmux) install_tmux ;;
      git) install_git ;;
    esac
  done

  print_summary
}

main "$@"
