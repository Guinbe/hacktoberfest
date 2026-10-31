import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hacktoberfest/tutor_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'sends a question to the configured proxy and returns its answer',
    () async {
      final service = TutorService(
        endpoint: Uri.parse('https://sabi.example/api/tutor'),
        client: MockClient((request) async {
          expect(request.url.path, '/api/tutor');
          expect(jsonDecode(request.body), {
            'question': 'Aide-moi avec Thalès.',
          });
          expect(request.headers['x-goog-api-key'], isNull);
          return http.Response(
            jsonEncode({'response': 'Repère les droites parallèles.'}),
            200,
          );
        }),
      );
      addTearDown(service.close);

      expect(
        await service.ask('Aide-moi avec Thalès.'),
        'Repère les droites parallèles.',
      );
    },
  );

  test('reports proxy errors without returning a fake answer', () async {
    final service = TutorService(
      endpoint: Uri.parse('https://sabi.example/api/tutor'),
      client: MockClient(
        (_) async => http.Response('{"error":"Service indisponible."}', 502),
      ),
    );
    addTearDown(service.close);

    await expectLater(
      service.ask('Question'),
      throwsA(
        isA<TutorServiceException>().having(
          (error) => error.message,
          'message',
          'Service indisponible.',
        ),
      ),
    );
  });

  test('allows plain HTTP only for local development hosts', () async {
    final service = TutorService(
      endpoint: Uri.parse('http://example.com/api/tutor'),
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    addTearDown(service.close);

    await expectLater(
      service.ask('Question'),
      throwsA(isA<TutorServiceException>()),
    );
  });
}
