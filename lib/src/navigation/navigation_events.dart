part of mapbox_maps_flutter;

final class NavigationEvents extends ChangeNotifier {
  bool _mounted = true;
  NavigationManager? _navigationManager;

  bool get mounted => _mounted;
  BinaryMessenger? binaryMessenger =
      ServicesBinding.instance.defaultBinaryMessenger;

  RouteProgressEvent? _routeProgress;

  RouteProgressEvent? get routeProgress => _routeProgress;

  set routeProgress(RouteProgressEvent? value) {
    _routeProgress = value;
    notifyListeners();
  }

  LocationMatcherResult? _location;

  LocationMatcherResult? get location => _location;

  set location(LocationMatcherResult? value) {
    _location = value;
    notifyListeners();
  }

  NavigationSessionState? _navigationSessionState;

  NavigationSessionState? get navigationSessionState => _navigationSessionState;

  @override
  void dispose() {
    super.dispose();
    _mounted = false;
  }

  set navigationSessionState(NavigationSessionState? value) {
    _navigationSessionState = value;
    notifyListeners();
  }

  void _setupEventStreams(NavigationManager navigationManager) {
    _navigationManager = navigationManager;
    // Route progress events.
    navigationManager.routeProgress = EventChannel(
      "com.mapbox.maps.flutter/navigation#route_progress",
    ).receiveBroadcastStream().map(
          (routeProgress) {
        // print(routeProgress);
        print("routeProgressEvent:${navigationManager._suffix}");
        final transformedRouteProgress =
        RouteProgressEvent.fromJson(jsonDecode(routeProgress));
        if (mounted) {
          this.routeProgress = transformedRouteProgress;
        }
        return transformedRouteProgress;
      },
    );

    // Location update events.
    navigationManager.location = EventChannel(
      "com.mapbox.maps.flutter/navigation#location_update",
    ).receiveBroadcastStream().map(
          (location) {
        print("locationEvent:${navigationManager._suffix}");
        final transformedLocation =
        LocationMatcherResult.fromJson(jsonDecode(location));
        if (mounted) {
          this.location = transformedLocation;
        }
        return transformedLocation;
      },
    );

    // Navigation state events.
    navigationManager.navigationSessionState = EventChannel(
      "com.mapbox.maps.flutter/navigation#navigation_state",
    ).receiveBroadcastStream().map(
          (navigationSessionState) {
        print("navigationStateEvent:${navigationManager._suffix}");
        final transformedNavigationSessionState =
        NavigationSessionState.fromString(
            jsonDecode(navigationSessionState));
        if (mounted) {
          this.navigationSessionState = transformedNavigationSessionState;
        }
        return transformedNavigationSessionState;
      },
    );
  }
}
