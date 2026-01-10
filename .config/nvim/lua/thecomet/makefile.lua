local function makefile_path()
  local makefile = vim.loop.cwd() .. "/Makefile"
  if vim.fn.filereadable(makefile) == 0 then return end
  return makefile
end

local function get_executable_name()
  local makefile = makefile_path()
  if not makefile then return end
  local lines = vim.fn.readfile(makefile)
  for _, line in ipairs(lines) do
    line = line:gsub("#.*$", "") -- strip comments
    local value = line:match("^all%s*:%s*(%S+).*$")
    if value then
      return value
    end
  end
end

local function expand_variables(variables)
  for name, str in pairs(variables) do
    local expanded = str
    local changed
    repeat
      changed = false
      expanded = expanded:gsub("%$%(([%w_]+)%)", function(v)
        if variables[v] then
          changed = true
          return variables[v]
        else
          return "$(" .. v .. ")"  -- leave unresolved as-is
        end
      end)
    until not changed
    variables[name] = expanded
  end
  return variables
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

  local lines = vim.fn.readfile(makefile)
  local variables = {}
  for _, line in ipairs(lines) do
    line = line:gsub("#.*$", "") -- strip comments
    -- match VAR = value or VAR := value
    local var, values = line:match("^%s*([%w_]+)%s*[:]?=%s*(.+)$")
    if var and values then
      variables[var] = values
    end
  end

  variables = expand_variables(variables)
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
  get_executable_name = get_executable_name,
  collect_variables = collect_variables,
}
