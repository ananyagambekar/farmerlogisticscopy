# PowerShell setup script for Dynamic Agri-Logistics monorepo

Write-Host "🌱 Setting up Dynamic Agri-Logistics Monorepo..." -ForegroundColor Green

# 1. Backend Setup
Write-Host "`n📦 Setting up Backend..." -ForegroundColor Yellow
Set-Location -Path "$PSScriptRoot/../backend"
npm install
npx prisma generate
npm run build

# 2. Web Setup
Write-Host "`n📦 Setting up Web Console..." -ForegroundColor Yellow
Set-Location -Path "$PSScriptRoot/../web"
npm install
npm run build

# 3. Mobile Setup
Write-Host "`n📦 Setting up Mobile Application..." -ForegroundColor Yellow
Set-Location -Path "$PSScriptRoot/../mobile"
flutter pub get
flutter test

Set-Location -Path "$PSScriptRoot/.."
Write-Host "`n✅ Full Monorepo Setup & Build Completed Successfully!" -ForegroundColor Green
