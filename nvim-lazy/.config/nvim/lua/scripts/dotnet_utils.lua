local M = {}

local fzf_ok, fzf = pcall(require, "fzf-lua")
if not fzf_ok then
  vim.notify("fzf-lua not found! dotnet_utils.lua requires fzf-lua.", vim.log.levels.ERROR)
  return M
end

-- find all .csproj files upwards from the start directory
local function find_solution_root(start)
  local file = start or vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.isdirectory(file) == 1 and file or vim.fn.fnamemodify(file, ":h")
  while dir ~= "/" and dir ~= "" do
    -- if dir has sln, it is root
    local slns = vim.fn.glob(dir .. "/*.sln")
    if slns ~= "" then
      return dir, "sln"
    end
    --fallback: if dir has multiple csproj, treat it as root
    local csprojs = vim.fn.glob(dir .. "/*.csproj")
    if csprojs ~= "" then
      -- don't return yet we want to see of a higher dir has sln
      local up = vim.fn.fnamemodify(dir, ":h")
      if up == dir then
        return dir, "csproj"
      end
      -- we onlyreturn here if we are at filesystem root
    end

    local up = vim.fn.fnamemodify(dir, ":h")
    if up == dir then
      break
    end
    dir = up
  end
  return nil, nil
end

function M.find_csprojs_for_current_solution(start)
  local root = select(1, find_solution_root(start) or vim.fn.getcwd())
  local results = {}

  if vim.fn.executable("fd") == 1 then
    -- scan only inside the root, not above
    local cmd = string.format("fd -I -p -e csproj %s", vim.fn.shellescape(root))
    local handle = io.popen(cmd)
    if handle then
      local out = handle:read("*a")
      handle:close()
      for line in out:gmatch("([^\r\n]+)") do
        table.insert(results, vim.fn.fnamemodify(line, ":p"))
      end
    end
  else
    -- fallback: glob recursively
    -- this is a bit slower
    local gl = vim.fn.glob(root .. "/**/*.csproj", true, true)
    for _, path in ipairs(gl) do
      table.insert(results, vim.fn.fnamemodify(path, ":p"))
    end
  end
  return results, root
end

-- Find the project root directory containing the .csproj file
-- returns cwd if not found
function M.find_project_root(start)
  local csproj = M.find_csproj_upwards(start)(start)
  if csproj then
    return vim.fn.fnamemodify(csproj, ":h")
  end
  return vim.fn.getcwd()
end

function M.build_csproj(csproj_path)
  if not csproj_path then
    csproj_path = M.find_csproj(vim.api.nvim_buf_get_name(0))
    if not csproj_path then
      vim.notify("No .csproj file found.", vim.log.levels.ERROR)
      return false
    end
  end
  vim.notify("Building project: " .. csproj_path, vim.log.levels.INFO)
  local job_id = vim.fn.jobstart({ "dotnet", "build", csproj_path }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            vim.notify("[dotnet build] " .. line, vim.log.levels.INFO)
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            vim.notify("[dotnet build ERROR] " .. line, vim.log.levels.ERROR)
          end
        end
      end
    end,
  })
  return job_id
end

function M.load_env(project_root)
  local launch_file = (project_root or M.find_project_root()) .. "/Properties/launchSettings.json"

  if vim.fn.filereadable(launch_file) == 1 then
    local ok, parsed = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(launch_file), "\n"))
    if not ok or not parsed or not parsed.profiles then
      vim.notify("Could not parse launchSettings.json, using default env vars.", vim.log.levels.WARN)
      return {
        ASPNETCORE_ENVIRONMENT = "Development",
        ASPNETCORE_URLS = "http://localhost:5149",
      }
    end
    local profile = parsed.profiles.http or select(2, next(parsed.profiles))
    if not profile then
      vim.notify("No profile found in launchSettings.json, using default env vars.", vim.log.levels.WARN)
      return {
        ASPNETCORE_ENVIRONMENT = "Development",
        ASPNETCORE_URLS = "http://localhost:5149",
      }
    end

    local env = vim.deepcopy(profile.environmentVariables or {})
    if profile.applicationUrl and profile.applicationUrl ~= "" then
      local urls = profile.applicationUrl:gsub(";", ",")
      env.ASPNETCORE_URLS = urls
      vim.notify("Set ASPNETCORE_URLS to " .. urls, vim.log.levels.INFO)
    else
      vim.notify("No applicationUrl found in profile, using default ASPNETCORE_URLS.", vim.log.levels.WARN)
      env.ASPNETCORE_URLS = env.ASPNETCORE_URLS or "http://localhost:5000"
    end

    return env
  end

  vim.notify("No launchSettings.json found, using default env vars.", vim.log.levels.WARN)
  return {
    ASPNETCORE_ENVIRONMENT = "Development",
    ASPNETCORE_URLS = "http://localhost:5149",
  }
end

function M.find_output_dll(csproj)
  if not csproj or csproj == "" then
    return nil
  end
  local proj_dir = vim.fn.fnamemodify(csproj, ":h")
  local proj_name = vim.fn.fnamemodify(csproj, ":t:r")
  -- try to find a DLL matching project name under bin/Debug/net*
  local cmd
  if vim.fn.executable("fd") == 1 then
    cmd = "fd -I -p -e dll " .. vim.fn.shellescape(proj_name) .. ".dll " .. vim.fn.shellescape(proj_dir)
  else
    cmd = "find " .. vim.fn.shellescape(proj_dir) .. " -type f -path '*/bin/Debug/*/" .. proj_name .. ".dll'"
  end
  local handle = io.popen(cmd)
  if not handle then
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  local fist_line = result:match("([^\r\n]+)")
  return fist_line and vim.fn.fnamemodify(fist_line, ":p") or nil
end

function M.pick_project_and_dll(callback)
  local csprojs = M.find_csprojs_for_current_solution()
  if not csprojs or #csprojs == 0 then
    vim.notify("No .csproj files found upwards from current directory.", vim.log.levels.WARN)
    return
  end

  fzf.fzf_exec(csprojs, {
    prompt = "Select .NET Project (.csproj)  ",
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then
          vim.notify("No project selected.", vim.log.levels.WARN)
          return
        end
        local csproj_path = selected[1]
        local dll = M.find_output_dll(csproj_path)
        if not dll or dll == "" then
          vim.notify("No built DLL found for project: " .. csproj_path, vim.log.levels.WARN)
          callback(nil, csproj_path)
          return
        end
        callback(dll, csproj_path)
      end,
    },
    ---@diagnostic disable-next-line: assign-type-mismatch
    fzf_colors = true,
  })
end

function M.pick_project_and_dll_sync()
  local co = coroutine.running()
  local result_dll, result_csproj
  M.pick_project_and_dll(function(dll_path, csproj_path)
    result_dll = dll_path
    result_csproj = csproj_path
    if co then
      coroutine.resume(co)
    end
  end)
  coroutine.yield()
  return result_dll, result_csproj
end

return M
