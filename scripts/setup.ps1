# Dynamic Agri-Logistics Setup Script
$ErrorActionPreference = "Stop"

Write-Host "🌱 Starting Dynamic Agri-Logistics Environment Setup..." -ForegroundColor Green

# 1. Check tools
Write-Host "🔍 Checking required development toolchain..." -ForegroundColor Cyan
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "  ✅ Node.js: $(node --version)" -ForegroundColor Green
} else {
    Write-Host "  ❌ Node.js is missing. Please install Node.js v18+" -ForegroundColor Red
}

if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "  ✅ Flutter: $(flutter --version | Select-Object -First 1)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ Flutter CLI not detected in PATH. Mobile app commands will require Flutter." -ForegroundColor Yellow
}

# 2. Setup Backend
Write-Host "`n📦 Installing Backend Dependencies & Generating Prisma Client..." -ForegroundColor Cyan
Set-Location -Path "$PSScriptRoot/../backend"
npm install
npx prisma generate

# 3. Setup Web Dashboard
Write-Host "`n📦 Installing Web Dashboard Dependencies..." -ForegroundColor Cyan
Set-Location -Path "$PSScriptRoot/../web"
npm install

# 4. Setup Mobile Flutter App
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "`n📱 Fetching Flutter Mobile Dependencies..." -ForegroundColor Cyan
    Set-Location -Path "$PSScriptRoot/../mobile"
    flutter pub get
}

# 5. Configure local.properties for Android
$androidSdkPath = "C:\Users\HP\AppData\Local\Android\Sdk"
$localPropsPath = "$PSScriptRoot/../mobile/android/local.properties"
if (Test-Path $androidSdkPath) {
    Set-Content -Path $localPropsPath -Value "sdk.dir=C:\Users\HP\AppData\Local\Android\Sdk`nflutter.sdk=C:\flutter`nflutter.buildMode=debug`nflutter.versionName=1.0.0`nflutter.versionCode=1"
    Write-Host "  ✅ Android local.properties configured." -ForegroundColor Green
}

Set-Location -Path "$PSScriptRoot/.."
Write-Host "`n✨ Dynamic Agri-Logistics Setup Complete!" -ForegroundColor Green
