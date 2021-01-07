import public
export public

import wsstructs
export wsstructs

import asyncdispatch
import ws
import std/[json, jsonutils]

const WS_REAL* = "wss://ws-feed.pro.coinbase.com"
const WS_SANDBOX* = "wss://ws-feed-public.sandbox.pro.coinbase.com"

const JPARSEOPTIONS = Joptions(allowExtraKeys: true, allowMissingKeys: true)

type
  # Channel = object
  #   name: ChannelType
  #   product_ids: seq[string]

  # SubscribeResponse* = object
  #   channels*: seq[Channel]

  Subscription* = object
    ws: WebSocket
    
using
  self: Coinbase

proc subscribe*(self; channels: seq[ChannelType], products: seq[string]): Future[Subscription] {.async.} =
  if self.ws.isNil:
    self.ws = await newWebSocket(WS_SANDBOX)

  let j = %*{
    "type": "subscribe",
    "channels": channels,
    "product_ids": products
  }
  await self.ws.send($j)
  let resp = await self.ws.receiveStrPacket()
  var jResp = parseJson(resp)
  if jResp{"type"}.getStr != "subscriptions":
    raise newException(ValueError, "invalid sub response")

  result.ws = self.ws

iterator items*(sub: Subscription): FeedMessage =
  var msg: string
  var res: FeedMessage
  while sub.ws.readyState == Open:
    msg = waitFor sub.ws.receiveStrPacket()
    let j = parseJson(msg)
    # echo j
    fromJson(res, j, JPARSEOPTIONS)
    yield res

iterator pairs*(sub: Subscription): (int, FeedMessage) =
  var i = 0
  for x in sub.items:
    yield (i, x)
    i.inc()
