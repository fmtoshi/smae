@echo off
REM Script para parar todos os servicos do SMAE
echo Parando todos os servicos...
docker compose --profile fullStack down
echo Servicos parados!
pause


