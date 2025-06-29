return {
    "github/copilot.vim",
    config = function(_, opts)
        -- Global enable/disable toggle of copilot
        vim.api.nvim_create_user_command("CopilotToggle", function()
            vim.g.copilot_enabled = not vim.g.copilot_enabled
            if vim.g.copilot_enabled then
                vim.cmd("Copilot disable")
                print("Copilot OFF")
            else
                vim.cmd("Copilot enable")
                print("Copilot ON")
            end
        end,
        {nargs = 0})

        -- Request completion from copilot, even if it is disabled
        vim.keymap.set("i", "<C-\\>", '<Plug>(copilot-suggest)')

        -- Cycle to next and previous suggestions
        vim.keymap.set("i", "<C-M-N>", '<Plug>(copilot-next)')
        vim.keymap.set("i", "<C-M-P>", '<Plug>(copilot-previous)')
        
        -- Override default behavior of autocompleting with TAB
        vim.keymap.set("i", "<C-M-Y>", 'copilot#Accept("")', {expr = true, replace_keycodes = false})
        vim.g.copilot_no_tab_map = true

        -- Accept next line of suggestion
        vim.keymap.set("i", "<C-M-L>", '<Plug>(copilot-accept-line)')

        -- Accept next word of suggestion
        vim.keymap.set("i", "<C-M-W>", '<Plug>(copilot-accept-word)')
    end,
    cond = function ()
        local handle = io.popen("uname -n")
        local hostname = handle:read("*a")
        handle:close()
        hostname = hostname:gsub("%s+", "")
        return hostname == "C017443" or hostname == "ripper"
    end
}
