-- Why
vim.o.guicursor = ""
vim.o.mouse = ""

-- Files
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true
vim.o.termguicolors = true

-- Line numbers and relative numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = true
vim.o.formatoptions = "cqjn"
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "80"

-- Search
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- Misc
vim.opt.isfname:append("@-@")
vim.o.updatetime = 50
vim.o.lazyredraw = true

vim.g.mapleader = " "

-- FLEX
vim.o.errorformat = vim.o.errorformat .. ',%*["]%f%*["]\\, line %l: %m'
vim.o.errorformat = vim.o.errorformat .. ',%f:%l.%c-%*\\d: %t%*[^:]: %m'
-- BISON
vim.o.errorformat = vim.o.errorformat .. ',%f:%l.%c-%*[0-9]: %m'
vim.o.errorformat = vim.o.errorformat .. ',%f:%l.%c: %m'
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
