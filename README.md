# Coinbase pro client for Nim

It is just experiment to compare effort of making the same like [coinbase-pro-rs](https://github.com/inv2004/coinbase-pro-rs).
It was made in 3 evening (?coinbase-pro-rs was made in a month or more?), the only stoppers here were:
- Nim's jsonutils bug and their fix (easy) https://github.com/nim-lang/Nim/pull/16615 and https://github.com/nim-lang/Nim/pull/16612
- Nim's kind objects cannot have the same field-names for different branches

## Api

### Sync

  Async in Nim has very little overhead, all you need is just to ``import asyncdispatch`` and ``waitFor`` before any async call. That is why specific sync API is not necessary

### ASync
- [x] getProduct(s)
- [x] getBook
- [x] getTicker
- [x] getTrades
- [x] getCandles
- [x] getStats
- [x] getTime
- [x] getCurrenc(y|ies)

### WS-Feed
- [x] heartbeat
- [x] status
- [x] ticker
- [x] level2
- [x] full
