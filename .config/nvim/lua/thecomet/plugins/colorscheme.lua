return {
    { "catppuccin/nvim", name = "catppuccin",
      config = function()
          vim.cmd.colorscheme("catppuccin-mocha")
          vim.keymap.set("n", "<leader>pc", "<CMD>Telescope colorscheme<CR>")
      end},
    { "tiagovla/tokyodark.nvim",name = "tokyodark" },
    { "folke/tokyonight.nvim",name = "tokyonight" },
    { "rebelot/kanagawa.nvim", name = "kanagawa" },
    { "kepano/flexoki-neovim", name = "flexoki" },
    { "jacoborus/tender.vim", name = "tender" },
    { "bluz71/vim-nightfly-colors", name = "nightfly" },
    { "bluz71/vim-moonfly-colors", name = "moonfly" },
    { "savq/melange-nvim", name = "melange" },
    { "EdenEast/nightfox.nvim", name = "nightfox" },
    { "sharpchen/Eva-Theme.nvim", name = "Eva-Theme" },
    { "rose-pine/neovim", name = "rose-pine" },
    { "DanielEliasib/sweet-fusion", name = "sweet-fusion" },
    { "neanias/everforest-nvim", name = "everforest" },
    { "ribru17/bamboo.nvim", name = "bamboo" },
    { "navarasu/onedark.nvim", name = "onedark" },
    { "Shatur/neovim-ayu", name = "ayu" },
    { "oxfist/night-owl.nvim", name = "night-owl" },
    { "barrientosvctor/abyss.nvim", name = "abyss" },
    { "mistweaverco/bluloco.nvim", name = "bluloco" },
    { "dasupradyumna/midnight.nvim", name = "midnight" },
    { "lettertwo/laserwave.nvim", name = "laserwave" },
    { "maxmx03/fluoromachine.nvim", name = "fluoromachine", opts = {
        glow = true, theme = "fluoromachine", transparent = true
    }},
    { "lunarvim/synthwave84.nvim", name = "synthwave84" },
    { "pauchiner/pastelnight.nvim", name = "pastelnight" },
    { "PunGrumpy/dullahan.nvim", name = "dullahan" },
    { "Biscuit-Theme/nvim", name = "biscuit" },
}
