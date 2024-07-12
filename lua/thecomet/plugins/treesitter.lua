--return {
--    "nvim-treesitter/nvim-treesitter",
--    build = ":TSUpdate",
--    config = function()
--        require("nvim-treesitter.configs").setup {
--            ensure_installed = { "c", "lua" },
--            highlight = { enable = true },
--        }
--    end
--}

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        highlight = { enabled = true },
        --indent = { enable = true },
        -- Install parsers synchronously (only applied to 'ensure_installed')
        sync_install = false,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
        ensure_installed = {
            "bash", "c", "diff", "html", "lua", "luadoc", "luap", "markdown",
            "markdown_inline", "python", "regex", "toml", "vim", "vimdoc",
            "xml", "yaml"
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                node_incremental = "v",
                node_decremental = "V"
            },
        },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
}
