type
  FeedMessageKind* = enum
    fkHeartbeat = "heartbeat"
    fkTicker = "ticker"
    fkLevel2 = "level2"
    fkMatches = "matches"
    fkSubscribe = "subscribe"
    fkReceived = "received"
    fkOpen = "open"
    fkMatch = "match"
    fkDone = "done"
    fkUser = "user"

  FeedMessage* = object
    case `type`*: FeedMessageKind
    of fkHeartbeat:
      last_trade_id*: int64
    of fkTicker:
      trade_id*: int64
    of fkFull:
      discard

  FullMessageKind* = enum
    fmkReceived = "received"
    fmkOpen = "open"
    fmkMatch = "match"
    fmkDone = "done"

  FullMessage* = object
    case `type`*: FullMessageKind
    of fmkReceived:
      discard
    of fmkOpen:
      discard
    of fmkMatch:
      discard
    of fmkDone:
      discard
