abstract class FuzzyBoltSearch {
  Future<List<Map<String, dynamic>>> search({
    required List<String> dataset,
    required String query,
    required double strictThreshold,
    required double typoThreshold,
  });
}
