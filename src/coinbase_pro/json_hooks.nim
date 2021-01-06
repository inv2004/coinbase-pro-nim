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

proc fixTime(x: var string) =
  var dotIdx = 1 + x.find('.')
  var l = 0
  while x[dotIdx + l] in '0'..'9':
    l.inc
  if l < 6:
    x.insert(repeat('0', 6 - l), dotIdx + l)

proc fromJsonHook*(x: var Time, j: JsonNode) =
  var timeStr = j.getStr
  fixTime(timeStr)
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
