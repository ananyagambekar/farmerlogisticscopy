# Dynamic Agri-Logistics Health Check Script
$ErrorActionPreference = "Continue"

Write-Host "🩺 Dynamic Agri-Logistics Health Check..." -ForegroundColor Cyan

try {
    $res = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/health" -Method Get -TimeoutSec 5
    Write-Host "✅ Backend API is UP & ONLINE!" -ForegroundColor Green
    Write-Host "  - Service: $($res.service)" -ForegroundColor White
    Write-Host "  - Version: $($res.version)" -ForegroundColor White
    Write-Host "  - Environment: $($res.environment)" -ForegroundColor White
    Write-Host "  - Server Timestamp: $($res.timestamp)" -ForegroundColor White
} catch {
    Write-Host "❌ Backend API is not responding on http://localhost:3000/api/v1/health" -ForegroundColor Red
    Write-Host "   Please ensure the backend process is running (`npm run dev` inside backend/)." -ForegroundColor Yellow
}
