import 'package:fuzzy_bolt/fuzzy_bolt.dart';
import 'package:test/test.dart';

void main() {
  group('LevenshteinSimilarity', () {
    late LevenshteinSimilarity algorithm;

    setUp(() {
      algorithm = const LevenshteinSimilarity();
    });

    test('should return 1.0 for identical strings', () {
      expect(algorithm.calculateSimilarity('test', 'test'), equals(1.0));
      expect(algorithm.calculateSimilarity('', ''), equals(1.0));
    });

    test('should return 0.0 for empty vs non-empty strings', () {
      expect(algorithm.calculateSimilarity('', 'test'), equals(0.0));
      expect(algorithm.calculateSimilarity('test', ''), equals(0.0));
    });

    test('should handle single character differences', () {
      final score = algorithm.calculateSimilarity('test', 'best');
      expect(score, equals(0.75)); // 3/4 characters match
    });

    test('should handle insertions', () {
      final score = algorithm.calculateSimilarity('test', 'tests');
      expect(score, equals(0.8)); // 4/5 characters match
    });

    test('should handle deletions', () {
      final score = algorithm.calculateSimilarity('tests', 'test');
      expect(score, equals(0.8)); // 4/5 characters match
    });

    test('should handle substitutions', () {
      final score = algorithm.calculateSimilarity('kitten', 'sitten');
      expect(score, equals(5.0 / 6.0)); // 5/6 characters match
    });

    test('should handle complex transformations', () {
      final score = algorithm.calculateSimilarity('saturday', 'sunday');
      expect(score, greaterThan(0.5));
      expect(score, lessThan(0.8));
    });

    test('should be case sensitive', () {
      final score = algorithm.calculateSimilarity('Test', 'test');
      expect(score, equals(0.75)); // 3/4 characters match
    });

    test('should handle unicode characters', () {
      final score = algorithm.calculateSimilarity('café', 'cafe');
      expect(score, equals(0.75)); // 3/4 characters match
    });

    test('should have correct algorithm name', () {
      expect(algorithm.algorithmName, equals('Levenshtein'));
    });

    group('edge cases', () {
      test('should handle completely different strings', () {
        final score = algorithm.calculateSimilarity('abc', 'xyz');
        expect(score, equals(0.0));
      });

      test('should handle strings of different lengths', () {
        final score = algorithm.calculateSimilarity('a', 'abc');
        expect(score, closeTo(1.0 / 3.0, 0.0001));
      });

      test('should handle single character strings', () {
        expect(algorithm.calculateSimilarity('a', 'a'), equals(1.0));
        expect(algorithm.calculateSimilarity('a', 'b'), equals(0.0));
      });

      test('should handle whitespace and special characters', () {
        final score = algorithm.calculateSimilarity('hello!', 'hello?');
        expect(score, equals(5.0 / 6.0));
      });

      test('should be symmetric', () {
        final score1 = algorithm.calculateSimilarity('abc', 'def');
        final score2 = algorithm.calculateSimilarity('def', 'abc');
        expect(score1, equals(score2));
      });
    });
  });
}
