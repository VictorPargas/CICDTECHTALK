# check-service.ps1
# Script para verificar o status e logs do Worker Service

param(
    [string]$ServiceName = "WorkerServiceTest",
    [int]$LogEntries = 20
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Status do Worker Service" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Verifica se o serviço existe
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if (-not $service) {
    Write-Host "`n❌ Serviço '$ServiceName' não encontrado!" -ForegroundColor Red
    Write-Host "Execute o script install-service.ps1 primeiro." -ForegroundColor Yellow
    exit 1
}

# Mostra informações do serviço
Write-Host "`Informações do Serviço:" -ForegroundColor Yellow
Write-Host "   Nome:           $($service.Name)" -ForegroundColor White
Write-Host "   Display Name:   $($service.DisplayName)" -ForegroundColor White
Write-Host "   Status:         $($service.Status)" -ForegroundColor $(if ($service.Status -eq 'Running') { 'Green' } else { 'Red' })
Write-Host "   Startup Type:   $($service.StartType)" -ForegroundColor White

# Mostra logs recentes
Write-Host "`Últimos $LogEntries eventos do serviço:" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

try {
    $events = Get-EventLog -LogName Application -Source $ServiceName -Newest $LogEntries -ErrorAction Stop
    
    if ($events) {
        foreach ($event in $events) {
            $color = switch ($event.EntryType) {
                'Error' { 'Red' }
                'Warning' { 'Yellow' }
                'Information' { 'Green' }
                default { 'White' }
            }
            
            Write-Host "$($event.TimeGenerated.ToString('yyyy-MM-dd HH:mm:ss')) " -NoNewline -ForegroundColor Gray
            Write-Host "[$($event.EntryType)]" -NoNewline -ForegroundColor $color
            Write-Host " $($event.Message)" -ForegroundColor White
        }
    } else {
        Write-Host "Nenhum evento encontrado." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Não foi possível acessar os logs: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Comandos úteis
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Comandos úteis:" -ForegroundColor Cyan
Write-Host "   Parar:         Stop-Service -Name $ServiceName" -ForegroundColor Gray
Write-Host "   Iniciar:       Start-Service -Name $ServiceName" -ForegroundColor Gray
Write-Host "   Reiniciar:     Restart-Service -Name $ServiceName" -ForegroundColor Gray
Write-Host "   Ver logs:      Get-EventLog -LogName Application -Source $ServiceName -Newest 10" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan