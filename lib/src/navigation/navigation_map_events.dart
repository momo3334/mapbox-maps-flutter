part of mapbox_maps_flutter;

typedef void OnRouteLineChangedListener(
    RouteChangedEventData routeChangedEventData);

final class _NavigationMapEvents {
  OnRouteLineChangedListener? _onRouteLineChangedListener;

  BinaryMessenger? binaryMessenger;
  late final MethodChannel _channel;
  List<_NavigationEventTypes> _subscribedEventTypes = [];

  List<_NavigationEventTypes> get eventTypes {
    final listenersMap = {
      _onRouteLineChangedListener: _NavigationEventTypes.routeLineChanged,
    };
    listenersMap.remove(null);

    return listenersMap.values.toList();
  }

  _NavigationMapEvents(
      {required this.binaryMessenger, required String channelSuffix}) {
    final pigeonChannelSuffix =
        channelSuffix.isNotEmpty ? '.$channelSuffix' : '';
    _channel = MethodChannel(
        'com.mapbox.maps.flutter.navigation_map_events$pigeonChannelSuffix',
        const StandardMethodCodec(),
        binaryMessenger);
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    try {
      if (call.method.startsWith("event")) {
        _handleEvents(call);
      } else {
        throw MissingPluginException();
      }
    } catch (error) {
      print(
          "Handle method call ${call.method}, arguments: ${call.arguments} with error: $error");
    }
  }

  void _handleEvents(MethodCall call) {
    final eventType =
        _NavigationEventTypes.values[int.parse(call.method.split("#")[1])];
    switch (eventType) {
      case _NavigationEventTypes.routeLineChanged:
        _onRouteLineChangedListener
            ?.call(RouteChangedEventData.fromJson(jsonDecode(call.arguments)));
        break;
    }
  }

  void updateSubscriptions() {
    final newEventTypes = eventTypes;

    if (listEquals(newEventTypes, _subscribedEventTypes)) {
      return;
    }

    // let the native side know which events we are interested in
    _channel.invokeMethod(
        "subscribeToEvents", newEventTypes.map((e) => e.index).toList());

    _subscribedEventTypes = newEventTypes;
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}
