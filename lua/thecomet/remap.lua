vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ">m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ">m '>-2<CR>gv=gv")

vim.keymap.set("n", "<leader>aj", ":.!justifier -w 79<CR>")
vim.keymap.set("v", "<leader>aj", ":!justifier -w 79<CR>")

-- If text is highlighted in visual mode, and "/" is pressed, paste the highlighted text into the prompt
vim.keymap.set("v", "//", "y/<C-R>=escape(@\", '/')<CR>")
vim.keymap.set("v", "/s", "y:%s/<C-R>=escape(@\", '/')<CR>")

-- Hotkeys for going through quickfix list
vim.keymap.set("n", "<A-q>", "<CMD>cp<CR>")
vim.keymap.set("n", "<C-q>", "<CMD>cn<CR>")
-- Hotkeys for going through location list
vim.keymap.set("n", "<C-s>", "<CMD>lne<CR>")
vim.keymap.set("n", "<A-s>", "<CMD>lp<CR>")

-- Select last changed text
vim.keymap.set("n", "gp", "`[v`]")

-- Open terminal in split
vim.keymap.set("n", "<leader>t", "<CMD>rightb vert term<CR>")

-- Toggle relative/absolute line numbers
vim.keymap.set("n", "<leader>l", "<CMD>set relativenumber!<CR>")

