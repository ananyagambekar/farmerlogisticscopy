# PowerShell script to stop backend and web server processes

Write-Host "🛑 Stopping server processes on ports 3000 and 5173..." -ForegroundColor Yellow

# Ports to target
$ports = @(3000, 5173)

foreach ($port in $ports) {
    $netstat = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($netstat) {
        foreach ($conn in $netstat) {
            $processId = $conn.OwningProcess
            try {
                Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                Write-Host "Stopped process $processId listening on port $port" -ForegroundColor Green
            } catch {
                Write-Host "Could not stop process $processId on port $port" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "No active process found listening on port $port" -ForegroundColor Gray
    }
}

Write-Host "`n✅ Servers stopped successfully." -ForegroundColor Green
