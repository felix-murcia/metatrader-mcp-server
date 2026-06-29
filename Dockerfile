# MetaTrader5 solo funciona en Windows — se requiere Windows Server Core
FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

# Instalar Python 3.12
RUN Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.2/python-3.12.2-amd64.exe" -OutFile "C:/python-installer.exe"; \
    Start-Process "C:/python-installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Wait; \
    Remove-Item "C:/python-installer.exe"

WORKDIR C:/app

# Copiar solo lo necesario (venv y logs quedan fuera via .dockerignore)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Las credenciales se pasan como variables de entorno en docker-compose o --env-file
# Se usa shell form para que cmd.exe expanda %MT5_LOGIN% etc.
CMD python -m metatrader_openapi.main --login %MT5_LOGIN% --password %MT5_PASSWORD% --server %MT5_SERVER% --host 0.0.0.0 --port 8000
