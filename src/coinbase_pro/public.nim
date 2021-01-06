import structs

import asyncdispatch
import httpclient
import ws
import times
import strformat
import std/[json,jsonutils]
import logging
import strutils
import decimal
import uuids

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

proc fromJsonHook(x: var DecimalType, j: JsonNode) =
  x = newDecimal(j.getStr)

proc fromJsonHook(x: var UUID, j: JsonNode) =
  x = parseUUID(j.getStr())

proc fromJsonHook*(x: var L1, j: JsonNode) =
  x.price = newDecimal(j[0].getStr)
  x.size = newDecimal(j[1].getStr)
  x.num_orders = j[2].getInt

proc fromJsonHook*(x: var L2, j: JsonNode) =
  x.price = newDecimal(j[0].getStr)
  x.size = newDecimal(j[1].getStr)
  x.num_orders = j[2].getInt

proc fromJsonHook*(x: var L3, j: JsonNode) =
  x.price = newDecimal(j[0].getStr)
  x.size = newDecimal(j[1].getStr)
  fromJson(x.order_id, j[2])    # TODO: probably shortcut

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
  # try:
  fromJson(result, json, Joptions(allowExtraKeys: true, allowMissingKeys: true))
  # except:
    # echo getCurrentExceptionMsg()
    # echo getCurrentException().getStackTrace()

proc getProducts*(self): Future[seq[Product]] {.async.} =
  return await self.getData[:seq[Product]](@["products"])

proc getProduct*(self; product: string): Future[Product] {.async.} =
  return await self.getData[:Product](@["products", product])

proc getCurrencies*(self): Future[seq[Currency]] {.async.} =
  return await self.getData[:seq[Currency]](@["currencies"])

proc getCurrency*(self; currency: string): Future[Currency] {.async.} =
  return await self.getData[:Currency](@["currencies", currency])

proc getBook*(self; product: string, bookLevel: typedesc[L1 | L2 | L3]): Future[Book[bookLevel]] {.async.} =
  when bookLevel is L1:
    return await self.getData[:Book[bookLevel]](@["products", product, "book?level=1"])
  elif bookLevel is L2:
    return await self.getData[:Book[bookLevel]](@["products", product, "book?level=2"])
  elif bookLevel is L3:
    return await self.getData[:Book[bookLevel]](@["products", product, "book?level=3"])
