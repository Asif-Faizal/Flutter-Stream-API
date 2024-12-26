import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

abstract class UserRemoteDataSource {
  Stream<List<UserModel>> getUsersStream();
}

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
            // Handle SSE format by removing the "data: " prefix
            final String jsonStr = chunk.startsWith('data: ') 
                ? chunk.substring(6) 
                : chunk;
            
            final List<dynamic> usersJson = json.decode(jsonStr);
            final List<UserModel> users = usersJson
                .map((json) => UserModel.fromJson(json))
                .toList();
            yield users;
          } catch (e) {
            print('Error parsing chunk: $e');
            print('Chunk content: $chunk');
            continue;
          }
        }
      }
    } else {
      throw Exception('Failed to connect to stream: ${response.statusCode}');
    }
  }
}

class UserRemoteDataSourceWithRetry implements UserRemoteDataSource {
  final UserRemoteDataSource _dataSource;
  final Duration retryDelay;
  final int maxRetries;

  UserRemoteDataSourceWithRetry(
    this._dataSource, {
    this.retryDelay = const Duration(seconds: 5),
    this.maxRetries = 3,
  });

  @override
  Stream<List<UserModel>> getUsersStream() async* {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await for (final users in _dataSource.getUsersStream()) {
          yield users;
        }
        break; // If we get here, the stream completed normally
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        print('Stream error, attempting retry $attempts after $retryDelay: $e');
        await Future.delayed(retryDelay);
      }
    }
  }
}