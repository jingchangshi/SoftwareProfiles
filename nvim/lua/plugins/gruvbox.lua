-- ~/.config/nvim/lua/plugins/gruvbox.lua
return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- 确保主题在其他插件之前加载
    config = function()
        -- 在这里进行可选的自定义配置
        require("gruvbox").setup({
            terminal_colors = true, -- 让内置终端也使用 gruvbox 颜色
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
                strings = true,
                comments = true,
                operators = false,
            },
            strikethrough = true,
            invert_selection = false,
            invert_signs = false,
            invert_tabline = false,
            invert_intend_guides = false,
            inverse = true, -- 反转搜索等元素的背景色
            contrast = "", -- 可设置为 "hard", "soft" 或留空
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = false,
        })
        -- 设置主题和背景色
        vim.o.background = "dark" -- 或 "light"
        vim.cmd.colorscheme("gruvbox")
    end,
}