## Golem Worker Gateway and Golem Rib

## Strategy of Demo
1. Start with a use-case of Golem
2. Explain why we need a HTTP API over the worker's functions
3. Explain the functions that are exposed by the existing component (video_distribution_analytics.wasm)
4. Explain the different possibilities of Rib script by adding routes one by one. This will include looking up from request details, and the explanation of Rib itself.
5. Try all the APIs.

### Usecase: Video Distribution using Golem

Say, you have used golem to deploy a video distribution analytics platform
where the system tries to compute a complex video distribution analytics logic 
(to get a sense of what that would look like, watch this talk https://www.youtube.com/watch?v=9WjUBOfgriY&t=1s).

Consider this to be a scenario, where you have spinned up a light weight worker for each user-id,
where each worker is responsible for computing the analytics for the user-id.

### Why we need HTTP Apis over the golem workers ?

* This is a simple example where you are able to compose a monitoring tool geared to your usecase
  without writing a separata backend service for it.

* We need exposing a monitoring API on top of this analytics platform. This API allows us to peek into the latest state of data 
correponding to a user. This is especially useful in failure scenario, such as to figure out why the output of an analytics engine is not as expected.
Example: By hitting the APIs we can figure out the event hasn't reached the worker yet.

* We also need an API to manage events to the worker.

### Introduction to Rib

Rib is a language that allows you call the specific worker function and allows you to manipulate the result of a worker. 
This Rib script is going to be part of the API definition and will exist under each route definition.

### Explanation of the functions exposed

The workers spinned up from the analytics-components expose the following functions.


```scala
  {
    "componentUrn": "urn:component:51163bf3-8ea4-4749-80e6-325434c93499",
    "componentVersion": 0,
    "componentName": "video-distribution-analytics-v5",
    "componentSize": 2782266,
    "exports": [
      "{get-latest-event-timestamp}(event-type: string, user-id: u64) -> string",
      "{get-player-state}(device-type: string) -> string",
      "{get-latest-event-details}(device-type: string) -> record { event-type: string, movie-name: string, device-type: string, timestamp: string }",
      "{get-total-play-time}(device-type: string) -> result<u64, string>",
      "{get-total-play-time-of-movie}(device-type: string, movie-name: string) -> result<option<u64>, string>",
      "{add-event}(event-info: record { event-type: string, movie-name: string, device-type: string, timestamp: string }) -> result<string, string>"
    ]
  }

```


* Get the time-stamp of the latest event tracked for a particular user. This returns a simple text output
* Get the latest player state (buffering, playing) tracked for a particular device-type of the user. This returns a simple text output
* Get the latest event details tracked for a particular device-type of the user. This returns a record data structure exposing event details
* Get the total play time tracked for a particular device-type of the user. This returns a result, indicating that it will return a failure for invalid device-id
* Get the total play time tracked for a particular movie played on a particular device-type of the user.  
  This returns a result, indicating that it will return a failure for invalid device-id, and the value itself is an option indicating that the user may not have watched the movie yet.
  We need to manipulate this data to send back a meaningful response to the user.
* Add an event to the tracking system. This returns a result indicating that it will return a failure for invalid event-type

Demo has to go thorugh the following steps

# Pre-requisite

Make sure to add the component in the root directory, either through console or golem-cli. Keep a note of this component.
Keep a note of the component-id

# Step 1: Create an API definition
In console make sure to update the following routes into the new API definition with `id` as `video-analytics` and `version` as `0.0.1`

# Step 2: Add Routes explaining different complicated scenarios

Add the following routes one by one explaining the details

---------------------

## Route 1: Get the time-stamp of the latest event tracked for a particular user


```

 "method": "Get",
 "path": "/v3/latest-event-timestamp/{event-type}/{user-id}",
 "workerName": "analytics-${request.path.user-id}",
      
```

Here the worker-name is derived from the user-id in the path. The worker-id is `analytics-${request.path.user-id}`
This implies the following rib-script will target that specific user's data.

Rib: Explaining dynamically creating a worker using request details, simple let binding and type-inference


```
let result = get-latest-event-timestamp(request.path.event-type, request.path.user-id); 
{status: 200, body: result}

```

Here Rib infers that `request.path.event-type` should be `Str` and `request.path.user-id` to be `U64`.
The final expression in the script act as the return value, which is a record with status and body.
The result is simply sent back to the user as a response body.

-------------------

## Route 2: Get the latest player state (buffering, playing) tracked for a particular device-type of the user

##### Route-details

```

 "method": "Get",
 "path": "/v3/status/{user-id}?{device-type}",
 "workerName": "event-processor-${request.path.user-id}",
      
```

Here the worker-name is derived from the user-id in the path. The worker-id is `event-processor-${request.path.user-id}`.
Also note that we are now explicity targetting the event-consumer worker ratrher than the `analytics` worker.

Rib: Explaining If Else condition to manipulate worker's response which is a simple String

Using `if-else` rib expression, it allows you to throw an unauthorised error if the user is an admin of the system.
The output is a simple text

```rib

let result = get-player-state(request.path.device-type); 
let response_body = if result == \"admin-netflix\" then  {status: 403, body: \"Unauthorized\"} else {status: 200, body: result} ; 
response_body

```

-------------



## Route 3: Get the latest player state (buffering, playing) tracked for a particular device-type of the user

##### Route-details 

```
 "method": "Get",
 "path": "/v3/player-state/{user-id}?{device-type}",
 "workerName": "event-processor-${request.path.user-id}",
      
```

Rib: In this case, body is a `record` type detailing the events. 

```rib
let result = get-latest-event-details(request.path.device-type); 
let response_body = {status: 200, body: result} ; 
response_body

```

-------------

## Route 4: Get the total play time tracked for a particular device-type of the user

In this case the worker actually responds with a `Result<u64, String>`. 
We need to manipulate this data to send back a meaningful response to the user.

##### Route-details

```
 "method": "Get",
 "path": "/v3/total-play-time/{user-id}?{device-type}",
 "workerName": "event-processor-${request.path.user-id}",
      
```

Rib: Explaining Patter Match, Error Handling, String Concatenation

```rib
let result = get-total-play-time(request.path.device-type);  
let status = match result { ok(_) => 200, err(_) => 400 };  
let response_body = match result { ok(value) => "playtime:${value}", err(msg) => msg }; 
{status: status, body: response_body}

```

-------------

## Route 5: Get the total play time tracked for a particular movie played on a particular device-type of the user.

In this case the worker actually responds with a `Result<Option<u64>, String>`.
This indicates that the total playtime is a Ok(None) if the user hasn't ever played that movie yet.
And it can also throw an error with a message as `Str` if you pass an invalid device-id, or for other failure scenarios.

##### Route-details

```
 "method": "Get",
 "path": "/v3/total-play-time-of-movie/{user-id}?{device-type}&{movie-name}",
 "workerName": "event-processor-${request.path.user-id}",
      
```

Rib: Explaining Patter Match, Error Handling, String Concatenation

```rib
let result = get-total-play-time(request.path.device-type);  
let status = match result { ok(_) => 200, err(_) => 400 };  
let response_body = match result { ok(value) => "playtime:${value}", err(msg) => msg }; 
{status: status, body: response_body}

```

-------------
