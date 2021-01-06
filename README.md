# Coinbase pro client for Nim

## Api

### Sync
  Async in Nim has very little overhead, all you need is just ``import asyncdispatch`` and ``waitFor`` before any async call. That is why specific sync API is not necessary

### ASync
- [x] getProduct(s)
- [x] getBook
- [x] getTicker
- [x] getTrades
- [x] getCandles
- [x] getStats
- [x] getTime
- [x] getCurrenc(y|ies)
