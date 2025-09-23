import '../interfaces/ranking_strategy.dart';
import '../interfaces/similarity_algorithm.dart';
import '../models/fuzzy_result.dart';
import '../models/search_candidate.dart';
import '../algorithms/jaro_winkler_similarity.dart';
import '../algorithms/levenshtein_similarity.dart';

/// Adaptive ranking strategy that combines multiple similarity algorithms.
///
/// This strategy uses both Jaro-Winkler and Levenshtein algorithms to
/// provide comprehensive fuzzy matching with adaptive scoring.
class AdaptiveRankingStrategy<T> implements RankingStrategy<T> {
  final SimilarityAlgorithm _jaroWinkler;
  final SimilarityAlgorithm _levenshtein;

  /// Weight for Jaro-Winkler algorithm in final score (0.0 to 1.0).
  final double jaroWinklerWeight;

  /// Weight for Levenshtein algorithm in final score (0.0 to 1.0).
  final double levenshteinWeight;

  const AdaptiveRankingStrategy({
    SimilarityAlgorithm? jaroWinkler,
    SimilarityAlgorithm? levenshtein,
    this.jaroWinklerWeight = 0.6,
    this.levenshteinWeight = 0.4,
  }) : _jaroWinkler = jaroWinkler ?? const JaroWinklerSimilarity(),
       _levenshtein = levenshtein ?? const LevenshteinSimilarity(),
       assert(
         jaroWinklerWeight >= 0.0 && jaroWinklerWeight <= 1.0,
         'jaroWinklerWeight must be between 0.0 and 1.0',
       ),
       assert(
         levenshteinWeight >= 0.0 && levenshteinWeight <= 1.0,
         'levenshteinWeight must be between 0.0 and 1.0',
       );

  @override
  List<FuzzyResult<T>> rankCandidates(
    List<SearchCandidate<T>> candidates,
    String query,
    double strictThreshold,
    double typeThreshold,
  ) {
    final normalizedQuery = _normalizeText(query);
    final results = <FuzzyResult<T>>[];

    for (final candidate in candidates) {
      final bestMatch = _findBestMatch(candidate, normalizedQuery);
      if (bestMatch != null && bestMatch.score >= typeThreshold) {
        results.add(bestMatch);
      }
    }

    // Sort by score in descending order
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  FuzzyResult<T>? _findBestMatch(SearchCandidate<T> candidate, String query) {
    double bestScore = 0.0;
    String bestMatchedText = candidate.searchableText;

    // Check against the combined searchable text
    final combinedScore = _calculateCombinedSimilarity(
      query,
      _normalizeText(candidate.searchableText),
    );

    if (combinedScore > bestScore) {
      bestScore = combinedScore;
      bestMatchedText = candidate.searchableText;
    }

    // Check against individual field texts for better granularity
    for (final fieldText in candidate.fieldTexts) {
      final normalizedFieldText = _normalizeText(fieldText);
      final fieldScore = _calculateCombinedSimilarity(
        query,
        normalizedFieldText,
      );

      if (fieldScore > bestScore) {
        bestScore = fieldScore;
        bestMatchedText = fieldText;
      }
    }

    if (bestScore <= 0.0) return null;

    return FuzzyResult<T>(
      item: candidate.item,
      score: bestScore,
      matchedText: bestMatchedText,
    );
  }

  double _calculateCombinedSimilarity(String query, String candidate) {
    if (query.isEmpty || candidate.isEmpty) return 0.0;

    final jaroWinklerScore = _jaroWinkler.calculateSimilarity(query, candidate);
    final levenshteinScore = _levenshtein.calculateSimilarity(query, candidate);

    // Combine scores with weights
    final combinedScore =
        (jaroWinklerScore * jaroWinklerWeight) +
        (levenshteinScore * levenshteinWeight);

    // Apply boost for exact prefix matches
    final prefixBoost = _calculatePrefixBoost(query, candidate);

    return (combinedScore + prefixBoost).clamp(0.0, 1.0);
  }

  double _calculatePrefixBoost(String query, String candidate) {
    if (query.isEmpty || candidate.isEmpty) return 0.0;

    final minLength =
        query.length < candidate.length ? query.length : candidate.length;
    var commonPrefix = 0;

    for (var i = 0; i < minLength; i++) {
      if (query[i] == candidate[i]) {
        commonPrefix++;
      } else {
        break;
      }
    }

    if (commonPrefix == 0) return 0.0;

    // Give a small boost (up to 0.1) for prefix matches
    return (commonPrefix / query.length) * 0.1;
  }

  String _normalizeText(String text) {
    return text.toLowerCase().trim();
  }

  @override
  String get strategyName => 'Adaptive (Jaro-Winkler + Levenshtein)';
}
