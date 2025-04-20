import 'package:fuzzy_bolt/core/search_impl.dart';
import 'package:fuzzy_bolt/core/stream_search_impl.dart';
import 'package:fuzzy_bolt/utils/constants.dart';

sealed class FuzzyBoltSearch {
  Future<List<String>> search({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  });

  Future<List<Map<String, dynamic>>> searchWithRanks({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  });

  Stream<List<String>> streamSearch({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  });

  Stream<List<Map<String, dynamic>>> streamSearchWithRanks({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  });
}

class FuzzyBolt implements FuzzyBoltSearch {
  @override
  Future<List<String>> search({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async {
    try {
      return await SearchImpl().search(
        dataset: dataset.map((e) => e.toLowerCase()).toList(),
        query: query.toLowerCase().trim(),
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
        kIsWeb: kIsWeb ?? false,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchWithRanks({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async {
    try {
      return await SearchImpl().searchWithRanks(
        dataset: dataset.map((e) => e.toLowerCase()).toList(),
        query: query.toLowerCase().trim(),
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
        kIsWeb: kIsWeb ?? false,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream<List<String>> streamSearch({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async* {
    try {
      yield* StreamSearchImpl().streamSearch(
        dataset: dataset.map((e) => e.toLowerCase()).toList(),
        query: query.map((e) => e.toLowerCase().trim()),
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
        kIsWeb: kIsWeb ?? false,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamSearchWithRanks({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async* {
    try {
      yield* StreamSearchImpl().streamSearchWithRanks(
        dataset: dataset.map((e) => e.toLowerCase()).toList(),
        query: query.map((e) => e.toLowerCase().trim()),
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
        kIsWeb: kIsWeb ?? false,
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}
