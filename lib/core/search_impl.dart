import 'package:fuzzy_bolt/mixin/isolate_search.dart';
import 'package:fuzzy_bolt/mixin/local_search.dart';
import 'package:fuzzy_bolt/utils/constants.dart';

class SearchImpl with LocalSearch, IsolateSearch {
  Future<List<String>> search({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async {
    try {
      if (dataset.length > Constants.isolateThreshold && kIsWeb == false) {
        final result = await searchWithIsolate(
          dataset: dataset,
          query: query,
          strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
          typoThreshold: typoThreshold ?? Constants.defaultStrictThreshold,
        );
        return result.map((e) => e['value'] as String).toList();
      } else {
        final result = searchLocally(
          dataset: dataset,
          query: query,
          strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
          typoThreshold: typoThreshold ?? Constants.defaultStrictThreshold,
        );
        return result.map((e) => e['value'] as String).toList();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Map<String, dynamic>>> searchWithRanks({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async {
    try {
      if (dataset.length > Constants.isolateThreshold && kIsWeb == false) {
        return searchWithIsolate(
          dataset: dataset,
          query: query,
          strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
          typoThreshold: typoThreshold ?? Constants.defaultStrictThreshold,
        );
      } else {
        return searchLocally(
          dataset: dataset,
          query: query,
          strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
          typoThreshold: typoThreshold ?? Constants.defaultStrictThreshold,
        );
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
