param(
    [string]$DfsRootName="\\Adatum.com\Shared",
    [string]$DfsFolderName="Projects",
    [string]$DfsFolderTarget="\\FS01\Projects"
)

# --- Helper: Extract server and share name from the target path
if ($DfsFolderTarget -match '\\\\([^\\]+)\\(.+)$') {
    $TargetServer = $matches[1]
    $ShareName = $matches[2]
} else {
    Write-Error "Invalid format for DfsFolderTarget: $DfsFolderTarget"
    exit 1
}

# --- Determine local folder path (assume standard path on target host)
$LocalFolderPath = "C:\DFSRoots\$ShareName"

Write-Host "🔹 DFS Root: $DfsRootName"
Write-Host "🔹 DFS Folder Name: $DfsFolderName"
Write-Host "🔹 DFS Target: $DfsFolderTarget"
Write-Host "🔹 Local Folder Path: $LocalFolderPath"
Write-Host ""

# --- Check if running on the target server
$CurrentHost = $env:COMPUTERNAME

$dfsRoot = Get-DfsnRoot -Path $DfsRootName -ErrorAction SilentlyContinue
if (-not $dfsRoot) {
    Write-Host "🪜 DFS root not found — creating: $DfsRootName"
    New-DfsnRoot -TargetPath "\\$TargetServer\$($DfsRootName.Split('\')[-1])" `
                 -Type DomainV2 `
                 -Path $DfsRootName
} else {
    Write-Host "✅ DFS root already exists: $DfsRootName"
}

if ($CurrentHost -ieq $TargetServer) {
    # --- Step 1. Ensure local folder exists
    if (-not (Test-Path $LocalFolderPath)) {
        Write-Host "📁 Creating local folder: $LocalFolderPath"
        New-Item -ItemType Directory -Path $LocalFolderPath -Force | Out-Null
    } else {
        Write-Host "✅ Local folder already exists."
    }

    # --- Step 2. Ensure SMB share exists
    $existingShare = Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue
    if (-not $existingShare) {
        Write-Host "🔗 Creating SMB share: \\$TargetServer\$ShareName"
        New-SmbShare -Name $ShareName -Path $LocalFolderPath -FullAccess "Domain Users" | Out-Null
    } else {
        Write-Host "✅ SMB share \\$TargetServer\$ShareName already exists."
    }
} else {
    Write-Host "⚠️ This script is running on $CurrentHost, but target is $TargetServer."
    Write-Host "    (Local folder and share creation skipped — run on target if needed.)"
}

# --- Step 3. Ensure DFS Folder exists
$DfsFolderPath = Join-Path $DfsRootName $DfsFolderName

$dfsFolder = Get-DfsnFolder -Path $DfsFolderPath -ErrorAction SilentlyContinue
if (-not $dfsFolder) {
    Write-Host "🗂️ Creating DFS folder: $DfsFolderPath"
    New-DfsnFolder -Path $DfsFolderPath -TargetPath $DfsFolderTarget -State Online -ErrorAction Stop
    
} else {
    Write-Host "✅ DFS folder already exists: $DfsFolderPath"
    # --- Step 4. Add DFS target if missing
    $existingTarget = Get-DfsnFolderTarget -Path $DfsFolderPath | Where-Object { $_.TargetPath -eq $DfsFolderTarget }
    if (-not $existingTarget) {
        Write-Host "➕ Adding DFS folder target: $DfsFolderTarget"
        New-DfsnFolderTarget -Path $DfsFolderPath -TargetPath $DfsFolderTarget
    } else {
        Write-Host "✅ DFS folder target already exists: $DfsFolderTarget"
    }
}

Write-Host ""
Write-Host "🎉 DFS folder setup complete!"
