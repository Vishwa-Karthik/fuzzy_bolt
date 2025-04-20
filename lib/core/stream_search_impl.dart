import 'dart:async';

import 'package:fuzzy_bolt/mixin/isolate_search.dart';
import 'package:fuzzy_bolt/mixin/local_search.dart';
import 'package:fuzzy_bolt/utils/constants.dart';

class StreamSearchImpl with LocalSearch, IsolateSearch {
  StreamSubscription<String>? _subscription;

  Completer<void>? _ongoingSearch;

  final StreamController<List<Map<String, dynamic>>> _controller =
      StreamController.broadcast();

  Stream<List<String>> streamSearch({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) {
    final controller = StreamController<List<String>>();
    late final StreamSubscription<String> subscription;

    // Listen to incoming search terms from the query stream
    subscription = query.listen(
      (inputQuery) async {
        if (inputQuery.trim().isEmpty) {
          controller.add([]);
          return;
        }

        try {
          final result = await _performSearch(
            dataset: dataset,
            query: inputQuery,
            strictThreshold:
                strictThreshold ?? Constants.defaultStrictThreshold,
            typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
            kIsWeb: kIsWeb ?? false,
          );

          if (!controller.isClosed) {
            controller.add(result);
          }
        } catch (e, stackTrace) {
          if (!controller.isClosed) {
            controller.addError(e, stackTrace);
          }
        }
      },
      onError: (e, stack) {
        if (!controller.isClosed) {
          controller.addError(e, stack);
        }
      },
      onDone: () {
        controller.close();
      },
      cancelOnError: false,
    );

    // Ensure the search subscription is cancelled when stream is closed
    controller.onCancel = () async {
      await subscription.cancel();
    };

    return controller.stream;
  }

  Stream<List<Map<String, dynamic>>> streamSearchWithRanks({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
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
        final result = await _performSearchWithRanks(
          dataset: dataset,
          query: inputQuery,
          strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
          typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
          kIsWeb: kIsWeb ?? false,
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

  Future<List<String>> _performSearch({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async {
    if (dataset.length > Constants.isolateThreshold && kIsWeb == false) {
      final result = await searchWithIsolate(
        dataset: dataset,
        query: query,
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
      );
      return result.map((e) => e['value'] as String).toList();
    } else {
      final result = searchLocally(
        dataset: dataset,
        query: query,
        strictThreshold: strictThreshold ?? Constants.defaultStrictThreshold,
        typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
      );
      return result.map((e) => e['value'] as String).toList();
    }
  }

  /// Determines search execution strategy (Isolate vs Local)
  Future<List<Map<String, dynamic>>> _performSearchWithRanks({
    required List<String> dataset,
    required String query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) async {
    if (dataset.length > Constants.isolateThreshold && kIsWeb == false) {
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
    _ongoingSearch = null;
  }
}
