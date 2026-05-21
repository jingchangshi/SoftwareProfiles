return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "VeryLazy",

  config = function()
    local fzf = require("fzf-lua")
    local map = vim.keymap.set

    ----------------------------------------------------------------
    -- 默认 exclude
    ----------------------------------------------------------------
    local global_excludes = {
      ".git",
      "node_modules",
      "third-party",
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

    ----------------------------------------------------------------
    -- fd 配置
    ----------------------------------------------------------------
    local function fd_opts(skip_excludes)
      skip_excludes = skip_excludes or {}

      local args = {
        "--type",
        "f",
        "--hidden",
        "--follow",
        "--color=never",
      }

      for _, item in ipairs(global_excludes) do
        if not vim.tbl_contains(skip_excludes, item) then
          table.insert(args, "--exclude")
          table.insert(args, item)
        end
      end

      return table.concat(args, " ")
    end

    ----------------------------------------------------------------
    -- rg 配置
    ----------------------------------------------------------------
    local function rg_opts(skip_excludes)
      skip_excludes = skip_excludes or {}

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
        if not vim.tbl_contains(skip_excludes, item) then
          table.insert(args, "--glob")
          table.insert(args, "!" .. item)

          table.insert(args, "--glob")
          table.insert(args, "!**/" .. item .. "/**")
        end
      end

      return table.concat(args, " ")
    end

    local function fd_cmd(extra_excludes)
      extra_excludes = extra_excludes or {}

      local args = {
        "fd",
        "--type f",
        "--hidden",
        "--follow",
        "--color=never",
      }

      for _, item in ipairs(global_excludes) do
        table.insert(args, "--exclude")
        table.insert(args, vim.fn.shellescape(item))
      end

      for _, item in ipairs(extra_excludes) do
        table.insert(args, "--exclude")
        table.insert(args, vim.fn.shellescape(item))
      end

      return table.concat(args, " ")
    end

    ----------------------------------------------------------------
    -- setup
    ----------------------------------------------------------------
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
        cmd = "fd " .. fd_opts(),
        debug = 1,
      },

      grep = {
        prompt = "Rg❯ ",
        rg_opts = rg_opts(),
      },
    })

    ----------------------------------------------------------------
    -- 文件搜索
    ----------------------------------------------------------------
    map("n", "<leader>ff", function()
      fzf.fzf_exec(fd_cmd(), {
        prompt = "Files❯ ",
        previewer = "builtin",
      })
    end, { desc = "查找文件(fzf-lua/fd)" })
    ----------------------------------------------------------------
    -- 临时 exclude 文件搜索
    ----------------------------------------------------------------
    --- TODO
    ----------------------------------------------------------------
    -- 默认全文搜索
    ----------------------------------------------------------------
    map("n", "<leader>fg", function()
      fzf.live_grep()
    end, { desc = "全文搜索(fzf-lua/rg)" })

    ----------------------------------------------------------------
    -- 临时 include 默认 exclude 的目录
    --
    -- 例如:
    -- third-party
    -- node_modules
    -- third-party node_modules
    ----------------------------------------------------------------
    map("n", "<leader>fG", function()
      local input = vim.fn.input("Force include dirs: ")

      local includes = {}

      for dir in input:gmatch("[^,%s]+") do
        table.insert(includes, dir)
      end

      fzf.live_grep({
        prompt = "Rg include❯ ",
        rg_opts = rg_opts(includes),
      })
    end, { desc = "全文搜索并临时 include exclude 目录" })

    ----------------------------------------------------------------
    -- buffers
    ----------------------------------------------------------------
    map("n", "<leader>fb", function()
      fzf.buffers()
    end, { desc = "查找 buffer" })

    ----------------------------------------------------------------
    -- tabs/buffers
    ----------------------------------------------------------------
    map("n", "<S-l>", "<cmd>bnext<CR>")
    map("n", "<S-h>", "<cmd>bprevious<CR>")

    ----------------------------------------------------------------
    -- help
    ----------------------------------------------------------------
    map("n", "<leader>fh", function()
      fzf.helptags()
    end, { desc = "查找帮助" })

    ----------------------------------------------------------------
    -- resume
    ----------------------------------------------------------------
    map("n", "<leader>fr", function()
      fzf.resume()
    end, { desc = "恢复上次搜索" })
  end,
}
