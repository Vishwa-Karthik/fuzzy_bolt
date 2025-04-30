import 'dart:async';

import 'package:fuzzy_bolt/src/fuzzy_bolt.dart';
import 'package:test/test.dart';

void main() {
  late List<String> dataset;
  late FuzzyBolt fuzzyBolt;

  setUp(() {
    fuzzyBolt = FuzzyBolt();

    dataset = [
      "apple",
      "banana",
      "grape",
      "apricot",
      "mango",
      "Pineapple",
      "blueberry",
      "Strawberry",
      "watermelon",
      "cantaloupe",
      "raspberry",
      "blackberry",
      "dragonfruit",
      "kiwi",
      "mangosteen",
      "grapefruit",
      "pomegranate",
      "lemon",
      "lime",
      "orange",
      "tangerine",
      "avocado",
      "coconut",
      "fig",
      "date",
      "passionfruit",
      "jackfruit",
    ];
  });

  group('FuzzyBolt Search Tests', () {
    test('Basic exact match', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "mango",
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.any((test) => test == "mango"), true);
      expect(results.any((test) => test == "mangosteen"), true);
    });

    test('Handles simple typo', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "aple", // Typo for "apple"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.any((test) => test == "apple"), true);
    });

    test('Handles phonetic similarity', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "mengo", // Should match "mango"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.any((test) => test == "mango"), true);
    });

    test('Handles case insensitivity', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "PINEAPPLE", // Should match "Pineapple"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.any((test) => test.toLowerCase() == "pineapple"), true);
    });

    test('Handles partial matches', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "grap", // Should match "grape", "grapefruit"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.any((test) => test.contains("grape")), true);
      expect(results.any((test) => test.contains("grapefruit")), true);
      expect(results.length, 2);
    });

    test('Handles multi-word queries', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "passion fruit", // Should match "passionfruit"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.any((test) => test == "passionfruit"), true);
    });

    test('Handles abbreviations', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "straw", // Should match "strawberry"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.any((test) => test == "strawberry"), true);
    });

    test('Handles special characters', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "avoc@do", // Should match "avocado"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.any((test) => test == "avocado"), true);
    });

    test('Handles no matches gracefully', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "xylophone", // Should return an empty list
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isEmpty, true);
    });

    test('Handles long and complex queries', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: dataset,
        query: "black rasp", // Should match "blackberry" or "raspberry"
        strictThreshold: 0.65,
        typoThreshold: 0.5,
      );
      expect(results.isNotEmpty, true);
      expect(results.any((test) => test.contains("blackberry")), true);
      expect(results.any((test) => test.contains("raspberry")), true);
      expect(results.length, 2);
    });
    test('Handles errors gracefully with onError callback', () async {
      final List<String> results = await fuzzyBolt.search(
        dataset: [], // Empty dataset to trigger an error
        query: "mango",
        strictThreshold: 0.85,
        typoThreshold: 0.7,
        onError: (error, stackTrace) {
          expect(error.toString(), contains("Dataset cannot be empty."));
        },
      );
      expect(results.isEmpty, true);
    });
  });

  group('FuzzyBolt Search Tests With Ranks', () {
    test('Basic exact match', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "mango",
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "mango");
      expect(results, "mango");
    });

    test('Handles simple typo', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "aple", // Typo for "apple"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "apple");
    });

    test('Handles phonetic similarity', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "mengo", // Should match "mango"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "mango");
    });

    test('Handles case insensitivity', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "PINEAPPLE", // Should match "Pineapple"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'].toLowerCase(), "pineapple");
    });

    test('Handles partial matches', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "grap", // Should match "grape", "grapefruit"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);

      expect(results.first['value'].contains("grape"), true);
      expect(results[1]['value'].contains("grapefruit"), true);
      expect(results.length, 2);
    });

    test('Handles multi-word queries', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "passion fruit", // Should match "passionfruit"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "passionfruit");
    });

    test('Handles abbreviations', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "straw", // Should match "strawberry"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "strawberry");
    });

    test('Handles special characters', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "avoc@do", // Should match "avocado"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "avocado");
    });

    test('Handles no matches gracefully', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "xylophone", // Should return an empty list
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isEmpty, true);
    });

    test('Handles long and complex queries', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: dataset,
        query: "black rasp", // Should match "blackberry" or "raspberry"
        strictThreshold: 0.65,
        typoThreshold: 0.5,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'].contains("blackberry"), true);
      expect(results[1]['value'].contains("raspberry"), true);

      expect(results.length, 2);
    });

    test('Handles errors gracefully with onError callback', () async {
      final results = await fuzzyBolt.searchWithRanks(
        dataset: [],
        query: "mango",
        strictThreshold: 0.85,
        typoThreshold: 0.7,
        onError: (error, stackTrace) {
          expect(error.toString(), contains("Dataset cannot be empty."));
        },
      );
      expect(results.isEmpty, true);
    });
  });

  group('stream Search Tests', () {
    test('streamSearch emits correct fuzzy results for a query', () async {
      final results = <List<String>>[];
      StreamController<String> queryController = StreamController<String>();

      final searchStream = FuzzyBolt().streamSearch(
        dataset: dataset,
        query: queryController.stream,
      );

      final subscription = searchStream.listen((event) {
        results.add(event);
      });

      // Add query after small delay
      await Future.delayed(Duration(milliseconds: 100));
      queryController.add('mango');

      // Allow time for async search processing
      await Future.delayed(Duration(milliseconds: 700));

      expect(results, isNotEmpty);
      expect(results.first.any((item) => item.contains('mango')), isTrue);
      expect(results.first, contains('mango'));
      expect(results.first, contains('mangosteen'));

      await subscription.cancel();
      await queryController.close();
    });

    test('Handles empty query input', () async {
      StreamController<String> queryController = StreamController<String>();
      final searchStream = fuzzyBolt.streamSearch(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<String>>[];
      final subscription = searchStream.listen(results.add);

      queryController.add("");
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isEmpty, true);
      expect(results.length, 0);

      await subscription.cancel();
      await queryController.close();
    });

    test('Handles rapid input changes (simulating fast typing)', () async {
      StreamController<String> queryController = StreamController<String>();
      final searchStream = fuzzyBolt.streamSearch(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<String>>[];

      final subscription = searchStream.listen(results.add);

      queryController.add("gr");
      await Future.delayed(Duration(milliseconds: 100));
      queryController.add("gra");
      await Future.delayed(Duration(milliseconds: 100));
      queryController.add("grape");
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isNotEmpty, true);
      expect(results.last.any((e) => e == 'grape'), true);
      await subscription.cancel();
      await queryController.close();
    });

    test('Handles case-insensitive search', () async {
      StreamController<String> queryController = StreamController<String>();
      final searchStream = fuzzyBolt.streamSearch(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<String>>[];

      final subscription = searchStream.listen(results.add);

      queryController.add("PINEAPPLE");
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isNotEmpty, true);
      expect(results.last.any((e) => e.toLowerCase() == 'pineapple'), true);
      await subscription.cancel();
      await queryController.close();
    });

    test('Handles cancellation of ongoing search', () async {
      StreamController<String> queryController = StreamController<String>();
      final searchStream = fuzzyBolt.streamSearch(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<String>>[];

      final subscription = searchStream.listen(results.add);

      queryController.add("mango");
      await Future.delayed(Duration(milliseconds: 250));
      queryController.add("mangosteen"); // Interrupt previous search
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isNotEmpty, true);
      expect(results.last.any((e) => e == 'mangosteen'), true);
      await subscription.cancel();
      await queryController.close();
    });

    test('Handles errors gracefully with onError callback', () async {
      // Create a StreamController for the query input
      StreamController<String> queryController = StreamController<String>();

      // Call the streamSearch method with an empty dataset
      final searchStream = fuzzyBolt.streamSearch(
        dataset: dataset, // Empty dataset to trigger an error
        query: queryController.stream,
        onError: (error, stackTrace) {
          // Verify that the error message contains the expected text
          expect(error.toString(), contains("Dataset cannot be empty."));
        },
      );

      final results = <List<String>>[];

      // Listen to the stream
      final subscription = searchStream.listen(results.add);

      // Add an empty query to the stream
      queryController.add("");

      // Allow time for the stream to process
      await Future.delayed(Duration(milliseconds: 500));

      // Verify that no results were emitted
      expect(results.isEmpty, true);

      // Clean up
      await subscription.cancel();
      await queryController.close();
      return;
    });
  });

  group('streamSearchWithRanks Tests', () {
    test('search streaming with ranks', () async {
      final StreamController<String> queryController =
          StreamController<String>();
      final searchStream = fuzzyBolt.streamSearchWithRanks(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<Map<String, dynamic>>>[];
      final subscription = searchStream.listen(results.add);

      queryController.add("mango");
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isNotEmpty, true);
      expect(results.last.first['value'], "mango");
      await subscription.cancel();
      await queryController.close();
    });

    test('Handles empty query input', () async {
      final StreamController<String> queryController =
          StreamController<String>();

      final searchStream = fuzzyBolt.streamSearchWithRanks(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<Map<String, dynamic>>>[];
      final subscription = searchStream.listen(results.add);

      queryController.add("");
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isEmpty, true);
      await subscription.cancel();
      await queryController.close();
    });

    test('Handles rapid input changes (simulating fast typing)', () async {
      final StreamController<String> queryController =
          StreamController<String>();

      final searchStream = fuzzyBolt.streamSearchWithRanks(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<Map<String, dynamic>>>[];
      final subscription = searchStream.listen(results.add);

      queryController.add("gr");
      await Future.delayed(Duration(milliseconds: 100));
      queryController.add("gra");
      await Future.delayed(Duration(milliseconds: 100));
      queryController.add("grape");
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isNotEmpty, true);
      expect(results.last.first['value'], "grape");
      await subscription.cancel();
      await queryController.close();
    });

    test('Handles case-insensitive search', () async {
      final StreamController<String> queryController =
          StreamController<String>();

      final searchStream = fuzzyBolt.streamSearchWithRanks(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<Map<String, dynamic>>>[];
      final subscription = searchStream.listen(results.add);

      queryController.add("PINEAPPLE");
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isNotEmpty, true);
      expect(results.first.first['value'].toLowerCase(), "pineapple");
      await subscription.cancel();
      await queryController.close();
    });

    test('Handles cancellation of ongoing search', () async {
      final StreamController<String> queryController =
          StreamController<String>();

      final searchStream = fuzzyBolt.streamSearchWithRanks(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<Map<String, dynamic>>>[];
      final subscription = searchStream.listen(results.add);

      queryController.add("mango");
      await Future.delayed(Duration(milliseconds: 250));
      queryController.add("mangosteen"); // Interrupt previous search
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isNotEmpty, true);
      expect(results.last.first['value'], "mangosteen");
      await subscription.cancel();
      await queryController.close();
    });
  });
}
