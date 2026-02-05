--vim.lsp.set_log_level(vim.log.levels.DEBUG)
vim.lsp.set_log_level(vim.log.levels.OFF)

local function find_project_root(patterns)
  local path = vim.fn.expand('%:p:h')
  local root = vim.fs.find(patterns, { path = path, upward = true })[1]
  if not root or root == vim.env.HOME then
    return path
  end
  return vim.fn.fnamemodify(root, ':h')
end

local function determine_cmake_compile_commands_dir()
  local status, cmake = pcall(require, "cmake-tools")
  if not status then return nil end
  local dir = tostring(cmake.get_build_directory())
  if vim.fn.filereadable(dir .. "/compile_commands.json") == 0 then return nil end
  return dir
end

local function write_compile_commands_from_makefile(build_dir)
   local result = vim.system(
    { "make", "-BnrR" },
    { text = true }
  ):wait()
  if result.code ~= 0 then
    vim.notify("make -n failed", vim.log.levels.ERROR)
    return
  end

  local lines = vim.split(result.stdout, "\n", { trimempty = true })

  -- 1. Reconstruct wrapped commands
  local commands = {}
  local current = nil

  for _, line in ipairs(lines) do
    if line:match("^%s") then
      -- continuation line
      if current then
        current = current .. " " .. vim.trim(line)
      end
    else
      if current then
        table.insert(commands, current)
      end
      current = line
    end
  end

  if current then
    table.insert(commands, current)
  end

  local compile_commands = {}
  local cwd = vim.loop.cwd()

  -- 2. Extract compiler commands
  for _, cmd in ipairs(commands) do
    -- must contain -c and -o something.o
    if (cmd:match("%s%-c%s") or cmd:match("%s%-c$")) and cmd:match("%s%-o%s+[^%s]+%.o") then
      -- extract source file (argument to -c)
      local src = cmd:match("%s(%S+%.c[cpx]*)%s")
      local output = cmd:match("%s%-o%s(%S+.c[cpx]*%S+)")
      if src and output then
        table.insert(compile_commands, {
          directory = cwd,
          command = cmd,
          file = src,
          output = output,
        })
      end
    end
  end

  if #compile_commands == 0 then
    vim.notify("No compiler commands found", vim.log.levels.WARN)
    return
  end

  -- 3. Write compile_commands.json
  vim.fn.mkdir(build_dir, "p")
  local out = build_dir .. "/compile_commands.json"

  local json = vim.json.encode(compile_commands, { indent="  " })
  vim.fn.writefile(vim.split(json, "\n"), out)
end

local function create_clangd_cmd()
  local cmd = {
    "clangd",
    "--clang-tidy",
    "--background-index",
    "--header-insertion=never",
  }

  local compile_commands_dir = determine_cmake_compile_commands_dir()
  if compile_commands_dir then
    table.insert(cmd, "--compile-commands-dir=" .. compile_commands_dir)
    return cmd
  end

  if makefile.exists() then
    local all = makefile.all_targets()
    local vars = makefile.collect_variables()
    local target = makefile.expand_vars(all[1], vars)
    local build_dir = vim.fs.dirname(target)
    local compile_commands = build_dir .. "/compile_commands.json"
    write_compile_commands_from_makefile(build_dir)
    table.insert(cmd, "--compile-commands-dir=" .. build_dir)
    return cmd
  end

  return cmd
end

local function clangd_switch_header_source(client, bufnr)
  local params = { uri = vim.uri_from_bufnr(0) }
  client:request(
    "textDocument/switchSourceHeader",
    params,
    function(err, result)
      if err then
        vim.notify("clangd: " .. err.message, vim.log.levels.ERROR)
        return
      end
      if not result then
        vim.notify("No corresponding file found", vim.log.levels.WARN)
        return
      end
      vim.cmd("edit " .. vim.uri_to_fname(result))
    end,
    bufnr
  )
end

vim.lsp.config.luals = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = find_project_root({
    ".luarc.json",
    ".luarc.jsonc",
    "lazy-lock.json",
  }),
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

vim.lsp.config.clangd = {
  cmd = create_clangd_cmd(),
  filetypes = { "c", "cpp", "cc" },
  root_dir = find_project_root({
    "compile_commands.json",
    ".clangd",
    "configure.ac",
    "CMakeLists.txt",
    "Makefile",
  }),
}

vim.lsp.config("*", {
  root_markers = { ".git" },
})

vim.lsp.enable({
  "clangd",
  "luals",
})

vim.api.nvim_create_user_command("ClangdStop", function(opts)
  for _, client in pairs(vim.lsp.get_clients()) do
    if client.name == "clangd" then
      client:stop()
    end
  end
end, { })

vim.api.nvim_create_user_command("ClangdRestart", function(opts)
  for _, client in pairs(vim.lsp.get_clients()) do
    if client.name == "clangd" then
      client:stop()
    end
  end
  -- The compile-commands-dir parameter may have changed
  vim.lsp.config("clangd", { cmd = create_clangd_cmd() })
  vim.lsp.start(vim.lsp.config.clangd)
end, { })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)    
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    --vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "K", "<CMD>Lspsaga hover_doc ++keep<CR>", opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    --vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gD", "<CMD>Lspsaga peek_definition<CR>")
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gR", "<CMD>Lspsaga finder<CR>")
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gC", "<CMD>Lspsaga incoming_calls<CR>")
    vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "gO", "<CMD>Lspsaga peek_type_declaration<CR>")
    vim.keymap.set("n", "<M-o>", function() clangd_switch_header_source(client, bufnr) end)
    --vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>r", "<CMD>Lspsaga rename<CR>", { silent = true, noremap = true })
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set({ "n", "v" }, "<leader>f", vim.lsp.buf.format, opts) --function()
  end
})

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = false,
  signs = true,
  underline = true,
  update_in_insert = false,
})

local cycle_diagnostics = 1
vim.keymap.set("n", "<Leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>dv", function()
  if cycle_diagnostics == 0 then
    vim.diagnostic.config({ virtual_lines = true, virtual_text = false })
    cycle_diagnostics = 1
  elseif cycle_diagnostics == 1 then
    vim.diagnostic.config({ virtual_lines = false, virtual_text = false })
    cycle_diagnostics = 2
  else
    vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
    cycle_diagnostics = 0
  end
end, { desc = "Toggle diagnostics virtual text" })


