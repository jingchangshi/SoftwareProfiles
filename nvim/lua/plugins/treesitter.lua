-- ~/.config/nvim/lua/plugins/

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",                -- 安装后更新解析器
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    -- 新 API：直接调用 require("nvim-treesitter").setup()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c", "cpp", "lua", "vim", "vimdoc", "query",
        -- MLIR 和 TableGen 可能尚未官方支持，可先不加，不影响主要功能
        -- "mlir", "tablegen"
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    })
  end,
}