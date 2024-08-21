curl -H "Accept: application/json" -X GET http://localhost:9006/latest-event-timestamp/buffer/100
curl -H "Accept: application/json" -X GET http://localhost:9006/status/100?device-type=ios
curl -H "Accept: application/json" -X GET http://localhost:9006/v2/latest-event-timestamp/buffer/100
curl -H "Accept: application/json" -X GET http://localhost:9006/v2/status/100?device-type=ios
curl -H "Accept: application/json" -X GET http://localhost:9006/v2/player-state/100?device-type=ios
curl -H "Accept: application/json" -X GET http://localhost:9006/v3/latest-event-timestamp/buffer/100
curl -H "Accept: application/json" -X GET http://localhost:9006/v3/status/100?device-type=ios
curl -H "Accept: application/json" -X GET http://localhost:9006/v3/player-state/100?device-type=ios
curl -H "Accept: application/json" -X GET http://localhost:9006/v3/total-play-time/100?device-type=ios
curl -H "Accept: application/json" -X GET http://localhost:9006/v3/total-play-time/100?device-type=android
curl -H "Accept: application/json" -X GET http://localhost:9006/v3/total-play-time/100?device-type=invalid
curl -H "Accept: application/json" -X GET http://localhost:9006/v3/total-play-time-of-movie/100?device-type=ios&movie-name=matrix
curl -H "Accept: application/json" -X GET http://localhost:9006/v3/total-play-time-of-movie/100?device-type=ioss&movie-name=brahma
curl -H "Accept: application/json" -X POST http://localhost:9006/v3/add-event -d @request-body.json
curl -H "Accept: application/json" -X POST http://localhost:9006/v3/add-event -d @invalid-request-body.json
