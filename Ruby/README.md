# Usage

```ruby
require 'ptx_client'

client = PtxClient.new(
  app_id: ENV['APP_ID'],
  app_key: ENV['APP_KEY']
)

client.get(
  '/v2/Air/FIDS/Airport/Arrival',
  '$filter': "ArrivalAirportID eq 'TPE'",
  '$top': 2,
)
```
