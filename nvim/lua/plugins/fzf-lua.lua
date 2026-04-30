return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "VeryLazy",

  config = function()
    local fzf = require("fzf-lua")

    local global_excludes = {
      ".git",
      "node_modules",
      "build",
      "dist",
      "target",
      ".cache",
      ".venv",
      "venv",
      "__pycache__",
      "*.pyc",
      "*.o",
      "*.so",
      "*.a",
      "*.dylib",
      "*.dll",
      "*.exe",
      "*.class",
      "*.jar",
      "*.log",
      "*.tmp",
      "*.swp",
      ".DS_Store",
    }

    local function fd_opts()
      local args = {
        "--type f",
        "--hidden",
        "--follow",
        "--color=never",
      }

      for _, item in ipairs(global_excludes) do
        table.insert(args, "--exclude")
        table.insert(args, item)
      end

      return table.concat(args, " ")
    end

    local function rg_opts()
      local args = {
        "--column",
        "--line-number",
        "--no-heading",
        "--color=always",
        "--smart-case",
        "--hidden",
        "--follow",
      }

      for _, item in ipairs(global_excludes) do
        table.insert(args, "--glob")
        table.insert(args, "!" .. item)
        table.insert(args, "--glob")
        table.insert(args, "!**/" .. item .. "/**")
      end

      return table.concat(args, " ")
    end

    fzf.setup({
      winopts = {
        height = 0.85,
        width = 0.85,
        preview = {
          layout = "flex",
        },
      },

      files = {
        prompt = "Files❯ ",
        fd_opts = fd_opts(),
      },

      grep = {
        prompt = "Rg❯ ",
        rg_opts = rg_opts(),
      },
    })

    local map = vim.keymap.set

    map("n", "<leader>ff", function()
      fzf.files()
    end, { desc = "查找文件(fzf-lua/fd)" })

    map("n", "<leader>fg", function()
      fzf.live_grep()
    end, { desc = "全文搜索(fzf-lua/rg)" })

    map("n", "<leader>fb", function()
      fzf.buffers()
    end, { desc = "查找 buffer" })

    map("n", "<S-l>", "<cmd>bnext<CR>")
    map("n", "<S-h>", "<cmd>bprevious<CR>")

    map("n", "<leader>fh", function()
      fzf.helptags()
    end, { desc = "查找帮助" })

    map("n", "<leader>fr", function()
      fzf.resume()
    end, { desc = "恢复上次搜索" })
  end,
}
