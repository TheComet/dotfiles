return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "debugloop/layers.nvim",
        },
        config = function()
            local dap = require("dap")
            local widgets = require("dap.ui.widgets")
            local layers = require("layers")

            dap.adapters.lldb = {
                type = "executable",
                command = "/usr/bin/lldb",
                name = "lldb"
            }
            dap.adapters.gdb = {
                type = "executable",
                command = "/usr/bin/gdb",
                name = "gdb"
            }

            -- Global keybindings
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
            vim.keymap.set("n", "<leader>dr", dap.continue)
            vim.keymap.set("n", "<leader>dl", dap.run_last)

            -- Keybindings that are only active during debugging
            local debug_map = layers.map.new()
            dap.listeners.after.event_initialized["keymap_config"] = function()
                debug_map:set("n", "<leader>dt", dap.terminate)
                debug_map:set("n", "<C-n>", dap.step_over)
                debug_map:set("n", "<A-n>", dap.step_back)
                debug_map:set("n", "<C-s>", dap.step_into)
                debug_map:set("n", "<A-s>", dap.step_out)
                debug_map:set("n", "<C-f>", dap.down)
                debug_map:set("n", "<A-f>", dap.up)
                debug_map:set("n", "<C-c>", dap.run_to_cursor)
                debug_map:set("n", "<leader>di", widgets.hover)
                debug_map:set("n", "<C-i>", function() require("dapui").eval() end)
                debug_map:set("v", "<C-i>", function() require("dapui").eval() end)
                debug_map:set("n", "<leader>dp", widgets.preview)
                debug_map:set("n", "<leader>da", function() require("dapui").elements.watches.add(vim.fn.expand("<cword>")) end)
                debug_map:set("n", "<Leader>df", function() widgets.centered_float(widgets.frames) end)
                debug_map:set("n", "<Leader>ds", function() widgets.centered_float(widgets.scopes) end)
                debug_map:set("n", "<leader>de", dap.repl.open)
            end
            dap.listeners.before.event_terminated["keymap_config"] = function()
                debug_map:clear()
            end
            dap.listeners.before.event_exited["keymap_config"] = function()
                debug_map:clear()
            end
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
                        { id = "repl", size = 1.0 },
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
            local ui = require("dapui")
            local dap = require("dap")
            ui.setup(opts)

            dap.listeners.after.event_initialized["dapui_config"] = function()
                ui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                ui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                ui.close()
            end
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
    }
}
