part of mapbox_maps_flutter;

final class NavigationEvents extends ChangeNotifier {
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

  set navigationSessionState(NavigationSessionState? value) {
    _navigationSessionState = value;
    notifyListeners();
  }

  NavigationEvents setupEventChannels() {
    // // Route progress events.
    // final eventChannel = EventChannel(
    //   "com.mapbox.maps.flutter/navigation#route_progress",
    // );
    // eventChannel.receiveBroadcastStream().listen((event) {
    //   routeProgress = RouteProgressEvent.fromJson(jsonDecode(event));
    //   notifyListeners();
    // });
    //
    // // Location update events.
    // final eventChannelLocation = EventChannel(
    //   "com.mapbox.maps.flutter/navigation#location_update",
    // );
    // eventChannelLocation.receiveBroadcastStream().listen((event) {
    //   speedLimit = SpeedLimit.fromJson(jsonDecode(event));
    //   notifyListeners();
    // });
    // // Navigation state events.
    // final eventChannelNavigationStatus = EventChannel(
    //   "com.mapbox.maps.flutter/navigation#navigation_state",
    // );
    // eventChannelNavigationStatus.receiveBroadcastStream().listen((event) {
    //   navigationSessionState =
    //       NavigationSessionState.fromString(jsonDecode(event));
    //   notifyListeners();

    // });
    return this;
  }
}
