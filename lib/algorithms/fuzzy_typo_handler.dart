/// Calculates the Damerau-Levenshtein distance between two strings.
/// The Damerau-Levenshtein distance is a measure of the minimum number of operations
/// (insertions, deletions, substitutions, and transpositions) required to transform one string into another.
int levensteinDistance({required String s1, required String s2}) {
  try {
    int len1 = s1.length;
    int len2 = s2.length;

    // If one of the strings is empty, return the length of the other string.
    if (len1 == 0) return len2;
    if (len2 == 0) return len1;

    // Create a 2D list to store the distances.
    List<List<int>> dp =
        List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    // Initialize the first row and column of the list.
    for (int i = 0; i <= len1; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      dp[0][j] = j;
    }

    // Fill in the rest of the list.
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        // Calculate the cost of substitution.
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1, // Deletion
          dp[i][j - 1] + 1, // Insertion
          dp[i - 1][j - 1] + cost, // Substitution
        ].reduce((a, b) => a < b ? a : b);

        // Check for transpositions.
        if (i > 1 &&
            j > 1 &&
            s1[i - 1] == s2[j - 2] &&
            s1[i - 2] == s2[j - 1]) {
          dp[i][j] = dp[i][j] < dp[i - 2][j - 2] + cost
              ? dp[i][j]
              : dp[i - 2][j - 2] + cost;
        }
      }
    }

    return dp[len1][len2];
  } catch (e) {
    print('An error occurred: $e');
    return -1;
  }
}
