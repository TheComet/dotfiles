return {
    "ggandor/leap.nvim",
    config = function()
        leap = require("leap")
        vim.keymap.set({'n', 'x', 'o'}, '<leader>f',  '<Plug>(leap-forward)')
        vim.keymap.set({'n', 'x', 'o'}, '<leader>F',  '<Plug>(leap-backward)')
        vim.keymap.set({'n', 'x', 'o'}, '<leader>gf', '<Plug>(leap-from-window)')
    end
}
