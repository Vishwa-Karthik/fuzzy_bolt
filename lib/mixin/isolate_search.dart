import 'dart:isolate';

import 'package:fuzzy_bolt/src/fuzzy_search_bolt.dart';

/// A mixin that provides search functionality using isolates.
mixin IsolateSearch {
  /// Searches the given dataset for items that match the query using isolates.
  ///
  /// The search is performed using both strict matching (Jaro-Winkler similarity)
  /// and typo-tolerant matching (Damerau-Levenshtein distance).
  ///
  /// - [dataset]: The list of strings to search within.
  /// - [query]: The search query string.
  /// - [strictThreshold]: The threshold for strict matching. Items with a strict
  ///   score above this threshold will be included in the results.
  /// - [typoThreshold]: The threshold for typo-tolerant matching. Items with a
  ///   typo score above this threshold will be included in the results.
  ///
  /// Returns a Future that resolves to a list of maps, where each map contains the matched item and its rank.
  Future<List<Map<String, dynamic>>> searchWithIsolate({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
  }) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _searchIsolate,
      [receivePort.sendPort, dataset, query, strictThreshold, typoThreshold],
    );
    return await receivePort.first;
  }

  /// The isolate function that performs the search.
  ///
  /// - [args]: A list containing the send port, dataset, query, strict threshold, and typo threshold.
  static void _searchIsolate(List<dynamic> args) async {
    SendPort sendPort = args[0];
    List<String> dataset = args[1];
    String query = args[2];
    double strictThreshold = args[3];
    double typoThreshold = args[4];

    List<Map<String, dynamic>> results = await FuzzyBolt().search(
      dataset: dataset.map((e) => e.toLowerCase()).toList(),
      query: query.toLowerCase(),
      strictThreshold: strictThreshold,
      typoThreshold: typoThreshold,
    );

    sendPort.send(results);
  }
}
