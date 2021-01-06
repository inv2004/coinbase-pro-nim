import structs

import asyncdispatch
import httpclient
import ws
import times
import strformat
import json
import logging
import strutils

const url = "https://api-public.sandbox.pro.coinbase.com"
const isoTime = "yyyy-MM-dd'T'HH:mm:ss'.'fffzzz"

import structs
export structs

type
  Coinbase* = object
    http*: AsyncHttpClient
    ws*: WebSocket

using
  self: Coinbase

proc newCoinbase*(): Coinbase =
  let http = newAsyncHttpClient()
  Coinbase(http: http)

proc getTime*(self): Future[TimeResp] {.async.} =
  let res = await self.http.getContent(fmt"{url}/time")
  let json = parseJson(res)
  return TimeResp(iso: parseTime(json["iso"].getStr, isoTime, utc()), epoch: json["epoch"].getFloat())

proc getData*[T](self; args: seq[string]): Future[T] {.async.} =
  let pStr = args.join("/")
  let res = await self.http.getContent(url & "/" & pStr)
  let json = parseJson(res)
  debug json.pretty()
  return json.to(T)

proc getProducts*(self): Future[seq[Product]] {.async.} =
  return await self.getData[:seq[Product]](@["products"])

proc getProduct*(self; product: string): Future[Product] {.async.} =
  return await self.getData[:Product](@["products", product])

proc getCurrencies*(self): Future[seq[Currency]] {.async.} =
  return await self.getData[:seq[Currency]](@["currencies"])

proc getCurrency*(self; currency: string): Future[Currency] {.async.} =
  return await self.getData[:Currency](@["currencies", currency])

proc getBook*(self; product: string, bookLevel: typedesc): Future[Book[bookLevel]] {.async.} =
  return await self.getData[:Book[bookLevel]](@["products", product, "book?level=1"])
