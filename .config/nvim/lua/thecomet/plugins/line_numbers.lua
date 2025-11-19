return {
  'mluders/comfy-line-numbers.nvim',
  opts = {},
  config = function(_, opts)
    require('comfy-line-numbers').setup(opts)
  end
}
