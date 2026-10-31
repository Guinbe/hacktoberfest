import 'dart:convert';

import 'package:http/http.dart' as http;

class TutorServiceException implements Exception {
  const TutorServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TutorService {
  TutorService({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint =
          endpoint ??
          (const String.fromEnvironment('TUTOR_API_URL').isEmpty
              ? null
              : Uri.tryParse(const String.fromEnvironment('TUTOR_API_URL')));

  static const _configuredEndpoint = String.fromEnvironment('TUTOR_API_URL');

  static bool get isConfigured => _configuredEndpoint.isNotEmpty;

  final http.Client _client;
  final Uri? _endpoint;

  Future<String> ask(String question) async {
    final endpoint = _endpoint;
    if (endpoint == null || !_isAllowedEndpoint(endpoint)) {
      throw const TutorServiceException(
        'L’adresse du serveur Sabi n’est pas configurée correctement.',
      );
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            endpoint,
            headers: const {'content-type': 'application/json'},
            body: jsonEncode({'question': question}),
          )
          .timeout(const Duration(seconds: 35));
    } on Exception {
      throw const TutorServiceException(
        'Impossible de joindre Gemma pour le moment.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TutorServiceException(_errorMessage(response.body));
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Réponse JSON invalide.');
      }
      final answer = decoded['response'];
      if (answer is! String || answer.trim().isEmpty) {
        throw const FormatException('Réponse de Gemma absente.');
      }
      return answer.trim();
    } on FormatException {
      throw const TutorServiceException(
        'La réponse reçue est illisible. Réessaie.',
      );
    }
  }

  String _errorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> &&
          decoded['error'] is String &&
          (decoded['error'] as String).trim().isNotEmpty) {
        return (decoded['error'] as String).trim();
      }
    } on FormatException {
      return 'Gemma ne peut pas répondre pour le moment. Réessaie bientôt.';
    }
    return 'Gemma ne peut pas répondre pour le moment. Réessaie bientôt.';
  }

  void close() => _client.close();

  bool _isAllowedEndpoint(Uri endpoint) {
    if (endpoint.host.isEmpty ||
        endpoint.userInfo.isNotEmpty ||
        endpoint.query.isNotEmpty ||
        endpoint.fragment.isNotEmpty) {
      return false;
    }
    if (endpoint.scheme == 'https') return true;
    return endpoint.scheme == 'http' &&
        const {'localhost', '127.0.0.1', '10.0.2.2'}.contains(endpoint.host);
  }
}
