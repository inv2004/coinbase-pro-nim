from structs import TradeSide, CurrencyStatus

import times
import decimal

type
  ChannelType* = enum
    ctHeartbeat = "heartbeat"
    ctStatus = "status"
    ctTicker = "ticker"
    ctLevel2 = "level2"
    ctMatches = "matches"
    ctFull = "full"
    ctUser = "user"

  FeedMessageKind* = enum
    fkHeartbeat = "heartbeat"
    fkStatus = "status"
    fkTicker = "ticker"
    fkSnapshot = "snapshot"
    fkL2Update = "l2update"
    fkMatches = "matches"
    # fkSubscribe = "subscribe"
    fkReceived = "received"
    fkOpen = "open" 
    fkMatch = "match"
    fkDone = "done"

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

  FeedMessage* = object
    sequence*: int64
    time*: Time   # not available for fkSnapshot
    product_id*: string
    case `type`*: FeedMessageKind
    of fkHeartbeat:
      last_trade_id*: int64
    of fkStatus:
      products*: seq[ProductStatusInfo]
      currencies*: seq[CurrencyStatusInfo]
    of fkTicker:
      trade_id*: int64
      price*: DecimalType
      side*: TradeSide
      last_size*: DecimalType
      best_bid*, best_ask*: DecimalType
    of fkSnapshot:
      bids*, asks*: seq[(DecimalType, DecimalType)]
    of fkL2Update:
      changes*: seq[(TradeSide, DecimalType, DecimalType)]
    of fkMatches:
      discard
    # of fkSubscribe:
    #   discard
    of fkReceived:
      discard
    of fkOpen:
      discard
    of fkMatch:
      discard
    of fkDone:
      discard

proc channelType*(msg: FeedMessage): ChannelType =
  let t = msg.`type`
  if t in {fkHeartbeat}: ctHeartbeat
  elif t in {fkStatus}: ctStatus
  elif t in {fkTicker}: ctTicker
  elif t in {fkSnapshot, fkL2Update}: ctLevel2
  elif t in {fkReceived, fkOpen, fkMatch, fkDone}: ctFull
  else: raise newException(ValueError, "cannot detect type: " & $t)
