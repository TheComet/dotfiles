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

        -- Fix issue where pressing tab somewhere else after aborting completion teleports your
        -- cursor back to where the last completion took place
        ls.config.set_config({
            region_check_events = 'InsertEnter',
            delete_check_events = 'InsertLeave'
        })

        local s = ls.snippet
        local t = ls.text_node
        local i = ls.insert_node
        local extras = require("luasnip.extras")
        ls.add_snippets("lua", {
            s("hello", {
                t('print("Hello '),
                i(1),
                t(' world")')
            }),
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
