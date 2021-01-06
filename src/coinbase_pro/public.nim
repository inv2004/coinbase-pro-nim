import structs
export structs

import json_hooks
export json_hooks

import asyncdispatch
import httpclient
import ws
import strformat
import std/[json,jsonutils]
import logging
import strutils

const url = "https://api-public.sandbox.pro.coinbase.com"

const jParseOptions = Joptions(allowExtraKeys: true, allowMissingKeys: true)

type
  Coinbase* = object
    http*: AsyncHttpClient
    ws*: WebSocket

using
  self: Coinbase

proc newCoinbase*(): Coinbase =
  let http = newAsyncHttpClient()
  Coinbase(http: http)

proc getData*[T](self; args: seq[string]): Future[T] {.async.} =
  let pStr = args.join("/")
  let res = await self.http.getContent(url & "/" & pStr)
  let json = parseJson(res)
  debug json.pretty()
  try:
    fromJson(result, json, jParseOptions)
  except:
    echo getCurrentExceptionMsg()
    echo getCurrentException().getStackTrace()

template mkCallP0(path: string, name: untyped, respType: typedesc) =
  proc name*(self: Coinbase): Future[respType] {.async.} =
    return await self.getData[:respType](@[path])

template mkCallP2(path: string, name: untyped, arg: untyped; path2: string, respType: typedesc) =
  proc name*(self: Coinbase, arg: string): Future[respType] {.async.} =
    return await self.getData[:respType](@[path, arg, path2])

mkCallP0("products", getProducts, seq[Product])
mkCallP2("products", getProduct, product, "", Product)
mkCallP2("products", getTicker, product, "ticker", Ticker)
mkCallP2("products", getTrades, product, "trades", seq[Trade])
mkCallP2("products", getCandles, product, "candles", seq[Candle])
mkCallP2("products", getStats, product, "stats", Stats)
mkCallP0("currencies", getCurrencies, seq[Currency])
mkCallP2("currencies", getCurrency, currency, "", Currency)
mkCallP0("time", getTime, TimeResp)

proc level(_: typedesc[L1]): int = 1
proc level(_: typedesc[L2]): int = 2
proc level(_: typedesc[L3]): int = 1

proc getBook*(self; product: string, bookLevel: typedesc[L1 | L2 | L3]): Future[Book[bookLevel]] {.async.} =
  return await self.getData[:Book[bookLevel]](@["products", product, "book?level=" & $level(bookLevel)])

