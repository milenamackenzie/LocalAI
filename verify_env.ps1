<#
.SYNOPSIS
    Verifies the development environment for Node.js and Flutter on Windows.

.DESCRIPTION
    Checks for:
    - System Hardware (RAM, CPU)
    - Node.js (v24+)
    - Git (v2.40+)
    - Flutter (v3.19+)
    - VS Code (Installed)
    
    Generates an HTML report and provides installation instructions for missing components.

.NOTES
    Author: DevOps Agent
    Date: 2026-01-19
#>

$ErrorActionPreference = "Stop"

# Configuration / Requirements
$Config = @{
    MinRamGB = 16
    MinCpuCores = 4
    MinNodeVersion = [System.Version]"24.0.0"
    MinGitVersion = [System.Version]"2.40.0"
    MinFlutterVersion = [System.Version]"3.19.0"
    ReportPath = Join-Path $PWD "env_report.html"
}

# Global Report Array
$ReportData = @()

function Add-ReportItem {
    param (
        [string]$Category,
        [string]$Item,
        [string]$Status,
        [string]$Details,
        [string]$Remediation = ""
    )
    $Script:ReportData += [PSCustomObject]@{
        Category    = $Category
        Item        = $Item
        Status      = $Status
        Details     = $Details
        Remediation = $Remediation
    }
}

function Write-Status {
    param (
        [string]$Message,
        [string]$Status = "INFO" 
    )
    switch ($Status) {
        "PASS" { Write-Host "[PASS] $Message" -ForegroundColor Green }
        "FAIL" { Write-Host "[FAIL] $Message" -ForegroundColor Red }
        "WARN" { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
        "INFO" { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
    }
}

function Test-SoftwareVersion {
    param (
        [string]$Name,
        [string]$Command,
        [string[]]$ArgumentsList,
        [string]$Pattern,
        [System.Version]$MinVersion
    )

    try {
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $Command
        $processInfo.Arguments = $ArgumentsList -join " "
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true
        
        $process = [System.Diagnostics.Process]::Start($processInfo)
        $process.WaitForExit()
        
        $output = $process.StandardOutput.ReadToEnd()
        if ([string]::IsNullOrWhiteSpace($output)) {
            $output = $process.StandardError.ReadToEnd()
        }

        if ($output -match $Pattern) {
            $versionStr = $Matches[1]
            
            # Clean up version string (remove non-numeric suffixes if any)
            # This handles cases like "2.52.0.windows.1" -> "2.52.0" comparison logic
            # or strictly parsing standard semantic versioning
            
            try {
                $currentVersion = [System.Version]$versionStr
            }
            catch {
                # Fallback for versions that might have 4 parts or non-standard formats
                # Attempt to extract just the first 3 parts (Major.Minor.Build)
                if ($versionStr -match "(\d+\.\d+\.\d+)") {
                    $currentVersion = [System.Version]$Matches[1]
                }
                else {
                    throw "Could not parse version from string: $versionStr"
                }
            }

            if ($currentVersion -ge $MinVersion) {
                Write-Status "$Name version $versionStr meets requirement (>= $($MinVersion))" "PASS"
                Add-ReportItem "Software" $Name "PASS" "Installed: $versionStr" ""
                return $true
            }
            else {
                Write-Status "$Name version $versionStr is too old (Requires >= $($MinVersion))" "FAIL"
                Add-ReportItem "Software" $Name "FAIL" "Installed: $versionStr" "Upgrade $Name to version $($MinVersion) or later."
                return $false
            }
        }
        else {
            Write-Status "Could not determine $Name version. Output was: $output" "FAIL"
            Add-ReportItem "Software" $Name "FAIL" "Version unknown" "Reinstall $Name."
            return $false
        }
    }
    catch {
        Write-Status "$Name not found or error executing command. Exception: $_" "FAIL"
        Add-ReportItem "Software" $Name "FAIL" "Not installed or not in PATH" "Install $Name."
        return $false
    }
}

Write-Host "`n=== Development Environment Verification ===`n" -ForegroundColor Cyan
Write-Host "Current PATH: $env:PATH" -ForegroundColor Gray

# 1. System Hardware Checks
Write-Status "Checking System Hardware..." "INFO"

# RAM Check
try {
    $osInfo = Get-CimInstance Win32_ComputerSystem
    $ramBytes = $osInfo.TotalPhysicalMemory
    $ramGB = [Math]::Round($ramBytes / 1GB, 2)

    if ($ramGB -ge $Config.MinRamGB) {
        Write-Status "RAM: $ramGB GB (Requirement: >= $($Config.MinRamGB) GB)" "PASS"
        Add-ReportItem "Hardware" "RAM" "PASS" "$ramGB GB Detected" ""
    }
    else {
        Write-Status "RAM: $ramGB GB (Requirement: >= $($Config.MinRamGB) GB)" "FAIL"
        Add-ReportItem "Hardware" "RAM" "FAIL" "$ramGB GB Detected" "Upgrade RAM to at least $($Config.MinRamGB) GB."
    }
}
catch {
    Write-Status "Failed to retrieve RAM info: $_" "FAIL"
    Add-ReportItem "Hardware" "RAM" "FAIL" "Error" "Check WMI/CIM permissions."
}

# CPU Check
try {
    $cpuInfo = Get-CimInstance Win32_Processor
    $coreCount = $cpuInfo.NumberOfCores
    $cpuName = $cpuInfo.Name

    if ($coreCount -ge $Config.MinCpuCores) {
        Write-Status "CPU: $cpuName ($coreCount Cores) (Requirement: >= $($Config.MinCpuCores) Cores)" "PASS"
        Add-ReportItem "Hardware" "CPU" "PASS" "$cpuName ($coreCount Cores)" ""
    }
    else {
        Write-Status "CPU: $cpuName ($coreCount Cores) (Requirement: >= $($Config.MinCpuCores) Cores)" "FAIL"
        Add-ReportItem "Hardware" "CPU" "FAIL" "$coreCount Cores Detected" "Upgrade CPU."
    }
}
catch {
    Write-Status "Failed to retrieve CPU info: $_" "FAIL"
    Add-ReportItem "Hardware" "CPU" "FAIL" "Error" "Check WMI/CIM permissions."
}

# GPU Info (Informational)
try {
    $gpuInfo = Get-CimInstance Win32_VideoController
    foreach ($gpu in $gpuInfo) {
        Write-Status "GPU Detected: $($gpu.Name)" "INFO"
        Add-ReportItem "Hardware" "GPU" "INFO" "$($gpu.Name)" "No minimum requirement set, check driver updates."
    }
}
catch {
    Write-Status "Failed to retrieve GPU info" "WARN"
}

# 2. Software Checks
Write-Host "`n--- Software Verification ---`n" -ForegroundColor Cyan

# Node.js Check
$null = Test-SoftwareVersion -Name "Node.js" `
    -Command "node" `
    -ArgumentsList @("-v") `
    -Pattern "v(\d+\.\d+\.\d+)" `
    -MinVersion $Config.MinNodeVersion

# Git Check
$null = Test-SoftwareVersion -Name "Git" `
    -Command "git" `
    -ArgumentsList @("--version") `
    -Pattern "version (\d+\.\d+\.\d+)" `
    -MinVersion $Config.MinGitVersion

# Flutter Check
# Flutter output is often on multiple lines or stderr, handled by generic reader
# Attempt to find flutter in path first
$flutterCmdStr = "flutter"
$flutterExecutable = Get-Command "flutter", "flutter.bat" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($flutterExecutable) {
    $flutterCmdStr = $flutterExecutable.Source
} elseif (Test-Path "C:\src\flutter\bin\flutter.bat") {
    $flutterCmdStr = "C:\src\flutter\bin\flutter.bat"
}

$null = Test-SoftwareVersion -Name "Flutter" `
    -Command $flutterCmdStr `
    -ArgumentsList @("--version") `
    -Pattern "Flutter (\d+\.\d+\.\d+)" `
    -MinVersion $Config.MinFlutterVersion

# VS Code Check (Path often differs, assume 'code' is in PATH)
try {
    $codePath = Get-Command "code", "code.cmd", "code.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($codePath) {
        # VS Code version is usually first line: 1.85.1
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        # Use cmd /c to ensure batch files (.cmd) run correctly
        $processInfo.FileName = "cmd"
        $processInfo.Arguments = "/c code --version"
        $processInfo.RedirectStandardOutput = $true
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true
        $process = [System.Diagnostics.Process]::Start($processInfo)
        $process.WaitForExit()
        $output = $process.StandardOutput.ReadToEnd()
        
        if ($output -match "(\d+\.\d+\.\d+)") {
            $codeVer = $Matches[1]
            Write-Status "VS Code version $codeVer found." "PASS"
            Add-ReportItem "Software" "VS Code" "PASS" "Installed: $codeVer" ""
        } else {
            Write-Status "VS Code found but version unclear." "WARN"
            Add-ReportItem "Software" "VS Code" "WARN" "Installed but version unreadable" "Check 'code --version' manually."
        }
    }
    else {
        throw "VS Code not found in PATH"
    }
}
catch {
    Write-Status "VS Code not found in PATH." "FAIL"
    Add-ReportItem "Software" "VS Code" "FAIL" "Not Found" "Install VS Code and add to PATH."
}


# 3. HTML Report Generation
Write-Host "`nGenerating Report..." -ForegroundColor Cyan

$css = @"
<style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f4f4f4; }
    h1 { color: #2c3e50; }
    table { border-collapse: collapse; width: 100%; background-color: white; box-shadow: 0 1px 3px rgba(0,0,0,0.2); }
    th, td { text-align: left; padding: 12px; border-bottom: 1px solid #ddd; }
    th { background-color: #2980b9; color: white; }
    tr:hover { background-color: #f5f5f5; }
    .status-pass { color: green; font-weight: bold; }
    .status-fail { color: red; font-weight: bold; }
    .status-warn { color: orange; font-weight: bold; }
    .status-info { color: #3498db; font-weight: bold; }
    .footer { margin-top: 20px; font-size: 0.9em; color: #7f8c8d; }
</style>
"@

$htmlRows = ""
foreach ($row in $ReportData) {
    $class = "status-$($row.Status.ToLower())"
    $htmlRows += @"
    <tr>
        <td>$($row.Category)</td>
        <td>$($row.Item)</td>
        <td class='$class'>$($row.Status)</td>
        <td>$($row.Details)</td>
        <td>$($row.Remediation)</td>
    </tr>
"@
}

$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Environment Verification Report</title>
    $css
</head>
<body>
    <h1>Development Environment Report</h1>
    <p>Generated on $(Get-Date)</p>
    <table>
        <thead>
            <tr>
                <th>Category</th>
                <th>Item</th>
                <th>Status</th>
                <th>Details</th>
                <th>Remediation / Actions</th>
            </tr>
        </thead>
        <tbody>
            $htmlRows
        </tbody>
    </table>
    <div class="footer">
        <p>System: $env:COMPUTERNAME | User: $env:USERNAME</p>
    </div>
</body>
</html>
"@

$htmlContent | Out-File -FilePath $Config.ReportPath -Encoding utf8
Write-Status "Report saved to: $($Config.ReportPath)" "INFO"

if ($ReportData.Status -contains "FAIL") {
    Write-Host "`n[ACTION REQUIRED] Some checks failed. Please review the report at $($Config.ReportPath) for instructions." -ForegroundColor Red
} else {
    Write-Host "`n[SUCCESS] Environment looks good! Ready for development." -ForegroundColor Green
}
