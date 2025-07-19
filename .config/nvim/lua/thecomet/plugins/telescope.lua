local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, "  ")
      local args = { "rg" }
      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end

      return vim.iter({
        args,
        { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case", }
      }):flatten():totable()
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers.new(opts, {
    debounce = 100,
    prompt_title = "Live Multigrep",
    finder = finder,
    previewer = conf.grep_previewer(opts),
    sorter = require("telescope.sorters").empty(),
  }):find()
end

return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = {
    "nvim-lua/plenary.nvim"
  },
  opts = {
    defaults = {
      file_ignore_patterns = {
        "^ShadowOrbot/",
        "^[Tt]hird[Pp]arty/",
      }
    },
  },
  config = function(_, opts)
    require("telescope").setup(opts)
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', "<leader>pf", builtin.find_files, {})
    vim.keymap.set('n', "<leader>pg", builtin.git_files, {})
    --vim.keymap.set('n', "<leader>ps", builtin.live_grep, {})
    vim.keymap.set('n', "<leader>ps", live_multigrep, {})
    vim.keymap.set('n', "gs", builtin.lsp_document_symbols, {})
    vim.keymap.set('n', "gc", builtin.lsp_incoming_calls, {})
  end
}
