
import times
import decimal
import uuids

type
  TimeResp* = object
    iso*: Time
    epoch*: float

  Product* = object
    id*, display_name*, base_currency*, quote_currency*: string
    base_increment*, base_min_size*, base_max_size*, quote_increment*: DecimalType

  L1* = object
    price*: DecimalType
    size*: DecimalType
    num_orders*: int

  L2* = object
    price*: DecimalType
    size*: DecimalType
    num_orders*: int

  L3* = object
    price*: DecimalType
    size*: DecimalType
    order_id*: UUID

  Book*[T: L1 | L2 | L3] = object
    sequence*: int64
    bids*: seq[T]
    asks*: seq[T]

  Ticker* = object
    trade_id*: int64
    price*, size*, bid*, ask*, volume*: DecimalType
    time*: Time

  OrderType* = enum Limit = "limit", Market = "market"

  TradeSide* = enum Buy = "buy", Sell = "sell"

  Trade* = object
    time*: Time
    trade_id*: int
    price*, size*: DecimalType
    side*: TradeSide

  Candle* = object
    time*: Time
    low*, high*, open*, close*, volume*: float64
  
  Stats* = object
    open*, high*, low*, volume*, last*, volume_30day*: DecimalType

  CurrencyStatus* = enum
    Online = "online"

  CurrencyType* = enum Crypto = "crypto", Fiat = "fiat"

  CurrencyDetails* = object
    `type`*: CurrencyType
    symbol*: string
    network_confirmations*: int
    sort_order*: int
    crypto_address_link*: string
    crypto_transaction_link*: string
    push_payment_methods*: seq[string]
    group_types*: seq[string]
    display_name*: string
    processing_time_seconds*: int64
    min_withdrawal_amount*, max_withdrawal_amount*: float64

  Currency* = object
    id*, name*: string
    min_size*: DecimalType
    status*: CurrencyStatus
    max_precision*: DecimalType
    message*: string
    details*: CurrencyDetails

