import 'package:fuzzy_bolt/fuzzy_bolt.dart';
import 'package:test/test.dart';

void main() {
  group('AdaptiveRankingStrategy', () {
    late AdaptiveRankingStrategy<TestItem> strategy;
    late List<SearchCandidate<TestItem>> candidates;

    setUp(() {
      strategy = const AdaptiveRankingStrategy<TestItem>();

      final items = [
        const TestItem('apple', 'fruit'),
        const TestItem('application', 'software'),
        const TestItem('apply', 'action'),
        const TestItem('banana', 'fruit'),
        const TestItem('band', 'music'),
      ];

      candidates =
          items.map((item) {
            return SearchCandidate<TestItem>(
              item: item,
              searchableText: '${item.name} ${item.category}',
              fieldTexts: [item.name, item.category],
            );
          }).toList();
    });

    test('should rank exact matches highest', () {
      final results = strategy.rankCandidates(candidates, 'apple', 0.8, 0.6);

      expect(results, isNotEmpty);
      expect(results.first.item.name, equals('apple'));
      expect(results.first.score, greaterThan(0.9));
    });

    test('should handle partial matches', () {
      final results = strategy.rankCandidates(candidates, 'app', 0.8, 0.5);

      expect(results, isNotEmpty);

      // Should find items starting with 'app'
      final names = results.map((r) => r.item.name).toList();
      expect(names, contains('apple'));
      expect(names, contains('application'));
      expect(names, contains('apply'));
    });

    test('should respect type threshold', () {
      final results = strategy.rankCandidates(
        candidates,
        'xyz', // should not match anything
        0.8,
        0.8, // high threshold
      );

      expect(results, isEmpty);
    });

    test('should sort results by score descending', () {
      final results = strategy.rankCandidates(candidates, 'app', 0.8, 0.3);

      if (results.length > 1) {
        for (int i = 0; i < results.length - 1; i++) {
          expect(results[i].score, greaterThanOrEqualTo(results[i + 1].score));
        }
      }
    });

    test('should include matched text in results', () {
      final results = strategy.rankCandidates(candidates, 'apple', 0.8, 0.6);

      expect(results, isNotEmpty);
      expect(results.first.matchedText, isNotEmpty);
    });

    test('should handle empty query gracefully', () {
      final results = strategy.rankCandidates(candidates, '', 0.8, 0.6);

      expect(results, isEmpty);
    });

    test('should handle case insensitive matching', () {
      final results = strategy.rankCandidates(candidates, 'APPLE', 0.8, 0.6);

      expect(results, isNotEmpty);
      expect(results.first.item.name, equals('apple'));
    });

    test('should have correct strategy name', () {
      expect(
        strategy.strategyName,
        equals('Adaptive (Jaro-Winkler + Levenshtein)'),
      );
    });

    group('algorithm weights', () {
      test('should use custom weights', () {
        final customStrategy = AdaptiveRankingStrategy<TestItem>(
          jaroWinklerWeight: 0.8,
          levenshteinWeight: 0.2,
        );

        final results = customStrategy.rankCandidates(
          candidates,
          'apple',
          0.8,
          0.6,
        );

        expect(results, isNotEmpty);
        expect(results.first.score, greaterThan(0.0));
      });

      test('should validate weight constraints', () {
        expect(
          () => AdaptiveRankingStrategy<TestItem>(
            jaroWinklerWeight: 1.5, // invalid
            levenshteinWeight: 0.2,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('field matching', () {
      test('should match against individual fields', () {
        final results = strategy.rankCandidates(candidates, 'fruit', 0.8, 0.6);

        expect(results, isNotEmpty);

        // Should find items in fruit category
        final categories = results.map((r) => r.item.category).toSet();
        expect(categories, contains('fruit'));
      });

      test('should prioritize best field match', () {
        final results = strategy.rankCandidates(
          candidates,
          'application software',
          0.8,
          0.5,
        );

        expect(results, isNotEmpty);

        // Should rank the application item highly
        final topResult = results.first;
        expect(topResult.item.name, equals('application'));
      });
    });
  });
}

// Test model
class TestItem {
  final String name;
  final String category;

  const TestItem(this.name, this.category);

  @override
  String toString() => 'TestItem(name: "$name", category: "$category")';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestItem &&
        other.name == name &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(name, category);
}
