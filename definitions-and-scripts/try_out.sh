curl -H "Accept: application/json" -X GET http://localhost:9006/latest-event-timestamp/buffer/100
curl -H "Accept: application/json" -X GET http://localhost:9006/status/100?device-type=ios
curl -H "Accept: application/json" -X GET http://localhost:9006/v2/latest-event-timestamp/buffer/100
curl -H "Accept: application/json" -X GET http://localhost:9006/v2/status/100?device-type=ios
curl -H "Accept: application/json" -X GET http://localhost:9006/v2/player-state/100?device-type=ios