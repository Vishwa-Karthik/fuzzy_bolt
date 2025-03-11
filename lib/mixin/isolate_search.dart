import 'dart:isolate';

import 'package:fuzzy_bolt/src/fuzzy_search_bolt.dart';

mixin IsolateSearch {
  Future<List<Map<String, dynamic>>> searchWithIsolate({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
  }) async {

    final receivePort = ReceivePort();
    await Isolate.spawn(
      _searchIsolate,
      [receivePort.sendPort, dataset, query, strictThreshold, typoThreshold],
    );
    return await receivePort.first;
  }

  static void _searchIsolate(List<dynamic> args) async {
    SendPort sendPort = args[0];
    List<String> dataset = args[1];
    String query = args[2];
    double strictThreshold = args[3];
    double typoThreshold = args[4];

    List<Map<String, dynamic>> results = await FuzzyBolt().search(
      dataset: dataset.map((e)=> e.toLowerCase()).toList(),
      query: query.toLowerCase(),
      strictThreshold: strictThreshold,
      typoThreshold: typoThreshold,
    );

    sendPort.send(results);
  }
}
