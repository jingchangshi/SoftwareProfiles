-- ~/.config/nvim/lua/plugins/telescope.lua
return {
	"nvim-telescope/telescope.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
					},
				},
				-- 这里保留少量全局兜底
				file_ignore_patterns = {
					"%.o$",
					"%.a$",
					"%.so$",
					"%.dSYM/",
				},
			},
			pickers = {
				find_files = {
					hidden = true,
					find_command = {
						"fd",
						"--type", "f",
						"--strip-cwd-prefix",
						"--hidden",
						"--follow",
						-- 不要 --no-ignore，这样 fd 才会读取 .gitignore / .ignore / .fdignore
						"--exclude", ".git",
					},
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

		local map = vim.keymap.set
		map("n", "ff", function()
			builtin.find_files()
		end, { desc = "查找文件" })

		map("n", "fg", function()
			builtin.live_grep()
		end, { desc = "全局内容查找" })

		map("n", "fb", function()
			builtin.buffers()
		end, { desc = "查找缓冲区" })

		map("n", "fh", function()
			builtin.help_tags()
		end, { desc = "查找帮助文档" })

		map("n", "fs", function()
			builtin.lsp_document_symbols()
		end, { desc = "查找文档符号" })

		map("n", "fS", function()
			builtin.lsp_workspace_symbols()
		end, { desc = "查找工作区符号" })
	end,
}
