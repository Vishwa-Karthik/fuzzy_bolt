import 'dart:async';
import 'dart:isolate';
import '../utils/fuzzy_ranking.dart';
import '../utils/fuzzy_typo_handler.dart';

class FuzzySearchAlgorithm {
  final List<String> dataset;

  // Constructor to initialize the dataset.
  FuzzySearchAlgorithm(this.dataset);

  /// Searches the dataset for the given query.
  /// If the dataset is large, it uses isolates for asynchronous processing.
  Future<List<Map<String, dynamic>>> search(String query) async {
    if (dataset.length > 10000) {
      return await _searchInIsolate(query, dataset);
    } else {
      return _performSearch(query, dataset);
    }
  }

  /// Performs the search in a separate isolate for large datasets.
  static Future<List<Map<String, dynamic>>> _searchInIsolate(
      String query, List<String> dataset) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateSearch, [query, dataset, receivePort.sendPort]);
    return await receivePort.first as List<Map<String, dynamic>>;
  }

  /// The function that runs in the isolate to perform the search.
  static void _isolateSearch(List<dynamic> args) {
    String query = args[0];
    List<String> dataset = args[1];
    SendPort sendPort = args[2];
    sendPort.send(_performSearch(query, dataset));
  }

  /// Performs the search on the dataset.
  static List<Map<String, dynamic>> _performSearch(
      String query, List<String> dataset) {
    query = query.toLowerCase();
    List<Map<String, dynamic>> results = [];

    for (var item in dataset) {
      String lowerItem = item.toLowerCase();
      double score = jaroWinklerSimilarity(query, lowerItem);
      int typoDistance = damerauLevenshtein(query, lowerItem);

      int rank = _determineRank(score, typoDistance);
      if (rank > 0) {
        results.add({'value': item, 'rank': rank});
      }
    }

    // Sort results by rank in descending order.
    results.sort((a, b) => b['rank'].compareTo(a['rank']));
    return results;
  }

  /// Determines the rank of a search result based on the similarity score and typo distance.
  static int _determineRank(double score, int typoDistance) {
    if (score == 1.0) return 3; // Strict match
    if (score >= 0.85) return 2; // Partial match
    if (typoDistance <= 2) return 1; // Typo match
    return 0; // No match
  }
}
