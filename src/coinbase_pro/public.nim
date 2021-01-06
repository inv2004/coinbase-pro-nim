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
  # try:
  fromJson(result, json, Joptions(allowExtraKeys: true, allowMissingKeys: true))
  # except:
    # echo getCurrentExceptionMsg()
    # echo getCurrentException().getStackTrace()

proc getTime*(self): Future[TimeResp] {.async.} =
  return await self.getData[:TimeResp](@["time"])

proc getProducts*(self): Future[seq[Product]] {.async.} =
  return await self.getData[:seq[Product]](@["products"])

proc getProduct*(self; product: string): Future[Product] {.async.} =
  return await self.getData[:Product](@["products", product])

proc getCurrencies*(self): Future[seq[Currency]] {.async.} =
  return await self.getData[:seq[Currency]](@["currencies"])

proc getCurrency*(self; currency: string): Future[Currency] {.async.} =
  return await self.getData[:Currency](@["currencies", currency])

proc getBookLevel*(bookLevel: typedesc[L1 | L2 | L3]): int =
  when bookLevel is L1:
    1
  elif bookLevel is L2:
    2
  elif bookLevel is L3:
    3

proc getBook*(self; product: string, bookLevel: typedesc[L1 | L2 | L3]): Future[Book[bookLevel]] {.async.} =
  return await self.getData[:Book[bookLevel]](@["products", product, "book?level=" & $getBookLevel(bookLevel)])

proc getTicker*(self; product:string): Future[Ticker] {.async.} =
  return await self.getData[:Ticker](@["products", product, "ticker"])
