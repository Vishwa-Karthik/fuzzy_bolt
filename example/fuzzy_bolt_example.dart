import 'dart:async';
import 'package:fuzzy_bolt/src/fuzzy_search_bolt.dart';

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

  // ✅ Standard Search Test
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

  // ✅ Stream-Based Search Test
  print("🚀 Running Stream-Based Search...");

  final StreamController<String> queryStreamController =
      StreamController<String>();

  final Stream<List<Map<String, dynamic>>> searchResults =
      FuzzyBolt().streamSearch(
    dataset: dataset,
    query: queryStreamController.stream,
    strictThreshold: 0.6,
    typoThreshold: 0.5,
  );

  // Listen for search results
  final StreamSubscription<List<Map<String, dynamic>>> subscription =
      searchResults.listen(
    (results) {
      print("🔄 Stream Update:");
      for (var res in results) {
        print(
            "   🔹 ${res['value']} (Score: ${res['rank'].toStringAsFixed(3)})");
      }
    },
    onError: (error) => print("⚠️ Stream Error: $error"),
    onDone: () => print("✅ Stream Completed"),
  );
  // Simulate typing "a" -> "p" -> "l" -> "e" with a delay
  List<String> querySequence = ["b", "be", "ber", "berr", "berry"];

  for (var query in querySequence) {
    await Future.delayed(Duration(milliseconds: 800)); // Simulate typing delay
    print("\n⌨️ Typing: '$query'");

    queryStreamController.add(query);
  }

  // Close the query stream after execution
  await Future.delayed(Duration(seconds: 1));
  await queryStreamController.close();
  await subscription.cancel();

  print("🏁 Stream-based search completed.");
}
