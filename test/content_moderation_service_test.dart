import 'package:flutter_test/flutter_test.dart';
import 'package:shecan_ai/services/content_moderation_service.dart';

void main() {
  group('ContentModerationService', () {
    test('allows normal service titles', () {
      final moderation = ContentModerationService();

      expect(moderation.findMatchInText('stiching'), isNull);
      expect(moderation.findMatchInText('stitching'), isNull);
      expect(moderation.findMatchInText('home bakery and cake baking'), isNull);
      expect(
        moderation.findMatchInText('catering and snacks preparation'),
        isNull,
      );
      expect(moderation.findMatchInText('painting'), isNull);
      expect(moderation.findMatchInText('online tutoring'), isNull);
      expect(moderation.findMatchInText('bridal makeup and mehndi'), isNull);
      expect(moderation.findMatchInText('custom tailoring'), isNull);
      expect(moderation.findMatchInText('sewing and cloth repair'), isNull);
      expect(
        moderation.findMatchInText('garment alteration and hemming'),
        isNull,
      );
    });

    test('does not block prohibited substrings inside safe words', () {
      final moderation = ContentModerationService();

      expect(moderation.findMatchInText('unisex clothing'), isNull);
      expect(moderation.findMatchInText('Sussex tutoring'), isNull);
      expect(moderation.findMatchInText('pitching deck design'), isNull);
      expect(moderation.findMatchInText('switching website theme'), isNull);
    });

    test('blocks prohibited service titles', () {
      final moderation = ContentModerationService();

      expect(moderation.findMatchInText('hacking service'), isNotNull);
      expect(moderation.findMatchInText('h@ck account'), isNotNull);
      expect(moderation.findMatchInText('fake passport'), isNotNull);
      expect(moderation.findMatchInText('ddos'), isNotNull);
      expect(moderation.findMatchInText('fake id'), isNotNull);
      expect(moderation.findMatchInText('bot followers'), isNotNull);
      expect(moderation.findMatchInText('account stealing'), isNotNull);
    });

    test('harmful keywords still win when safe keywords are present', () {
      final moderation = ContentModerationService();

      expect(
        moderation.findMatchInText('baking and hacking service'),
        isNotNull,
      );
      expect(
        moderation.findMatchInText('graphic design with fake reviews'),
        isNotNull,
      );
    });
  });
}
