# Install the Standard EFMT on Windows:
#   1. uv (installed in ~\.local\bin if missing) puts Python 3.10 and exactly
#      the package versions in uv.lock into .venv
#   2. checks for the NimStim faces
#   3. desktop shortcuts for the practice and scan runs
# Usage, in PowerShell from this folder:
#   powershell -ExecutionPolicy Bypass -File install.ps1 [-NoShortcuts]
# Rerun after `git pull` to update .venv to the new uv.lock; it is safe to rerun.
param([switch]$NoShortcuts)
$ErrorActionPreference = 'Stop'

$Here = $PSScriptRoot
Set-Location $Here
$VenvPy = Join-Path $Here '.venv\Scripts\python.exe'

function Say($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Warn($msg) { Write-Host "`nWARNING: $msg" -ForegroundColor Yellow }
function Die($msg) { Write-Host "`nERROR: $msg" -ForegroundColor Red; exit 1 }
function Check($what) { if ($LASTEXITCODE -ne 0) { Die "$what failed; see the messages above" } }
function Find-Uv {
    $found = Get-Command uv -ErrorAction SilentlyContinue
    if (-not $found) {
        $uvExe = Join-Path $env:USERPROFILE '.local\bin\uv.exe'
        if (Test-Path $uvExe) { $found = Get-Command $uvExe }
    }
    $found
}

# 1. Python environment
$uv = Find-Uv
if (-not $uv) {
    Say "Installing uv in ~\.local\bin (it provides Python 3.10 and the task's packages)"
    & powershell -ExecutionPolicy ByPass -c 'irm https://astral.sh/uv/install.ps1 | iex'; Check 'Installing uv'
    $uv = Find-Uv
    if (-not $uv) { Die 'uv did not install; see the messages above' }
}

Say 'Installing Python 3.10 and the packages in uv.lock into .venv (the first install takes a few minutes)'
& $uv.Source sync --locked; Check 'uv sync'
& $VenvPy -c "import psychopy; print('PsychoPy', psychopy.__version__)"; Check 'Importing PsychoPy'

# 2. Faces
$line = Select-String -Path (Join-Path $Here 'Default.params') -Pattern "^face_dir\s+'(.*)'" | Select-Object -First 1
$faceDir = $line.Matches[0].Groups[1].Value -replace '^~', $env:USERPROFILE
if (-not (Test-Path $faceDir)) {
    Warn "NimStim face folder not found: $faceDir`nCopy the faces there, or set face_dir in Default.params (see README.md)."
} else {
    $n = @(Get-ChildItem $faceDir -File | Where-Object { $_.Name -match '_(AN|FE)_C\.' }).Count
    if ($n -lt 32) { Warn "Only $n closed-mouth angry/fearful faces in $faceDir (the task uses 32; see README.md)." }
}

# 3. Shortcuts
if (-not $NoShortcuts) {
    $shell = New-Object -ComObject WScript.Shell
    $desktop = [Environment]::GetFolderPath('Desktop')
    foreach ($run in @(@('practice', 'Practice'), @('scan', 'Scan'))) {
        $lnk = $shell.CreateShortcut((Join-Path $desktop "EFMT $($run[1]).lnk"))
        $lnk.TargetPath = $VenvPy
        $lnk.Arguments = "StimTool.py $($run[0])"
        $lnk.WorkingDirectory = $Here
        $lnk.Description = "Standard emotional face matching task: $($run[0]) run"
        $lnk.Save()
    }
    Say "Added 'EFMT Practice' and 'EFMT Scan' shortcuts to the desktop ($desktop)"
}

Say ("Done. Start the task with the shortcuts, or from this folder:`n" +
     "    .venv\Scripts\python.exe StimTool.py practice   (training, before scanning)`n" +
     "    .venv\Scripts\python.exe StimTool.py scan       (in the scanner; waits for the trigger)")
