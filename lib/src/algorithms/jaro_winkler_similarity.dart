import '../interfaces/similarity_algorithm.dart';

/// Implementation of Jaro-Winkler similarity algorithm.
///
/// The Jaro-Winkler algorithm is particularly good for detecting
/// transpositions and gives higher scores to strings that match
/// from the beginning.
class JaroWinklerSimilarity implements SimilarityAlgorithm {
  /// Scaling factor for the prefix bonus (typically 0.1).
  final double scalingFactor;

  /// Maximum length of prefix to consider (typically 4).
  final int maxPrefixLength;

  const JaroWinklerSimilarity({
    this.scalingFactor = 0.1,
    this.maxPrefixLength = 4,
  });

  @override
  double calculateSimilarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;

    final jaroSimilarity = _calculateJaroSimilarity(a, b);
    if (jaroSimilarity < 0.7) return jaroSimilarity;

    final prefixLength = _calculateCommonPrefixLength(a, b);
    return jaroSimilarity +
        (scalingFactor * prefixLength * (1.0 - jaroSimilarity));
  }

  double _calculateJaroSimilarity(String a, String b) {
    final aLength = a.length;
    final bLength = b.length;

    if (aLength == 0 && bLength == 0) return 1.0;
    if (aLength == 0 || bLength == 0) return 0.0;

    final matchWindow = ((aLength > bLength ? aLength : bLength) ~/ 2) - 1;
    if (matchWindow < 0) return 0.0;

    final aMatches = List<bool>.filled(aLength, false);
    final bMatches = List<bool>.filled(bLength, false);

    var matches = 0;
    var transpositions = 0;

    // Find matches
    for (var i = 0; i < aLength; i++) {
      final start = i - matchWindow > 0 ? i - matchWindow : 0;
      final end = i + matchWindow + 1 < bLength ? i + matchWindow + 1 : bLength;

      for (var j = start; j < end; j++) {
        if (bMatches[j] || a[i] != b[j]) continue;
        aMatches[i] = true;
        bMatches[j] = true;
        matches++;
        break;
      }
    }

    if (matches == 0) return 0.0;

    // Find transpositions
    var k = 0;
    for (var i = 0; i < aLength; i++) {
      if (!aMatches[i]) continue;
      while (!bMatches[k]) {
        k++;
      }
      if (a[i] != b[k]) transpositions++;
      k++;
    }

    return (matches / aLength +
            matches / bLength +
            (matches - transpositions / 2) / matches) /
        3.0;
  }

  int _calculateCommonPrefixLength(String a, String b) {
    final minLength = a.length < b.length ? a.length : b.length;
    final maxPrefix = minLength < maxPrefixLength ? minLength : maxPrefixLength;

    for (var i = 0; i < maxPrefix; i++) {
      if (a[i] != b[i]) return i;
    }
    return maxPrefix;
  }

  @override
  String get algorithmName => 'Jaro-Winkler';
}
