import 'package:fuzzy_bolt/fuzzy_bolt.dart';
import 'package:test/test.dart';

void main() {
  group('FuzzyBolt', () {
    late List<User> users;

    setUp(() {
      users = [
        const User(id: 1, name: "Alice", email: "alice@example.com"),
        const User(id: 2, name: "Bob", email: "bob@sample.com"),
        const User(id: 3, name: "Charlie", email: "charlie@hello.com"),
        const User(id: 4, name: "David", email: "dave@test.org"),
        const User(id: 5, name: "Eve", email: "eve@demo.net"),
        const User(id: 6, name: "Frank", email: "frank@company.io"),
        const User(id: 7, name: "Grace", email: "grace@startup.co"),
        const User(id: 8, name: "Henry", email: "henry@business.com"),
        const User(id: 9, name: "Ivy", email: "ivy@tech.dev"),
        const User(id: 10, name: "Jack", email: "jack@innovation.ai"),
      ];
    });

    group('search()', () {
      test('should return exact matches', () async {
        final results = await FuzzyBolt.search<User>(
          users,
          "Alice",
          selectors: [(u) => u.name],
        );

        expect(results, hasLength(1));
        expect(results.first.name, equals("Alice"));
      });

      test('should handle typos', () async {
        final results = await FuzzyBolt.search<User>(
          users,
          "Alise", // typo in Alice
          selectors: [(u) => u.name],
          typeThreshold: 0.6,
        );

        expect(results, isNotEmpty);
        expect(results.first.name, equals("Alice"));
      });

      test('should search multiple fields', () async {
        final results = await FuzzyBolt.search<User>(
          users,
          "alice@example",
          selectors: [(u) => u.name, (u) => u.email],
          typeThreshold: 0.5, // Lower threshold for better email matching
        );

        expect(results, hasLength(1));
        expect(results.first.email, contains("alice@example"));
      });

      test('should limit results', () async {
        final results = await FuzzyBolt.search<User>(
          users,
          "a", // will match many names
          selectors: [(u) => u.name],
          maxResults: 3,
          typeThreshold: 0.3,
        );

        expect(results.length, lessThanOrEqualTo(3));
      });

      test('should handle empty query', () async {
        final results = await FuzzyBolt.search<User>(
          users,
          "",
          selectors: [(u) => u.name],
        );

        expect(results, isEmpty);
      });

      test('should handle empty dataset', () async {
        final results = await FuzzyBolt.search<User>(
          [],
          "test",
          selectors: [(u) => u.name],
        );

        expect(results, isEmpty);
      });
    });

    group('searchWithScores()', () {
      test('should return results with scores', () async {
        final results = await FuzzyBolt.searchWithScores<User>(
          users,
          "Alice",
          selectors: [(u) => u.name],
        );

        expect(results, hasLength(1));
        expect(results.first.item.name, equals("Alice"));
        expect(results.first.score, greaterThan(0.8));
        expect(results.first.matchedText, isNotEmpty);
      });

      test('should sort by score descending', () async {
        final results = await FuzzyBolt.searchWithScores<User>(
          users,
          "a",
          selectors: [(u) => u.name],
          typeThreshold: 0.3,
        );

        if (results.length > 1) {
          for (int i = 0; i < results.length - 1; i++) {
            expect(
              results[i].score,
              greaterThanOrEqualTo(results[i + 1].score),
            );
          }
        }
      });

      test('should respect thresholds', () async {
        final results = await FuzzyBolt.searchWithScores<User>(
          users,
          "xyz", // unlikely to match well
          selectors: [(u) => u.name],
          typeThreshold: 0.8, // high threshold
        );

        expect(results, isEmpty);
      });
    });

    group('searchWithConfig()', () {
      test('should use configuration object', () async {
        final config = FuzzySearchConfig(
          strictThreshold: 0.9,
          typeThreshold: 0.7,
          maxResults: 5,
          skipIsolate: true,
        );

        final results = await FuzzyBolt.searchWithConfig<User>(users, "Alice", [
          (u) => u.name,
        ], config);

        expect(results, hasLength(1));
        expect(results.first.item.name, equals("Alice"));
      });
    });

    group('edge cases', () {
      test('should handle special characters', () async {
        final specialUsers = [
          const User(id: 1, name: "José", email: "jose@test.com"),
          const User(id: 2, name: "François", email: "francois@test.com"),
          const User(id: 3, name: "Müller", email: "muller@test.com"),
        ];

        final results = await FuzzyBolt.search<User>(
          specialUsers,
          "Jose",
          selectors: [(u) => u.name],
          typeThreshold: 0.6,
        );

        expect(results, isNotEmpty);
      });

      test('should handle whitespace in query', () async {
        final results = await FuzzyBolt.search<User>(
          users,
          "  Alice  ",
          selectors: [(u) => u.name],
        );

        expect(results, hasLength(1));
        expect(results.first.name, equals("Alice"));
      });

      test('should handle case insensitivity', () async {
        final results = await FuzzyBolt.search<User>(
          users,
          "ALICE",
          selectors: [(u) => u.name],
        );

        expect(results, hasLength(1));
        expect(results.first.name, equals("Alice"));
      });
    });
  });
}

// Test models
class User {
  final int id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  @override
  String toString() => 'User(id: $id, name: "$name", email: "$email")';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => Object.hash(id, name, email);
}
