local M = {}

local fzf_ok, fzf = pcall(require, "fzf-lua")
if not fzf_ok then
  vim.notify("fzf-lua not found! dotnet_utils.lua requires fzf-lua.", vim.log.levels.ERROR)
  return M
end

function M.find_csproj(start)
  local file = start or vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.isdirectory(file) == 1 and file or vim.fn.fnamemodify(file, ":h")

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

-- Find the project root directory containing the .csproj file
-- returns cwd if not found
function M.find_project_root(start)
  local csproj = M.find_csproj(start)
  if csproj then
    vim.notify("Found project root: " .. vim.fn.fnamemodify(csproj, ":h"), vim.log.levels.INFO)
    return vim.fn.fnamemodify(csproj, ":h")
  end
  return vim.fn.getcwd()
end

-- Helper: find all built DLLs recursively
local function find_dlls()
  -- TODO: Revise filters maybe works without
  local cmd = vim.fn.executable("fd") == 1 and "fd -I -e dll --full-path bin/Debug src -E 'Microsoft.*' -E 'System.*'"
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

function M.pick_dll(callback)
  local dlls = find_dlls()
  if #dlls == 0 then
    vim.notify("No DLLs found in bin/Debug directories.", vim.log.levels.WARN)
    return
  end

  local bufpath = vim.api.nvim_buf_get_name(0)
  local csproj = M.find_csproj(bufpath)
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

function M.pick_dll_sync()
  local co = coroutine.running()
  local result
  M.pick_dll(function(dll_path)
    result = dll_path
    if co then
      coroutine.resume(co)
    end
  end)
  coroutine.yield()
  return result
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
    local ok, json = pcall(vim.fn.readfile, launch_file)
    if ok and json and json.profiles then
      local _, profile = next(json.profiles)
      if profile and profile.environmentVariables then
        return profile.environmentVariables
      end
    end
  end

  vim.notify("Could not load launchSettings.json, using default env vars.", vim.log.levels.WARN)
  return {
    ASPNETCORE_ENVIRONMENT = "Development",
    ASPNETCORE_URLS = "http://localhost:5149",
  }
end

return M
