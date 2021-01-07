

import structs
export structs

import jhooks
export jhooks

import base
export base

import asyncdispatch
import httpclient
import std/[json,jsonutils]
import strutils
import logging

const JPARSEOPTIONS = Joptions(allowExtraKeys: true, allowMissingKeys: true)

using
  self: Coinbase

proc getData*[T](self; args: seq[string]): Future[T] {.async.} =
  let pStr = args.join("/")
  let res = await self.http.getContent(self.url & "/" & pStr)
  let json = parseJson(res)
  debug json.pretty()
  # try:
  fromJson(result, json, JPARSEOPTIONS)
  # except:
  #   echo getCurrentExceptionMsg()
  #   echo getCurrentException().getStackTrace()

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
