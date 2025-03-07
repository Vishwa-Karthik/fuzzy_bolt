import 'package:fuzzy_bolt/core/fuzzy_search_bolt_interface.dart';
import 'package:fuzzy_bolt/isolate/fuzzy_bolt_isolate.dart';
import 'package:fuzzy_bolt/utils/fuzzy_ranking.dart';
import 'package:fuzzy_bolt/utils/fuzzy_typo_handler.dart';

class FuzzyBolt implements FuzzyBoltSearch {
  @override
  Future<List<Map<String, dynamic>>> search({
    required List<String> dataset,
    required String query,
    required double strictThreshold,
    required double typoThreshold,
  }) async {
    if (dataset.length > 10000) {
      return FuzzyBoltIsolate.searchWithIsolate(
        dataset: dataset,
        query: query,
        strictThreshold: strictThreshold,
        typoThreshold: typoThreshold,
      );
    } else {
      return _searchLocally(
        dataset: dataset,
        query: query,
        strictThreshold: strictThreshold,
        typoThreshold: typoThreshold,
      );
    }
  }

  List<Map<String, dynamic>> _searchLocally({
    required List<String> dataset,
    required String query,
    required double strictThreshold,
    required double typoThreshold,
  }) {
    List<Map<String, dynamic>> results = [];

    for (var item in dataset) {
      String lowerItem = item.toLowerCase();
      String lowerQuery = query.toLowerCase();

      double strictScore = jaroWinklerSimilarity(lowerItem, lowerQuery);
      int typoDistance = damerauLevenshtein(lowerItem, lowerQuery);
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
  }
}
