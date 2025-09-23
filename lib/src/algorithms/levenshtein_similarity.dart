import '../interfaces/similarity_algorithm.dart';

/// Implementation of Levenshtein distance algorithm converted to similarity.
///
/// The Levenshtein distance measures the minimum number of single-character
/// edits (insertions, deletions, or substitutions) required to change one
/// string into another. This implementation converts distance to similarity.
class LevenshteinSimilarity implements SimilarityAlgorithm {
  const LevenshteinSimilarity();

  @override
  double calculateSimilarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;

    final distance = _calculateLevenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;

    // Convert distance to similarity: similarity = 1 - (distance / maxLength)
    return 1.0 - (distance / maxLength);
  }

  int _calculateLevenshteinDistance(String a, String b) {
    final aLength = a.length;
    final bLength = b.length;

    if (aLength == 0) return bLength;
    if (bLength == 0) return aLength;

    // Create a matrix to store distances
    final matrix = List.generate(
      aLength + 1,
      (i) => List<int>.filled(bLength + 1, 0),
    );

    // Initialize the first row and column
    for (var i = 0; i <= aLength; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= bLength; j++) {
      matrix[0][j] = j;
    }

    // Fill the matrix
    for (var i = 1; i <= aLength; i++) {
      for (var j = 1; j <= bLength; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;

        matrix[i][j] = _min3(
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        );
      }
    }

    return matrix[aLength][bLength];
  }

  int _min3(int a, int b, int c) {
    return a < b ? (a < c ? a : c) : (b < c ? b : c);
  }

  @override
  String get algorithmName => 'Levenshtein';
}
