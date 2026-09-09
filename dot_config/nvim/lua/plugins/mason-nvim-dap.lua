return {
  "jay-babu/mason-nvim-dap.nvim",
  opts = {
    handlers = {
      coreclr = function(_) end,
    },
    ensure_installed = {
      "netcoredbg",
    },
  },
}
