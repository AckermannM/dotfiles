# ---------------------------------------------------------------------------
# PowerShell profile. Managed by chezmoi.
#
# The real $PROFILE path lives under OneDrive-redirected Documents, which is a
# bad place for anything chezmoi or a symlink should own. So that file is a
# one-line stub that dot-sources this one, and this is what actually changes.
#
# Keep this cheap. Startup on this machine is dominated by process spawns
# (~100 ms each, Defender for Endpoint hooks process creation), so nothing here
# should shell out. The old 5.1 profile imported posh-git, which cost 365 ms to
# import plus ~500 ms on the first prompt.
# ---------------------------------------------------------------------------

# XDG so starship, and anything else XDG-aware, finds config where the Linux
# machines keep it rather than in %APPDATA%.
$env:XDG_CONFIG_HOME = Join-Path $HOME '.config'

# Windows has no notion of "sudo state" to poll, and elevation is fixed for the
# life of a process -- so resolve it once here and let starship render it. The
# IsInRole check costs ~0.1 ms.
#
# Exactly one of these is set, never both: the prompt uses them as two mutually
# exclusive segments so the separator running into the path is drawn in the
# right colour (red after an ADMIN block, purple otherwise).
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $env:STARSHIP_ELEVATED     = 'ADMIN'
    $env:STARSHIP_NOT_ELEVATED = $null
} else {
    $env:STARSHIP_ELEVATED     = $null
    $env:STARSHIP_NOT_ELEVATED = '1'
}

# --- shortcuts (carried over from the old Windows PowerShell profile) --------

Set-Alias -Name gg -Value lazygit

function lc {
    & "$env:LOCALAPPDATA\Programs\LazyClocking\LazyClocking.exe" @args
}

# --- prompt -----------------------------------------------------------------

$env:STARSHIP_CONFIG = Join-Path $HOME '.config\powershell\starship.toml'

# Resolve starship by probing known install locations instead of Get-Command.
# Get-Command builds its command cache across all 55 entries of PATH on first
# call, and with Defender hooking each probe that measured ~840 ms in a fresh
# shell -- more than the rest of startup combined. Test-Path on a literal path
# is ~0 ms. Get-Command stays as the fallback for when starship moves.
$starship = @(
    "$env:ProgramFiles\starship\bin\starship.exe"
    "$env:LOCALAPPDATA\Programs\starship\bin\starship.exe"
    "$env:USERPROFILE\scoop\shims\starship.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $starship) {
    $starship = (Get-Command starship -ErrorAction SilentlyContinue).Source
}

if ($starship) {
    # --print-full-init emits the init script directly. Plain `init powershell`
    # emits a shim that spawns starship a second time to fetch it, and a spawn
    # costs ~100 ms here: 261 ms plain vs 113 ms this way.
    Invoke-Expression (& $starship init powershell --print-full-init | Out-String)
}
