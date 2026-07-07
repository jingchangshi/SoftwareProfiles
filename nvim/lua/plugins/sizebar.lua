return {
  "sidebar-nvim/sidebar.nvim",
  lazy = false,
  config = function()
    require("sidebar-nvim").setup({
      side = "left",
      initial_width = 35,
      sections = {
        "buffers",
      },
      section_separator = "",
      section_title_separator = { "" },
      disable_default_keybindings = false,
    })
  end,
}
