import structs

import decimal
import times
import uuids
import std/[json, jsonutils]
import strutils

const isoTime = "yyyy-MM-dd'T'HH:mm:ss'.'ffffffzzz"

proc fromJsonHook*(x: var DecimalType, j: JsonNode) =
  x = newDecimal(j.getStr)

proc fromJsonHook*(x: var UUID, j: JsonNode) =
  x = parseUUID(j.getStr())

proc fixTimeStr(x: var string) =
  var dotIdx = x.find('.')
  if dotIdx < 0:
    x.insert(".000000", 19)
  else:
    var l = 0
    while x[dotIdx + 1 + l] in '0'..'9':
      l.inc
    if l < 6:
      # echo x
      x.insert(repeat('0', 6 - l), dotIdx + 1 + l)
      # echo x

proc fromJsonHook*(x: var Time, j: JsonNode) =
  var timeStr = j.getStr
  fixTimeStr(timeStr)
  x = parseTime(timeStr, isoTime, utc())

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

proc fromJsonHook*(x: var Candle, j: JsonNode) =
  x.time = fromUnix(j[0].getInt)
  x.low = j[1].getFloat
  x.high = j[2].getFloat
  x.open = j[3].getFloat
  x.close = j[4].getFloat
  x.volume = j[5].getFloat

import unittest

test "fixTimeStr":
  var t1 = "2021-01-06T18:01:24Z"
  fixTimeStr(t1)
  check t1 == "2021-01-06T18:01:24.000000Z"
  var t2 = "2021-01-06T18:01:24.1Z"
  fixTimeStr(t2)
  check t2 == "2021-01-06T18:01:24.100000Z"
  var t3 = "2021-01-06T18:01:24.Z"
  fixTimeStr(t3)
  check t3 == "2021-01-06T18:01:24.000000Z"
  var t4 = "2021-01-06T18:01:24.123Z"
  fixTimeStr(t4)
  check t4 == "2021-01-06T18:01:24.123000Z"
  var t5 = "2021-01-06T18:01:24.123+03:00"
  fixTimeStr(t5)
  check t5 == "2021-01-06T18:01:24.123000+03:00"
