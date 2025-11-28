@echo off
REM Script para iniciar apenas o banco de dados
docker compose up -d db
echo Banco de dados iniciado!
pause


