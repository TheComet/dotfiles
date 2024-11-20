return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "debugloop/layers.nvim",
    },
    config = function()
      local dap = require("dap")

      -- Global keybindings
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
      vim.keymap.set("n", "<leader>dr", dap.continue)
    end
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    opts = {
      icons = {
        expanded = "▾",
        collapsed = "▸",
        current_frame = "",
      },
      layouts = {
        {
          elements = {
            -- Provide IDs as strings or tables with "id" and "size" keys
            { id = "breakpoints", size = 0.15 },
            { id = "stacks",      size = 0.25 },
            { id = "scopes",      size = 0.40 },
            { id = "watches",     size = 0.20 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "rtt",  size = 0.5 },
          },
          size = 15,
          position = "bottom",
        },
      },
      floating = {
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      controls = {
        enabled = false,
        element = "repl",
        icons = {
          pause = "",
          play = "",
          step_into = "",
          step_over = "",
          step_out = "",
          step_back = "",
          run_last = "",
          terminate = "",
          disconnect = "",
        },
      }
    },
    config = function(_, opts)
      local dap = require("dap")
      local widgets = require("dap.ui.widgets")
      local ui = require("dapui")
      local layers = require("layers")
      ui.setup(opts)

      local open_and_bind = function()
        ui.open({ reset = "true" })

        -- Keybindings that are only active during debugging
        local debug_map = layers.map.new()
        debug_map:set("n", "<leader>r", dap.continue)
        debug_map:set("n", "<leader>t", dap.terminate)
        debug_map:set("n", "<C-n>", dap.step_over)
        debug_map:set("n", "<A-n>", dap.step_back)
        debug_map:set("n", "<C-s>", dap.step_into)
        debug_map:set("n", "<A-s>", dap.step_out)
        debug_map:set("n", "<C-f>", dap.down)
        debug_map:set("n", "<A-f>", dap.up)
        debug_map:set("n", "<C-c>", dap.run_to_cursor)
        debug_map:set("n", "<leader>h", widgets.hover)
        debug_map:set("n", "<leader>i", function() require("dapui").eval() end)
        debug_map:set("v", "<leader>i", function() require("dapui").eval() end)
        debug_map:set("n", "<leader>p", widgets.preview)
        debug_map:set("n", "<leader>a", function() require("dapui").elements.watches.add(vim.fn.expand("<cword>")) end)
        debug_map:set("n", "<Leader>f", function() widgets.centered_float(widgets.frames) end)
        debug_map:set("n", "<Leader>s", function() widgets.centered_float(widgets.scopes) end)
        debug_map:set("n", "<leader>e", dap.repl.open)
        debug_map:set("n", "<leader>o", function() require("dapui").float_element("rtt") end)
        debug_map:set("n", "<leader>dc", function()
          ui.close()
          debug_map:clear()
        end)
        dap.listeners.before.event_terminated["keymap_config"] = function()
          --debug_map:clear()
          --ui.close()
        end
        dap.listeners.before.event_exited["keymap_config"] = function()
          --debug_map:clear()
          --ui.close()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          --debug_map:clear()
          --ui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          --debug_map:clear()
          --ui.close()
        end
      end

      vim.keymap.set("n", "<leader>do", open_and_bind)
      dap.listeners.before.event_initialized["dapui_config"] = open_and_bind
    end
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = { handlers = {} },
    ensure_installed = { "codelldb" },
  },
  {
    "ldelossa/nvim-dap-projects",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local projects = require('nvim-dap-projects')
      projects.search_project_config()

      vim.api.nvim_create_autocmd(
        "BufWritePost",
        {
          pattern = "*nvim-dap.lua",
          callback = projects.search_project_config
        }
      )
    end
  },
  {
    "jedrzejboczar/nvim-dap-cortex-debug",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    opts = {
      -- log debug messages
      debug = false,
      extension_path = "~/.local/share/nvim/mason/share/cortex-debug/dist/",
      lib_extension = nil,
      node_path = "node",
      dapui_rtt = true,
      -- make :DapLoadLaunchJSON register cortex-debug for C/C++,
      -- set false to disable
      dap_vscode_filetypes = false,
      rtt = {
        -- 'Terminal' or 'BufTerminal' for terminal buffer vs normal buffer
        buftype = "Terminal",
      },
    },
    config = function(_, opts)
      require("dap-cortex-debug").setup(opts)
    end
  }
}
