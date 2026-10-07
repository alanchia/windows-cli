[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [Alias('Search', 'Name')]
    [string]$SearchCriteria
)

$registryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$matches = @(
    Get-ItemProperty -Path $registryPaths -ErrorAction SilentlyContinue |
        Where-Object {
            $_.DisplayName -and
            ($_.DisplayName -like "*$SearchCriteria*" -or
             $_.Publisher -like "*$SearchCriteria*" -or
             $_.PSChildName -like "*$SearchCriteria*")
        } |
        Sort-Object DisplayName, PSChildName |
        Select-Object DisplayName, Publisher, PSChildName, UninstallString, QuietUninstallString
)

if ($matches.Count -eq 0) {
    Write-Host "No installed applications matched '$SearchCriteria'."
    exit 0
}

Write-Host "`nMatches:`n" -ForegroundColor Cyan
$matches |
    Select-Object DisplayName, Publisher, PSChildName |
    Format-Table -AutoSize |
    Out-Host

$continue = Read-Host "Continue and review these applications for uninstall? (y/N)"
if ($continue -notmatch '^(?i)y(?:es)?$') {
    Write-Host 'No changes were made.'
    exit 0
}

foreach ($application in $matches) {
    $guid = $application.PSChildName
    $uninstallCommand = $application.QuietUninstallString
    if ([string]::IsNullOrWhiteSpace($uninstallCommand)) {
        $uninstallCommand = $application.UninstallString
    }

    if ([string]::IsNullOrWhiteSpace($uninstallCommand)) {
        Write-Warning "Skipping '$($application.DisplayName)' ($guid): no uninstall command was found."
        continue
    }

    Write-Host "`n$($application.DisplayName) [$guid]" -ForegroundColor Yellow
    Write-Host "Command: $uninstallCommand"
    $uninstall = Read-Host 'Uninstall this application? (y/N)'
    if ($uninstall -notmatch '^(?i)y(?:es)?$') {
        Write-Host 'Skipped.'
        continue
    }

    try {
        # Invoke through cmd.exe so quoted paths and MSI command lines are handled as stored.
        $process = Start-Process -FilePath 'cmd.exe' -ArgumentList '/d', '/s', '/c', $uninstallCommand -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Host 'Uninstall command completed.' -ForegroundColor Green
        } else {
            Write-Warning "Uninstall command exited with code $($process.ExitCode)."
        }
    } catch {
        Write-Error "Could not start the uninstall command: $($_.Exception.Message)"
    }
}
