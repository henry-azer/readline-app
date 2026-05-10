import 'package:flutter_test/flutter_test.dart';
import 'package:readline_app/core/services/content_generation/content_generation_response_parser.dart';

void main() {
  const parser = ContentGenerationResponseParser();

  group('parse — TITLE/--- format', () {
    test('parses title and body, strips trailing separator', () {
      final result = parser.parse(
        'TITLE: A Quiet Morning\n---\n'
        'The harbor was still and the gulls were drifting silently above the water.\n'
        '---',
      );
      expect(result, isNotNull);
      expect(result!.title, 'A Quiet Morning');
      expect(result.body.endsWith('---'), false);
      expect(result.body.startsWith('The harbor'), true);
    });

    test('when body is a JSON envelope, body field gets unwrapped not dumped raw', () {
      final result = parser.parse(
        'TITLE: Octopus Minds\n---\n'
        '{"body":"Octopuses solve puzzles and remember faces."}',
      );
      expect(result, isNotNull);
      expect(result!.title, 'Octopus Minds');
      expect(result.body.contains('{'), false);
      expect(result.body.contains('"body"'), false);
      expect(result.body.startsWith('Octopuses'), true);
    });

    test('body wrapped in ```json fences is unwrapped', () {
      final result = parser.parse(
        'TITLE: Tides And Time\n---\n'
        '```json\n{"passage":"Tides rise and fall twice each day."}\n```',
      );
      expect(result, isNotNull);
      expect(result!.title, 'Tides And Time');
      expect(result.body, 'Tides rise and fall twice each day.');
    });

    test('JSON-shaped title is rejected and replaced with title from body', () {
      final result = parser.parse(
        'TITLE: {"title": "junk", "body": "..."}\n---\n'
        'The lighthouse keeper rose before dawn to trim the wicks.',
      );
      expect(result, isNotNull);
      expect(result!.title.contains('{'), false);
      expect(result.title.contains('"'), false);
      expect(result.title.toLowerCase().contains('lighthouse'), true);
      expect(result.body.startsWith('The lighthouse'), true);
    });

    test('strips "Variant 12345:" prefix the model echoes from the seed', () {
      final result = parser.parse(
        'TITLE: Variant 50008: The Curious Path\n---\n'
        'Curiosity has always been a quiet engine of human discovery and progress.',
      );
      expect(result, isNotNull);
      expect(result!.title, 'The Curious Path');
      expect(result.title.toLowerCase().contains('variant'), false);
      expect(RegExp(r'\d').hasMatch(result.title), false);
    });

    test('strips surrounding markdown emphasis chars on both ends of title', () {
      final result = parser.parse(
        'TITLE: *The Ripple Effect*\n---\n'
        'Small acts of kindness create ripples that touch many lives over time.',
      );
      expect(result, isNotNull);
      expect(result!.title, 'The Ripple Effect');
      expect(result.title.contains('*'), false);
    });

    test('strips trailing punctuation and trailing whitespace from title', () {
      final result = parser.parse(
        'TITLE: The Quiet Power of Everyday Moments  \n---  \n'
        'In the quiet hum of a rainy afternoon, we sometimes find ourselves at peace.',
      );
      expect(result, isNotNull);
      expect(result!.title, 'The Quiet Power of Everyday Moments');
      expect(result.title.endsWith(' '), false);
    });

    test('plain prose body stays untouched', () {
      final result = parser.parse(
        'TITLE: Solar Cells\n---\n'
        'A photovoltaic cell uses silicon to convert photons into electrical current.',
      );
      expect(result, isNotNull);
      expect(result!.body.startsWith('A photovoltaic'), true);
      expect(result.body.contains('current'), true);
    });

    test('strips a second --- separator the model echoes before the body', () {
      final result = parser.parse(
        'TITLE: A Quiet Morning\n---\n'
        '---      \n'
        'The harbor was still and the gulls were drifting silently above.',
      );
      expect(result, isNotNull);
      expect(result!.title, 'A Quiet Morning');
      expect(result.body.startsWith('---'), false);
      expect(result.body.startsWith('The harbor'), true);
    });

    test('strips multiple leading --- separator lines', () {
      final result = parser.parse(
        'TITLE: A Quiet Morning\n---\n'
        '---\n'
        '---   \n'
        'The harbor was still.',
      );
      expect(result, isNotNull);
      expect(result!.body.startsWith('---'), false);
      expect(result.body.startsWith('The harbor'), true);
    });

    test('strips smart double quotes from title', () {
      final result = parser.parse(
        'TITLE: “The Quiet Path”\n---\n'
        'A passage about a quiet path through the woods that meanders for miles.',
      );
      expect(result, isNotNull);
      expect(result!.title, 'The Quiet Path');
      expect(result.title.contains('“'), false);
      expect(result.title.contains('”'), false);
    });
  });

  group('parse — JSON shaped responses', () {
    test('extracts title and body from a JSON object', () {
      final result = parser.parse(
        '{"title":"Octopus Minds","body":"Octopuses solve puzzles and remember faces."}',
      );
      expect(result, isNotNull);
      expect(result!.title, 'Octopus Minds');
      expect(result.body, 'Octopuses solve puzzles and remember faces.');
    });

    test('handles JSON wrapped in commentary or markdown fences', () {
      final result = parser.parse(
        'Here is the passage:\n```json\n'
        '{"title": "Coral Lives", "passage": "Reefs grow slowly across centuries."}\n'
        '```',
      );
      expect(result, isNotNull);
      expect(result!.title, 'Coral Lives');
      expect(result.body, 'Reefs grow slowly across centuries.');
    });

    test('unwraps OpenAI-style choices.message.content envelope', () {
      final result = parser.parse(
        '{"choices":[{"message":{"content":"TITLE: Edge of Dawn\\n---\\nThe sky began to glow."}}]}',
      );
      expect(result, isNotNull);
      expect(result!.body.contains('The sky began to glow'), true);
    });

    test('falls back when JSON has no body-ish field', () {
      final result = parser.parse(
        '{"title":"Just A Title","unrelated":"value"}',
      );
      expect(result, isNotNull);
    });

    test('derives title from body when JSON has body but no title', () {
      final result = parser.parse(
        '{"body":"The lighthouse keeper rose before dawn to trim the wicks."}',
      );
      expect(result, isNotNull);
      expect(result!.title, isNot('Generated passage'));
      expect(result.title.toLowerCase().contains('lighthouse'), true);
    });
  });

  group('parse — chat envelope unwrapping', () {
    test('raw OpenAI message JSON is unwrapped, not parsed as text', () {
      final result = parser.parse(
        '{"role":"assistant","reasoning":"We need to output exactly:\\n\\n'
        'TITLE: <title>\\n---\\n<the passage>","content":"TITLE: Sunrise '
        'Over The Bay\\n---\\nFishing boats slipped out of the harbor as '
        'the eastern sky turned pale orange and the gulls circled overhead."}',
      );
      expect(result, isNotNull);
      expect(result!.title, 'Sunrise Over The Bay');
      expect(result.title.contains('{'), false);
      expect(result.title.contains('reasoning'), false);
      expect(result.body, contains('Fishing boats'));
      expect(result.body.contains('"reasoning"'), false);
    });

    test('envelope with empty content returns null', () {
      final result = parser.parse(
        '{"role":"assistant","reasoning":"thinking...","content":null}',
      );
      expect(result, isNull);
    });

    test('choices envelope is unwrapped', () {
      final result = parser.parse(
        '{"choices":[{"message":{"role":"assistant","content":'
        '"TITLE: Edge Of Dawn\\n---\\nThe sky began to glow as the first '
        'light of day broke gently over the calm sea."}}],"object":"chat.completion"}',
      );
      expect(result, isNotNull);
      expect(result!.title, 'Edge Of Dawn');
      expect(result.body, contains('The sky began to glow'));
    });

  });

  group('parse — refusal detection', () {
    test('refusal text is rejected as null', () {
      final result = parser.parse(
        "I'm sorry, but I can't produce a passage that long.",
      );
      expect(result, isNull);
    });

    test('detects refusal with smart apostrophe', () {
      final result = parser.parse(
        "I'm sorry, but I can't produce that for you.",
      );
      expect(result, isNull);
    });
  });

  group('parse — empty input', () {
    test('empty string returns null', () {
      expect(parser.parse(''), isNull);
      expect(parser.parse('   \n   '), isNull);
    });
  });
}
