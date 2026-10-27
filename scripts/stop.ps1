# Dynamic Agri-Logistics Stop Script
$ErrorActionPreference = "Continue"

Write-Host "🛑 Stopping Dynamic Agri-Logistics Local Development Services..." -ForegroundColor Yellow

# Find node processes running ts-node or index.ts or vite
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue

if ($nodeProcesses) {
    Write-Host "  Stopping running Node.js development servers..." -ForegroundColor Cyan
    foreach ($proc in $nodeProcesses) {
        try {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    Write-Host "  ✅ Node processes stopped." -ForegroundColor Green
} else {
    Write-Host "  No active Node.js processes found." -ForegroundColor Gray
}

Write-Host "`n✨ Services stopped successfully!" -ForegroundColor Green
