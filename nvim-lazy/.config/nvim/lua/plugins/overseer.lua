return {
  "stevearc/overseer.nvim",
  opts = function(_, opts)
    local overseer = require("overseer")
    local dotnet = require("scripts.dotnet_utils")

    overseer.register_template({
      name = "dotnet: build current project",
      builder = function()
        local proj = dotnet.find_csproj_upwards(vim.api.nvim_buf_get_name(0))
        if not proj then
          return
        end
        return {
          cmd = { "dotnet" },
          args = { "build", proj },
          name = "dotnet build",
          cwd = vim.fn.getcwd(),
          components = { "default" },
        }
      end,
      condition = {
        filetype = { "cs" },
      },
      desc = "Build the closest .NET project (.csproj) from the current buffer",
    })
  end,
}
