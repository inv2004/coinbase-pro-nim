# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import coinbase_pro/public

import unittest
import asyncdispatch
import times
import logging

var logger = newConsoleLogger()
addHandler(logger)
setLogFilter(lvlError)

test "getTime":
  let cb = newCoinbase()
  let time = waitFor cb.getTime()
  check time.iso - getTime() <= initDuration(seconds = 5)

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
  let bookL1 = waitFor cb.getBook("BTC-USD", L1)
  echo bookL1
