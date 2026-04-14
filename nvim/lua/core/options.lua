-- ~/.config/nvim/lua/core/options.lua
local opt = vim.opt

-- 行号与相对行号
opt.number = true
opt.relativenumber = false

-- 标签与缩进 (符合 LLVM/MLIR 规范)
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true -- 使用空格代替 Tab
opt.autoindent = true
opt.smartindent = true
opt.colorcolumn = "80,120"
opt.wrap = true
opt.linebreak = true
opt.breakindent = true

-- 性能与体验优化
opt.updatetime = 50    -- 加快响应速度
opt.timeoutlen = 1000
opt.signcolumn = "yes" -- 始终显示符号列，防止界面抖动
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 搜索与替换
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- 其他
opt.termguicolors = true      -- 启用真彩色
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- 使用系统剪贴板
opt.swapfile = false
opt.undofile = true
opt.backup = false
opt.wrap = false
opt.cmdheight = 1
opt.showmode = false
opt.cursorline = true

vim.filetype.add({
  extension = {
    td = "tablegen",
  },
})
