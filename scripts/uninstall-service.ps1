param(
    [string]$ServiceName = "WorkerServiceTest",
    [string]$InstallPath = "C:\Services\WorkerServiceTest"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Desinstalando Worker Service" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Verifica se está rodando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Este script precisa ser executado como Administrador!" -ForegroundColor Red
    exit 1
}

# Verifica se o serviço existe
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if (-not $service) {
    Write-Host "Serviço '$ServiceName' não encontrado!" -ForegroundColor Yellow
    exit 0
}

# Para o serviço
Write-Host "`Parando o serviço..." -ForegroundColor Yellow
Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Remove o serviço
Write-Host "Removendo o serviço..." -ForegroundColor Yellow
sc.exe delete $ServiceName

if ($LASTEXITCODE -eq 0) {
    Write-Host "Serviço removido com sucesso!" -ForegroundColor Green
} else {
    Write-Host "Erro ao remover o serviço!" -ForegroundColor Red
}

# Remove os arquivos (opcional)
Write-Host "`Deseja remover os arquivos de instalação? (S/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq 'S' -or $response -eq 's') {
    if (Test-Path $InstallPath) {
        Write-Host "Removendo arquivos de $InstallPath..." -ForegroundColor Yellow
        Remove-Item -Path $InstallPath -Recurse -Force
        Write-Host "Arquivos removidos!" -ForegroundColor Green
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Desinstalação concluída!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan