-- Why
vim.opt.guicursor = ""
vim.opt.mouse = ""

-- Line numbers and relative numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Don't wrap text, don't insert newlines when I don't want them
vim.opt.wrap = true
vim.opt.formatoptions = "cqj"

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.cursorline = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

vim.g.mapleader = " "

-- FLEX
vim.o.errorformat = vim.o.errorformat .. ',%*["]%f%*["]\\, line %l: %m'
vim.o.errorformat = vim.o.errorformat .. ',%f:%l.%c-%*\\d: %t%*[^:]: %m'
-- BISON
vim.o.errorformat = vim.o.errorformat .. ',%f:%l.%c-%*[0-9]: %m'
vim.o.errorformat = vim.o.errorformat .. ',%f:%l.%c: %m'
--vim.o.errorformat = vim.o.errorformat .. ',%f: %m'
-- CMake
vim.o.errorformat = vim.o.errorformat .. ',CMake Error at %f:%l%.%#'
-- GTest
vim.o.errorformat = vim.o.errorformat .. ',%f:%l: Failure'

-- Treat .h as c files instead of cpp files
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.h",
  callback = function()
    vim.bo.filetype = "c"
  end,
})

-- GLSL filetypes
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.[fv]sh",
  callback = function()
    vim.bo.filetype = "glsl"
  end,
})
