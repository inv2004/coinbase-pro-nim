
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

  CurrencyStatus* = enum
    Online = "online"

  Currency* = object
    id*, name*: string
    min_size*: DecimalType
    status*: CurrencyStatus
    max_precision*: DecimalType
    message*: string

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

  Trade* = object
    time*: string
    trade_id*: int
    price*, size*: DecimalType
    side*: string
