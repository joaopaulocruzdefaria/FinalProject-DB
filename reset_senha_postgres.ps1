# =============================================================================
# Reset da senha do usuario 'postgres' (PostgreSQL 18)
# Define a nova senha como 123456.
#
# COMO RODAR:
#   1. Abra o PowerShell COMO ADMINISTRADOR
#      (Menu Iniciar -> digite "PowerShell" -> clique direito -> "Executar como administrador")
#   2. Cole e execute:
#      & 'C:\Users\jao\Documents\Faculdade\Periodo 5\Banco de Dados\Trabalho Final\reset_senha_postgres.ps1'
#
# O script faz backup do pg_hba.conf, troca a autenticacao para 'trust'
# temporariamente, redefine a senha e RESTAURA o pg_hba.conf original.
# =============================================================================

$ErrorActionPreference = 'Stop'

$pgBin   = 'C:\Program Files\PostgreSQL\18\bin'
$dataDir = 'C:\Program Files\PostgreSQL\18\data'
$service = 'postgresql-x64-18'
$hba     = Join-Path $dataDir 'pg_hba.conf'
$bak     = Join-Path $dataDir 'pg_hba.conf.reset-bak'
$novaSenha = '123456'

# verificar admin
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$pr = New-Object Security.Principal.WindowsPrincipal($id)
if (-not $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERRO: rode este script em um PowerShell COMO ADMINISTRADOR." -ForegroundColor Red
    exit 1
}

Write-Host "1) Fazendo backup do pg_hba.conf..." -ForegroundColor Cyan
Copy-Item $hba $bak -Force

try {
    Write-Host "2) Trocando autenticacao para 'trust' (temporario)..." -ForegroundColor Cyan
    $orig = Get-Content $hba -Raw
    # troca o metodo apenas; todas as linhas usam scram-sha-256
    $trustCfg = $orig -replace 'scram-sha-256', 'trust' -replace '\bmd5\b', 'trust'
    Set-Content -Path $hba -Value $trustCfg -Encoding ASCII

    Write-Host "3) Reiniciando o servico $service..." -ForegroundColor Cyan
    Restart-Service $service
    Start-Sleep -Seconds 3

    Write-Host "4) Redefinindo a senha do usuario postgres..." -ForegroundColor Cyan
    & "$pgBin\psql.exe" -U postgres -h localhost -d postgres -c "ALTER USER postgres WITH PASSWORD '$novaSenha';"
    if ($LASTEXITCODE -ne 0) { throw "Falha ao alterar a senha (psql exit $LASTEXITCODE)." }
}
finally {
    Write-Host "5) Restaurando o pg_hba.conf original..." -ForegroundColor Cyan
    Copy-Item $bak $hba -Force
    Remove-Item $bak -Force
    Write-Host "6) Reiniciando o servico para reativar a autenticacao por senha..." -ForegroundColor Cyan
    Restart-Service $service
    Start-Sleep -Seconds 3
}

Write-Host "7) Testando login com a nova senha..." -ForegroundColor Cyan
$env:PGPASSWORD = $novaSenha
& "$pgBin\psql.exe" -U postgres -h localhost -d postgres -w -c "SELECT 'senha OK -> ' || current_user;"
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nPRONTO! Senha do postgres agora e: $novaSenha" -ForegroundColor Green
} else {
    Write-Host "`nAlgo deu errado no teste final. Verifique as mensagens acima." -ForegroundColor Red
}
