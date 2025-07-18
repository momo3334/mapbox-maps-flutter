import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'example.dart';

class FullMapExample extends StatefulWidget implements Example {
  @override
  final Widget leading = const Icon(Icons.map);
  @override
  final String title = 'Full screen map';
  @override
  final String? subtitle = null;

  @override
  State createState() => FullMapExampleState();
}

class FullMapExampleState extends State<FullMapExample>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  MapboxMap? mapboxMap;
  var isLight = true;
  PointAnnotationManager? annotationManager;
  Point? lastLocation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween<double>(begin: 100, end: 300).animate(controller)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object's value.
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    mapboxMap.style;
    annotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    await Permission.locationWhenInUse.request();
  }

  _onStyleLoadedCallback(StyleLoadedEventData data) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Style loaded :), time: ${data.timeInterval}"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 1),
    ));
  }

  _onCameraChangeListener(CameraChangedEventData data) {
    // print("CameraChangedEventData: ${data.debugInfo}");
  }

  _onResourceRequestListener(ResourceEventData data) {
    // print("ResourceEventData: time: ${data.timeInterval}");
  }

  _onMapIdleListener(MapIdleEventData data) {
    // print("MapIdleEventData: timestamp: ${data.timestamp}");
  }

  _onMapLoadedListener(MapLoadedEventData data) {
    // print("MapLoadedEventData: time: ${data.timeInterval}");
  }

  _onMapLoadingErrorListener(MapLoadingErrorEventData data) {
    // print("MapLoadingErrorEventData: timestamp: ${data.timestamp}");
  }

  _onRenderFrameStartedListener(RenderFrameStartedEventData data) {
    // print("RenderFrameStartedEventData: timestamp: ${data.timestamp}");
  }

  _onRenderFrameFinishedListener(RenderFrameFinishedEventData data) {
    // print("RenderFrameFinishedEventData: time: ${data.timeInterval}");
  }

  _onSourceAddedListener(SourceAddedEventData data) {
    // print("SourceAddedEventData: timestamp: ${data.timestamp}");
  }

  _onSourceDataLoadedListener(SourceDataLoadedEventData data) {
    // print("SourceDataLoadedEventData: time: ${data.timeInterval}");
  }

  _onSourceRemovedListener(SourceRemovedEventData data) {
    // print("SourceRemovedEventData: timestamp: ${data.timestamp}");
  }

  _onStyleDataLoadedListener(StyleDataLoadedEventData data) {
    // print("StyleDataLoadedEventData: time: ${data.timeInterval}");
  }

  _onStyleImageMissingListener(StyleImageMissingEventData data) {
    // print("StyleImageMissingEventData: timestamp: ${data.timestamp}");
  }

  _onStyleImageUnusedListener(StyleImageUnusedEventData data) {
    // print("StyleImageUnusedEventData: timestamp: ${data.timestamp}");
  }

  // Print out map coordinates and screen position at tapped location
  _onTap(MapContentGestureContext context) async {
    // print("OnTap coordinate: {${context.point.coordinates.lng}, ${context.point.coordinates.lat}}" +
    //     " point: {x: ${context.touchPosition.x}, y: ${context.touchPosition.y}}");
    //
    // // Load the image from assets
    // final ByteData bytes =
    //     await rootBundle.load('assets/symbols/custom-icon.png');
    // final Uint8List imageData = bytes.buffer.asUint8List();
    // var pointAnnotationOptions = PointAnnotationOptions(
    //     geometry: context.point,
    //     // Example coordinates
    //     image: imageData,
    //     iconSize: 3.0);
    //
    // annotationManager?.create(pointAnnotationOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
                child: Icon(Icons.swap_horiz),
                heroTag: null,
                onPressed: () {
                  setState(
                    () => isLight = !isLight,
                  );
                  if (isLight) {
                    mapboxMap?.loadStyleURI(MapboxStyles.LIGHT);
                  } else {
                    mapboxMap?.loadStyleURI(MapboxStyles.DARK);
                  }
                }),
            SizedBox(height: 10),
          ],
        ),
      ),
      body: NavigationEventProvider(
        child: NavigationManagerConsumer(
          builder: (context, navigationManager, child) {
            return Stack(
              children: [
                if (navigationManager != null)
                  NavigationMap(
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
                    onMapCreated: _onMapCreated,
                    onStyleLoadedListener: _onStyleLoadedCallback,
                    onCameraChangeListener: _onCameraChangeListener,
                    onMapIdleListener: _onMapIdleListener,
                    onMapLoadedListener: _onMapLoadedListener,
                    onMapLoadErrorListener: _onMapLoadingErrorListener,
                    onRenderFrameStartedListener: _onRenderFrameStartedListener,
                    onRenderFrameFinishedListener:
                        _onRenderFrameFinishedListener,
                    onSourceAddedListener: _onSourceAddedListener,
                    onSourceDataLoadedListener: _onSourceDataLoadedListener,
                    onSourceRemovedListener: _onSourceRemovedListener,
                    onStyleDataLoadedListener: _onStyleDataLoadedListener,
                    onStyleImageMissingListener: _onStyleImageMissingListener,
                    onStyleImageUnusedListener: _onStyleImageUnusedListener,
                    onResourceRequestListener: _onResourceRequestListener,
                    onLongTapListener: _onTap,
                    withNavigation: true,
                  ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // await navigationManager?.setRoute();
                        },
                        child: Text("Set Route"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await mapboxMap?.requestNavigationCameraToFollowing();
                        },
                        child: Text("Start Navigation"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await mapboxMap?.requestNavigationCameraToFollowing();
                        },
                        child: Text("Recenter"),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 48,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BannerInstruction(),
                    ],
                  ),
                ),
                // Positioned(
                //   bottom: 100,
                //   left: 24,
                //   child: SpeedLimitInfo(),
                // ),
                NavigationEventConsumer(
                  builder: (context, navigationEvent, child) {
                    return navigationEvent?.navigationSessionState ==
                            NavigationSessionState.activeGuidance
                        //TODO find a way to not include unnecessary widget here.
                        ? Container()
                        : Positioned(
                            bottom: 100,
                            left: 24,
                            child: SizedBox(
                              width: 300,
                              child: TextField(
                                canRequestFocus: false,
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  final result =
                                      await ResultListView().show(context);
                                  if (result != null) {
                                    navigationManager?.setRoute(
                                      GeoPoint(
                                          type: result.coordinate.type,
                                          coordinates:
                                              result.coordinate.coordinates),
                                      GeoPoint(
                                          type: result.coordinate.type,
                                          coordinates:
                                              result.coordinate.coordinates),
                                    );
                                  }
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

extension on CameraChangedEventData {
  String get debugInfo {
    return "timestamp ${DateTime.fromMicrosecondsSinceEpoch(timestamp)}, camera: ${cameraState.debugInfo}";
  }
}

extension on CameraState {
  String get debugInfo {
    return "lat: ${center.coordinates.lat}, lng: ${center.coordinates.lng}, zoom: ${zoom}, bearing: ${bearing}, pitch: ${pitch}";
  }
}
