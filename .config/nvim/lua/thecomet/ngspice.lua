vim.api.nvim_create_user_command("NGSpiceRun", function()
  local file = vim.fn.expand("%:p")
  if vim.fn.empty(file) == 1 then
    vim.notify("No file to run ngspice on", vim.log.levels.ERROR)
    return
  end

  local command = { "ngspice", file }
  vim.cmd("new")
  vim.cmd("resize 15")
  vim.cmd("startinsert")
  vim.fn.jobstart(command, {
    term = true,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data, _)
      if data then
        vim.fn.setqflist({}, ' ', {
          title = "ngspice output",
          lines = data,
        })
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        vim.fn.setqflist({}, ' ', {
          title = "ngspice errors",
          lines = data,
        })
        vim.cmd("copen")
      end
    end,
    on_exit = function(_, code, _)
      if code ~= 0 then
        vim.notify("ngspice exited with code: " .. code, vim.log.levels.ERROR)
      end
    end,
  })
end, {
  desc = "Run ngspice on the current file",
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.spice,*.cir,*.net",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>cb", ":NGSpiceRun<CR>", {
      noremap = true,
      silent = true,
      desc = "Run ngspice on current file",
    })
  end,
})

vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.spice,*.cir,*.net",
  callback = function()
    vim.bo.filetype = "spice"
  end,
})
