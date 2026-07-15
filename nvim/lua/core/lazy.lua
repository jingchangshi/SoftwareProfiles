-- ~/.config/nvim/lua/core/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to install lazy.nvim:\n" .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

if not uv.fs_stat(lazypath .. "/lua/lazy/init.lua") then
  error("lazy.nvim installation is incomplete: " .. lazypath)
end

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = {
    colorscheme = { "habamax" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  rocks = {
    enabled = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
