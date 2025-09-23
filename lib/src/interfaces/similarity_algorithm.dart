/// Interface for string similarity algorithms.
abstract class SimilarityAlgorithm {
  /// Calculates similarity between two strings.
  /// Returns a value between 0.0 (no similarity) and 1.0 (identical).
  double calculateSimilarity(String a, String b);

  /// Gets the name of this algorithm for debugging purposes.
  String get algorithmName;
}
