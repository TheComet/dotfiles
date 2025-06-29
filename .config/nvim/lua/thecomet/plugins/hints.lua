return {
    "MysticalDevil/inlay-hints.nvim",
    opts = {
        autocmd = { enable = false },
        commands = { enable = true },
    },
    config = function (_, opts)
        require("inlay-hints").setup(opts)
        vim.keymap.set("n", "<leader>i", "<CMD>InlayHintsToggle<CR>")
    end
}
