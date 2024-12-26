# Flutter Stream API

This project demonstrates a complete architecture for managing and streaming user data using clean architecture principles, asynchronous streams, and state management with the BLoC (Business Logic Component) pattern in Flutter.

## Overview

The architecture is divided into three main layers:

**Data Layer:** Handles data fetching from external sources (e.g., APIs).
**Domain Layer:** Contains business logic and core entities.
**Presentation Layer:** Manages the UI and state using the BLoC pattern.

The goal is to provide a highly modular and testable architecture that adheres to the principles of clean code.

## Traditional REST APIs

### Request/Response Model:

* In traditional REST APIs, data is fetched by explicitly sending requests to the server and receiving responses.
* Example: To get the latest users, the client repeatedly makes requests (polling) to the /users endpoint.

### Polling Overhead:

* If the client wants real-time updates, it needs to poll the server at regular intervals.
* Polling increases server load and network traffic as the client may send unnecessary requests even when no new data is available.

### Latency:

* Polling introduces latency because updates can only be fetched during the next polling cycle.

### Implementation Simplicity:

* REST APIs are simpler to implement and widely supported by most backends and clients.

## Streaming APIs with SSE (Server-Sent Events)

### Real-Time Data:

* The server pushes updates to the client as soon as new data is available, eliminating the need for polling.
* Example: The UserRemoteDataSource listens to the server's stream endpoint, and updates are received immediately when they occur.

### Efficient Resource Usage:

* Streams reduce unnecessary requests, as the client maintains a single open connection to the server.
* This approach is more efficient for scenarios requiring frequent or real-time updates.

### Lower Latency:

* Data is pushed to the client as soon as it's available, resulting in minimal delay.

### Complexity:

* Implementing streams requires additional considerations such as handling connection lifecycle, retries, and parsing streamed data.

### Use Cases:

* Ideal for real-time features like live user updates, chat applications, stock price tracking, etc.

## Summary

| Feature 	| REST API (Polling) 	| Streaming API (SSE) 	|
|---	|---	|---	|
| Data Delivery 	| Client-initiated 	| Server-initiated 	|
| Real-Time Updates 	| Limited by polling interval 	| Immediate 	|
| Resource Usage 	| High (due to polling) 	| Low (persistent connection) 	|
| Latency 	| High 	| Low 	|
| Implementation 	| Simple 	| More Complex 	|

## Data Source Comparison: REST API vs. Streaming API

### REST API Data Source

In a typical REST API setup, the data source fetches user data with discrete HTTP requests. The implementation might look like this:

```dart
class UserRemoteDataSource {
  final String baseUrl;

  UserRemoteDataSource({required this.baseUrl});

  Future<List<UserModel>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }
}
```

**Characteristics:**
Uses Future for single responses.
Data is fetched upon request (no continuous updates).
Multiple requests are needed for updated data (e.g., through polling).

### Streaming API Data Source

For streaming data, the data source uses Server-Sent Events (SSE) or WebSockets to continuously listen for updates from the server.

```dart
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final String baseUrl;

  UserRemoteDataSourceImpl({required this.baseUrl});

  @override
  Stream<List<UserModel>> getUsersStream() async* {
    final request = http.Request('GET', Uri.parse('$baseUrl/stream-users'));
    final response = await http.Client().send(request);

    if (response.statusCode == 200) {
      await for (final chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.isNotEmpty) {
          try {
            final String jsonStr = chunk.startsWith('data: ') ? chunk.substring(6) : chunk;
            final List<dynamic> usersJson = json.decode(jsonStr);
            yield usersJson.map((json) => UserModel.fromJson(json)).toList();
          } catch (e) {
            print('Error parsing chunk: $e');
            continue;
          }
        }
      }
    } else {
      throw Exception('Failed to connect to stream: ${response.statusCode}');
    }
  }
}
```

**Characteristics:**
Uses Stream for continuous updates.
Establishes a single long-lived connection with the server.
No need to repeatedly send requests for updated data.

**Error Handling:**

* Streaming APIs need robust error handling and retry mechanisms (e.g., reconnecting after a connection failure).
* The UserRemoteDataSourceWithRetry adds retry logic to address these challenges.

```dart
class UserRemoteDataSourceWithRetry implements UserRemoteDataSource {
  final UserRemoteDataSource _dataSource;
  final Duration retryDelay;
  final int maxRetries;

  @override
  Stream<List<UserModel>> getUsersStream() async* {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await for (final users in _dataSource.getUsersStream()) {
          yield users;
        }
        break;
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        await Future.delayed(retryDelay);
      }
    }
  }
}
```
