import 'package:flutter_test/flutter_test.dart';
import 'package:provider_app/core/api/api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = 'https://s4u.lasireneexim.com/api/categories';
  final response = await http.get(Uri.parse(url));
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
