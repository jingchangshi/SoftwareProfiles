return {
  "NeogitOrg/neogit",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "sindrets/diffview.nvim",
  },
  opts = {
    disable_hint = false,
    disable_context_highlighting = false,
    disable_signs = false,
    disable_insert_on_commit = "auto",
    filewatcher = {
      interval = 1000,
      enabled = true,
    },
    graph_style = "ascii",
    remember_settings = true,
    use_per_project_settings = true,
    highlight = {
      italic = true,
      bold = true,
      underline = true,
    },
    use_default_keymaps = true,
    auto_refresh = true,
    kind = "tab",
    commit_popup = {
      kind = "split",
    },
    preview_buffer = {
      kind = "split",
    },
    popup = {
      kind = "split",
    },
    sort_branches = "-committerdate",
  },
  config = function(_, opts)
    local neogit = require("neogit")
    neogit.setup(opts)

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc })
    end

    map("n", "<leader>gg", neogit.open, "打开 Neogit")
    map("n", "<leader>gc", function()
      neogit.open({ "commit" })
    end, "打开 Commit 窗口")
    map("n", "<leader>gp", function()
      neogit.open({ "pull" })
    end, "打开 Pull 窗口")
    map("n", "<leader>gP", function()
      neogit.open({ "push" })
    end, "打开 Push 窗口")
    map("n", "<leader>gb", function()
      neogit.open({ "branch" })
    end, "打开 Branch 窗口")

    -- 配置 vimdiff 作为 merge tool
    vim.cmd([[
      if executable("vim")
        let g:neogit_use_git_mergetool = 1
        let g:git_mergetool = "vimdiff"
      endif
    ]])
  end,
}

