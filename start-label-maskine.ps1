$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$port = 5173
$url = "http://localhost:$port/index.html"

$lanIp = Get-CimInstance Win32_NetworkAdapterConfiguration |
  Where-Object { $_.IPEnabled } |
  ForEach-Object { $_.IPAddress } |
  Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' -and $_ -ne '127.0.0.1' -and $_ -notlike '169.254.*' } |
  Select-Object -First 1

$lanUrl = if ($lanIp) { "http://$lanIp:$port/index.html" } else { $url }

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
  $pythonCmd = Get-Command py -ErrorAction SilentlyContinue
}

if (-not $pythonCmd) {
  Write-Host 'Python blev ikke fundet. Installer Python 3 eller start en webserver manuelt.' -ForegroundColor Yellow
  Write-Host 'Tryk Enter for at afslutte...'
  [void][System.Console]::ReadLine()
  exit 1
}

# Start lokal webserver i nyt vindue
if ($pythonCmd.Name -eq 'py') {
  Start-Process -FilePath 'powershell.exe' -ArgumentList "-NoExit", "-Command", "Set-Location '$root'; py -m http.server $port --bind 0.0.0.0"
} else {
  Start-Process -FilePath 'powershell.exe' -ArgumentList "-NoExit", "-Command", "Set-Location '$root'; python -m http.server $port --bind 0.0.0.0"
}

Start-Sleep -Seconds 2
Start-Process $url

Write-Host "Label Maskine startet på $url" -ForegroundColor Green
Write-Host "LAN-link til kollegaer: $lanUrl" -ForegroundColor Cyan
Write-Host 'Installer i Edge: ... > Apps > Installer denne side som en app'
