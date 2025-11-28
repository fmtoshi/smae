#!/bin/bash
# ============================================
# SMAE - Configurar Nginx e SSL na VPS
# Execute: sudo bash setup-vps-nginx.sh seu-dominio.com
# ============================================

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Uso: sudo bash setup-vps-nginx.sh seu-dominio.com"
    exit 1
fi

echo "============================================"
echo "   SMAE - Configurando Nginx para $DOMAIN"
echo "============================================"

# Instalar Nginx e Certbot
echo "[1/4] Instalando Nginx e Certbot..."
apt-get update
apt-get install -y nginx certbot python3-certbot-nginx

# Criar configuracao do Nginx
echo "[2/4] Configurando Nginx..."
cat > /etc/nginx/sites-available/smae <<EOF
server {
    server_name $DOMAIN www.$DOMAIN;

    client_max_body_size 5000M;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_http_version 1.1;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_http_version 1.1;
    }
}
EOF

# Ativar site
ln -sf /etc/nginx/sites-available/smae /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Testar configuracao
echo "[3/4] Testando configuracao..."
nginx -t

if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "Nginx configurado com sucesso!"
else
    echo "ERRO: Configuracao do Nginx invalida!"
    exit 1
fi

# Obter certificado SSL
echo "[4/4] Obtendo certificado SSL..."
certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

echo ""
echo "============================================"
echo "   Configuracao concluida!"
echo "============================================"
echo ""
echo "Acesse: https://$DOMAIN"
echo ""


