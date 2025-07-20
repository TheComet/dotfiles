-- Why
vim.opt.guicursor = ""
vim.opt.mouse = ""

-- Line numbers and relative numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Sane settings for tabs
--vim.opt.tabstop = hostname == "C017443" and 2 or 4
--vim.opt.softtabstop = hostname == "C017443" and 2 or 4
--vim.opt.shiftwidth = hostname == "C017443" and 2 or 4
--vim.opt.expandtab = true
--vim.opt.smartindent = true

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
vim.opt.colorcolumn = hostname == "C017443" and "120" or "80"

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

vim.fn.sign_define("DebugBreakpoint", {
  text = "⦿",
  priority = 50,
})

local function load_gdbinit()
  local cmake = require("cmake-tools")
  local executable = cmake.get_launch_target_path()
  local working_dir = vim.fs.dirname(executable)
  local gdb_init = working_dir .. "/.gdbinit"

  -- Load gdbinit file and split newlines
  local gdb_commands = {}
  if vim.fn.filereadable(gdb_init) == 1 then
    local file = io.open(gdb_init, "r")
    if file then
      for line in file:lines() do
        table.insert(gdb_commands, line)
      end
      file:close()
    end
  end

  return gdb_commands
end

local function gdbinit_filename()
  local cmake = require("cmake-tools")
  local executable = cmake.get_launch_target_path()
  local working_dir = vim.fs.dirname(executable)
  return working_dir .. "/.gdbinit"
end

local function save_gdbinit(gdb_commands)
  local gdb_init = gdbinit_filename()
  local file = io.open(gdb_init, "w")
  if file then
    for _, command in ipairs(gdb_commands) do
      file:write(command .. "\n")
    end
    file:close()
  end
end

local function find_suite_name()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  for i = row, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    local suite = line:match("#define%s+NAME%s+(%S+)")
    if suite then
      return suite
    end
  end
  return nil
end

local function find_test_name()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  for i = row, 1, -1 do
    -- TEST, TEST_F, TEST_P
    local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    local test = line:match("TEST%s*%(%s*NAME%s*,%s*(%S+)%s*%)") or line:match("TEST_F%s*%(%s*NAME%s*,%s*(%S+)%s*%)")
    if test then
      return test
    end
  end
  return nil
end

local function run_command_in_gdb(args)
  local cmake = require("cmake-tools")
  local executable = cmake.get_launch_target_path()
  local working_dir = vim.fs.dirname(executable)
  args = args and args or cmake.get_launch_args()
  local command = string.format("tmux split-window -c %s -h 'gdb --args %s %s'",
    working_dir,
    executable,
    args and table.concat(args, " ") or "")
  vim.fn.system(command)
  vim.cmd("wincmd h")
end

local function get_program_special_args()
  local cmake = require("cmake-tools")
  local executable_name = cmake.get_launch_target()
  if executable_name == "clither" then
    return { "--tests" }
  end
  return nil
end

vim.keymap.set("n", "<leader>dr", function()
  local cmake = require("cmake-tools")
  local args = cmake.get_launch_args()
  run_command_in_gdb(args)
end)

vim.keymap.set("n", "<leader>dt", function()
  local suite = find_suite_name()
  local test = find_test_name()
  if not suite or not test then
    error("No tests found")
    return
  end

  local args = get_program_special_args() or {}
  table.insert(args, "--gtest_filter=" .. suite .. "." .. test)

  run_command_in_gdb(args)
end)

vim.keymap.set("n", "<leader>ds", function()
  local suite = find_suite_name()
  if not suite then
    error("No tests found")
    return
  end

  local args = get_program_special_args() or {}
  table.insert(args, '--gtest_filter="' .. suite .. '.*"')

  run_command_in_gdb(args)
end)

vim.keymap.set("n", "<leader>dc", function()
  vim.cmd("split " .. gdbinit_filename())
end)

vim.keymap.set("n", "<leader>db", function()
  local gdb_commands = load_gdbinit()
  local current_file = vim.fn.expand("%:p")
  local current_line = vim.fn.line(".")

  -- Create "break" command and append it to .gdbinit
  local break_command = string.format("break %s:%d", current_file, current_line)
  local found = false
  for i, command in ipairs(gdb_commands) do
    if command:match(break_command) then
      table.remove(gdb_commands, i)
      vim.fn.sign_unplace(current_file, { buffer = vim.fn.bufnr("%"), id = current_line })
      found = true
      break
    end
  end
  if not found then
    vim.fn.sign_place(current_line, current_file, "DebugBreakpoint", vim.fn.bufnr("%"), { lnum = current_line })
    table.insert(gdb_commands, break_command)
  end

  save_gdbinit(gdb_commands)
end)

vim.api.nvim_create_autocmd("BufRead", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.cxx", "*.cc" },
  callback = function()
    local gdb_commands = load_gdbinit()
    local current_file = vim.fn.expand("%:p")
    for _, command in ipairs(gdb_commands) do
      local filename, line_number = command:match("^break (.+):(%d+)")
      if filename and line_number and filename == current_file then
        vim.fn.sign_place(line_number, current_file, "DebugBreakpoint", vim.fn.bufnr("%"),
          { lnum = tonumber(line_number) })
      end
    end
  end,
})
