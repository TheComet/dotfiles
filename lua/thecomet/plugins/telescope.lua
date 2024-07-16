return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    opts = {
        file_ignore_patterns = {
            "build/",
            "build_cppcheck/",
        },
        pickers = {
            colorscheme = { enable_preview = true }
        },
    },
    config = function(_, opts)
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', "<leader>pf", builtin.find_files, {})
        vim.keymap.set('n', "<leader>pg", builtin.git_files, {})
        vim.keymap.set('n', "<leader>ps", builtin.live_grep, {})
        vim.keymap.set('n', "gs", builtin.lsp_document_symbols, {})
        vim.keymap.set('n', "gc", builtin.lsp_incoming_calls, {})
        require("telescope").setup(opts)
    end
}

