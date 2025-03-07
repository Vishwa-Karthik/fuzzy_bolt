import 'package:fuzzy_bolt/core/fuzzy_search_bolt_impl.dart';
import 'package:test/test.dart';

void main() {
  group('FuzzyBolt Search Tests', () {
    late List<String> dataset;
    late FuzzyBolt fuzzyBolt;

    setUp(() {
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
        "jackfruit"
      ];
      fuzzyBolt = FuzzyBolt();
    });

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
        strictThreshold: 0.85,
        typoThreshold: 0.7,
      );
      expect(results.isNotEmpty, true);
      expect(results.first['value'].contains("berry"), true);
    });
  });
}
