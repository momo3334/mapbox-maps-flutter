part of mapbox_maps_flutter;

final _NavigationInstanceManager _navigationInstanceManager =
    _NavigationInstanceManager();

class NavigationManager {
  final int _suffix = _suffixesRegistry.getSuffix();

  String get _messageChannel => "navigation-manager/${_suffix.toString()}";
  late final _NavigationManager _api;
  NavigationEvents? _navigationEvents;

  // EventStreams.
  Stream<NavigationSessionState>? navigationSessionState;
  Stream<LocationMatcherResult>? location;
  Stream<RouteProgressEvent>? routeProgress;

  // Stream<DirectionRoute>? directionRoute;

  static final Finalizer<int> _finalizer = Finalizer((suffix) {
    try {
      _navigationInstanceManager
          .tearDownNavigationManager("navigation-manager/${suffix.toString()}");
      _suffixesRegistry.releaseSuffix(suffix);
    } catch (e) {}
  });

  static NavigationManager? _manager;

  NavigationManager._() {
    _api = _NavigationManager(
      binaryMessenger: ServicesBinding.instance.defaultBinaryMessenger,
      messageChannelSuffix: _messageChannel,
    );
  }

  /// Creates a new instance of [NavigationManager].
  static Future<NavigationManager> create() async {
    final manager = NavigationManager._();
    await Permission.locationWhenInUse.request();
    await _navigationInstanceManager
        .setupNavigationManager(manager._messageChannel);
    _finalizer.attach(manager, manager._suffix, detach: manager);
    return manager;
  }

  /// Creates a new instance of [NavigationManager].
  static Future<NavigationManager> createWithEventStreams() async {
    if (_manager == null) {
      _manager = NavigationManager._();
      await Permission.locationWhenInUse.request();
      await _navigationInstanceManager
          .setupNavigationManager(_manager!._messageChannel);
      // _manager!._setupEventStreams();
      _finalizer.attach(_manager!, _manager!._suffix, detach: _manager);
    }

    return _manager!;
  }

  void _setupEventStreams(NavigationEvents navigationEvents) {
    _navigationEvents = navigationEvents;
    // Route progress events.
    routeProgress = EventChannel(
      "com.mapbox.maps.flutter/navigation#route_progress",
    ).receiveBroadcastStream().map(
      (routeProgress) {
        // print(routeProgress);
        print(_suffix);
        final transformedRouteProgress =
            RouteProgressEvent.fromJson(jsonDecode(routeProgress));
        if (_navigationEvents?.mounted ?? false) {
          _navigationEvents?.routeProgress = transformedRouteProgress;
        }
        return transformedRouteProgress;
      },
    );

    // Location update events.
    location = EventChannel(
      "com.mapbox.maps.flutter/navigation#location_update",
    ).receiveBroadcastStream().map(
      (location) {
        print(_suffix);
        final transformedLocation =
            LocationMatcherResult.fromJson(jsonDecode(location));
        if (_navigationEvents?.mounted ?? false) {
          _navigationEvents?.location = transformedLocation;
        }
        return transformedLocation;
      },
    );

    // Navigation state events.
    navigationSessionState = EventChannel(
      "com.mapbox.maps.flutter/navigation#navigation_state",
    ).receiveBroadcastStream().map(
      (navigationSessionState) {
        print(navigationSessionState);
        final transformedNavigationSessionState =
            NavigationSessionState.fromString(
                jsonDecode(navigationSessionState));
        if (_navigationEvents?.mounted ?? false) {
          _navigationEvents?.navigationSessionState =
              transformedNavigationSessionState;
        }
        return transformedNavigationSessionState;
      },
    );
  }

  Future<void> example() async {
    await _api.example();
  }

  Future<String> getHostLanguage() {
    // TODO: implement getHostLanguage
    throw UnimplementedError();
  }

  Future<void> setRoute(GeoPoint origin, GeoPoint destination) async {
    await _api.setRoute(origin, destination);
  }

  Future<void> cancelRoute() async {
    await _api.cancelRoute();
  }

  Future<void> setRouteById(String routeId) async {
    await _api.setRouteById(routeId);
  }

  Future<NavigationSessionState> getNavigationSessionState() async {
    return NavigationSessionState.fromString(
      await _api.getNavigationSessionState(),
    );
  }
}
