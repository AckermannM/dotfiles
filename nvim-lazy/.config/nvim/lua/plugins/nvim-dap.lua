return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "ibhagwan/fzf-lua",
  },
  opts = function()
    local dap = require("dap")
    local fzf = require("fzf-lua")

    local netcoredbg_adapter = {
      type = "executable",
      command = vim.fn.exepath("netcoredbg"),
      args = { "--interpreter=vscode" },
      options = {
        detached = false,
      },
      enritch_config = function(config, _)
        if config.request == "launch" and config.program then
          config.program = vim.fn.expand(config.program)
        end
      end,
    }

    dap.adapters.netcoredbg = netcoredbg_adapter

    local function find_csproj(start)
      local dir = vim.fn.isdirectory(start) == 1 and start or vim.fn.fnamemodify(start, ":h")
      while dir ~= "/" and dir ~= "" do
        local hit = vim.fn.glob(dir .. "/*.csproj")
        if hit ~= "" then
          local proj = nil
          local dirname = vim.fn.fnamemodify(hit, ":t")
          for f in hit:gmatch("[^\r\n]+") do
            if vim.fn.fnamemodify(f, ":t:r") == dirname then
              proj = f
              break
            end
            proj = proj or f
          end
          return proj
        end
        local up = vim.fn.fnamemodify(dir, ":h")
        if up == dir then
          break
        end
        dir = up
      end
      return nil
    end

    -- Helper: find all built DLLs recursively
    local function find_dlls()
      local cmd = vim.fn.executable("fd") == 1
          and "fd -I -e dll --full-path bin/Debug src -E 'Microsoft.*' -E 'System.*'"
        or "find ./src -type f -path '*/bin/Debug/*.dll' ! -name 'Microsoft.*' ! -name 'System.*'"
      local handle = io.popen(cmd)
      if not handle then
        return {}
      end
      local result = handle:read("*a")
      handle:close()
      local dlls = {}
      for line in result:gmatch("[^\r\n]+") do
        table.insert(dlls, line)
      end
      return dlls
    end

    local function esc_pat(s)
      return (s or ""):gsub("(%p)", "%%%0")
    end

    local function score_dll(dll, proj_dir, proj_name)
      local score = 0
      if proj_dir and dll:find(proj_dir, 1, true) then
        score = score + 1000
      end
      if proj_name then
        local pname_pat = esc_pat(proj_name)
        if dll:match("/" .. pname_pat .. "%.dll$") then
          score = score + 500
        end
        if dll:match("/bin/Debug/net[%w%.%-]+/" .. pname_pat .. "%.dll$") then
          score = score + 200
        end
      end
      score = score - #dll
      return score
    end

    local function pick_dll(callback)
      local dlls = find_dlls()
      if #dlls == 0 then
        vim.notify("No DLLs found in bin/Debug directories.", vim.log.levels.WARN)
        return
      end

      local bufpath = vim.api.nvim_buf_get_name(0)
      local csproj = find_csproj(bufpath)
      local proj_name, proj_dir, initial_query

      if csproj then
        proj_name = vim.fn.fnamemodify(csproj, ":t:r")
        proj_dir = vim.fn.fnamemodify(csproj, ":h")
        initial_query = proj_name .. ".dll"
        table.sort(dlls, function(a, b)
          return score_dll(a, proj_dir, proj_name) > score_dll(b, proj_dir, proj_name)
        end)
      end

      fzf.fzf_exec(dlls, {
        prompt = "Select .NET Project DLL  ",
        fzf_opts = {
          ["--no-sort"] = true,
          ["--tiebreak"] = "index",
          ["--select-1"] = true,
          ["--exit-0"] = true,
          ["--query"] = initial_query or "",
        },
        actions = {
          ["default"] = function(selected)
            if not selected or #selected == 0 then
              vim.notify("No DLL selected.", vim.log.levels.WARN)
              return
            end
            callback(selected[1])
          end,
        },
        ---@diagnostic disable-next-line: assign-type-mismatch
        fzf_colors = true,
      })
    end

    dap.configurations.cs = {
      {
        type = "netcoredbg",
        name = "NetCoreDbg: Pick Project DLL (fzf-lua)",
        request = "launch",
        program = function()
          return coroutine.create(function(co)
            pick_dll(function(dll_path)
              coroutine.resume(co, dll_path)
            end)
          end)
        end,
        cwd = function()
          local dll = dap.session() and dap.session().config.program or ""
          -- walk up four dirs from bin/Debug/netX.Y/ to project root
          return dll ~= "" and vim.fn.fnamemodify(dll, ":h:h:h:h") or vim.fn.getcwd()
        end,
        -- TODO: Add option to build before launch
        -- preLaunchTask = "something",
        stopAtEntry = false,
        env = {
          ASPNETCORE_ENVIRONMENT = "Development",
          ASPNETCORE_URLS = "http://localhost:5595",
        },
      },
    }
  end,
}
