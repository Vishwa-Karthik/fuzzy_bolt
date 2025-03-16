import 'dart:async';

import 'package:fuzzy_bolt/mixin/isolate_search.dart';
import 'package:fuzzy_bolt/mixin/local_search.dart';
import 'package:fuzzy_bolt/utils/constants.dart';

class StreamSearchImpl with LocalSearch, IsolateSearch {
  StreamSubscription<String>? _subscription;
  Completer<void>? _ongoingSearch;
  final StreamController<List<Map<String, dynamic>>> _controller =
      StreamController.broadcast();

  Stream<List<Map<String, dynamic>>> streamSearch({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
  }) {
    _subscription?.cancel(); // Cancel any existing subscription safely
    _subscription = query.listen((inputQuery) async {
      if (inputQuery.isEmpty) return;

      // Cancel any ongoing search before starting a new one
      if (_ongoingSearch != null && !_ongoingSearch!.isCompleted) {
        _ongoingSearch!.complete();
      }
      _ongoingSearch = Completer<void>();

      try {
        final result = await _performSearch(
          dataset: dataset,
          query: inputQuery,
          strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
          typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
        );

        if (!_controller.isClosed) {
          _controller.add(result);
        }
      } catch (e, stackTrace) {
        if (!_controller.isClosed) {
          _controller.addError(e, stackTrace);
        }
      } finally {
        _ongoingSearch?.complete();
      }
    });

    return _controller.stream;
  }

  /// Determines search execution strategy (Isolate vs Local)
  Future<List<Map<String, dynamic>>> _performSearch({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
  }) async {
    if (dataset.length > Constants.isolateThreshold) {
      return searchWithIsolate(
        dataset: dataset,
        query: query,
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
      );
    } else {
      return searchLocally(
        dataset: dataset,
        query: query,
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
      );
    }
  }

  /// Cancel ongoing search and close the stream
  void dispose() {
    _subscription?.cancel();
    if (_ongoingSearch != null && !_ongoingSearch!.isCompleted) {
      _ongoingSearch!.complete();
    }
    _controller.close();
  }
}
