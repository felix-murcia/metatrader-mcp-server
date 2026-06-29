# MetaTrader MCP Server

Servidor MCP/HTTP para operar MetaTrader 5 desde LLMs (Claude, Open WebUI, etc.).

## Requisitos

- Windows 10/11
- MetaTrader 5 instalado
- Python 3.12

## Instalación

```powershell
python -m venv venv_mt5
.\venv_mt5\Scripts\activate
pip install metatrader-mcp-server
```

## Configuración

Crea un fichero `.env` en la raíz del proyecto:

```env
MT5_LOGIN=tu_login
MT5_PASSWORD=tu_password
MT5_SERVER=tu_servidor
```

> `.env` está en `.gitignore` — nunca se sube al repositorio.

## Arranque manual

```powershell
.\start_mcp_server.bat
```

O directamente:

```powershell
.\venv_mt5\Scripts\python.exe -m metatrader_openapi.main `
  --login tu_login --password tu_password --server tu_servidor `
  --host 0.0.0.0 --port 8000
```

## Arranque automático como servicio

El servidor está registrado como tarea de Windows y arranca automáticamente al iniciar el sistema.

Para gestionar el servicio manualmente usa `mcp_service.ps1`:

```powershell
.\mcp_service.ps1 status     # comprobar estado
.\mcp_service.ps1 start      # arrancar
.\mcp_service.ps1 stop       # parar
.\mcp_service.ps1 restart    # reiniciar (si se queda colgado)
```

El comando `status` comprueba tres cosas:
- Estado de la tarea en el Programador de Windows
- Si el proceso Python está corriendo
- Si el endpoint HTTP responde

## Logs

Los logs se guardan en `metatrader_mcp.log` en la raíz del proyecto.

```
2026-06-29 12:52:12  INFO  === MetaTrader MCP Server started (login=tu_login server=tu_servidor) ===
2026-06-29 12:52:33  INFO  GET /api/v1/account/info 200 7ms client=100.81.112.95
2026-06-29 12:53:01  INFO  POST /api/v1/order/market 200 312ms client=100.81.112.95
```

Cada línea incluye: fecha/hora, nivel, método HTTP, ruta, código de respuesta, tiempo en ms e IP del cliente.

## Endpoints HTTP

El servidor expone una API REST en `http://localhost:8000`. Documentación interactiva en `http://localhost:8000/docs`.

### Cuenta

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/v1/account/info` | Balance, equity, margen, divisa, leverage |

### Mercado

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/v1/market/symbols` | Lista de símbolos disponibles |
| GET | `/api/v1/market/price/{symbol}` | Precio actual de un símbolo |
| GET | `/api/v1/market/candles/{symbol}/{timeframe}` | Últimas N velas |

### Posiciones abiertas

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/v1/positions` | Todas las posiciones abiertas |
| GET | `/api/v1/positions/symbol/{symbol}` | Posiciones por símbolo |
| GET | `/api/v1/positions/{id}` | Posición por ID |
| DELETE | `/api/v1/positions/{id}` | Cerrar posición por ID |
| DELETE | `/api/v1/positions` | Cerrar todas las posiciones |
| DELETE | `/api/v1/positions/profitable` | Cerrar todas las posiciones con beneficio |
| DELETE | `/api/v1/positions/losing` | Cerrar todas las posiciones con pérdida |

### Órdenes

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/v1/order/market` | Abrir orden de mercado |
| POST | `/api/v1/order/pending` | Colocar orden pendiente |
| GET | `/api/v1/order/pending` | Listar órdenes pendientes |
| GET | `/api/v1/order/pending/{id}` | Orden pendiente por ID |
| PUT | `/api/v1/order/pending/{id}` | Modificar orden pendiente |
| DELETE | `/api/v1/order/pending/{id}` | Cancelar orden pendiente |
| DELETE | `/api/v1/order/pending` | Cancelar todas las órdenes pendientes |

#### Ejemplo — orden de mercado con SL y TP

```bash
curl -X POST http://localhost:8000/api/v1/order/market \
  -H "Content-Type: application/json" \
  -d '{"symbol":"EURUSD","volume":0.01,"type":"BUY","stop_loss":1.13500,"take_profit":1.15000}'
```

#### Ejemplo — cerrar posición

```bash
curl -X DELETE http://localhost:8000/api/v1/positions/9328864980
```

### Historial

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/v1/history/deals` | Historial de deals (acepta `from_date`, `to_date`, `symbol`) |
| GET | `/api/v1/history/orders` | Historial de órdenes |

## Herramientas MCP

El servidor expone las mismas operaciones como herramientas MCP para uso directo desde Claude u otros LLMs compatibles con MCP.

| Herramienta | Descripción |
|-------------|-------------|
| `get_account_info` | Info de cuenta |
| `get_symbol_price` | Precio de un símbolo |
| `get_symbols` | Lista de símbolos (con filtro opcional) |
| `get_candles_latest` | Últimas N velas |
| `get_candles_by_date` | Velas por rango de fechas |
| `get_deals` | Historial de deals como CSV |
| `get_orders` | Historial de órdenes como CSV |
| `get_all_positions` | Posiciones abiertas |
| `place_market_order` | Orden de mercado (con SL/TP opcionales) |
| `place_pending_order` | Orden pendiente |
| `modify_position` | Modificar SL/TP de posición abierta |
| `modify_pending_order` | Modificar orden pendiente |
| `close_position` | Cerrar posición por ID |
| `close_all_positions` | Cerrar todas las posiciones |
| `close_all_profitable_positions` | Cerrar posiciones con beneficio |
| `close_all_losing_positions` | Cerrar posiciones con pérdida |
| `cancel_pending_order` | Cancelar orden pendiente por ID |
| `cancel_all_pending_orders` | Cancelar todas las órdenes pendientes |

## Docker

```powershell
docker-compose up -d
```

Las credenciales se leen del fichero `.env` automáticamente.
