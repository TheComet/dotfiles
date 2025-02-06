local function get_hostname()
    local handle = io.popen("uname -n")
    local hostname = handle:read("*a")
    handle:close()
    return hostname:gsub("%s+", "")
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
                filetypes = { "c", "cpp", "h", "hpp" },
                config = {
                    tabwidth = function()
                        return get_hostname() == "C017443" and 2 or 4
                    end,
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
