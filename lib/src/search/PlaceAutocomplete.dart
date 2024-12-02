part of mapbox_maps_flutter;

final _PlaceAutocompleteInstanceManager _placeAutocompleteInstanceManager =
    _PlaceAutocompleteInstanceManager();

final class PlaceAutocomplete {
  late _PlaceAutocompleteManager _api;
  late _MapEvents _mapEvents;
  final int _suffix = _suffixesRegistry.getSuffix();
  static final Finalizer<int> _finalizer = Finalizer((suffix) {
    try {
      _placeAutocompleteInstanceManager
          .tearDownPlaceAutocompleteManager(suffix.toString());
      _suffixesRegistry.releaseSuffix(suffix);
    } catch (e) {
      print("Error: Failed to dispose snapshotter, error: $e");
    }
  });

  PlaceAutocomplete._() {
    _api = _PlaceAutocompleteManager(messageChannelSuffix: _suffix.toString());
  }

  /// Creates a new [PlaceAutocomplete] instance.
  static Future<PlaceAutocomplete> create() async {
    final placeAutocomplete = PlaceAutocomplete._();

    await _placeAutocompleteInstanceManager.setupPlaceAutocompleteManager(
      placeAutocomplete._suffix.toString(),
    );

    PlaceAutocomplete._finalizer.attach(
        placeAutocomplete, placeAutocomplete._suffix,
        detach: placeAutocomplete);
    return placeAutocomplete;
  }

  /// Disposes the snapshotter instance.
  /// The instance should not be used after calling this method.
  Future<void> dispose() async {
    _finalizer.detach(this);
    await _placeAutocompleteInstanceManager
        .tearDownPlaceAutocompleteManager(_suffix.toString());
    _suffixesRegistry.releaseSuffix(_suffix);
  }

  Future<List<PlaceAutoCompleteSuggestion>> suggestions(
      {required String query}) async {
    return await _api.suggestions(query);
  }

  Future<PlaceAutocompleteResult?> select({required int index}) async {
    return await _api.select(index);
  }
}
