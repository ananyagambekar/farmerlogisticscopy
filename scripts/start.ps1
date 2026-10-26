# PowerShell launch script for backend and web servers

Write-Host "🚀 Launching Dynamic Agri-Logistics Servers..." -ForegroundColor Green

# Launch Backend in new process
$backendPath = Join-Path $PSScriptRoot "..\backend"
Write-Host "Starting Backend API server on http://localhost:3000..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$backendPath'; npm run dev"

# Launch Web in new process
$webPath = Join-Path $PSScriptRoot "..\web"
Write-Host "Starting Web Console server on http://localhost:5173..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$webPath'; npm run dev"

Write-Host "`n✅ Both Backend and Web servers launched!" -ForegroundColor Green
Write-Host "Run `health-check.ps1` to test backend readiness." -ForegroundColor Cyan
