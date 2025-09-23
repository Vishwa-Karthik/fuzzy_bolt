import 'package:fuzzy_bolt/fuzzy_bolt.dart';
import 'package:test/test.dart';

void main() {
  group('JaroWinklerSimilarity', () {
    late JaroWinklerSimilarity algorithm;

    setUp(() {
      algorithm = const JaroWinklerSimilarity();
    });

    test('should return 1.0 for identical strings', () {
      expect(algorithm.calculateSimilarity('test', 'test'), equals(1.0));
      expect(algorithm.calculateSimilarity('', ''), equals(1.0));
    });

    test('should return 0.0 for completely different strings', () {
      expect(algorithm.calculateSimilarity('abc', 'xyz'), lessThan(0.3));
    });

    test('should handle empty strings', () {
      expect(algorithm.calculateSimilarity('', 'test'), equals(0.0));
      expect(algorithm.calculateSimilarity('test', ''), equals(0.0));
    });

    test('should give higher scores for prefix matches', () {
      final prefixScore = algorithm.calculateSimilarity('test', 'testing');
      final noPrefix = algorithm.calculateSimilarity('test', 'sting');

      expect(prefixScore, greaterThan(noPrefix));
    });

    test('should handle transpositions well', () {
      final score = algorithm.calculateSimilarity('martha', 'marhta');
      expect(score, greaterThan(0.9));
    });

    test('should be case sensitive', () {
      final score = algorithm.calculateSimilarity('Test', 'test');
      expect(score, lessThan(1.0));
    });

    test('should handle unicode characters', () {
      final score = algorithm.calculateSimilarity('café', 'cafe');
      expect(score, greaterThan(0.7));
    });

    test('should have correct algorithm name', () {
      expect(algorithm.algorithmName, equals('Jaro-Winkler'));
    });

    group('edge cases', () {
      test('should handle very long strings', () {
        final longString1 = 'a' * 1000;
        final longString2 = 'a' * 999 + 'b';

        final score = algorithm.calculateSimilarity(longString1, longString2);
        expect(score, greaterThan(0.9));
      });

      test('should handle single character strings', () {
        expect(algorithm.calculateSimilarity('a', 'a'), equals(1.0));
        expect(algorithm.calculateSimilarity('a', 'b'), equals(0.0));
      });

      test('should handle whitespace', () {
        final score = algorithm.calculateSimilarity(
          'hello world',
          'hello  world',
        );
        expect(score, greaterThan(0.8));
      });
    });
  });
}
