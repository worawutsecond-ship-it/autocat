param([string]$ClientWorkspace = "$env:LOCALAPPDATA\Real\workspace")
$ErrorActionPreference = 'Stop'
$publicRoot = 'https://raw.githubusercontent.com/worawutsecond-ship-it/autocat/main/'
$config = (Invoke-WebRequest -Uri ($publicRoot + 'config.json?t=' + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()) -UseBasicParsing).Content | ConvertFrom-Json
$serviceUri = $null
if (-not [Uri]::TryCreate([string]$config.licenseServer,[UriKind]::Absolute,[ref]$serviceUri) -or $serviceUri.Scheme -ne 'https' -or $serviceUri.IsLoopback -or $serviceUri.UserInfo -or $serviceUri.AbsolutePath -ne '/' -or $serviceUri.Query -or $serviceUri.Fragment) {
    throw 'The administrator has not configured a public HTTPS license server yet.'
}
$targetDir = [System.IO.Path]::GetFullPath($ClientWorkspace)
if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) { throw 'Real workspace not found. Set -ClientWorkspace to the correct workspace.' }
$loaderSource = (Invoke-WebRequest -Uri ($publicRoot + 'loader.luau') -UseBasicParsing).Content
if (-not $loaderSource.Contains('AUTOCAT public entry point')) { throw 'Loader download failed.' }
$machineIdentity = (Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Cryptography' -Name MachineGuid).MachineGuid
if ([string]::IsNullOrWhiteSpace($machineIdentity)) { throw 'Windows installation identifier is unavailable.' }
$hasher = [System.Security.Cryptography.SHA256]::Create()
try { $fingerprint = [BitConverter]::ToString($hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes('rivals-license:v1:' + $machineIdentity))).Replace('-','').ToLowerInvariant() } finally { $hasher.Dispose() }
$encoding = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText((Join-Path $targetDir 'rivals-license-device.json'),(@{deviceId=$fingerprint;source='windows-installation'} | ConvertTo-Json -Compress),$encoding)
$loaderPath = Join-Path $targetDir 'RIVALS-License-Loader.luau'
[System.IO.File]::WriteAllText($loaderPath,$loaderSource,$encoding)
Write-Output "Installed: $loaderPath"
Write-Output 'Open the loader in Real, Execute, then enter your redeemed license key.'
