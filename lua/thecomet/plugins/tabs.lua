local function get_hostname()
    local handle = io.popen("uname -n")
    local hostname = handle:read("*a")
    handle:close()
    return hostname:gsub("%s+", "")
end

local c_tabwidth = get_hostname() == "C017443" and 2 or 4

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
                filetypes = { "json", "nix", "lua" },
                config = {
                    tabwidth = 2,
                    expandtab = true,
                }
            },
        },
    },
    config = function(_, opts)
        require("tabset").setup(opts)
    end,
}
