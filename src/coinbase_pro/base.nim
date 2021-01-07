import httpclient
import ws

const REAL* = "https://api.pro.coinbase.com"
const SANDBOX* = "https://api-public.sandbox.pro.coinbase.com"

type
  Coinbase* = ref object
    http*: AsyncHttpClient
    url*: string
    ws*: WebSocket

proc newCoinbase*(url = SANDBOX): Coinbase =
  let http = newAsyncHttpClient()
  Coinbase(http: http, url: url)
