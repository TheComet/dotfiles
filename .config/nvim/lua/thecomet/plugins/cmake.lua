return {
    "Civitasv/cmake-tools.nvim",
    opts = {
        cmake_command = "cmake", -- this is used to specify cmake command path
        ctest_command = "ctest", -- this is used to specify ctest command path
        cmake_use_preset = false,
        cmake_regenerate_on_save = false, -- auto generate when save CMakeLists.txt
        cmake_generate_options = {}, -- this will be passed when invoke `CMakeGenerate`
        cmake_build_options = { "--parallel 32" }, -- this will be passed when invoke `CMakeBuild`
        -- support macro expansion:
        --             ${kit}
        --             ${kitGenerator}
        --             ${variant:xx}
        cmake_build_directory = "build-${variant:buildType}",
        cmake_soft_link_compile_commands = false,
        cmake_compile_commands_from_lsp = false,
        cmake_kits_path = nil, -- this is used to specify global cmake kits path, see CMakeKits for detailed usage
        cmake_variants_message = {
            short = { show = true },
            long = { show = true, max_length = 40 },
        },
        cmake_dap_configuration = {
            name = "cpp",
            type = "codelldb",
            request = "launch",
            stopOnEntry = false,
            runInTerminal = true,
            console = "integratedTerminal",
        },
        cmake_executor = {
            name = "quickfix",
            opts = {},
            default_opts = {
                quickfix = {
                    show = "always", -- "always", "only_on_error"
                    position = "belowright",
                    size = 10,
                    encoding = "utf-8",
                    auto_close_when_success = true,
                },
                toggleterm = {
                    direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
                    close_on_exit = false, -- whether close the terminal when exit
                    auto_scroll = true, -- whether auto scroll to the bottom
                    singleton = true, -- single instance, autocloses the opened one, if present
                },
                overseer = {
                    new_task_opts = {
                        strategy = {
                            "toggleterm",
                            direction = "horizontal",
                            autos_croll = true,
                            quit_on_exit = "success"
                        }
                    },
                    on_new_task = function(task)
                        require("overseer").open(
                            { enter = false, direction = "right" }
                        )
                    end,
                },
                terminal = {
                    name = "Main Terminal",
                    prefix_name = "[CMakeTools]: ",
                    split_direction = "horizontal", -- "horizontal", "vertical"
                    split_size = 11,

                    -- Window handling
                    single_terminal_per_instance = true, -- Single viewport, multiple windows
                    single_terminal_per_tab = true, -- Single viewport per tab
                    keep_terminal_static_location = true, -- Static location of the viewport if avialable
                    auto_resize = false, -- Resize the terminal if it already exists

                    -- Running Tasks
                    start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
                    focus = false, -- Focus on terminal when cmake task is launched.
                    do_not_add_newline = false,
                },
            },
        },
        cmake_runner = {
            name = "terminal",
            opts = {},
            default_opts = {
                quickfix = {
                    show = "always", -- "always", "only_on_error"
                    position = "belowright", -- "bottom", "top"
                    size = 10,
                    encoding = "utf-8",
                    auto_close_when_success = true,
                },
                toggleterm = {
                    direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
                    close_on_exit = false, -- whether close the terminal when exit
                    auto_scroll = true, -- whether auto scroll to the bottom
                    singleton = true, -- single instance, autocloses the opened one, if present
                },
                overseer = {
                    new_task_opts = {
                        strategy = {
                            "toggleterm",
                            direction = "horizontal",
                            autos_croll = true,
                            quit_on_exit = "success"
                        }
                    }, -- options to pass into the `overseer.new_task` command
                    on_new_task = function(task)
                    end,     -- a function that gets overseer.Task when it is created, before calling `task:start`
                },
                terminal = {
                    name = "Main Terminal",
                    prefix_name = "[CMakeTools]: ",
                    split_direction = "horizontal",
                    split_size = 11,

                    -- Window handling
                    single_terminal_per_instance = true, -- Single viewport, multiple windows
                    single_terminal_per_tab = true, -- Single viewport per tab
                    keep_terminal_static_location = true, -- Static location of the viewport if avialable
                    auto_resize = false, -- Resize the terminal if it already exists

                    -- Running Tasks
                    start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
                    focus = false, -- Focus on terminal when cmake task is launched.
                    do_not_add_newline = false,
                },
            },
        },
        cmake_notifications = {
            runner = { enabled = true },
            executor = { enabled = true },
            spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }, -- icons used for progress display
            refresh_rate_ms = 100, -- how often to iterate icons
        },
        cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at right corner)
    },
    keys = {
        --{ "<leader>cc", "<CMD>CMakeClean<CR>" },
        { "<leader>cg", "<CMD>CMakeGenerate<CR>" },
        --{ "<leader>cb", "<CMD>CMakeBuild<CR>" },
        { "<leader>ctt", "<CMD>CMakeSelectLaunchTarget<CR>" },
        { "<leader>cts", "<CMD>CMakeTargetSettings<CR>" },
        { "<leader>ctb", "<CMD>CMakeSelectBuildDir<CR>" },
        { "<leader>ctc", "<CMD>CMakeSelectCwd<CR>" },
        --{ "<leader>cr", "<CMD>CMakeRun<CR>" },
        { "<leader>cs", "<CMD>CMakeSettings<CR>" },
        { "<leader>cx", "<CMD>CMakeStopExecutor<CR>" },
    },
    config = function(_, opts)
        require("cmake-tools").setup(opts)
        local cmake_file = vim.fn.expand("%:p:h") .. "/CMakeLists.txt"
        if vim.fn.filereadable(cmake_file) ~= 0 then
            vim.keymap.set("n", "<leader>cb", "<CMD>CMakeBuild<CR>")
            vim.keymap.set("n", "<leader>cc", "<CMD>CMakeClean<CR>")
            vim.keymap.set("n", "<leader>cr", "<CMD>CMakeRun<CR>")
        end
    end
}
