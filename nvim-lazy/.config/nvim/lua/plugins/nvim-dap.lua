return {
  "mfussenegger/nvim-dap",
  opts = function()
    local dap = require("dap")
    local netcoredbg_adapter = {
      type = "executable",
      command = vim.fn.exepath("netcoredbg"),
      args = { "--interpreter=vscode" },
      options = {
        detached = false,
      },
    }
    dap.adapters.netcoredbg = netcoredbg_adapter
    dap.adapters.coreclr = netcoredbg_adapter

    -- for _, lang in ipairs({ "cs", "csharp", "fsharp", "vb" }) do
    -- if not dap.configurations[lang] then
    dap.configurations = {}
    dap.configurations.cs = {
      {
        type = "netcoredbg",
        name = "NetCoreDbg: Autolaunch",
        request = "launch",
        program = function()
          return require("dap-dll-autopicker").build_dll_path()
        end,
        cwd = "${workspaceFolder}",
      },
    }
    -- end
    -- end
  end,
}
