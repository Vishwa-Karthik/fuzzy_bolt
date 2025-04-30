import 'dart:async';

import 'package:fuzzy_bolt/mixin/isolate_search.dart';
import 'package:fuzzy_bolt/mixin/local_search.dart';
import 'package:fuzzy_bolt/utils/constants.dart';

class StreamSearchImpl with LocalSearch, IsolateSearch {
  StreamSubscription<String>? _subscription;
  Completer<void>? _ongoingSearch;

  final StreamController<List<Map<String, dynamic>>> _controller =
      StreamController.broadcast();

  /// Stream-based search for fuzzy results
  Stream<List<String>> streamSearch({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) {
    // Validate inputs
    if (dataset.isEmpty) {
      throw ArgumentError("Dataset cannot be empty.");
    }
    if (strictThreshold != null &&
        (strictThreshold < 0 || strictThreshold > 1)) {
      throw ArgumentError("strictThreshold must be between 0 and 1.");
    }
    if (typoThreshold != null && (typoThreshold < 0 || typoThreshold > 1)) {
      throw ArgumentError("typoThreshold must be between 0 and 1.");
    }

    final controller = StreamController<List<String>>.broadcast();

    // Listen to incoming search terms from the query stream
    final subscription = query.listen(
      (inputQuery) async {
        if (inputQuery.trim().isEmpty) {
          // Emit an empty list for empty queries
          if (!controller.isClosed) {
            controller.add([]);
          }
          return;
        }

        try {
          // Perform the search
          final result = await _performSearch(
            dataset: dataset,
            query: inputQuery,
            strictThreshold:
                strictThreshold ?? Constants.defaultStrictThreshold,
            typoThreshold: typoThreshold ?? Constants.defaultTypoThreshold,
            kIsWeb: kIsWeb ?? false,
          );

          // Emit the search results
          if (!controller.isClosed) {
            controller.add(result);
          }
        } catch (e, stackTrace) {
          if (!controller.isClosed) {
            controller.addError(e, stackTrace);
          }
        }
      },
      onError: (e, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(e, stackTrace);
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );

    // Ensure the subscription is canceled when the stream is closed
    controller.onCancel = () async {
      await subscription.cancel();
    };

    return controller.stream;
  }

  /// Stream-based search with ranked results
  Stream<List<Map<String, dynamic>>> streamSearchWithRanks({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
  }) {
    if (dataset.isEmpty) {
      throw ArgumentError("Dataset cannot be empty.");
    }

    _subscription?.cancel(); // Cancel any existing subscription safely
    _subscription = query.listen((inputQuery) async {
      if (inputQuery.trim().isEmpty) {
        // Emit an empty list for empty queries
        if (!_controller.isClosed) {
          _controller.add([]);
        }
        throw ArgumentError("Query cannot be empty or whitespace.");
      }

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
          rethrow;
        }
      } finally {
        _ongoingSearch?.complete();
      }
    });

    return _controller.stream;
  }

  /// Perform search for non-ranked results
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

  /// Perform search for ranked results
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
