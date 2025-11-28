# 🚀 SMAE - Guia de Deploy Itapevi

## Configurações

| Ambiente | URL |
|----------|-----|
| **Desenvolvimento** | http://localhost:8080 |
| **Produção** | https://projetos.itapevi.sp.gov.br |

---

## 📁 Arquivos Criados

| Arquivo | Descrição |
|---------|-----------|
| `.env` | Configuração atual (desenvolvimento) |
| `.env.production` | Configuração de produção |
| `.env.development` | Configuração de desenvolvimento |
| `deploy.ps1` | Script de deploy automatizado |
| `configurar-smtp-producao.sql` | SQL para configurar SMTP real |

---

## 🖥️ Ambiente de Desenvolvimento (Local)

### Iniciar
```powershell
cd D:\SMAE
docker compose --profile fullStack up -d
```

### Parar
```powershell
docker compose --profile fullStack down
```

### Acessar
- **Frontend:** http://localhost:8080
- **API:** http://localhost:3001
- **MinIO:** http://localhost:9001
- **Metabase:** http://localhost:3003

---

## 🌐 Deploy para Produção (VPS)

### Primeiro Deploy (única vez)
```powershell
cd D:\SMAE
.\deploy.ps1 -FirstDeploy
```

### Atualizações subsequentes
```powershell
cd D:\SMAE
.\deploy.ps1
```

### Apenas atualizar código (sem rebuild)
```powershell
cd D:\SMAE
.\deploy.ps1 -UpdateOnly
```

---

## 🔄 Sincronização com Git

### Enviar alterações para seu repositório
```powershell
cd D:\SMAE
git add .
git commit -m "Sua mensagem"
git push origin main
```

### Receber atualizações do projeto original
```powershell
cd D:\SMAE
git fetch upstream
git merge upstream/main
git push origin main
```

---

## 📧 Configurar SMTP de Produção

Após o primeiro deploy, execute na VPS:
```bash
docker exec smae_postgres psql -U smae -d smae_dev_persistent -f /tmp/configurar-smtp.sql
```

Ou manualmente:
```bash
docker exec -it smae_postgres psql -U smae -d smae_dev_persistent

# Dentro do psql:
UPDATE emaildb_config 
SET config = jsonb_set(config, '{sender,args}', 
  '{"host": "mail.mudtech.com.br", "port": 465, "ssl": 1, 
    "sasl_username": "sistema@mudtech.com.br", 
    "sasl_password": "*EbJ8;14^541"}'::jsonb) 
WHERE id = (SELECT id FROM emaildb_config WHERE ativo = true LIMIT 1);
```

---

## 🔐 Credenciais

### Aplicação SMAE
- **Email:** superadmin@admin.com
- **Senha:** !286!QDM7H

### VPS
- **Host:** 162.240.228.174
- **Porta SSH:** 22022
- **Usuário:** root

### MinIO (Produção)
- **Usuário:** minioadmin
- **Senha:** Itapevi2024Minio!Secure

### Metabase (Produção)
- **Banco:** metabase
- **Usuário:** postgres
- **Senha:** MetabaseItapevi2024!

---

## 🛠️ Comandos Úteis na VPS

### Verificar containers
```bash
docker ps
```

### Ver logs da API
```bash
docker logs -f smae_api --tail 100
```

### Reiniciar serviço específico
```bash
docker restart smae_api
docker restart smae_web
```

### Acessar banco de dados
```bash
docker exec -it smae_postgres psql -U smae -d smae_dev_persistent
```

### Rebuild completo
```bash
cd /home/smae/smae
docker compose --profile fullStack down
docker compose --profile fullStack up --build -d
```

---

## ⚠️ Importante

1. **PRISMA_FIELD_ENCRYPTION_KEY** - Nunca altere após ter dados criptografados
2. **Backup** - Faça backup do banco antes de atualizações
3. **DNS** - O domínio deve apontar para 162.240.228.174 antes do SSL
4. **Firewall** - Portas 80 e 443 devem estar abertas

---

## 📞 Suporte

- **Git:** https://github.com/fmtoshi/smae
- **Projeto Original:** https://github.com/AppCivico/smae

