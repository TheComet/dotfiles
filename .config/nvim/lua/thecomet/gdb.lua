local last_run_args = {}

vim.fn.sign_define("DebugBreakpoint", {
  text = "⦿",
  priority = 50,
})

local function gdbinit_filepath()
  local cmake = require("cmake-tools")
  local executable = cmake.get_launch_target_path()
  if not executable then
    return nil
  end
  local working_dir = vim.fs.dirname(executable)
  return working_dir .. "/.gdbinit"
end

local function load_gdbinit()
  local gdb_init = gdbinit_filepath()
  if not gdb_init then
    return {}
  end

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

local function save_gdbinit(gdb_commands)
  local gdb_init = gdbinit_filepath()
  if not gdb_init then
    return
  end
  local file = io.open(gdb_init, "w")
  if file then
    for _, command in ipairs(gdb_commands) do
      file:write(command .. "\n")
    end
    file:close()
  end
end

local function find_testing_framework()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  for i = row, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    if line:match("#include \"CppUTest/TestHarness%.h") then
      return "CppUTest"
    end
    if line:match("#include [\"<]gmock") then
      return "gtest"
    end
    if line:match("#include [\"<]gtest") then
      return "gtest"
    end
  end
  return nil
end

local function find_suite_define()
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

local function find_test_and_suite_names()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local pattern = "TEST_?[FP]?%(([%w_]+),%s*([%w_]+)%)"
  for i = row, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    local suite, test = line:match(pattern)
    if suite == "NAME" then
      suite = find_suite_define()
    end
    if suite and test then
      return suite, test
    end
  end
  return nil
end

local function run_command_in_gdb(args)
  last_run_args = args
  local cmake = require("cmake-tools")
  local executable = cmake.get_launch_target_path()
  if not executable then
    error("No executable found. Please configure the project first (using cmake-tools).")
    return
  end
  local working_dir = vim.fs.dirname(executable)
  local command = string.format("tmux split-window -c %s -h 'gdb --args %s %s'",
    working_dir,
    executable,
    args and table.concat(args, " ") or "")

  local sock = "/tmp/gdb-nvim.sock"
  if not vim.tbl_contains(vim.fn.serverlist(), sock) then
    vim.fn.serverstart(sock)
  end

  vim.fn.system(command)
  vim.cmd("wincmd h")
end

local function get_program_special_args()
  local cmake = require("cmake-tools")
  local executable_name = cmake.get_launch_target()
  if executable_name == "clither" then
    return { "--tests" }
  end
  return vim.deepcopy(cmake.get_launch_args())
end

local function get_breakpoint_sign_on_line(bufnr, current_file, current_line)
  local placed = vim.fn.sign_getplaced(bufnr, {
    group = current_file,
    lnum = current_line
  })
  for _, sign in ipairs(placed) do
    for _, s in ipairs(sign.signs) do
      if s.name == "DebugBreakpoint" then
        return s
      end
    end
  end
  return nil
end

local function toggle_breakpoint()
  local bufnr = vim.fn.bufnr("%")
  local current_file = vim.fn.expand("%:p")
  local current_line = vim.fn.line(".")
  local sign = get_breakpoint_sign_on_line(bufnr, current_file, current_line)
  if sign then
    vim.fn.sign_unplace(current_file, {
      buffer = bufnr,
      id = sign.id
    })
  else
    vim.fn.sign_place(current_line, current_file, "DebugBreakpoint", bufnr, {
      lnum = current_line
    })
  end
end

local function update_gdbinit_with_breakpoints()
  local current_file = vim.fn.expand("%:p")
  local gdb_commands = load_gdbinit()
  local new_gdb_commands = {}
  for _, command in ipairs(gdb_commands) do
    local filename = command:match("break (.+):(%d+)")
    if filename ~= current_file then
      table.insert(new_gdb_commands, command)
    end
  end
  local placed = vim.fn.sign_getplaced(vim.fn.bufnr("%"), {
    group = current_file,
  })
  for _, sign in ipairs(placed) do
    for _, s in ipairs(sign.signs) do
      if s.name == "DebugBreakpoint" then
        local command = "break " .. current_file .. ":" .. s.lnum
        table.insert(new_gdb_commands, command)
      end
    end
  end

  save_gdbinit(new_gdb_commands)
end

vim.keymap.set("n", "<leader>dc", function()
  local gdbinit = gdbinit_filepath()
  if gdbinit then
    vim.cmd("split " .. gdbinit)
  end
end)

vim.keymap.set("n", "<leader>db", function()
  toggle_breakpoint()
  update_gdbinit_with_breakpoints()
end)

vim.keymap.set("n", "<leader>dr", function()
  local cmake = require("cmake-tools")
  local args = cmake.get_launch_args()
  run_command_in_gdb(args)
end)

vim.keymap.set("n", "<leader>da", function()
  vim.ui.input({ prompt = "Args: ", default = table.concat(last_run_args, " ")}, function(args)
    if args ~= nil then
      run_command_in_gdb(vim.split(args, " +"))
    end
  end)
end)

vim.keymap.set("n", "<leader>dt", function()
  local suite, test = find_test_and_suite_names()
  if not suite or not test then
    error("No tests found")
    return
  end
  local framework = find_testing_framework()
  if not framework then
    error("Could not identify test framework")
  end

  local args = get_program_special_args() or {}
  if framework == "gtest" then
    table.insert(args, '--gtest_filter="*' .. suite .. "." .. test .. '*"')
  end
  if framework == "CppUTest" then
    table.insert(args, "-sg")
    table.insert(args, suite)
    table.insert(args, "-sn")
    table.insert(args, test)
  end

  run_command_in_gdb(args)
end)

vim.keymap.set("n", "<leader>ds", function()
  local suite, test = find_test_and_suite_names()
  if not suite then
    error("No tests found")
    return
  end
  local framework = find_testing_framework()
  if not framework then
    error("Could not identify test framework")
  end

  local args = get_program_special_args() or {}
  if framework == "gtest" then
    table.insert(args, '--gtest_filter="*' .. suite .. '.*"')
  end
  if framework == "CppUTest" then
    table.insert(args, "-sg")
    table.insert(args, suite)
  end

  run_command_in_gdb(args)
end)

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.cxx", "*.cc" },
  callback = function()
    update_gdbinit_with_breakpoints()
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
   pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.cxx", "*.cc" },
   callback = function()
    local gdb_commands = load_gdbinit()
    local current_file = vim.fn.expand("%:p")
    vim.fn.sign_unplace(current_file, { buffer = vim.fn.bufnr("%") })
    for _, command in ipairs(gdb_commands) do
      local filename, line_number = command:match("^break (.+):(%d+)")
      if filename and line_number and filename == current_file then
        vim.fn.sign_place(line_number, current_file, "DebugBreakpoint", vim.fn.bufnr("%"),
          { lnum = tonumber(line_number) })
      end
    end
   end,
 })
