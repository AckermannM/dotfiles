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

        local dll, csproj = dotnet.pick_project_and_dll_sync()
        if not csproj or csproj == "" then
          vim.notify("No .csproj selected for debugging.", vim.log.levels.ERROR)
          return
        end

        dll = vim.fn.fnamemodify(dll, ":p")
        local project_root = vim.fn.fnamemodify(csproj, ":h")
        new_config.program = dll
        new_config.cwd = project_root
        new_config.env = dotnet.load_env(project_root)

        vim.notify("Debugging DLL: " .. dll .. " from project: " .. csproj, vim.log.levels.INFO)

        on_config(new_config)
      end,
    }

    dap.adapters.netcoredbg = netcoredbg_adapter

    dap.configurations.cs = {
      {
        type = "netcoredbg",
        name = "NetCoreDbg: Smart Launch (fzf-lua)",
        request = "launch",
        -- preLaunchTask = "dotnet: build current project",
        stopAtEntry = false,
      },
    }
  end,
}
