import 'dart:convert';

import 'package:http/http.dart' as http;

class GroqError {
  final String message;
  final String type;

  GroqError({required this.message, required this.type});

  factory GroqError.fromJson(Map<String, dynamic> json) => GroqError(
        message: json['error']['message'],
        type: json['error']['type'],
      );

  @override
  String toString() => 'GroqError (Type: $type): $message';
}

class GroqException implements Exception {
  final int statusCode;
  final GroqError error;

  GroqException({required this.statusCode, required this.error});

  factory GroqException.fromResponse(http.Response response) {
    final Map<String, dynamic> jsonBody =
        json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));

    if (jsonBody.containsKey('error')) {
      final groqError = GroqError.fromJson(jsonBody);
      return GroqException(
        statusCode: response.statusCode,
        error: groqError,
      );
    } else {
      // Handle cases where the response doesn't follow the standard Groq error structure
      return GroqException(
        statusCode: response.statusCode,
        error: GroqError(message: 'Unknown error', type: 'unknown_error'),
      );
    }
  }

  @override
  String toString() => 'GroqException (Status Code: $statusCode): $error';
}

class GroqRateLimitException implements GroqException {
  final Duration retryAfter;

  GroqRateLimitException({
    required this.retryAfter,
  });

  @override
  GroqError get error =>
      GroqError(message: 'rate-limit-exceeded', type: 'rate_limit');

  @override
  int get statusCode => 429;

  @override
  String toString() =>
      'GroqRateLimitException (Status Code: $statusCode): $error (Retry After: ${retryAfter.inSeconds} seconds)';
}
