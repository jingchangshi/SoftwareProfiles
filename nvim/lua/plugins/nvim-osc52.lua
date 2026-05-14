-- nvim/lua/plugins/osc52.lua
return {
  "ojroques/nvim-osc52",
  event = { "BufReadPre", "BufNewFile" },

  opts = {
    max_length = 0, -- 0 = 不限制长度，适合大段文本
    silent = false,
    trim = false,
  },

  config = function(_, opts)
    local osc52 = require("osc52")
    osc52.setup(opts)

    -- 不走系统 clipboard provider，避免 tmux provider 导致乱码/卡死
    vim.opt.clipboard = ""

    vim.api.nvim_create_autocmd("TextYankPost", {
      desc = "Yank 后通过 OSC52 复制到本地系统剪贴板",
      callback = function()
        if vim.v.event.operator == "y" and vim.v.event.regname == "" then
          osc52.copy_register('"')
        end
      end,
    })

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc })
    end

    map("n", "<leader>y", function()
      osc52.copy_register('"')
    end, "OSC52 复制默认寄存器")

    map("v", "<leader>y", function()
      vim.cmd('normal! "zy')
      osc52.copy_register("z")
    end, "OSC52 复制选中内容")
  end,
}
