# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import coinbase_pro

import unittest
import asyncdispatch
import times
import logging
import std/[json,jsonutils]
import decimal

const defProd = "BTC-USD"

var logger = newConsoleLogger()
addHandler(logger)
setLogFilter(lvlError)

test "extraKeys":
  let j = parseJson "[{\"id\":\"BAT-USDC\",\"base_currency\":\"BAT\",\"quote_currency\":\"USDC\",\"base_min_size\":\"1\",\"base_max_size\":\"300000\",\"quote_increment\":\"0.000001\",\"base_increment\":\"0.000001\",\"display_name\":\"BAT/USDC\",\"min_market_funds\":\"1\",\"max_market_funds\":\"100000\",\"margin_enabled\":false,\"post_only\":false,\"limit_only\":false,\"cancel_only\":false,\"trading_disabled\":false,\"status\":\"online\",\"status_message\":\"\"}]"
  var p: seq[Product]
  fromJson(p, j, Joptions(allowExtraKeys: true, allowMissingKeys: true))
  check p[0].id == "BAT-USDC"

test "getProduct(s)":
  let cb = newCoinbase()
  let prds = waitFor cb.getProducts()
  check prds.len > 5
  let p = waitFor cb.getProduct(prds[0].id)
  check p == prds[0]

test "getBook":
  let cb = newCoinbase()
  let bookL1 = waitFor cb.getBook(defProd, L1)
  check bookL1.bids.len == 1
  check bookL1.asks.len == 1
  let bookL2 = waitFor cb.getBook(defProd, L2)
  check bookL2.bids.len == 50
  check bookL2.asks.len == 50
  # let bookL3 = waitFor cb.getBook(defProd, L3)
  # check bookL3.bids.len > 50
  # check bookL3.asks.len > 50
  # check bookL3.bids[0].price < bookL3.asks[0].price

test "getTicker":
  let cb = newCoinbase()
  let tick = waitFor cb.getTicker(defProd)
  check getTime() - tick.time <= initDuration(minutes = 60)

test "getTrades":
  let cb = newCoinbase()
  let trades = waitFor cb.getTrades(defProd)
  check trades.len > 0
  check trades[0].trade_id > 0
  check trades[0].price > 0
  check trades[0].size > 0
  check trades[0].side in {Buy, Sell}
  check getTime() - trades[0].time <= initDuration(minutes = 60)

import sequtils

test "getCandles":
  let cb = newCoinbase()
  let candles = waitFor cb.getCandles(defProd)
  check candles.len > 0
  check candles.allIt(it.time < getTime())
  check candles[0].close > 0.0
  check candles[0].volume > 0.0

test "getStats":
  let cb = newCoinbase()
  let stats = waitFor cb.getStats(defProd)
  check stats.volume_30day > 0

test "getTime":
  let cb = newCoinbase()
  let time = waitFor cb.getTime()
  check gettime() - time.iso <= initDuration(seconds = 5)

test "getCurrenc(y|ies)":
  let cb = newCoinbase()
  let currs = waitFor cb.getCurrencies()
  check currs.len > 5
  let c = waitFor cb.getCurrency(currs[0].id)
  check c == currs[0]
  check c.details.`type` in {Crypto, Fiat}
  check c.details.max_withdrawal_amount > 0

test "subscribeHeartbeat":
  let cb = newCoinbase()
  let subs = waitFor cb.subscribe(@[ctHeartbeat], @[defProd])
  for i, x in subs:
    check x.`type` == ctHeartbeat
    check x.time - getTime() <= initDuration(seconds = 2)
    check x.last_trade_id > 0
    if i >= 1:
      break

test "subscribeStatus":
  let cb = newCoinbase()
  let subs = waitFor cb.subscribe(@[ctStatus], @[defProd])
  for i, x in subs:
    check x.`type` == ctStatus
    check x.products.len > 0
    check x.currencies.len > 0
    break

test "subscribeTicker":
  let cb = newCoinbase()
  let subs = waitFor cb.subscribe(@[ctHeartbeat, ctTicker], @[defProd])
  var i = 0
  for x in subs:
    if x.`type` == ctTicker:
      check x.time - getTime() <= initDuration(seconds = 2)
      check x.best_bid < x.best_ask
      check x.price > 0
      check x.last_size > 0
      i.inc()
      if i >= 2:
        break

test "subscribeLevel2":
  let cb = newCoinbase()
  let subs = waitFor cb.subscribe(@[ctHeartbeat, ctLevel2], @[defProd])
  var i = 0
  for x in subs:
    if x.`type` == ctLevel2:
      check x.product_id == defProd
      let msg = x.l2Msg
      if x.l2Msg.`type` == l2mkSnapshot:
        check msg.bids[0][0] < msg.asks[0][0]
        check msg.bids.len > 0
        check msg.asks.len > 0
        i.inc()
      if i == 1 and x.l2Msg.`type` == l2mkUpdate:
        check msg.changes.len > 0
        check msg.changes[0][0] in {Buy, Sell}
        check msg.changes[0][1] > 0
        check msg.changes[0][2] >= 0
        break

import sets

test "subscribeFull":
  let cb = newCoinbase()
  let subs = waitFor cb.subscribe(@[ctHeartbeat, ctFull], @[defProd])

  var checkSet = initHashSet[FullMessageKind]()

  for i, x in subs:
    if x.`type` == ctFull:
      checkSet.incl x.fullMsg.`type`
      if checkSet.len >= 4:
        check true
        break
      if i >= 50:
        check false
        break
