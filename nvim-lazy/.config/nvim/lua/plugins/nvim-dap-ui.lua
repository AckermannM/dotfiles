return {
  "rcarriga/nvim-dap-ui",
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    ---@diagnostic disable-next-line: missing-fields
    dapui.setup({
      expand_lines = true,
      ---@diagnostic disable-next-line: missing-fields
      controls = { enabled = false },
      ---@diagnostic disable-next-line: missing-fields
      floating = { border = "rounded" },
      ---@diagnostic disable-next-line: missing-fields
      render = { max_type_length = 60, max_value_lines = 200 },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 1.0 },
          },
          size = 15,
          position = "bottom",
        },
      },
    })

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open({})
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close({})
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close({})
    end
  end,
}
