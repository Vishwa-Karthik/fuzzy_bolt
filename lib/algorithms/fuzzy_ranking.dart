/// Calculates the Jaro-Winkler similarity between two strings.
/// The Jaro-Winkler similarity is a measure of similarity between two strings.
/// It is a variant of the Jaro distance metric, giving more favorable ratings
/// to strings that match from the beginning for a set prefix length.
double jaroWinklerDistance({required String s1, required String s2}) {
  try {
    // If the strings are identical, return 1.0 (perfect match).
    if (s1 == s2) return 1.0;

    // If either string is empty, return 0.0 (no match).
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Calculate the match distance, which is used to determine matching characters.
    int matchDistance = (s1.length / 2 - 1).clamp(0, s1.length).toInt();

    // Arrays to keep track of matches in both strings.
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

    if (matches == 0) return 0.0;

    int k = 0;
    for (int i = 0; i < s1.length; i++) {
      if (!s1Matches[i]) continue;
      while (!s2Matches[k]) {
        k++;
      }
      if (s1[i] != s2[k]) transpositions++;
      k++;
    }

    double jaro = ((matches / s1.length) +
            (matches / s2.length) +
            ((matches - transpositions ~/ 2) / matches)) /
        3.0;

    int prefixLength = 0;
    for (int i = 0; i < s1.length && i < s2.length && s1[i] == s2[i]; i++) {
      prefixLength++;
    }

    double jaroWinkler = jaro + (prefixLength * 0.1 * (1 - jaro)).clamp(0, 0.1);
    return jaroWinkler;
  } catch (e) {
    print('An error occurred: $e');
    return -1;
  }
}
