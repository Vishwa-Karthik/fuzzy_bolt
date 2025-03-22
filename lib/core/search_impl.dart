import 'package:fuzzy_bolt/mixin/isolate_search.dart';
import 'package:fuzzy_bolt/mixin/local_search.dart';
import 'package:fuzzy_bolt/utils/constants.dart';

class SearchImpl with LocalSearch, IsolateSearch {
  Future<List<Map<String, dynamic>>> search({
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
