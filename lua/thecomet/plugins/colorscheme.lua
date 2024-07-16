return {
    { "catppuccin/nvim", name = "catppuccin" },
    { "tiagovla/tokyodark.nvim",name = "tokyodark" },
    { "folke/tokyonight.nvim",name = "tokyonight" },
    { "rebelot/kanagawa.nvim", name = "kanagawa" },
    { "kepano/flexoki-neovim", name = "flexoki" },
    { "jacoborus/tender.vim", name = "tender" },
    { "bluz71/vim-nightfly-colors", name = "nightfly",
      config = function()
          vim.cmd.colorscheme("nightfly")
          vim.keymap.set("n", "<leader>pc", "<CMD>Telescope colorscheme<CR>")
      end},
    { "bluz71/vim-moonfly-colors", name = "moonfly" },
    { "savq/melange-nvim", name = "melange" },
    { "scottmckendry/cyberdream.nvim", name = "cyberdream" }
}
