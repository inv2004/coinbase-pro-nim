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
import uuids

const defProd = "BTC-USD"

var logger = newConsoleLogger()
addHandler(logger)
setLogFilter(lvlError)

test "extra_keys":
  let j = parseJson "[{\"id\":\"BAT-USDC\",\"base_currency\":\"BAT\",\"quote_currency\":\"USDC\",\"base_min_size\":\"1\",\"base_max_size\":\"300000\",\"quote_increment\":\"0.000001\",\"base_increment\":\"0.000001\",\"display_name\":\"BAT/USDC\",\"min_market_funds\":\"1\",\"max_market_funds\":\"100000\",\"margin_enabled\":false,\"post_only\":false,\"limit_only\":false,\"cancel_only\":false,\"trading_disabled\":false,\"status\":\"online\",\"status_message\":\"\"}]"
  var p: seq[Product]
  fromJson(p, j, Joptions(allowExtraKeys: true, allowMissingKeys: true))
  check p[0].id == "BAT-USDC"

test "getTime":
  let cb = newCoinbase()
  let time = waitFor cb.getTime()
  check gettime() - time.iso <= initDuration(seconds = 5)

test "getProduct(s)":
  let cb = newCoinbase()
  let prds = waitFor cb.getProducts()
  check prds.len > 5
  let p = waitFor cb.getProduct(prds[0].id)
  check p == prds[0]

test "getCurrenc(y|ies)":
  let cb = newCoinbase()
  let currs = waitFor cb.getCurrencies()
  check currs.len > 5
  let c = waitFor cb.getCurrency(currs[0].id)
  check c == currs[0]

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

test "getTicker":
  let cb = newCoinbase()
  let tick = waitFor cb.getTicker(defProd)
  check getTime() - tick.time <= initDuration(minutes = 60)
