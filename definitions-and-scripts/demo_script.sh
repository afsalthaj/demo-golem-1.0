golem-cli api-definition add api-definition.json
golem-cli api-deployment deploy --definition video-analytics/0.0.1 --host localhost:9006
golem-cli api-definition list
curl -H "Accept: application/json" -X GET http://localhost:9006/latest-event-timestamp/buffer/100
curl -H "Accept: application/json" -X GET http://localhost:9006/status/100?device-type=ios

