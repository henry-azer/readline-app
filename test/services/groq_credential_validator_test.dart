import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:readline_app/core/services/content_generation/groq_credential_validator.dart';

void main() {
  GroqCredentialValidator validatorReturning(int statusCode) {
    final client = MockClient((req) async {
      expect(req.url.toString(), 'https://api.groq.com/openai/v1/models');
      expect(req.headers['authorization'], 'Bearer gsk_test');
      return http.Response(statusCode == 200 ? '{}' : 'err', statusCode);
    });
    return GroqCredentialValidator(client: client);
  }

  test('200 → valid', () async {
    expect(
      await validatorReturning(200).validate('gsk_test'),
      GroqCredentialResult.valid,
    );
  });

  test('401 → unauthorized', () async {
    expect(
      await validatorReturning(401).validate('gsk_test'),
      GroqCredentialResult.unauthorized,
    );
  });

  test('403 → unauthorized', () async {
    expect(
      await validatorReturning(403).validate('gsk_test'),
      GroqCredentialResult.unauthorized,
    );
  });

  test('429 → server', () async {
    expect(
      await validatorReturning(429).validate('gsk_test'),
      GroqCredentialResult.server,
    );
  });

  test('5xx → server', () async {
    expect(
      await validatorReturning(503).validate('gsk_test'),
      GroqCredentialResult.server,
    );
  });

  test('network failure → network', () async {
    final client = MockClient((_) async {
      throw http.ClientException('no route to host');
    });
    final validator = GroqCredentialValidator(client: client);
    expect(
      await validator.validate('gsk_test'),
      GroqCredentialResult.network,
    );
  });

  test('empty key → unauthorized (does not call network)', () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return http.Response('', 200);
    });
    final validator = GroqCredentialValidator(client: client);
    expect(
      await validator.validate(''),
      GroqCredentialResult.unauthorized,
    );
    expect(
      await validator.validate('   '),
      GroqCredentialResult.unauthorized,
    );
    expect(called, false);
  });

  test('whitespace-trimmed key sent in header', () async {
    final client = MockClient((req) async {
      expect(req.headers['authorization'], 'Bearer gsk_test');
      return http.Response('{}', 200);
    });
    final validator = GroqCredentialValidator(client: client);
    expect(
      await validator.validate('  gsk_test  '),
      GroqCredentialResult.valid,
    );
  });
}
