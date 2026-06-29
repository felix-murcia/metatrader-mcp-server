@echo off
cd C:\Users\felix\metatrader-mcp-server

echo Activando entorno virtual...
call venv_mt5\Scripts\activate.bat

echo Cargando variables de entorno...
if exist .env (
    for /f "usebackq tokens=1,* delims==" %%A in (".env") do set "%%A=%%B"
)

echo Iniciando MetaTrader MCP Server...
metatrader-http-server --login %MT5_LOGIN% --password %MT5_PASSWORD% --server %MT5_SERVER% --host 0.0.0.0 --port 8000

echo.
echo Servidor finalizado. Pulsa una tecla para cerrar.
pause
