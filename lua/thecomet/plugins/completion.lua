return {
    "L3MON4D3/LuaSnip",
    dependencies = {
        "VonHeikemen/lsp-zero.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "saadparwaiz1/cmp_luasnip",
        -- vscode snippet collection. See #1
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local cmp = require("cmp")
        local lsp_zero = require("lsp-zero")
        local ls = require("luasnip")

        -- #1 This is the function that loads the extra snippets to luasnip
        -- from rafamadriz/friendly-snippets
        require('luasnip.loaders.from_vscode').lazy_load()

        require("luasnip.loaders.from_lua").load({
            paths = vim.fn.getcwd() .. "/.nvim/luasnippets",
            fs_event_providers = {
                autocmd = true,
                libuv = true
            }
        })

        ls.config.set_config({
            -- Remember to keep around the last snippet. You can jump back into
            -- it even if you move outside of the selection
            history = true,

            -- Update as you type (in dynamic snippets)
            updateevents = "TextChanged,TextChangedI",

            -- Fix issue where pressing tab somewhere else after aborting
            -- completion teleports your cursor back to where the last
            -- completion took place
            region_check_events = 'InsertEnter',
            delete_check_events = 'InsertLeave'
        })

        local cmp_action = lsp_zero.cmp_action()
        cmp.setup({
            formatting = lsp_zero.cmp_format({ details = false }),
            snippet = {
                expand = function(args)
                    ls.lsp_expand(args.body)
                end,
            },
            sources = {
                { name = "nvim_lsp" },
                --{ name = "nvim_lua" },
                { name = "luasnip", keyword_length = 2 },
                { name = "buffer",  keyword_length = 3 },
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

                -- Scroll up and down in the completion documentation
                ["<Up>"] = cmp.mapping.scroll_docs(-4),
                ["<Down>"] = cmp.mapping.scroll_docs(4),
            })
        })
    end
}
