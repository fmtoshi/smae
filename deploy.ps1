# ============================================
# SMAE - Script de Deploy Completo
# Prefeitura de Itapevi
# ============================================

param(
    [switch]$FirstDeploy,
    [switch]$UpdateOnly,
    [switch]$Local
)

# Configuracoes da VPS
$VPS_HOST = "162.240.228.174"
$VPS_USER = "root"
$VPS_PORT = "22022"
$VPS_PASSWORD = "n4k4mur4T@Z"
$DOMAIN = "projetos.itapevi.sp.gov.br"
$SSL_EMAIL = "francis@toshimitsu.com.br"
$REMOTE_PATH = "/home/smae/smae"

# Git
$GIT_REPO = "https://github.com/fmtoshi/smae.git"
$GIT_USER = "fmtoshi"
$GIT_EMAIL = "francis@toshimitsu.com.br"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   SMAE - Deploy para Producao" -ForegroundColor Cyan
Write-Host "   $DOMAIN" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Funcao para executar comando SSH
function Invoke-SSHCommand {
    param([string]$Command)
    $sshCmd = "ssh -o StrictHostKeyChecking=no -p $VPS_PORT $VPS_USER@$VPS_HOST `"$Command`""
    Invoke-Expression $sshCmd
}

if ($Local) {
    Write-Host "[LOCAL] Iniciando ambiente de desenvolvimento..." -ForegroundColor Green
    Copy-Item ".env.development" ".env" -Force
    docker compose --profile fullStack up --build -d
    Write-Host ""
    Write-Host "Ambiente local iniciado!" -ForegroundColor Green
    Write-Host "Acesse: http://localhost:8080" -ForegroundColor Yellow
    exit 0
}

# Verificar se eh primeiro deploy
if ($FirstDeploy) {
    Write-Host "[1/6] Primeiro deploy - Configurando VPS..." -ForegroundColor Yellow
    
    $setupScript = @"
# Instalar Docker
apt-get update
apt-get install -y ca-certificates curl git
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=`$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu `$(. /etc/os-release && echo \`$VERSION_CODENAME) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Instalar Nginx e Certbot
apt-get install -y nginx certbot python3-certbot-nginx

# Criar diretorio
mkdir -p /home/smae
cd /home/smae

# Clonar repositorio
git clone $GIT_REPO
cd smae

# Configurar git
git config user.name "$GIT_USER"
git config user.email "$GIT_EMAIL"
"@
    
    Write-Host "Executando setup inicial na VPS..."
    Invoke-SSHCommand -Command $setupScript
}

# Commit e push local
Write-Host "[2/6] Verificando alteracoes locais..." -ForegroundColor Yellow
$status = git status --porcelain
if ($status) {
    Write-Host "Commitando alteracoes..." -ForegroundColor Yellow
    git add .
    git commit -m "Deploy $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}
git push origin main

# Copiar .env.production para VPS
Write-Host "[3/6] Enviando configuracoes para VPS..." -ForegroundColor Yellow
scp -P $VPS_PORT ".env.production" "${VPS_USER}@${VPS_HOST}:${REMOTE_PATH}/.env"

# Atualizar nginx.conf do frontend
Write-Host "[4/6] Atualizando configuracao do frontend..." -ForegroundColor Yellow
$nginxUpdate = @"
cd $REMOTE_PATH
sed -i 's/server_name _;/server_name $DOMAIN;/g' frontend/docker/nginx.conf
sed -i 's/server_name my-custom-host;/server_name $DOMAIN;/g' frontend/docker/nginx.conf
"@
Invoke-SSHCommand -Command $nginxUpdate

# Pull e rebuild na VPS
Write-Host "[5/6] Atualizando e reconstruindo containers..." -ForegroundColor Yellow
$deployScript = @"
cd $REMOTE_PATH
git pull origin main
docker compose --profile fullStack up --build -d
docker ps --format 'table {{.Names}}\t{{.Status}}'
"@
Invoke-SSHCommand -Command $deployScript

# Configurar Nginx e SSL (apenas primeiro deploy)
if ($FirstDeploy) {
    Write-Host "[6/6] Configurando Nginx e SSL..." -ForegroundColor Yellow
    
    $nginxConfig = @"
cat > /etc/nginx/sites-available/smae << 'NGINX'
server {
    server_name $DOMAIN;
    client_max_body_size 5000M;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \`$host;
        proxy_set_header X-Real-IP \`$remote_addr;
        proxy_set_header X-Forwarded-For \`$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \`$scheme;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_http_version 1.1;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host \`$host;
        proxy_set_header X-Real-IP \`$remote_addr;
        proxy_set_header X-Forwarded-For \`$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \`$scheme;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_http_version 1.1;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/smae /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

# SSL
certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $SSL_EMAIL
"@
    Invoke-SSHCommand -Command $nginxConfig
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   Deploy concluido!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Acesse: https://$DOMAIN" -ForegroundColor Yellow
Write-Host ""
Write-Host "Login padrao:" -ForegroundColor Cyan
Write-Host "  Email: superadmin@admin.com"
Write-Host "  Senha: !286!QDM7H"
Write-Host ""

