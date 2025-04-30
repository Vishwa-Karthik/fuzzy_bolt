import 'dart:async';

import 'package:fuzzy_bolt/fuzzy_bolt.dart';

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
    "tangerine",
  ];

  List<Map<String, dynamic>> testCases = [
    {"query": "", "strict": 0.85, "typo": 0.7}, // Empty Query
    {"query": "aple", "strict": 0.85, "typo": 0.7}, // Typo Handling
    {"query": "mengo", "strict": 0.85, "typo": 0.6}, // Close Phonetic Match
    {"query": "berry", "strict": 0.6, "typo": 0.5}, // Partial Match
    {"query": "PINEAPPLE", "strict": 0.9, "typo": 0.8}, // Case Insensitivity
    {"query": "pomgranate", "strict": 0.8, "typo": 0.6}, // Complex Typo
  ];

  // ✅ Basic Search Test
  print("🚀 Running Basic Search Test...");

  for (var test in testCases) {
    print("🔍 Searching for: '${test["query"]}'");
    var basicSearchTextResults = await FuzzyBolt().search(
      dataset: dataset,
      query: test["query"] as String,
      strictThreshold: test["strict"] as double,
      typoThreshold: test["typo"] as double,
      onError: (error, stackTrace) {
        print("⚠️ Error: $error");
      },
    );

    print("📌 Top Results:");
    basicSearchTextResults.map((e) => print('$e \n')).toList();
  }

  // ✅ Standard Search With Ranked Test
  for (var test in testCases) {
    print("🔍 Searching for: '${test["query"]}'");
    var searchRankedResults = await FuzzyBolt().searchWithRanks(
      dataset: dataset,
      query: test["query"] as String,
      strictThreshold: test["strict"] as double,
      typoThreshold: test["typo"] as double,
    );

    print("📌 Top Results:");
    for (var res in searchRankedResults) {
      print(
        "   🔹 ${res['value']} (Score: ${res['rank'].toStringAsFixed(3)}) \n",
      );
    }
  }

  // ✅ Web Support Test
  print("🚀 Web Support Test...");
  for (var test in testCases) {
    try {
      print("🔍 Searching for: '${test["query"]}'");
      var webSupportResults = await FuzzyBolt().searchWithRanks(
        dataset: dataset,
        query: test["query"] as String,
        strictThreshold: test["strict"] as double,
        typoThreshold: test["typo"] as double,
        kIsWeb: true,
      );

      print("📌 Top Results:");
      for (var res in webSupportResults) {
        print(
          "   🔹 ${res['value']} (Score: ${res['rank'].toStringAsFixed(3)}) \n",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  // ✅ Stream-Based Search Test
  print("🚀 Running Stream-Based Search...");

  final StreamController<String> queryStreamControllers =
      StreamController<String>();

  final Stream<List<String>> searchResults = FuzzyBolt().streamSearch(
    dataset: dataset,
    query: queryStreamControllers.stream,
    strictThreshold: 0.6,
    typoThreshold: 0.5,
    onError: (error, stackTrace) {
      print("⚠️ Error: $error");
    },
  );

  // Listen for search results
  final StreamSubscription<List<String>> subscriptions = searchResults.listen(
    (results) {
      print("🔄 Stream Update:");
      for (var res in results) {
        print("   🔹 $res");
      }
    },
    onError: (error) => print("⚠️ Stream Error: $error"),
    onDone: () => print("✅ Stream Completed"),
  );
  // Simulate typing "a" -> "p" -> "l" -> "e" with a delay
  List<String> querySequences = ["b", "be", "ber", "berr", "berry"];

  for (var query in querySequences) {
    await Future.delayed(Duration(milliseconds: 300)); // Simulate typing delay
    print("\n⌨️ Typing: '$query'");

    queryStreamControllers.add(query);
  }

  // Close the query stream after execution
  await Future.delayed(Duration(seconds: 1));
  await queryStreamControllers.close();
  await subscriptions.cancel();

  print("🏁 Stream-based search completed.");

  // ✅ Stream-Based Search With Ranked Test
  print("🚀 Running Stream-Based Search With Ranked...");

  final StreamController<String> queryStreamController =
      StreamController<String>();

  final Stream<List<Map<String, dynamic>>> searchResultsWithRank = FuzzyBolt()
      .streamSearchWithRanks(
        dataset: dataset,
        query: queryStreamController.stream,
        strictThreshold: 0.6,
        typoThreshold: 0.5,
      );

  // Listen for search results
  final StreamSubscription<List<Map<String, dynamic>>>
  subscription = searchResultsWithRank.listen(
    (results) {
      print("🔄 Stream Update:");
      for (var res in results) {
        print(
          "   🔹 ${res['value']} (Score: ${res['rank'].toStringAsFixed(3)})",
        );
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
