local function makefile_path()
  local makefile = vim.loop.cwd() .. "/Makefile"
  if vim.fn.filereadable(makefile) == 0 then return end
  return makefile
end

local function makefile_exists()
  local makefile = vim.loop.cwd() .. "/Makefile"
  return vim.fn.filereadable(makefile) == 1
end

local function all_targets()
  local makefile = makefile_path()
  if not makefile then return end
  local lines = vim.fn.readfile(makefile)
  for _, line in ipairs(lines) do
    line = line:gsub("#.*$", "") -- strip comments
    local targets = line:match("^all%s*:%s*(.+)$")
    if targets then
      local result = {}
      for t in targets:gmatch("%S+") do
        table.insert(result, t)
      end
      return result
    end
  end
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

return {
  exists = makefile_exists,
  all_targets = all_targets,
  collect_variables = collect_variables,
  expand_vars = expand_vars,
}
