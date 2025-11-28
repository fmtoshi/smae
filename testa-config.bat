@echo off
REM Script para testar configuracoes do docker-compose
docker compose config 2>&1 | findstr /i "WARNING"
if %errorlevel% equ 0 (
    echo.
    echo ATENCAO: Existem warnings na configuracao!
) else (
    echo Configuracao OK - Nenhum warning encontrado.
)
pause


