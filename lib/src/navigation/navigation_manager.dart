part of mapbox_maps_flutter;

final _NavigationInstanceManager _navigationInstanceManager =
_NavigationInstanceManager();

class NavigationManager {
  final int _suffix = _suffixesRegistry.getSuffix();

  String get _messageChannel => "navigation-manager/${_suffix.toString()}";
  late final _NavigationManager _api;
  final NavigationEvents _navigationEvents = NavigationEvents();

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
    final manager = NavigationManager._();
    await Permission.locationWhenInUse.request();
    await _navigationInstanceManager
        .setupNavigationManager(manager._messageChannel);
    manager._setupEventStreams();
    _finalizer.attach(manager, manager._suffix, detach: manager);

    return manager;
  }

  void _setupEventStreams() {
    // Route progress events.
    routeProgress = EventChannel(
      "com.mapbox.maps.flutter/navigation#route_progress",
    ).receiveBroadcastStream().map(
          (routeProgress) {
        final transformedRouteProgress =
        RouteProgressEvent.fromJson(jsonDecode(routeProgress));
        _navigationEvents.routeProgress = transformedRouteProgress;
        return transformedRouteProgress;
      },
    );

    // Location update events.
    location = EventChannel(
      "com.mapbox.maps.flutter/navigation#location_update",
    ).receiveBroadcastStream().map(
          (location) {
        final transformedLocation =
        LocationMatcherResult.fromJson(jsonDecode(location));
        _navigationEvents.location = transformedLocation;
        return transformedLocation;
      },
    );

    // Navigation state events.
    navigationSessionState = EventChannel(
      "com.mapbox.maps.flutter/navigation#navigation_state",
    ).receiveBroadcastStream().map(
          (navigationSessionState) {
        final transformedNavigationSessionState =
        NavigationSessionState.fromString(
            jsonDecode(navigationSessionState));
        _navigationEvents.navigationSessionState =
            transformedNavigationSessionState;
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
