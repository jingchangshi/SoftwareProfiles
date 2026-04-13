-- ~/.config/nvim/lua/plugins/comment.lua
return {
  "numToStr/Comment.nvim",
  config = function()
    local comment = require("Comment")

    comment.setup({
      -- 可选：自定义配置
      padding = true,        -- 注释符号后是否添加空格
      sticky = true,         -- 注释时是否保持光标位置
      ignore = nil,          -- 忽略某些文件类型
      toggler = {
        line = "<leader>\\", -- 行注释快捷键
        block = "gbc",       -- 块注释快捷键
      },
      opleader = {
        line = "gc",  -- 行注释操作符
        block = "gb", -- 块注释操作符
      },
      mappings = {
        basic = true,
        extra = true,
      },
    })

    vim.keymap.set("x", "<leader>\\", function()
      require("Comment.api").toggle.linewise(vim.fn.visualmode())
    end, { desc = "Toggle comment selection" })
  end,
}