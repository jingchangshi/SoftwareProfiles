-- ~/.config/nvim/lua/plugins/trouble.lua
return {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
                -- 你的配置（可选）
        },
        config = function(_, opts)
                require("trouble").setup(opts)
                -- 可选：添加快捷键
                vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "诊断列表" })
                vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "当前文件诊断" })
                vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle<CR>", { desc = "符号列表" })
                vim.keymap.set("n", "<leader>cl", "<cmd>Trouble lsp toggle<CR>", { desc = "LSP 引用/定义" })
                vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<CR>", { desc = "Location 列表" })
                vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", { desc = "QuickFix 列表" })
        end,
}