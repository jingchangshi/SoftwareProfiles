-- ~/.config/nvim/lua/plugins/comment.lua
return {
  "numToStr/Comment.nvim",
  lazy = false,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "c", "cpp" },
      callback = function()
        vim.bo.commentstring = "// %s"
      end,
    })

    require("Comment").setup({
      padding = true,
      sticky = true,
      mappings = {
        basic = true,
        extra = false,
      },
      pre_hook = function(_)
        local cs = vim.bo.commentstring
        if cs == nil or cs == "" then
          local ft = vim.bo.filetype
          if ft == "c" or ft == "cpp" then
            return "// %s"
          end
        end
        return cs
      end,
    })
  end,
}