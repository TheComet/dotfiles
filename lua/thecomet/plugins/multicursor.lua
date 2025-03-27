return {
  -- "mg979/vim-visual-multi",
  -- init = function(_, opts)
  --     -- https://github.com/mg979/vim-visual-multi/wiki/Mappings
  --     vim.g.VM_default_mappings = 0
  --     vim.g.VM_maps = {
  --         ["Find Under"] = "<leader>m"
  --         ["Find Subword Under"] = "<leader>m"
  --     }
  -- end
  "smoka7/multicursors.nvim",
  event = "VeryLazy",
  dependencies = {
    'nvimtools/hydra.nvim',
  },
  opts = {},
  cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
  keys = {
    {
      mode = { 'v', 'n' },
      '<Leader>m',
      '<cmd>MCstart<cr>',
      desc = 'Create a selection for selected text or word under the cursor',
    },
  },
}
