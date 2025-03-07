int damerauLevenshtein(String s1, String s2) {
  int len1 = s1.length;
  int len2 = s2.length;

  if (len1 == 0) return len2;
  if (len2 == 0) return len1;

  List<List<int>> dp = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

  for (int i = 0; i <= len1; i++) {
    dp[i][0] = i;
  }
  for (int j = 0; j <= len2; j++) {
    dp[0][j] = j;
  }

  for (int i = 1; i <= len1; i++) {
    for (int j = 1; j <= len2; j++) {
      int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      dp[i][j] = [
        dp[i - 1][j] + 1, // Deletion
        dp[i][j - 1] + 1, // Insertion
        dp[i - 1][j - 1] + cost, // Substitution
      ].reduce((a, b) => a < b ? a : b);

      if (i > 1 && j > 1 && s1[i - 1] == s2[j - 2] && s1[i - 2] == s2[j - 1]) {
        dp[i][j] = dp[i][j] < dp[i - 2][j - 2] + cost
            ? dp[i][j]
            : dp[i - 2][j - 2] + cost; // Transposition
      }
    }
  }

  return dp[len1][len2];
}
