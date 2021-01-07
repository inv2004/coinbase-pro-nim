from structs import TradeSide, CurrencyStatus, OrderType

import times
import decimal
import uuids
import options

type
  ChannelType* = enum
    ctHeartbeat = "heartbeat"
    ctStatus = "status"
    ctTicker = "ticker"
    ctLevel2 = "level2"
    ctFull = "full"
    ctUser = "user"

  ProductStatusInfo* = object
    id*: string
    base_currency*: string
    quote_currency*: string
    base_min_size*: DecimalType
    base_max_size*: DecimalType
    base_increment*: DecimalType
    quote_increment*: DecimalType
    display_name*: string
    status*: CurrencyStatus
    status_message*: string
    min_market_funds*: DecimalType
    max_market_funds*: DecimalType
    post_only*: bool
    limit_only*: bool
    cancel_only*: bool
  
  CurrencyStatusInfo* = object
    id*: string
    name*: string
    min_size*: DecimalType
    status*: CurrencyStatus
    status_message*: string
    max_precision*: DecimalType
    convertible_to*: seq[string]
    # "details": {}

  L2MessageKind* = enum
    l2mkSnapshot = "snapshot"
    l2mkUpdate = "l2update"

  L2Message* = object
    case `type`*: L2MessageKind
    of l2mkSnapshot:
      bids*, asks*: seq[(DecimalType, DecimalType)]
    of l2mkUpdate:
      changes*: seq[(TradeSide, DecimalType, DecimalType)]

  FullMessageKind* = enum
    fmkReceived = "received"
    fmkOpen = "open"
    fmkMatch = "match"
    fmkChange = "change"
    fmkDone = "done"

  DoneReason = enum Filled = "filled", Canceled = "canceled"

  FullMessage* = object
    order_id*: Uuid
    size*: Option[DecimalType]
    price*: DecimalType
    side*: TradeSide
    funds*: Option[DecimalType]
    remaining_size*: Option[DecimalType]
    case `type`*: FullMessageKind
    of fmkReceived:
      order_type*: OrderType
    of fmkOpen:
      discard
    of fmkMatch:
      maker_order_id*, taker_order_id*: Uuid
    of fmkChange:
      new_size*, old_size*: DecimalType
      new_funds*, old_funds*: DecimalType
    of fmkDone:
      reason*: DoneReason

  FeedMessage* = object
    sequence*: int64
    time*: Time   # not available for fkSnapshot
    product_id*: string
    case `type`*: ChannelType
    of ctHeartbeat:
      last_trade_id*: int64
    of ctStatus:
      products*: seq[ProductStatusInfo]
      currencies*: seq[CurrencyStatusInfo]
    of ctTicker:
      trade_id*: int64
      price*: DecimalType
      side*: TradeSide
      last_size*: DecimalType
      best_bid*, best_ask*: DecimalType
    of ctLevel2:
      l2Msg*: L2Message
    of ctFull:
      fullMsg*: FullMessage
    of ctUser:
      discard
