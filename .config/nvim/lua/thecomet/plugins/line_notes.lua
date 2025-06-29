return {
    "kristijanhusak/line-notes.nvim",
    opts = {
        auto_preview = true,
        icon = "🗨",
        mappings = {
            add = "<leader>na",
            edit = "<leader>ne",
            preview = "<leader>np",
            delete = "<leader>nd",
        },
    },
    config = function(_, opts)
        require("line-notes").setup(opts)
        vim.keymap.set("n", "<leader>pn", "<CMD>Telescope line_notes<CR>")
    end
}
