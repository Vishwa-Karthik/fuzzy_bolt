/// Computes the Jaro-Winkler similarity score between two strings.
///
/// The **Jaro-Winkler similarity** is a metric for measuring the similarity
/// between two strings. It is an **enhanced version of Jaro distance**, giving
/// **higher scores** to strings that share a **common prefix**.
///
///
/// ### Example Usage:
/// ```dart
/// double similarity = jaroWinklerDistance(s1: "hello", s2: "helo");
/// print(similarity); // Output: ~0.93
/// ```
///
///
/// Returns:
/// - A **double similarity score** (range: 0.0 - 1.0).
/// - Returns `0.0` for completely different strings.
/// - Returns `1.0` for identical strings.
/// - Returns `-1.0` if an error occurs.
///
double jaroWinklerDistance({required String s1, required String s2}) {
  try {
    // Edge Cases: If both strings are identical, return perfect match.
    if (s1 == s2) return 1.0;

    // If either string is empty, return no similarity.
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Determine matching distance based on the shorter string.
    int matchDistance = (s1.length ~/ 2 - 1).clamp(0, s1.length);

    // Arrays to track character matches.
    List<bool> s1Matches = List.filled(s1.length, false);
    List<bool> s2Matches = List.filled(s2.length, false);

    int matches = 0;
    int transpositions = 0;

    // Find matching characters.
    for (int i = 0; i < s1.length; i++) {
      int start = (i - matchDistance).clamp(0, s2.length);
      int end = (i + matchDistance + 1).clamp(0, s2.length);

      for (int j = start; j < end; j++) {
        if (s2Matches[j]) continue;
        if (s1[i] != s2[j]) continue;

        s1Matches[i] = true;
        s2Matches[j] = true;
        matches++;
        break;
      }
    }

    // If no matches found, return 0 similarity.
    if (matches == 0) return 0.0;

    // Count transpositions.
    int k = 0;
    for (int i = 0; i < s1.length; i++) {
      if (!s1Matches[i]) continue;
      while (!s2Matches[k]) {
        k++;
      }
      if (s1[i] != s2[k]) transpositions++;
      k++;
    }

    // Compute Jaro similarity.
    double jaro = ((matches / s1.length) +
            (matches / s2.length) +
            ((matches - transpositions ~/ 2) / matches)) /
        3.0;

    // Compute prefix length (up to 4 chars).
    int prefixLength = 0;
    for (int i = 0; i < s1.length && i < s2.length && s1[i] == s2[i]; i++) {
      prefixLength++;
    }

    // Compute Jaro-Winkler score.
    double jaroWinkler = jaro + (prefixLength * 0.1 * (1 - jaro)).clamp(0, 0.1);

    return jaroWinkler;
  } catch (e) {
    print("Error computing Jaro-Winkler similarity: $e");
    return -1.0; 
  }
}
