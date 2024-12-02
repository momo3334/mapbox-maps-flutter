part of mapbox_maps_flutter;

class NavigationMap extends StatefulWidget {
  NavigationMap({
    super.key,
    this.mapOptions,
    this.cameraOptions,
    // FIXME Flutter 3.x has memory leak on Android using in SurfaceView mode, see https://github.com/flutter/flutter/issues/118384
    // As a workaround default is true.
    this.textureView = true,
    this.androidHostingMode = AndroidPlatformViewHostingMode.VD,
    this.styleUri = MapboxStyles.STANDARD,
    this.gestureRecognizers,
    this.onMapCreated,
    this.onStyleLoadedListener,
    this.onCameraChangeListener,
    this.onMapIdleListener,
    this.onMapLoadedListener,
    this.onMapLoadErrorListener,
    this.onRenderFrameStartedListener,
    this.onRenderFrameFinishedListener,
    this.onSourceAddedListener,
    this.onSourceDataLoadedListener,
    this.onSourceRemovedListener,
    this.onStyleDataLoadedListener,
    this.onStyleImageMissingListener,
    this.onStyleImageUnusedListener,
    this.onResourceRequestListener,
    this.onRouteLineChangedListener,
    this.onTapListener,
    this.onLongTapListener,
    this.onScrollListener,
    this.withNavigation = false,
  });

  /// Describes the map options value when using a MapWidget.
  final MapOptions? mapOptions;

  /// The Initial Camera options when creating a MapWidget.
  final CameraOptions? cameraOptions;

  /// Flag indicating to use a TextureView as render surface for the MapWidget.
  /// Only works for Android.
  /// FIXME Flutter 3.x has memory leak on Android using in SurfaceView mode, see https://github.com/flutter/flutter/issues/118384
  /// As a workaround default is true.
  final bool? textureView;

  /// Controls the way the underlying MapView is being hosted by Flutter on Android.
  /// This setting has no effect on iOS.
  @experimental
  final AndroidPlatformViewHostingMode androidHostingMode;

  /// The styleUri will applied for the MapWidget in the onStart lifecycle event if no style is set. Default is [Style.MAPBOX_STREETS].
  final String styleUri;

  /// Invoked when a new Map is created and return a MapboxMap instance to handle the Map.
  final MapCreatedCallback? onMapCreated;

  /// Invoked when the requested style has been fully loaded, including the style, specified sprite and sources' metadata.
  final OnStyleLoadedListener? onStyleLoadedListener;

  /// Invoked whenever camera position changes.
  final OnCameraChangeListener? onCameraChangeListener;

  /// Invoked when the Map has entered the idle state. The Map is in the idle state when there are no ongoing transitions
  /// and the Map has rendered all available tiles.
  final OnMapIdleListener? onMapIdleListener;

  /// Invoked when the Map's style has been fully loaded, and the Map has rendered all visible tiles.
  final OnMapLoadedListener? onMapLoadedListener;

  /// Invoked whenever the map load errors out.
  final OnMapLoadErrorListener? onMapLoadErrorListener;

  /// Invoked whenever the Map finished rendering a frame.
  /// The render-mode value tells whether the Map has all data ("full") required to render the visible viewport.
  /// The needs-repaint value provides information about ongoing transitions that trigger Map repaint.
  /// The placement-changed value tells if the symbol placement has been changed in the visible viewport.
  final OnRenderFrameFinishedListener? onRenderFrameFinishedListener;

  /// Invoked whenever the Map started rendering a frame.
  final OnRenderFrameStartedListener? onRenderFrameStartedListener;

  /// Invoked whenever the Source has been added with StyleManager#addStyleSource runtime API.
  final OnSourceAddedListener? onSourceAddedListener;

  /// Invoked when the requested source data has been loaded.
  final OnSourceDataLoadedListener? onSourceDataLoadedListener;

  /// Invoked whenever the Source has been removed with StyleManager#removeStyleSource runtime API.
  final OnSourceRemovedListener? onSourceRemovedListener;

  /// Invoked when the requested style data has been loaded.
  final OnStyleDataLoadedListener? onStyleDataLoadedListener;

  /// Invoked whenever a style has a missing image. This event is emitted when the Map renders visible tiles and
  /// one of the required images is missing in the sprite sheet. Subscriber has to provide the missing image
  /// by calling StyleManager#addStyleImage method.
  final OnStyleImageMissingListener? onStyleImageMissingListener;

  /// Invoked whenever an image added to the Style is no longer needed and can be removed using StyleManager#removeStyleImage method.
  final OnStyleImageUnusedListener? onStyleImageUnusedListener;

  /// Invoked when map makes a request to load required resources.
  final OnResourceRequestListener? onResourceRequestListener;

  /// Invoked when the selected routeLine changes (eg: user taps on alternative route line).
  final OnRouteLineChangedListener? onRouteLineChangedListener;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  final bool withNavigation;

  final _navigationMapWidgetState = _NavigationMapState();

  final OnMapTapListener? onTapListener;
  final OnMapLongTapListener? onLongTapListener;
  final OnMapScrollListener? onScrollListener;

  @override
  State<NavigationMap> createState() => _navigationMapWidgetState;

  MapboxMap? getMapboxMap() => _navigationMapWidgetState.mapboxMap;
}

class _NavigationMapState extends State<NavigationMap> {
  MapboxMap? mapboxMap;
  late final _NavigationMapEvents _events;
  final _suffix = _suffixesRegistry.getSuffix();
  late final _MapboxMapsPlatform _mapboxMapsPlatform =
  _MapboxMapsPlatform.instance(_suffix);

  @override
  void initState() {
    super.initState();

    _events = _NavigationMapEvents(
        binaryMessenger: _mapboxMapsPlatform.binaryMessenger,
        channelSuffix: _suffix.toString());
    _updateEventListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: ValueKey("mapWidget"),
      cameraOptions: CameraOptions(
          center: Point(
              coordinates: Position(
                6.0033416748046875,
                43.70908256335716,
              )),
          zoom: 3.0),
      styleUri: MapboxStyles.STANDARD,
      textureView: true,
      onMapCreated: widget.onMapCreated,
      onStyleLoadedListener: widget.onStyleLoadedListener,
      onCameraChangeListener: widget.onCameraChangeListener,
      onMapIdleListener: widget.onMapIdleListener,
      onMapLoadedListener: widget.onMapLoadedListener,
      onMapLoadErrorListener: widget.onMapLoadErrorListener,
      onRenderFrameStartedListener: widget.onRenderFrameStartedListener,
      onRenderFrameFinishedListener: widget.onRenderFrameFinishedListener,
      onSourceAddedListener: widget.onSourceAddedListener,
      onSourceDataLoadedListener: widget.onSourceDataLoadedListener,
      onSourceRemovedListener: widget.onSourceRemovedListener,
      onStyleDataLoadedListener: widget.onStyleDataLoadedListener,
      onStyleImageMissingListener: widget.onStyleImageMissingListener,
      onStyleImageUnusedListener: widget.onStyleImageUnusedListener,
      onResourceRequestListener: widget.onResourceRequestListener,
      onLongTapListener: widget.onLongTapListener,
      withNavigation: true,
      onMapboxControllerCreated: _onMapboxControllerCreated,
      suffix: _suffix,
    );
  }

  Future<void> _onMapboxControllerCreated(MapboxMap controller) async {
    mapboxMap = controller;
    _events.updateSubscriptions();
  }

  void _updateEventListeners() {
    _events._onRouteLineChangedListener = widget.onRouteLineChangedListener;
  }

  @override
  void didUpdateWidget(NavigationMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateEventListeners();

    if (mapboxMap != null) {
      _events.updateSubscriptions();
    }
  }

  @override
  void dispose() {
    mapboxMap?.dispose();
    _suffixesRegistry.releaseSuffix(_suffix);
    _events.dispose();

    super.dispose();
  }
}
