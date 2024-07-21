return {
    "debugloop/telescope-undo.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    opts = {
        extensions = {
            undo = {
                use_delta = true,
                use_custom_command = nil, -- setting this implies `use_delta = false`. Accepted format is: { "bash", "-c", "echo '$DIFF' | delta" }
                side_by_side = false,
                vim_diff_opts = {
                  ctxlen = vim.o.scrolloff,
                },
                entry_format = "state #$ID, $STAT, $TIME",
                time_format = "",
                saved_only = false,
            },
        },
    },
    config = function(_, opts)
        telescope = require("telescope")
        telescope.setup(opts)
        telescope.load_extension("undo")
        vim.keymap.set("n", "<leader>pu", "<CMD>Telescope undo<CR>")
    end
}
