import 'package:fuzzy_bolt/core/search_impl.dart';
import 'package:fuzzy_bolt/core/stream_search_impl.dart';
import 'package:fuzzy_bolt/utils/constants.dart';

sealed class FuzzyBoltSearch {
  Future<List<Map<String, dynamic>>> search({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  });

  Stream<List<Map<String, dynamic>>> streamSearch({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  });
}

class FuzzyBolt implements FuzzyBoltSearch {
  @override
  Future<List<Map<String, dynamic>>> search({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async {
    try {
      return await SearchImpl().search(
        dataset: dataset,
        query: query,
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
        kIsWeb: kIsWeb ?? false,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamSearch({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async* {
    try {
      yield* StreamSearchImpl().streamSearch(
        dataset: dataset,
        query: query,
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
        kIsWeb: kIsWeb ?? false,
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}
