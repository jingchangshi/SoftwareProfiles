-- ~/.config/nvim/lua/core/keymaps.lua
local map = vim.keymap.set

-- 基础编辑快捷键
map("n", "<C-s>", ":w<CR>", { desc = "保存文件" })
map("n", "<leader>q", ":q<CR>", { desc = "退出" })
map("n", "<leader>w", ":w<CR>", { desc = "保存" })
map("n", "<leader>x", ":x<CR>", { desc = "保存并退出" })

-- 更好的分屏导航
map("n", "<C-h>", "<C-w>h", { desc = "切换到左侧窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "切换到下方窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "切换到上方窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "切换到右侧窗口" })

-- 调整分屏大小
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "缩小窗口宽度" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "增大窗口宽度" })
map("n", "<C-Up>", ":resize -2<CR>", { desc = "缩小窗口高度" })
map("n", "<C-Down>", ":resize +2<CR>", { desc = "增大窗口高度" })

-- Tab 页切换与移动
map("n", "<F5>", ":tabprev<CR>", { desc = "切换到上一个标签页" })
map("n", "<F6>", ":tabnext<CR>", { desc = "切换到下一个标签页" })
map("n", "<F7>", ":tabmove -1<CR>", { desc = "当前标签页向左移动" })
map("n", "<F8>", ":tabmove +1<CR>", { desc = "当前标签页向右移动" })

-- 复制文件路径相关信息到系统剪贴板

-- 当前 buffer 文件名
map("n", "<leader>fn", function()
  local name = vim.fn.expand("%:t")
  vim.fn.setreg("+", name)
  print("Copied filename: " .. name)
end, { desc = "复制文件名" })

-- 当前 buffer 相对路径
map("n", "<leader>fr", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  print("Copied relative path: " .. path)
end, { desc = "复制相对路径" })

-- 当前 buffer 绝对路径
map("n", "<leader>fa", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("Copied absolute path: " .. path)
end, { desc = "复制绝对路径" })
