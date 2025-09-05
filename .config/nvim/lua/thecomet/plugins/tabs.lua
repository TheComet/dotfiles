local function get_hostname()
  local handle = io.popen("uname -n")
  local hostname = handle:read("*a")
  handle:close()
  return hostname:gsub("%s+", "")
end

local hostname = get_hostname()
local c_tabwidth = hostname == "C017443" and 2 or 4

if hostname == "C017443" then
  vim.opt.colorcolumn = "120"
  vim.opt.colorcolumn = "120"
end

return {
  "FotiadisM/tabset.nvim",
  opts = {
    defaults = {
      tabwidth = 4,
      expandtab = true,
    },
    languages = {
      {
        filetypes = { "c", "cpp", "h", "hpp", "cmake" },
        config = {
          tabwidth = c_tabwidth,
          expandtab = true,
        }
      },
      {
        filetypes = { "json", "nix", "lua", ".s", ".asm" },
        config = {
          tabwidth = 2,
          expandtab = true,
        }
      },
      {
        filetypes = { "make" },
        config = {
          tabwidth = 4,
          expandtab = false,
        }
      },
    },
  },
  config = function(_, opts)
    require("tabset").setup(opts)
  end,
}
