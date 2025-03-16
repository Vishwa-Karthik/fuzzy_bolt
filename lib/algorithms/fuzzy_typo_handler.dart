/// Computes the Damerau-Levenshtein distance between two strings.
///
/// The **Damerau-Levenshtein distance** is a metric for measuring the
/// similarity between two strings. It calculates the **minimum number of
/// operations** required to convert one string into another.
///
///
/// This algorithm is particularly useful in:
/// - **Typo correction**
/// - **Fuzzy search ranking**
/// - **Auto-suggestions**
///
/// ### Example Usage:
/// ```dart
/// int distance = levenshteinDistance(s1: "hello", s2: "helo");
/// print(distance); // Output: 1
/// ```
///
/// ### Edge Cases:
/// - If `source` or `s2` is empty, the function returns the length of the other string.
/// - If both strings are identical, returns `0`.
int levensteinDistance({
  required String s1,
  required String s2,
}) {
  try {
    int len1 = s1.length;
    int len2 = s2.length;

    // If one of the strings is empty, return the length of the other.
    if (len1 == 0) return len2;
    if (len2 == 0) return len1;

    // 2D list to store distances.
    List<List<int>> dp =
        List.generate(len1 + 1, (_) => List.filled(len2 + 1, 0));

    // Initialize the first row and column.
    for (int i = 0; i <= len1; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        int cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;

        dp[i][j] = [
          dp[i - 1][j] + 1, // Deletion
          dp[i][j - 1] + 1, // Insertion
          dp[i - 1][j - 1] + cost, // Substitution
        ].reduce((a, b) => a < b ? a : b);

        // Check for transposition
        if (i > 1 &&
            j > 1 &&
            s1[i - 1] == s2[j - 2] &&
            s1[i - 2] == s2[j - 1]) {
          dp[i][j] = dp[i][j].clamp(0, dp[i - 2][j - 2] + cost);
        }
      }
    }

    return dp[len1][len2];
  } catch (e) {
    print("Error computing Levenshtein distance: $e");
    return -1;
  }
}
