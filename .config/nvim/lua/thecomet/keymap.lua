vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move highlighted lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

-- Justify text
vim.keymap.set("v", "gj", ":JustifyText<CR>")
vim.keymap.set("n", "gjip", "vipgj", { remap = true })
vim.keymap.set("v", "<leader>lf", ":!~/documents/programming/cpp/commentfmt/commentfmt<CR>")
vim.keymap.set("n", "<leader>lf", ":%!~/documents/programming/cpp/commentfmt/commentfmt<CR>")

-- If text is highlighted in visual mode, and "/" is pressed, paste the highlighted text into the prompt
vim.keymap.set("v", "//", "y/<C-R>=escape(@\", '/')<CR>")
vim.keymap.set("v", "/s", "y:%s/<C-R>=escape(@\", '/')<CR>")

-- Paste without losing yanked text in register
vim.keymap.set("x", "<leader>p", "\"_dP")
-- Copy to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- Hotkeys for going through quickfix list
vim.keymap.set("n", "<A-q>", "<CMD>cp<CR>")
vim.keymap.set("n", "<C-q>", "<CMD>cn<CR>")
-- Hotkeys for going through location list
vim.keymap.set("n", "<C-s>", "<CMD>lne<CR>")
vim.keymap.set("n", "<A-s>", "<CMD>lp<CR>")

-- Select last changed text
vim.keymap.set("n", "gp", "`[v`]")

-- Toggle relative/absolute line numbers
vim.keymap.set("n", "<leader>l", "<CMD>set relativenumber!<CR>")

-- Default to :make. cmake.nvim will override this if it detects a CMakeLists.txt
vim.keymap.set("n", "<leader>cc", function()
  require("thecomet.makefile").clean()
end)
vim.keymap.set("n", "<leader>cb", function()
  require("thecomet.makefile").build()
end)
