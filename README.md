# Thermio

**Central API for an MQTT-based IoT ecosystem**

## Usage

### Climate logging

The Climate API is designed to work with the [Thermio Climate Module](https://github.com/jackcuthbert/thermio), though any MQTT publishing device will work, so long as it publishes in the same format.

#### `GET /api/climates`

```
Content-Type: application/json
Authorization: Bearer someJsonWebToken
```

Returns climates from the last 24h, most recent first.

```json
{
  "data": [
    {
      "time": "2017-04-29T08:17:34.013089",
      "temperature": 25.9,
      "id": 526,
      "humidity": 52.7,
      "heatIndex": 25.92
    }, ...
  ]
}
```



## Developing

* Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
