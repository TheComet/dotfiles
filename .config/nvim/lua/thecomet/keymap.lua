vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move highlighted lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

-- Justify text
justifier_script = vim.fn.stdpath("config") .. "/lua/thecomet/justifier.py"
vim.keymap.set("n", "<leader>j", ":.!python3 " .. justifier_script .. " -w 79<CR>")
vim.keymap.set("v", "<leader>j", ":'<,'>!python3 " .. justifier_script .. " -w 79<CR>")

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
local function default_build()
    vim.cmd("wa")
    vim.cmd("copen")
    vim.cmd("silent make")
    local qflist = vim.fn.getqflist()
    local has_errors = false
    for _, item in ipairs(qflist) do
        if item.valid and item.bufnr ~= 0 then
            has_errors = true
            break
        end
    end
    if not has_errors then
        vim.cmd('cclose')
        print("Compilation succeeded!")
    end
end
vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("silent make clean")
end)
vim.keymap.set("n", "<leader>cr", function()
  local make = require("thecomet.makefile")
  local exe = make.get_executable_name()
  if not exe then return end
  default_build()
  vim.system({"./" .. exe}, {cwd = vim.loop.cwd()})
end)
vim.keymap.set("n", "<leader>cb", default_build, { noremap = true, silent = true })
