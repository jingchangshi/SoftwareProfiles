-- ~/.config/nvim/lua/plugins/comment.lua
return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    padding = true,
    sticky = true,
    ignore = nil,
    mappings = {
      basic = true, -- 保留 gcc / gbc / gc / gb
      extra = true,
    },
  },
  keys = {
    -- 普通模式：<leader>\ -> gcc
    {
      "<leader>\\",
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      mode = "n",
      desc = "Toggle comment line",
    },
    -- 可视模式：<leader>\ -> 注释选中行
    {
      "<leader>\\",
      function()
        local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
        vim.api.nvim_feedkeys(esc, "nx", false)
        require("Comment.api").toggle.linewise(vim.fn.visualmode())
      end,
      mode = "x",
      desc = "Toggle comment selection",
    },
  },
}