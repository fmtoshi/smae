# ============================================
# SMAE - Script de Deploy para VPS
# Execute: .\deploy-vps.ps1 -VPS "usuario@sua-vps.com"
# ============================================

param(
    [Parameter(Mandatory=$true)]
    [string]$VPS,
    
    [string]$RemotePath = "/home/smae/smae",
    
    [switch]$FirstDeploy,
    
    [switch]$SyncEnv
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   SMAE - Deploy para VPS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se tem alteracoes locais
Write-Host "[1/5] Verificando alteracoes locais..." -ForegroundColor Yellow
$status = git status --porcelain
if ($status) {
    Write-Host "Existem alteracoes nao commitadas:" -ForegroundColor Red
    Write-Host $status
    $confirm = Read-Host "Deseja fazer commit agora? (s/n)"
    if ($confirm -eq "s") {
        $msg = Read-Host "Mensagem do commit"
        git add .
        git commit -m $msg
    }
}

# Push para o repositorio
Write-Host "[2/5] Enviando para repositorio Git..." -ForegroundColor Yellow
git push origin main

# Sincronizar .env se solicitado
if ($SyncEnv) {
    Write-Host "[3/5] Sincronizando arquivo .env..." -ForegroundColor Yellow
    scp .\.env "${VPS}:${RemotePath}/.env"
}

# Executar deploy na VPS
Write-Host "[4/5] Executando deploy na VPS..." -ForegroundColor Yellow

$deployScript = @"
cd $RemotePath
echo '>> Baixando atualizacoes...'
git pull origin main
echo '>> Reconstruindo containers...'
sudo docker compose --profile fullStack up --build -d
echo '>> Verificando status...'
sudo docker ps --format 'table {{.Names}}\t{{.Status}}'
echo '>> Deploy concluido!'
"@

ssh $VPS $deployScript

Write-Host ""
Write-Host "[5/5] Deploy finalizado!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan


