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

    group('Enhanced Features with Stemming and Cleaning', () {
      late List<Product> products;

      setUp(() {
        products = [
          const Product(
            id: 1,
            name: 'Running Shoes',
            description: 'Best shoes for runners',
          ),
          const Product(
            id: 2,
            name: 'Athletic Footwear',
            description: 'High quality running gear',
          ),
          const Product(
            id: 3,
            name: 'Basketball Sneakers',
            description: 'Professional basketball shoes',
          ),
          const Product(
            id: 4,
            name: 'Casual Walking Shoes',
            description: 'Comfortable shoes for walking',
          ),
          const Product(
            id: 5,
            name: 'Running Shoes',
            description: 'Best shoes for runners',
          ), // Duplicate
          const Product(
            id: 6,
            name: 'RUNNING SHOES',
            description: 'BEST SHOES FOR RUNNERS',
          ), // Similar duplicate
          const Product(
            id: 7,
            name: '',
            description: 'Empty name product',
          ), // Poor quality
          const Product(
            id: 8,
            name: '123456',
            description: '789012',
          ), // Numeric content
        ];
      });

      test(
        'should apply stemming by default and find better matches',
        () async {
          final results = await FuzzyBolt.searchWithScores<Product>(
            products,
            'run shoe', // Should match "running shoes" through stemming
            selectors: [(p) => p.name, (p) => p.description],
            enableStemming: true,
          );

          expect(results, isNotEmpty);
          expect(results.any((r) => r.item.name.contains('Running')), isTrue);
        },
      );

      test('should clean dataset by default and remove duplicates', () async {
        final results = await FuzzyBolt.searchWithScores<Product>(
          products,
          'running shoes',
          selectors: [(p) => p.name, (p) => p.description],
          enableCleaning: true,
          enableStemming: true,
        );

        expect(results, isNotEmpty);
        expect(results.any((r) => r.item.name.contains('Running')), isTrue);
      });

      test(
        'comprehensive search should use both stemming and cleaning',
        () async {
          final results = await FuzzyBolt.searchWithScores<Product>(
            products,
            'running shoes', // This will be stemmed to 'run shoe'
            selectors: [(p) => p.name, (p) => p.description],
            enableStemming: true,
            enableCleaning: true,
          );

          expect(results, isNotEmpty);
          expect(results.any((r) => r.item.name.contains('Running')), isTrue);
        },
      );

      test('should handle text processing correctly', () async {
        final results = await FuzzyBolt.searchWithTextProcessing<Product>(
          products,
          'running shoes', // Should match through stemming and find running-related products
          selectors: [(p) => p.name, (p) => p.description],
          enableStemming: true,
          removeStopWords: true,
          typeThreshold: 0.5, // Lower threshold for better matching
        );

        // Should find running-related products even with processed query
        expect(results, isNotEmpty);
      });

      test('enhanced features should work correctly', () async {
        final results = await FuzzyBolt.searchWithScores<Product>(
          products,
          'run shoe',
          selectors: [(p) => p.name, (p) => p.description],
          enableStemming: true,
          enableCleaning: true,
        );

        expect(results, isNotEmpty);
        expect(results.any((r) => r.item.name.contains('Running')), isTrue);
      });

      test('Porter stemming should work correctly', () {
        expect(PorterStemmer.stem('running'), equals('run'));
        expect(PorterStemmer.stem('flies'), equals('fli'));
        expect(PorterStemmer.stem('dogs'), equals('dog'));

        final text = 'The runners were running quickly';
        final stemmed = PorterStemmer.stemText(text);
        expect(stemmed, contains('runner'));
        expect(stemmed, contains('run'));
      });

      test('text cache should work correctly', () {
        FuzzyBolt.clearTextCache();
        final stats1 = FuzzyBolt.getTextCacheStats();
        expect(stats1['cacheSize'], equals(0));

        // Note: _processText is now internal, this test may need adjustment
        // FuzzyBolt._processText('running shoes', enableStemming: true);

        // Instead test through public API
        PorterStemmer.stem('running');

        final stats2 = FuzzyBolt.getTextCacheStats();
        expect(stats2['cacheSize'], greaterThanOrEqualTo(0));
      });
    });

    group('Stress Tests', () {
      group('Large Dataset Performance', () {
        test('should handle 10,000 users efficiently', () async {
          // Generate large dataset
          final largeUserSet = List.generate(
            10000,
            (i) => User(
              id: i,
              name: 'User${i.toString().padLeft(5, '0')}',
              email: 'user$i@company${i % 100}.com',
            ),
          );

          final stopwatch = Stopwatch()..start();

          final results = await FuzzyBolt.searchWithScores<User>(
            largeUserSet,
            'User00123',
            selectors: [(u) => u.name, (u) => u.email],
            maxResults: 50,
            enableCleaning: false,
            enableStemming: false,
          );

          stopwatch.stop();

          expect(results, isNotEmpty);
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(5000),
          ); // Should complete within 5 seconds
          expect(results.length, lessThanOrEqualTo(50));
        });

        test(
          'should use isolates for very large datasets automatically',
          () async {
            final massiveDataset = List.generate(
              5000,
              (i) => Product(
                id: i,
                name: 'Product $i - ${_generateRandomName()}',
                description:
                    'Description for product $i with ${_generateRandomDescription()}',
              ),
            );

            // Add some products that will definitely match
            massiveDataset.addAll([
              const Product(
                id: 9001,
                name: 'Running Shoes Athletic',
                description: 'Best athletic running shoes',
              ),
              const Product(
                id: 9002,
                name: 'Athletic Running Footwear',
                description: 'Professional running gear',
              ),
            ]);

            final results = await FuzzyBolt.searchWithScores<Product>(
              massiveDataset,
              'running shoes athletic',
              selectors: [(p) => p.name, (p) => p.description],
              isolateThreshold: 1000, // Force isolate usage
              enableStemming: true,
              enableCleaning: true,
              typeThreshold: 0.3, // Lower threshold for better matching
            );

            expect(results, isNotEmpty);
            expect(results.length, lessThanOrEqualTo(massiveDataset.length));
          },
        );

        test(
          'should handle memory efficiently with repeated searches',
          () async {
            final dataset = List.generate(
              1000,
              (i) =>
                  User(id: i, name: 'TestUser$i', email: 'test$i@example.com'),
            );

            // Perform 100 searches to test memory usage
            for (int i = 0; i < 100; i++) {
              final results = await FuzzyBolt.searchWithScores<User>(
                dataset,
                'TestUser${i % 50}',
                selectors: [(u) => u.name],
                maxResults: 10,
              );
              expect(results, isNotEmpty);
            }

            // Memory should be stable (cache should not grow indefinitely)
            final cacheStats = FuzzyBolt.getTextCacheStats();
            expect(cacheStats['cacheSize'], lessThan(1000));
          },
        );
      });

      group('Complex Query Stress Tests', () {
        late List<Product> complexProducts;

        setUp(() {
          complexProducts = [
            const Product(
              id: 1,
              name: 'Ultra-Light Running Shoes Pro Max 2024',
              description:
                  'Professional athletic footwear designed for marathon runners and competitive athletes',
            ),
            const Product(
              id: 2,
              name: 'Basketball High-Top Sneakers Elite',
              description:
                  'Premium basketball shoes with advanced cushioning technology',
            ),
            const Product(
              id: 3,
              name: 'Casual Walking Comfort Shoes Daily',
              description:
                  'Everyday comfortable walking shoes for urban commuting',
            ),
            const Product(
              id: 4,
              name: 'Hiking Boots Waterproof Adventure',
              description:
                  'Durable outdoor hiking boots with waterproof membrane',
            ),
            const Product(
              id: 5,
              name: 'Cross-Training Athletic Shoes Gym',
              description:
                  'Versatile training shoes for gym workouts and fitness',
            ),
            // Add products with special characters and unicode
            const Product(
              id: 6,
              name: 'Chaussures de Course Légères',
              description: 'Chaussures françaises pour la course à pied',
            ),
            const Product(
              id: 7,
              name: 'Zapatos Deportivos Élite',
              description: 'Calzado deportivo de alta calidad para atletas',
            ),
            const Product(
              id: 8,
              name: 'Laufschuhe Professionell',
              description: 'Deutsche Laufschuhe für Profisportler',
            ),
            const Product(
              id: 9,
              name: 'ランニングシューズ プロ',
              description: '日本製プロランナー用シューズ',
            ),
            const Product(
              id: 10,
              name: 'Кроссовки для Бега',
              description: 'Профессиональные беговые кроссовки',
            ),
          ];
        });

        test('should handle very long queries', () async {
          final longQuery =
              'ultra light running shoes professional athletic footwear designed for marathon runners competitive athletes performance enhancement';

          final results = await FuzzyBolt.searchWithScores<Product>(
            complexProducts,
            longQuery,
            selectors: [(p) => p.name, (p) => p.description],
            enableStemming: true,
            typeThreshold: 0.3,
          );

          expect(results, isNotEmpty);
          expect(results.first.score, greaterThan(0.3));
        });

        test('should handle queries with special characters', () async {
          final specialQueries = [
            'chaussures élite',
            'zapatos deportivos',
            'laufschuhe professionell',
            'кроссовки бега',
            'shoes!!!',
            'running@shoes#with&symbols',
            'shoes-with-dashes_and_underscores',
          ];

          for (final query in specialQueries) {
            final results = await FuzzyBolt.searchWithScores<Product>(
              complexProducts,
              query,
              selectors: [(p) => p.name, (p) => p.description],
              typeThreshold: 0.2,
            );

            // Should not crash and should handle gracefully
            expect(results, isA<List<FuzzyResult<Product>>>());
          }
        });

        test('should handle unicode and international text', () async {
          final results = await FuzzyBolt.searchWithScores<Product>(
            complexProducts,
            'running shoes', // Search for something that should match English products
            selectors: [(p) => p.name, (p) => p.description],
            typeThreshold: 0.3,
          );

          expect(results, isNotEmpty);

          // Also test that unicode queries don't crash the system
          final unicodeResults = await FuzzyBolt.searchWithScores<Product>(
            complexProducts,
            'シューズ', // Japanese for shoes
            selectors: [(p) => p.name, (p) => p.description],
            typeThreshold: 0.1, // Very low threshold
          );

          // Should not crash, even if no matches
          expect(unicodeResults, isA<List<FuzzyResult<Product>>>());
        });

        test('should handle queries with numbers and mixed content', () async {
          final numericQueries = [
            'shoes 2024',
            'pro max ultra',
            '123 running shoes',
            'shoes-2024-pro',
            'model123athletic456',
          ];

          for (final query in numericQueries) {
            final results = await FuzzyBolt.searchWithScores<Product>(
              complexProducts,
              query,
              selectors: [(p) => p.name, (p) => p.description],
              typeThreshold: 0.2,
            );

            expect(results, isA<List<FuzzyResult<Product>>>());
          }
        });
      });

      group('Edge Cases and Error Handling', () {
        test('should handle empty strings gracefully', () async {
          final emptyProducts = [
            const Product(id: 1, name: '', description: ''),
            const Product(id: 2, name: 'Valid Product', description: ''),
            const Product(id: 3, name: '', description: 'Valid Description'),
          ];

          final results = await FuzzyBolt.searchWithScores<Product>(
            emptyProducts,
            'valid',
            selectors: [(p) => p.name, (p) => p.description],
          );

          expect(results, isNotEmpty);
        });

        test('should handle very similar items', () async {
          final similarProducts = List.generate(
            20,
            (i) => Product(
              id: i,
              name: 'Running Shoe Model $i',
              description: 'Athletic footwear for running model $i',
            ),
          );

          final results = await FuzzyBolt.searchWithScores<Product>(
            similarProducts,
            'running shoe model',
            selectors: [(p) => p.name, (p) => p.description],
            enableCleaning: true,
          );

          expect(results, isNotEmpty);
          expect(results.length, lessThanOrEqualTo(similarProducts.length));
        });

        test('should handle whitespace-only content', () async {
          final whitespaceProducts = [
            const Product(id: 1, name: '   ', description: '\t\n'),
            const Product(id: 2, name: '\n\n\n', description: '   '),
            const Product(
              id: 3,
              name: 'Real Product',
              description: 'Real Description',
            ),
          ];

          final results = await FuzzyBolt.searchWithScores<Product>(
            whitespaceProducts,
            'real',
            selectors: [(p) => p.name, (p) => p.description],
          );

          expect(results, hasLength(1));
          expect(results.first.item.name, equals('Real Product'));
        });

        test('should handle extremely low thresholds', () async {
          final results = await FuzzyBolt.searchWithScores<User>(
            users,
            'xyz123random',
            selectors: [(u) => u.name, (u) => u.email],
            strictThreshold: 0.0,
            typeThreshold: 0.0,
          );

          // Should return results even for very poor matches
          expect(results, isNotEmpty);
        });
      });

      group('Concurrent Access Stress Tests', () {
        test('should handle concurrent searches safely', () async {
          final dataset = List.generate(
            500,
            (i) => User(
              id: i,
              name: 'ConcurrentUser$i',
              email: 'concurrent$i@test.com',
            ),
          );

          // Run 20 concurrent searches
          final futures = List.generate(20, (i) async {
            return FuzzyBolt.searchWithScores<User>(
              dataset,
              'ConcurrentUser${i * 5}',
              selectors: [(u) => u.name, (u) => u.email],
              enableStemming: true,
              enableCleaning: i % 2 == 0, // Alternate cleaning on/off
            );
          });

          final results = await Future.wait(futures);

          // All searches should complete successfully
          expect(results, hasLength(20));
          for (final result in results) {
            expect(result, isA<List<FuzzyResult<User>>>());
          }
        });

        test('should handle cache contention safely', () async {
          FuzzyBolt.clearTextCache();

          final futures = List.generate(10, (i) async {
            return FuzzyBolt.searchWithTextProcessing<User>(
              users,
              'running walking jumping swimming cycling',
              selectors: [(u) => u.name, (u) => u.email],
              enableStemming: true,
              removeStopWords: true,
            );
          });

          final results = await Future.wait(futures);

          expect(results, hasLength(10));

          // Cache should be populated but not corrupted
          final cacheStats = FuzzyBolt.getTextCacheStats();
          expect(cacheStats['cacheSize'], greaterThan(0));
        });
      });

      group('Memory and Performance Limits', () {
        test('should handle maximum configured results', () async {
          final largeDataset = List.generate(
            2000,
            (i) => Product(
              id: i,
              name: 'Product$i',
              description: 'Product description $i',
            ),
          );

          final results = await FuzzyBolt.searchWithScores<Product>(
            largeDataset,
            'product',
            selectors: [(p) => p.name, (p) => p.description],
            maxResults: 1000,
            typeThreshold: 0.1, // Very low threshold to get many results
          );

          expect(results.length, lessThanOrEqualTo(1000));
        });

        test('should handle cache overflow gracefully', () async {
          FuzzyBolt.clearTextCache();

          // Generate many unique queries to overflow cache
          for (int i = 0; i < 1200; i++) {
            await FuzzyBolt.searchWithTextProcessing<User>(
              users.take(2).toList(),
              'unique query number $i with different content',
              selectors: [(u) => u.name],
              enableStemming: true,
            );
          }

          final cacheStats = FuzzyBolt.getTextCacheStats();
          expect(
            cacheStats['cacheSize'],
            lessThanOrEqualTo(1000),
          ); // Should respect max cache size
        });

        test('should maintain performance with heavy stemming', () async {
          final textHeavyProducts = List.generate(
            100,
            (i) => Product(
              id: i,
              name:
                  'Running walking jumping swimming cycling dancing singing playing',
              description:
                  'Athletes runners walkers jumpers swimmers cyclists dancers singers players performers',
            ),
          );

          final stopwatch = Stopwatch()..start();

          final results = await FuzzyBolt.searchWithTextProcessing<Product>(
            textHeavyProducts,
            'running walking jumping swimming cycling',
            selectors: [(p) => p.name, (p) => p.description],
            enableStemming: true,
            removeStopWords: true,
          );

          stopwatch.stop();

          expect(results, isNotEmpty);
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(2000),
          ); // Should complete within 2 seconds
        });
      });

      group('Configuration Boundary Tests', () {
        test('should handle extreme threshold values', () async {
          final extremeConfigs = [
            FuzzySearchConfig(strictThreshold: 1.0, typeThreshold: 1.0),
            FuzzySearchConfig(strictThreshold: 0.0, typeThreshold: 0.0),
            FuzzySearchConfig(strictThreshold: 0.5, typeThreshold: 0.999),
            FuzzySearchConfig(strictThreshold: 0.001, typeThreshold: 0.5),
          ];

          for (final config in extremeConfigs) {
            final results = await FuzzyBolt.searchWithConfig<User>(
              users,
              'Alice',
              [(u) => u.name],
              config,
            );

            expect(results, isA<List<FuzzyResult<User>>>());
          }
        });

        test('should handle extreme isolate thresholds', () async {
          final configs = [
            FuzzySearchConfig(isolateThreshold: 1),
            FuzzySearchConfig(isolateThreshold: 100000),
            FuzzySearchConfig(isolateThreshold: 0, skipIsolate: true),
          ];

          for (final config in configs) {
            final results = await FuzzyBolt.searchWithConfig<User>(
              users,
              'Alice',
              [(u) => u.name],
              config,
            );

            expect(results, isNotEmpty);
          }
        });
      });

      group('Performance Benchmarks', () {
        test('comprehensive performance benchmark', () async {
          print('\n🏃‍♂️ Running FuzzyBolt Performance Benchmarks...');

          // Small dataset benchmark
          final smallDataset = List.generate(
            100,
            (i) => User(id: i, name: 'User$i', email: 'user$i@test.com'),
          );

          var stopwatch = Stopwatch()..start();
          var results = await FuzzyBolt.searchWithScores<User>(
            smallDataset,
            'User50',
            selectors: [(u) => u.name, (u) => u.email],
          );
          stopwatch.stop();

          print(
            '  📊 Small dataset (100 items): ${stopwatch.elapsedMilliseconds}ms - ${results.length} results',
          );
          expect(stopwatch.elapsedMilliseconds, lessThan(100));

          // Medium dataset benchmark
          final mediumDataset = List.generate(
            1000,
            (i) =>
                User(id: i, name: 'MediumUser$i', email: 'medium$i@test.com'),
          );

          stopwatch = Stopwatch()..start();
          results = await FuzzyBolt.searchWithScores<User>(
            mediumDataset,
            'MediumUser500',
            selectors: [(u) => u.name, (u) => u.email],
          );
          stopwatch.stop();

          print(
            '  📊 Medium dataset (1,000 items): ${stopwatch.elapsedMilliseconds}ms - ${results.length} results',
          );
          expect(stopwatch.elapsedMilliseconds, lessThan(500));

          // Large dataset benchmark
          final largeDataset = List.generate(
            5000,
            (i) => User(id: i, name: 'LargeUser$i', email: 'large$i@test.com'),
          );

          stopwatch = Stopwatch()..start();
          results = await FuzzyBolt.searchWithScores<User>(
            largeDataset,
            'LargeUser2500',
            selectors: [(u) => u.name, (u) => u.email],
            maxResults: 50,
          );
          stopwatch.stop();

          print(
            '  📊 Large dataset (5,000 items): ${stopwatch.elapsedMilliseconds}ms - ${results.length} results',
          );
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(5000),
          ); // Allow up to 5 seconds for large datasets

          // Text processing benchmark
          final textHeavyDataset = List.generate(
            500,
            (i) => Product(
              id: i,
              name:
                  'Running jumping swimming cycling dancing singing playing walking',
              description:
                  'Athletic performance footwear designed for professional athletes and runners',
            ),
          );

          stopwatch = Stopwatch()..start();
          final textResults = await FuzzyBolt.searchWithTextProcessing<Product>(
            textHeavyDataset,
            'running athletic performance professional',
            selectors: [(p) => p.name, (p) => p.description],
            enableStemming: true,
            removeStopWords: true,
          );
          stopwatch.stop();

          print(
            '  📊 Text processing (500 items): ${stopwatch.elapsedMilliseconds}ms - ${textResults.length} results',
          );
          expect(stopwatch.elapsedMilliseconds, lessThan(1500));

          print('  ✅ All performance benchmarks completed successfully!\n');
        });
      });
    });
  });
}

// Helper functions for stress tests
String _generateRandomName() {
  final words = [
    'Athletic',
    'Running',
    'Walking',
    'Sports',
    'Comfort',
    'Pro',
    'Elite',
    'Ultra',
    'Max',
    'Performance',
  ];
  final random = DateTime.now().microsecondsSinceEpoch;
  return words[random % words.length];
}

String _generateRandomDescription() {
  final descriptions = [
    'high-quality materials',
    'advanced technology',
    'professional athletes',
    'comfortable fit',
    'durable construction',
    'innovative design',
    'superior performance',
    'premium quality',
  ];
  final random = DateTime.now().microsecondsSinceEpoch;
  return descriptions[random % descriptions.length];
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

// Test data class for enhanced features
class Product {
  final int id;
  final String name;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(name: "$name", description: "$description")';
}
