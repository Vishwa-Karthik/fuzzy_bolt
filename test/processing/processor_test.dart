import 'package:fuzzy_bolt/fuzzy_bolt.dart';
import 'package:test/test.dart';

void main() {
  group('SynchronousProcessor', () {
    late SynchronousProcessor processor;
    late List<TestUser> users;

    setUp(() {
      processor = const SynchronousProcessor();
      users = [
        const TestUser('Alice', 'alice@test.com'),
        const TestUser('Bob', 'bob@test.com'),
        const TestUser('Charlie', 'charlie@test.com'),
      ];
    });

    test('should process search synchronously', () async {
      final results = await processor.processSearch<TestUser>(
        dataset: users,
        query: 'Alice',
        selectors: [(u) => u.name],
        strictThreshold: 0.8,
        typeThreshold: 0.6,
        maxResults: null,
      );

      expect(results, hasLength(1));
      expect(results.first.item.name, equals('Alice'));
      expect(results.first.score, greaterThan(0.8));
    });

    test('should respect max results limit', () async {
      final results = await processor.processSearch<TestUser>(
        dataset: users,
        query: 'a', // matches multiple users
        selectors: [(u) => u.name],
        strictThreshold: 0.5,
        typeThreshold: 0.3,
        maxResults: 2,
      );

      expect(results.length, lessThanOrEqualTo(2));
    });

    test('should never use parallel processing', () {
      expect(processor.shouldUseParallelProcessing(1000, 100, false), isFalse);
      expect(processor.shouldUseParallelProcessing(10000, 100, false), isFalse);
      expect(processor.shouldUseParallelProcessing(1000, 100, true), isFalse);
    });

    test('should handle empty dataset', () async {
      final results = await processor.processSearch<TestUser>(
        dataset: [],
        query: 'test',
        selectors: [(u) => u.name],
        strictThreshold: 0.8,
        typeThreshold: 0.6,
        maxResults: null,
      );

      expect(results, isEmpty);
    });

    test('should handle multiple selectors', () async {
      final results = await processor.processSearch<TestUser>(
        dataset: users,
        query: 'test.com',
        selectors: [(u) => u.name, (u) => u.email],
        strictThreshold: 0.8,
        typeThreshold: 0.4, // Lower threshold to catch all matches
        maxResults: null,
      );

      expect(results, hasLength(3)); // All users have test.com email
    });

    test('should respect thresholds', () async {
      final results = await processor.processSearch<TestUser>(
        dataset: users,
        query: 'xyz',
        selectors: [(u) => u.name],
        strictThreshold: 0.8,
        typeThreshold: 0.8, // high threshold
        maxResults: null,
      );

      expect(results, isEmpty);
    });
  });

  group('IsolateParallelProcessor', () {
    late IsolateParallelProcessor processor;
    late List<TestUser> users;

    setUp(() {
      processor = const IsolateParallelProcessor();
      users = [
        const TestUser('Alice', 'alice@test.com'),
        const TestUser('Bob', 'bob@test.com'),
        const TestUser('Charlie', 'charlie@test.com'),
      ];
    });

    test('should process search with isolates when appropriate', () async {
      final results = await processor.processSearch<TestUser>(
        dataset: users,
        query: 'Alice',
        selectors: [(u) => u.name],
        strictThreshold: 0.8,
        typeThreshold: 0.6,
        maxResults: null,
      );

      expect(results, hasLength(1));
      expect(results.first.item.name, equals('Alice'));
      expect(results.first.score, greaterThan(0.8));
    });

    test('should determine when to use parallel processing', () {
      // Should use for large datasets
      expect(processor.shouldUseParallelProcessing(1500, 1000, false), isTrue);

      // Should not use for small datasets
      expect(processor.shouldUseParallelProcessing(500, 1000, false), isFalse);

      // Should not use when skipIsolate is true
      expect(processor.shouldUseParallelProcessing(1500, 1000, true), isFalse);
    });

    test('should handle fallback to synchronous processing', () async {
      // This should work even if isolates fail internally
      final results = await processor.processSearch<TestUser>(
        dataset: users,
        query: 'test',
        selectors: [(u) => u.email],
        strictThreshold: 0.8,
        typeThreshold: 0.5,
        maxResults: null,
      );

      expect(results, isNotEmpty);
    });

    test('should respect max results in isolate processing', () async {
      final results = await processor.processSearch<TestUser>(
        dataset: users,
        query: 'a',
        selectors: [(u) => u.name],
        strictThreshold: 0.5,
        typeThreshold: 0.3,
        maxResults: 2,
      );

      expect(results.length, lessThanOrEqualTo(2));
    });
  });
}

// Test model
class TestUser {
  final String name;
  final String email;

  const TestUser(this.name, this.email);

  @override
  String toString() => 'TestUser(name: "$name", email: "$email")';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestUser && other.name == name && other.email == email;
  }

  @override
  int get hashCode => Object.hash(name, email);
}
