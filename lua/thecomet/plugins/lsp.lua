return {
    "VonHeikemen/lsp-zero.nvim", branch = "v3.x",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local lsp_zero = require("lsp-zero")
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")

        lsp_zero.on_attach(function(client, bufnr)
            local opts = { buffer = bufnr, remap = false }
            -- see :help lsp-zero-keybindings to learn the available actions
            -- NOTE: Not required, we've mapped everything below already
            --lsp_zero.default_keymaps({buffer = bufnr})
            
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
            vim.keymap.set("n", "<M-o>", "<CMD>ClangdSwitchSourceHeader<CR>")
            vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set("n", "<leader>wl", function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set({ "n", "v" }, "<leader>f", function()
                vim.lsp.buf.format { async = true }
            end, opts)
        end)
        
        mason.setup({})
        mason_lspconfig.setup({
            ensure_installed = { "clangd" },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({})
                end,
                clangd = function()
                    local lsp = require("lspconfig")
                    local util = require("lspconfig.util")
                    lsp.clangd.setup({
                        cmd = {
                            "clangd",
                            "--header-insertion=never",
                        },
                        filetypes = { "c", "cpp" },
                        root_dir = function(fname)
                            local root_files = {
                                ".clangd",
                                ".clang-tidy",
                                ".clang-format",
                                "compile_commands.json",
                                "compile_flags.txt",
                            }
                            print(util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname))
                            return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
                        end,
                        on_new_config = function(new_config, new_cwd)
                            require("cmake-tools").clangd_on_new_config(new_config)
                        end,
                    })
                end
            }
        })

        -- this is the function that loads the extra snippets to luasnip
        -- from rafamadriz/friendly-snippets
        require('luasnip.loaders.from_vscode').lazy_load()

        -- Fix issue where pressing tab somewhere else after aborting completion teleports your
        -- cursor back to where the last completion took place
        local luasnip = require("luasnip")
        luasnip.config.set_config({
            region_check_events = 'InsertEnter',
            delete_check_events = 'InsertLeave'
        })

        local cmp = require("cmp")
        local cmp_action = lsp_zero.cmp_action()
        cmp.setup({
            formatting = lsp_zero.cmp_format({ details = false }),
            sources = {
                { name = "nvim_lsp" },
                { name = "nvim_lua" },
                { name = "luasnip", keyword_length = 2 },
                { name = "buffer", keyword_length = 3 },
            },
            mapping = cmp.mapping.preset.insert({
                -- Confirm completion, and select first by default
                ["<C-y>"] = cmp.mapping.confirm({ select = true }),

                -- Trigger completion menu
                ["<C-Space>"] = cmp.mapping.complete(),

                -- Navigate to previous/next item in completion menu
                ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

                -- Navigate between snippet placeholders
                ["<tab>"] = cmp_action.luasnip_jump_forward(),
                ["<S-tab>"] = cmp_action.luasnip_jump_backward(),

                -- SCroll up and down in the completion documentation
                ["<Up>"] = cmp.mapping.scroll_docs(-4),
                ["<Down>"] = cmp.mapping.scroll_docs(4),
            })
        })
    end
}
