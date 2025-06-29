return {
    "nvimdev/lspsaga.nvim",
    opts = {
        finder = {
            keys = {
                vsplit = "v",
                split = "s",
                quit = "q",
                close = "<ESC>",
            }
        },
        rename = {
            in_select = false,
            keys = {
                quit = "<ESC>",
                exec = "<CR>",
            }
        },
        definition = {
            keys = {
                edit = "o",
                vsplit = "v",
                split = "s",
                quit = "q",
                close = "<ESC>"
            }
        },
        callhierarchy = {
            keys = {
                edit = "o",
                vsplit = "v",
                split = "s",
                quit = "q",
                close = "<ESC>"
            }
        }
    },
    dependencies = {
        "nvim-treesitter/nvim-treesitter", -- optional
        "nvim-tree/nvim-web-devicons",     -- optional
        "VonHeikemen/lsp-zero.nvim",
    },
    config = function(_, opts)
        require("lspsaga").setup(opts)
        vim.keymap.set("n", "<leader>t", "<CMD>Lspsaga term_toggle<CR>")
    end,
}
