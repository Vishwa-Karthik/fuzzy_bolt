import 'package:fuzzy_bolt/algorithms/fuzzy_ranking.dart';
import 'package:fuzzy_bolt/algorithms/fuzzy_typo_handler.dart';

mixin LocalSearch {
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
    } catch (e) {
      throw Exception(e);
    }
  }
}
