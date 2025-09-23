import '../models/fuzzy_result.dart';
import '../models/search_candidate.dart';

/// Interface for ranking search results.
abstract class RankingStrategy<T> {
  /// Ranks a list of candidates against a query and returns scored results.
  List<FuzzyResult<T>> rankCandidates(
    List<SearchCandidate<T>> candidates,
    String query,
    double strictThreshold,
    double typeThreshold,
  );

  /// Gets the name of this ranking strategy for debugging purposes.
  String get strategyName;
}
