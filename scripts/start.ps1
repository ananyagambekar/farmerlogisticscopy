# Dynamic Agri-Logistics Start Services Script
$ErrorActionPreference = "Continue"

Write-Host "🚀 Starting Dynamic Agri-Logistics Services..." -ForegroundColor Green

# Unset conflicting Android environment variables if present
$env:ANDROID_PREFS_ROOT = $null

# 1. Start Backend in Background Process
$backendPath = Join-Path $PSScriptRoot "..\backend"
Write-Host "🌱 Launching Node.js Express Backend on http://localhost:3000..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$backendPath'; npm run dev" -WindowStyle Normal

Start-Sleep -Seconds 3

# 2. Start Web Dashboard in Background Process
$webPath = Join-Path $PSScriptRoot "..\web"
Write-Host "💻 Launching React Vite Web Dashboard on http://localhost:5173..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$webPath'; npm run dev" -WindowStyle Normal

Start-Sleep -Seconds 2

# 3. Check Backend Health
Write-Host "`n🩺 Checking Backend Health Endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/health" -Method Get
    Write-Host "  ✅ Backend Health Status: $($response.status)" -ForegroundColor Green
    Write-Host "  Service: $($response.service)" -ForegroundColor Gray
} catch {
    Write-Host "  ⚠️ Backend still initializing. Try running .\scripts\health-check.ps1 in a few seconds." -ForegroundColor Yellow
}

Write-Host "`n🎉 All services initiated! Access points:" -ForegroundColor Green
Write-Host "  - Backend REST API: http://localhost:3000/api/v1" -ForegroundColor White
Write-Host "  - Web Operations Dashboard: http://localhost:5173" -ForegroundColor White
Write-Host "  - Android Emulator API Host: http://10.0.2.2:3000/api/v1" -ForegroundColor White
