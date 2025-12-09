# install-service.ps1
# Script para instalar o Worker Service no Windows

param(
    [string]$ServiceName = "WorkerServiceTest",
    [string]$InstallPath = "C:\Services\WorkerServiceTest"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Instalando Worker Service" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Verifica se está rodando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Este script precisa ser executado como Administrador!" -ForegroundColor Red
    exit 1
}

# Build da aplicação
Write-Host "`Fazendo build da aplicação..." -ForegroundColor Yellow
dotnet publish -c Release -o $InstallPath --runtime win-x64 --self-contained false

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao fazer build da aplicação!" -ForegroundColor Red
    exit 1
}

# Verifica se o serviço já existe
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($service) {
    Write-Host "`Serviço '$ServiceName' já existe!" -ForegroundColor Yellow
    Write-Host "Parando o serviço..." -ForegroundColor Yellow
    Stop-Service -Name $ServiceName -Force
    Start-Sleep -Seconds 3
    
    Write-Host "Removendo o serviço antigo..." -ForegroundColor Yellow
    sc.exe delete $ServiceName
    Start-Sleep -Seconds 2
}

# Cria o novo serviço
Write-Host "`Criando o serviço Windows..." -ForegroundColor Yellow
$exePath = Join-Path $InstallPath "WorkerServiceTest.exe"

New-Service -Name $ServiceName `
    -BinaryPathName $exePath `
    -DisplayName "Worker Service Test" `
    -Description "Serviço de teste Worker .NET 8 com CI/CD" `
    -StartupType Automatic

# Inicia o serviço
Write-Host "`Iniciando o serviço..." -ForegroundColor Yellow
Start-Service -Name $ServiceName
Start-Sleep -Seconds 3

# Verifica o status
$service = Get-Service -Name $ServiceName
Write-Host "`n========================================" -ForegroundColor Cyan
if ($service.Status -eq 'Running') {
    Write-Host "Serviço instalado e iniciado com sucesso!" -ForegroundColor Green
    Write-Host "Status: $($service.Status)" -ForegroundColor Green
} else {
    Write-Host "Serviço instalado mas não está rodando!" -ForegroundColor Red
    Write-Host "Status: $($service.Status)" -ForegroundColor Red
}
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`Comandos úteis:" -ForegroundColor Cyan
Write-Host "   Ver status:    Get-Service -Name $ServiceName" -ForegroundColor Gray
Write-Host "   Parar:         Stop-Service -Name $ServiceName" -ForegroundColor Gray
Write-Host "   Iniciar:       Start-Service -Name $ServiceName" -ForegroundColor Gray
Write-Host "   Ver logs:      Get-EventLog -LogName Application -Source $ServiceName -Newest 10" -ForegroundColor Gray