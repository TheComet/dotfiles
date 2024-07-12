return {
    "FabijanZulj/blame.nvim",
    config = function()
        require("blame").setup()
        vim.keymap.set({"n", "i", "v"}, "<A-a>", "<CMD>BlameToggle<CR>")
    end
}
