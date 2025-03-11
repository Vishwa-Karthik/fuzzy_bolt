import 'package:fuzzy_bolt/mixin/isolate_search.dart';
import 'package:fuzzy_bolt/mixin/local_search.dart';
import 'package:fuzzy_bolt/utils/constants.dart';

class SearchImpl with LocalSearch, IsolateSearch {
  Future<List<Map<String, dynamic>>> search({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
  }) async {
    try {
      if (dataset.length > 1000) {
        return searchWithIsolate(
          dataset: dataset,
          query: query,
          strictThreshold: strictThreshold ?? Constants.strictThreshold,
          typoThreshold: typoThreshold ?? Constants.strictThreshold,
        );
      } else {
        return searchLocally(
          dataset: dataset,
          query: query,
          strictThreshold: strictThreshold ?? Constants.strictThreshold,
          typoThreshold: typoThreshold ?? Constants.strictThreshold,
        );
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
