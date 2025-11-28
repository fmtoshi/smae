@echo off
REM Script para iniciar todo o SMAE via Docker Compose
echo ============================================
echo    SMAE - Sistema de Metas
echo ============================================
echo.

REM Verifica se Docker esta rodando
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Docker nao esta rodando!
    echo Por favor, inicie o Docker Desktop primeiro.
    pause
    exit /b 1
)

echo Docker OK. Iniciando servicos...
echo.

REM Inicia todos os servicos incluindo frontend
docker compose --profile fullStack up --build -d

echo.
echo ============================================
echo   Servicos iniciados!
echo ============================================
echo.
echo   Frontend: http://localhost:8080
echo   API: http://localhost:3001
echo   MinIO Console: http://localhost:9001
echo   Metabase: http://localhost:3003
echo   SMTP Web: http://localhost:3004
echo.
echo   Login padrao:
echo   Email: superadmin@admin.com
echo   Senha: !286!QDM7H
echo.
echo ============================================
pause


