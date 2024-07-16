local function get_hostname()
    local handle = io.popen("uname -n")
    local hostname = handle:read("*a")
    handle:close()
    return hostname:gsub("%s+", "")
end

local hostname = get_hostname()

-- Why
vim.opt.guicursor = ""
vim.opt.mouse = ""

-- Line numbers and relative numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Sane settings for tabs
vim.opt.tabstop = hostname == "work" and 2 or 4
vim.opt.softtabstop = hostname == "work" and 2 or 4
vim.opt.shiftwidth = hostname == "work" and 2 or 4
vim.opt.expandtab = true
vim.opt.smartindent = true

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
vim.opt.colorcolumn = hostname == "work" and "120" or "80"

vim.g.mapleader = " "

