return {
    "mbbill/undotree",
    config = function(_, opts)
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_ShortIndicators = 1
        vim.g.undotree_SetFocusWhenToggle = 1
        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    end
}
