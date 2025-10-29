return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "ibhagwan/fzf-lua",
  },
  opts = function()
    local dap = require("dap")
    local dotnet = require("scripts.dotnet_utils")

    local netcoredbg_adapter = {
      type = "executable",
      command = vim.fn.exepath("netcoredbg"),
      args = { "--interpreter=vscode" },
      options = {
        detached = false,
      },
      enrich_config = function(config, on_config)
        local new_config = vim.deepcopy(config)

        if not new_config.program or new_config.program == "" then
          local dll = dotnet.pick_dll_sync()
          if not dll or dll == "" then
            vim.notify("No DLL selected for debugging.", vim.log.levels.ERROR)
            return
          end
          dll = vim.fn.fnamemodify(dll, ":p")
          new_config.program = dll
        end

        local project_root = dotnet.find_project_root(new_config.program)
        new_config.cwd = project_root
        new_config.env = dotnet.load_env(project_root)

        on_config(new_config)
      end,
    }

    dap.adapters.netcoredbg = netcoredbg_adapter

    dap.configurations.cs = {
      {
        type = "netcoredbg",
        name = "NetCoreDbg: Smart Launch (fzf-lua)",
        request = "launch",
        preLaunchTask = "dotnet: build current project",
        stopAtEntry = false,
      },
    }
  end,
}
