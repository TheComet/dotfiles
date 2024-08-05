return {
    "Civitasv/cmake-tools.nvim",
    opts = {
        cmake_regenerate_on_save = false,
        cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
        cmake_build_options = { "--parallel 12" },
        -- support macro expansion:
        --       ${kit}
        --       ${kitGenerator}
        --       ${variant:xx}
        cmake_build_directory = "build-${variant:buildType}",
        cmake_executor = { -- executor to use
            name = "quickfix", -- name of the executor
            default_opts = { -- a list of default and possible values for executors
                terminal = {
                    name = "Main Terminal",
                    split_direction = "horizontal",
                    split_size = 20,
                },
            },
        },
        cmake_runner = {
            name = "terminal",
            default_opts = {
                terminal = {
                    name = "Main Terminal",
                    split_direction = "vertical",
                    split_size = 100,
                    --focus = true, -- Focus on terminal when cmake task is launched.
                },
            },
        },
    },
    keys = {
        { "<leader>cc", "<CMD>CMakeClean<CR>" },
        { "<leader>cg", "<CMD>CMakeGenerate<CR>" },
        { "<leader>cb", "<CMD>CMakeBuild<CR>" },
        { "<leader>ctt", "<CMD>CMakeSelectLaunchTarget<CR>" },
        { "<leader>cts", "<CMD>CMakeTargetSettings<CR>" },
        { "<leader>cr", "<CMD>CMakeRun<CR>" },
        { "<leader>cs", "<CMD>CMakeSettings<CR>" },
        { "<leader>cx", "<CMD>CMakeStopExecutor<CR>" },
    },
    config = function(_, opts)
        require("cmake-tools").setup(opts)
    end
}
