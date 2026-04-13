-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {},
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("fidget").setup({})

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "clangd",
          "lua_ls",
        },
        automatic_installation = false,
      })

      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      local capabilities = cmp_nvim_lsp.default_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )

      local on_attach = function(client, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
        map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
        map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
        map("n", "gr", vim.lsp.buf.references, "Goto References")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n", "<leader>e", vim.diagnostic.open_float, "Line Diagnostics")
        map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
        map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

        if client:supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr, async = false })
            end,
          })
        end
      end

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
      })

      local function find_mlir_lsp_server()
        local root_dir = vim.fs.root(0, { ".git", "compile_commands.json" })
        if root_dir then
          local candidates = {
            root_dir .. "/build/bin/mlir-lsp-server",
            root_dir .. "/build-debug/bin/mlir-lsp-server",
            root_dir .. "/build-release/bin/mlir-lsp-server",
            root_dir .. "/llvm/build/bin/mlir-lsp-server",
          }
          for _, path in ipairs(candidates) do
            if vim.uv.fs_stat(path) then
              return path
            end
          end
        end
        return "mlir-lsp-server"
      end

      -- clangd: 用于 LLVM/MLIR C++ 源码开发
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          ".clangd",
          ".git",
        },
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- MLIR/PDLL/TableGen
      vim.lsp.config("mlir", {
        cmd = { find_mlir_lsp_server() },
        filetypes = { "mlir", "pdll", "tablegen" },
        root_markers = { ".git", "compile_commands.json" },
        single_file_support = true,
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Lua 自己的 nvim 配置也顺手补上
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      vim.lsp.enable("clangd")
      vim.lsp.enable("mlir")
      vim.lsp.enable("lua_ls")

      -- 如果没有 filetype 检测，手动补
      vim.filetype.add({
        extension = {
          mlir = "mlir",
          pdll = "pdll",
          td = "tablegen",
        },
      })
    end,
  },
}