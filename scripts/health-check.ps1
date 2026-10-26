# PowerShell health check script for Dynamic Agri-Logistics backend API

$healthUrl = "http://localhost:3000/api/v1/health"

Write-Host "🔍 Checking Backend Health Endpoint at $healthUrl..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $healthUrl -Method Get -TimeoutSec 5
    Write-Host "`n✅ Backend API Health Status:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 4
} catch {
    Write-Host "`n❌ Backend API is not responding or offline on port 3000." -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
}
