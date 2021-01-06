import structs

import decimal
import times
import uuids
import std/[json, jsonutils]

const isoTime = "yyyy-MM-dd'T'HH:mm:ss'.'fffzzz"
const isoTimeFull = "yyyy-MM-dd'T'HH:mm:ss'.'ffffffzzz"

proc fromJsonHook*(x: var DecimalType, j: JsonNode) =
  x = newDecimal(j.getStr)

proc fromJsonHook*(x: var UUID, j: JsonNode) =
  x = parseUUID(j.getStr())

proc fromJsonHook*(x: var Time, j: JsonNode) =
  x = parseTime(j.getStr, isoTimeFull, utc())

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

proc fromJsonHook*(x: var TimeResp, j: JsonNode) =
  x.iso = parseTime(j["iso"].getStr, isoTime, utc())
  x.epoch = j["epoch"].getFloat()
