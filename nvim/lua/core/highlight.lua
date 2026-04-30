-- lua/core/highlight.lua
-- 多字段固定高亮：支持 5 个字段、不同颜色、光标处删除、全部清除

local highlight_groups = {
  "MyHighlight1",
  "MyHighlight2",
  "MyHighlight3",
  "MyHighlight4",
  "MyHighlight5",
}

local highlight_colors = {
  MyHighlight1 = { bg = "#5f875f", fg = "#ffffff" },
  MyHighlight2 = { bg = "#875f5f", fg = "#ffffff" },
  MyHighlight3 = { bg = "#5f5f87", fg = "#ffffff" },
  MyHighlight4 = { bg = "#87875f", fg = "#000000" },
  MyHighlight5 = { bg = "#5f8787", fg = "#ffffff" },
}

for group, color in pairs(highlight_colors) do
  vim.api.nvim_set_hl(0, group, color)
end

local match_stack = {}

local function current_word()
  return vim.fn.expand("<cword>")
end

-- 快速清空搜索高亮
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "清除搜索高亮" })

-- 添加光标所在字段高亮
vim.keymap.set("n", "<leader>m", function()
  local word = current_word()
  if word == "" then
    print("当前光标下没有字段")
    return
  end

  for _, item in ipairs(match_stack) do
    if item.word == word then
      print("已经高亮: " .. word)
      return
    end
  end

  if #match_stack >= #highlight_groups then
    print("最多同时高亮 5 个字段")
    return
  end

  local group = highlight_groups[#match_stack + 1]
  local pattern = "\\V" .. vim.fn.escape(word, "\\/")

  local id = vim.fn.matchadd(group, pattern)

  table.insert(match_stack, {
    id = id,
    word = word,
    group = group,
  })

  print("Highlight " .. #match_stack .. ": " .. word)
end, { desc = "添加当前字段固定高亮" })

-- 删除光标所在字段高亮
vim.keymap.set("n", "<leader>md", function()
  local word = current_word()
  if word == "" then
    print("当前光标下没有字段")
    return
  end

  for i = #match_stack, 1, -1 do
    local item = match_stack[i]
    if item.word == word then
      pcall(vim.fn.matchdelete, item.id)
      table.remove(match_stack, i)
      print("Removed highlight: " .. word)
      return
    end
  end

  print("当前字段没有固定高亮: " .. word)
end, { desc = "删除光标所在字段高亮" })

-- 清除所有固定高亮
vim.keymap.set("n", "<leader>M", function()
  for _, item in ipairs(match_stack) do
    pcall(vim.fn.matchdelete, item.id)
  end

  match_stack = {}
  print("Cleared all highlights")
end, { desc = "清除所有固定高亮" })
