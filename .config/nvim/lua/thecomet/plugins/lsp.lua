return {
  "VonHeikemen/lsp-zero.nvim",
  branch = "v3.x",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  config = function()
    local lsp_zero = require("lsp-zero")
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")

    vim.lsp.set_log_level("off")

    lsp_zero.on_attach(function(client, bufnr)
      local opts = { buffer = bufnr, remap = false }
      -- see :help lsp-zero-keybindings to learn the available actions
      -- NOTE: Not required, we've mapped everything below already
      --lsp_zero.default_keymaps({buffer = bufnr})

      --vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "K", "<CMD>Lspsaga hover_doc ++keep<CR>", opts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      --vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gD", "<CMD>Lspsaga peek_definition<CR>")
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "gR", "<CMD>Lspsaga finder<CR>")
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "gC", "<CMD>Lspsaga incoming_calls<CR>")
      vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
      vim.keymap.set("n", "gO", "<CMD>Lspsaga peek_type_declaration<CR>")
      vim.keymap.set("n", "<M-o>", "<CMD>LspClangdSwitchSourceHeader<CR>")
      --vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>r", "<CMD>Lspsaga rename<CR>", { silent = true, noremap = true })
      vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
      vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
      vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
      vim.keymap.set("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, opts)
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set({ "n", "v" }, "<leader>f", vim.lsp.buf.format, opts) --function()
      -- Bundled version of clang-format does wrong things, use system clang-format
      --vim.g.cursor_position = vim.fn.winsaveview()
      --vim.cmd("%!clang-format")
      --vim.fn.winrestview(vim.g.cursor_position)
      --end, opts)
    end)

    mason.setup({})
    mason_lspconfig.setup({
      ensure_installed = { "clangd", "lua_ls" },
      handlers = {
        function(server_name)
          local capabilities = require("cmp_nvim_lsp").default_capabilities()
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
          })
        end,
        clangd = function()
          local lsp = require("lspconfig")
          local util = require("lspconfig.util")
          lsp.clangd.setup({
            cmd = {
              "clangd",
              "--header-insertion=never",
            },
            filetypes = { "c", "cpp" },
            root_dir = function(fname)
              local root_files = {
                ".clangd",
                ".clang-tidy",
                ".clang-format",
                "compile_commands.json",
                "compile_flags.txt",
              }
              return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
            end,
            on_new_config = function(new_config, new_cwd)
              local status, cmake = pcall(require, "cmake-tools")
              if status then
                cmake.clangd_on_new_config(new_config)
              end
            end,
          })
        end
      }
    })
  end
}
