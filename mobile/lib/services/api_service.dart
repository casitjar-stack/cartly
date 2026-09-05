import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/item.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Map<String, String> _headers(String userId) {
    return {
      'Content-Type': 'application/json',
      'x-user-id': userId,
    };
  }

  Future<List<Item>> getItems(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/items'),
      headers: _headers(userId),
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response));
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((json) => Item.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Item> createItem(
    String userId,
    String name,
    int quantity,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: _headers(userId),
      body: jsonEncode({
        'name': name,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_getErrorMessage(response));
    }

    return Item.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Item> toggleBought(String userId, String itemId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/items/$itemId/toggle'),
      headers: _headers(userId),
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response));
    }

    return Item.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteItem(String userId, String itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/items/$itemId'),
      headers: _headers(userId),
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response));
    }
  }

  Future<int> clearBought(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/items/bought/clear'),
      headers: _headers(userId),
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response));
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return data['deletedCount'] as int;
  }

  String _getErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        final message = data['message'];

        if (message is List) {
          return message.join(', ');
        }

        if (message != null) {
          return message.toString();
        }
      }
    } catch (_) {}

    return 'Request failed with status ${response.statusCode}';
  }
}