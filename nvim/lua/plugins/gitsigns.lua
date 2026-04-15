return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = false,
    current_line_blame_opts = {
      delay = 300,
    },
    signs = {
      add = { text = "┃" },
      change = { text = "┃" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- hunk 导航
      map("n", "]h", function()
        gs.nav_hunk("next")
      end, "下一个 git hunk")

      map("n", "[h", function()
        gs.nav_hunk("prev")
      end, "上一个 git hunk")

      -- hunk 操作
      map("n", "<leader>hs", gs.stage_hunk, "stage 当前 hunk")
      map("n", "<leader>hr", gs.reset_hunk, "reset 当前 hunk")
      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "stage 选中 hunk")
      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "reset 选中 hunk")

      map("n", "<leader>hS", gs.stage_buffer, "stage 当前 buffer")
      map("n", "<leader>hR", gs.reset_buffer, "reset 当前 buffer")

      -- 预览 / blame / diff
      map("n", "<leader>hp", gs.preview_hunk, "预览 hunk")
      map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, "查看当前行 blame")
      map("n", "<leader>hd", gs.diffthis, "diff 当前文件")
      map("n", "<leader>hD", function()
        gs.diffthis("~")
      end, "diff 到上一个版本")

      -- toggle
      map("n", "<leader>tb", gs.toggle_current_line_blame, "切换当前行 blame")
      map("n", "<leader>tw", gs.toggle_word_diff, "切换 word diff")

      -- text object
      map({ "o", "x" }, "ih", gs.select_hunk, "选择 git hunk")
    end,
  },
}

