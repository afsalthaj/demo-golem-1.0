# To be executed one by one
golem-cli api-definition add api-definition.json
golem-cli api-deployment deploy --definition video-analytics/0.0.1 --host localhost:9006
golem-cli api-definition list


# To be executed one by one
golem-cli api-definition add api-definition-v2.json
golem-cli api-deployment deploy --definition video-analytics/0.0.2 --host localhost:9006
golem-cli api-definition list

# To be executed one by one
golem-cli api-definition add api-definition-v3.json
golem-cli api-deployment deploy --definition video-analytics/0.0.3 --host localhost:9006
golem-cli api-definition list
