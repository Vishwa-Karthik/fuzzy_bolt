import 'package:fuzzy_bolt/algorithms/fuzzy_ranking.dart';
import 'package:fuzzy_bolt/algorithms/fuzzy_typo_handler.dart';

/// A mixin that provides local search functionality.
mixin LocalSearch {
  /// Searches the given dataset for items that match the query.
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
  /// Returns a list of maps, where each map contains the matched item and its rank.
  List<Map<String, dynamic>> searchLocally({
    required List<String> dataset,
    required String query,
    required double strictThreshold,
    required double typoThreshold,
  }) {
    try { 
      List<Map<String, dynamic>> results = [];

      for (var item in dataset) {
        String lowerItem = item.toLowerCase();
        String lowerQuery = query.toLowerCase();

        double strictScore = jaroWinklerDistance(s1: lowerItem, s2: lowerQuery);
        int typoDistance = levensteinDistance(s1: lowerItem, s2: lowerQuery);
        double typoScore = 1 - (typoDistance / lowerItem.length);

        double rank = strictScore > strictThreshold
            ? strictScore
            : typoScore > typoThreshold
                ? typoScore * 0.8
                : 0.0;

        if (rank > 0) {
          results.add({'value': item, 'rank': rank});
        }
      }

      results.sort((a, b) => b['rank'].compareTo(a['rank']));
      return results;
    } catch (e) {
      throw Exception(e);
    }
  }
}