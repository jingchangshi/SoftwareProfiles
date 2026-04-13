-- ~/.config/nvim/lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  -- tag = "0.1.6",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod

    -- 自定义快捷键
    local trouble_actions = transform_mod({
      open_trouble = function(prompt_bufnr)
        actions.close(prompt_bufnr)
        require("trouble").open("telescope")
      end,
    })

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            -- ["<C-t>"] = trouble_actions.open_trouble,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
        file_ignore_patterns = {
          "build/",
          ".git/",
          "__pycache__/",
          "node_modules/",
          "lld",
          "pstl",
          "%.o",
          "%.a",
          "%.so",
          "%.dSYM/"
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })
    telescope.load_extension("fzf")

    -- 快捷键映射
    local map = vim.keymap.set
    map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
    map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "全局内容查找" })
    map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "查找缓冲区" })
    map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "查找帮助文档" })
    map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "查找文档符号" })
    map("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "查找工作区符号" })
  end,
}