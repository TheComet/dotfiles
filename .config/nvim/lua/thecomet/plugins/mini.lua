return {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
        require("mini.cursorword").setup({})
        require("mini.hipatterns").setup({
            highlighters = {
                xxx = { pattern = "XXX:?", group = "MiniHipatternsFixme" },
                todo = { pattern = "TODO:?", group = "MiniHipatternsTodo" },
                doxygenbrief = { pattern = "[\\@]brief", group = "MiniHipatternsNote"},
                doxygenparam = { pattern = "[\\@]param", group = "MiniHipatternsNote"},
                doxygenparamin = { pattern = "[\\@]param.in.", group = "MiniHipatternsNote"},
                doxygenparamout = { pattern = "[\\@]param.out.", group = "MiniHipatternsNote"},
                doxygenparaminout = { pattern = "[\\@]param.inout.", group = "MiniHipatternsNote"},
                doxygenreturn = { pattern = "[\\@]return", group = "MiniHipatternsNote"},
                doxygennote = { pattern = "[\\@]note", group = "MiniHipatternsHack"},
                doxygenwarning = { pattern = "[\\@]warning", group = "MiniHipatternsFixme"},
                doxygenwarning = { pattern = "[\\@]see", group = "MiniHipatternsNote"},
            }
        })
        --require("mini.pairs").setup({
        --    mappings = {
        --        ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
        --        ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
        --        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
        --    
        --        [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
        --        [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
        --        ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
        --    
        --        ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
        --        ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
        --        ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
        --    },
        --})
        require("mini.splitjoin").setup({
            mappings = {
                toggle = 'gS',
                split = '',
                join = '',
            },
        })
        require("mini.surround").setup({
            mappings = {
                add = '<leader>sa', -- Add surrounding in Normal and Visual modes
                delete = '<leader>sd', -- Delete surrounding
                find = '<leader>sf', -- Find surrounding (to the right)
                find_left = '<leader>sF', -- Find surrounding (to the left)
                highlight = '<leader>sh', -- Highlight surrounding
                replace = '<leader>sr', -- Replace surrounding
                update_n_lines = '<leader>sn', -- Update `n_lines`
            
                suffix_last = 'l', -- Suffix to search with "prev" method
                suffix_next = 'n', -- Suffix to search with "next" method
            },
        })
    end
}

