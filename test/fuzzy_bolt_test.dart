import 'dart:async';

import 'package:fuzzy_bolt/src/fuzzy_search_bolt.dart';
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
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "mango",
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "mango");
    });

    test('Handles simple typo', () async {
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "aple", // Typo for "apple"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "apple");
    });

    test('Handles phonetic similarity', () async {
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "mengo", // Should match "mango"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "mango");
    });

    test('Handles case insensitivity', () async {
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "PINEAPPLE", // Should match "Pineapple"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'].toLowerCase(), "pineapple");
    });

    test('Handles partial matches', () async {
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "grap", // Should match "grape", "grapefruit"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'].contains("grap"), true);
    });

    test('Handles multi-word queries', () async {
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "passion fruit", // Should match "passionfruit"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "passionfruit");
    });

    test('Handles abbreviations', () async {
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "straw", // Should match "strawberry"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "Strawberry");
    });

    test('Handles special characters', () async {
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "avoc@do", // Should match "avocado"
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'], "avocado");
    });

    test('Handles no matches gracefully', () async {
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "xylophone", // Should return an empty list
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isEmpty, true);
    });

    test('Handles long and complex queries', () async {
      final results = await fuzzyBolt.search(
        dataset: dataset,
        query: "black rasp", // Should match "blackberry" or "raspberry"
        strictThreshold: 0.65,
        typoThreshold: 0.5,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'].contains("berry"), true);
    });
  });

  group('StreamSearch Tests', () {
    late StreamController<String> queryController;

    setUp(() {
      queryController = StreamController<String>.broadcast();
    });

    tearDown(() {
      queryController.close();
    });

    test('Basic search streaming', () async {
      final searchStream = fuzzyBolt.streamSearch(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<Map<String, dynamic>>>[];
      final subscription = searchStream.listen(results.add);

      queryController.add("mango");
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isNotEmpty, true);
      expect(results.first.first['value'], "mango");
      await subscription.cancel();
    });

    test('Handles empty query input', () async {
      final searchStream = fuzzyBolt.streamSearch(
        dataset: dataset,
        query: queryController.stream,
      );

      final results = <List<Map<String, dynamic>>>[];
      final subscription = searchStream.listen(results.add);

      queryController.add("");
      await Future.delayed(Duration(milliseconds: 500));

      expect(results.isEmpty, true);
      await subscription.cancel();
    });

    test('Handles rapid input changes (simulating fast typing)', () async {
      final searchStream = fuzzyBolt.streamSearch(
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
    });

    test('Handles case-insensitive search', () async {
      final searchStream = fuzzyBolt.streamSearch(
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
    });

    test('Handles cancellation of ongoing search', () async {
      final searchStream = fuzzyBolt.streamSearch(
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
    });
  });
}
