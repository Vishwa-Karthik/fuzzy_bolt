import 'package:fuzzy_bolt/core/fuzzy_search_bolt_impl.dart';

void main() async {
  List<String> dataset = [
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
    "tangerine"
  ];

  List<Map<String, dynamic>> testCases = [
    {"query": "aple", "strict": 0.85, "typo": 0.7}, // Typo Handling
    {"query": "mengo", "strict": 0.85, "typo": 0.6}, // Close Phonetic Match
    {"query": "berry", "strict": 0.6, "typo": 0.5}, // Partial Match
    {"query": "PINEAPPLE", "strict": 0.9, "typo": 0.8}, // Case Insensitivity
    {"query": "pomgranate", "strict": 0.8, "typo": 0.6} // Complex Typo
  ];

  for (var test in testCases) {
    print("🔍 Searching for: '${test["query"]}'");
    var results = await FuzzyBolt().search(
      dataset: dataset,
      query: test["query"] as String,
      strictThreshold: test["strict"] as double,
      typoThreshold: test["typo"] as double,
    );

    print("📌 Top Results:");
    for (var res in results.take(3)) {
      print("   🔹 ${res['value']} (Score: ${res['rank'].toStringAsFixed(3)})");
    }
    print("\n");
  }
}
