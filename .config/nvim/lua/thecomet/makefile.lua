local function makefile_path()
  local makefile = vim.loop.cwd() .. "/Makefile"
  if vim.fn.filereadable(makefile) == 0 then return end
  return makefile
end

local function makefile_exists()
  local makefile = vim.loop.cwd() .. "/Makefile"
  return vim.fn.filereadable(makefile) == 1
end

local function canonicalize_include_paths(variables)
  for name, str in pairs(variables) do
    variables[name] = str:gsub("%-I%s*([^%s]+)", function(path)
      return "-I" .. vim.fn.fnamemodify(path, ":p")
    end)
  end
  return variables
end

local function collect_variables()
  local makefile = makefile_path()
  if not makefile then return end

  local result = vim.system(
    { "make", "-f", makefile, "-f", "-", "print_all_vars" },
    { stdin = [[
print_all_vars:
	$(foreach v, $(.VARIABLES), $(if $(filter file,$(origin $(v))), $(info $(v)=$($(v)))))]], text = true,
    }
  ):wait()

  local lines = vim.split(result.stdout, "\n")

  local variables = {}
  for _, line in ipairs(lines) do
    line = line:gsub("#.*$", "") -- strip comments
    -- match VAR=value
    local var, values = line:match("^([%w_]+)=(.+)$")
    if var and values then
      variables[var] = values
    end
  end

  variables = canonicalize_include_paths(variables)

  for name, str in pairs(variables) do
    values = {}
    for value in str:gmatch("%S+") do
      table.insert(values, value)
    end
    variables[name] = values
  end

  return variables
end

local function expand_vars(str, vars)
  return (str:gsub("%$%(([%w_]+)%)", function(name)
    local val = vars[name]
    -- unknown variable
    if not val then return nil end

    if type(val) == "table" then
      return table.concat(val, " ")
    end

    return tostring(val)
  end))
end

local function targets()
  local makefile = makefile_path()
  if not makefile then return end
  local lines = vim.fn.readfile(makefile)
  local vars = collect_variables()

  local phony_targets = { "all", "tests", "tests-y", "game", "doc", "doc-y" }
  local patterns = {}
  for _, target in ipairs(phony_targets) do
    target = string.gsub(target, "%-", "%%-")
    table.insert(patterns, "^" .. target .. "%s*:%s*(.+)$")
  end

  local function is_phony_target(target)
    for _, t in ipairs(phony_targets) do
      if t == target then return true end
    end
    return false
  end

  local result = {}
  for _, line in ipairs(lines) do
    line = line:gsub("#.*$", "") -- strip comments
    for _, pattern in ipairs(patterns) do
      local targets = line:match(pattern)
      if targets then
        for t in targets:gmatch("%S+") do
          t = expand_vars(t, vars)
          if is_phony_target(t) == false then
            table.insert(result, t)
          end
        end
      end
    end
  end
  return result
end

local function output_to_qflist(err, data)
  for _, line in ipairs(data) do
    if line ~= "" then
      vim.fn.setqflist({}, 'a', { lines = { line } })
    end
  end
  vim.cmd.cbottom()
end

local function build()
  vim.cmd("wa")
  local curwin = vim.api.nvim_get_current_win()
  vim.cmd("copen")
  vim.api.nvim_set_current_win(curwin)
  vim.notify("Running make…", vim.log.levels.INFO)
  vim.fn.setqflist({}, 'r')
  vim.fn.jobstart(vim.o.makeprg, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = output_to_qflist,
    on_stderr = output_to_qflist,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify("Make successful!", vim.log.levels.INFO)
          vim.cmd("cclose")
        else
          vim.notify("Make failed (exit code " .. code .. ")",
            vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

local function clean()
  vim.cmd("silent make clean")
end

return {
  exists = makefile_exists,
  targets = targets,
  build = build,
  clean = clean,
}
