
import times

type
  TimeResp* = object
    iso*: Time
    epoch*: float

  Product* = object
    id*, base_currency*, quote_currency*: string
    base_min_size*, base_max_size*, quote_increment*: string

  CurrencyStatus* = enum
    Online = "online"

  Currency* = object
    id*, name*: string
    min_size*: string
    status*: CurrencyStatus
    max_precision: string

  L1* = tuple
    price: string
    size: string
    num_orders: int

  L2* = tuple
    price: string
    size: string
    num_orders: int

  L3* = tuple
    price: string
    size: string
    order_id: string

  Book*[T] = object
    sequence*: int64
    bids: seq[T]
    asks: seq[T]
  