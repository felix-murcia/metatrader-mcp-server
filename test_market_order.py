# test_market_order.py
import os
from dotenv import load_dotenv
from metatrader_client import MT5Client

load_dotenv()

config = {
    "login": int(os.environ["MT5_LOGIN"]),
    "password": os.environ["MT5_PASSWORD"],
    "server": os.environ["MT5_SERVER"],
}

client = MT5Client(config)
client.connect()

# Obtener precio actual
price_info = client.market.get_symbol_price("EURUSD")
current_price = price_info['ask']
print(f"Precio actual: {current_price}")

# Calcular SL y TP válidos
stop_loss_price = round(current_price - 0.0010, 5)  # 10 pips por debajo
take_profit_price = round(current_price + 0.0020, 5)  # 20 pips por encima

print(f"Stop Loss: {stop_loss_price}")
print(f"Take Profit: {take_profit_price}")

# Colocar orden MARKET con SL/TP válidos
result = client.order.place_market_order(
    type="BUY",
    symbol="EURUSD",
    volume=0.01,
    stop_loss=stop_loss_price,
    take_profit=take_profit_price
)

print(result)
client.disconnect()