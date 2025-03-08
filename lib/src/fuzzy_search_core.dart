import 'dart:isolate';
import '../utils/fuzzy_ranking.dart';
import '../utils/fuzzy_typo_handler.dart';

class FuzzyBolt {
  /// Searches the dataset for the given query.
  /// If the dataset is large, it uses isolates for asynchronous processing.
  static Future<List<Map<String, dynamic>>> search(
    List<String> dataset,
    String query,
  ) async {
    if (dataset.length > 10000) {
      return _searchWithIsolate(dataset, query);
    } else {
      return _searchLocally(dataset, query);
    }
  }

  /// Performs the search locally on the main thread.
  static List<Map<String, dynamic>> _searchLocally(
    List<String> dataset,
    String query,
  ) {
    List<Map<String, dynamic>> results = [];

    for (var item in dataset) {
      double strictScore = jaroWinklerSimilarity(item, query);
      int typoDistance = damerauLevenshtein(item, query);
      double typoScore = 1 - (typoDistance / item.length);

      double rank = strictScore > 0.85
          ? strictScore
          : typoScore > 0.7
              ? typoScore * 0.8
              : 0.0;

      if (rank > 0) {
        results.add({'value': item, 'rank': rank});
      }
    }

    // Sort results by rank in descending order.
    results.sort((a, b) => b['rank'].compareTo(a['rank']));
    return results;
  }

  /// Performs the search in a separate isolate for large datasets.
  static Future<List<Map<String, dynamic>>> _searchWithIsolate(
    List<String> dataset,
    String query,
  ) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_searchIsolate, [receivePort.sendPort, dataset, query]);
    return await receivePort.first;
  }

  /// The function that runs in the isolate to perform the search.
  static void _searchIsolate(List<dynamic> args) {
    SendPort sendPort = args[0];
    List<String> dataset = args[1];
    String query = args[2];

    List<Map<String, dynamic>> results = _searchLocally(dataset, query);
    sendPort.send(results);
  }
}
