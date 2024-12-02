import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/pigeons/messages.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/mapbox/maps/mapbox_maps/pigeons/Messages.g.kt',
  kotlinOptions: KotlinOptions(package: "com.mapbox.maps.mapbox_maps.pigeons"),
  swiftOut: 'ios/Classes/Generated/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'mapbox_maps_flutter',
))
class RouteProgressEventData {
  RouteProgressEventData({required this.distanceTraveled});

  double distanceTraveled;
}

enum PlaceAutocompleteType {
  country(name: "country"),
  region(name: "region"),
  postcode(name: "postcode"),
  district(name: "district"),
  place(name: "place"),
  locality(name: "locality"),
  neighborhood(name: "neighborhood"),
  street(name: "street"),
  address(name: "address");

  const PlaceAutocompleteType({
    required this.name,
  });

  final String name;
}

class GeoPoint {
  final String type;

  // final BoundingBox? bbox;

  final List<double> coordinates;

  GeoPoint(this.type, this.coordinates);
}

class PlaceAutoCompleteSuggestion {
  /// Place's name.
  final String name;

  /// Formatted address.
  final String? formattedAddress;

  /// Place geographic point.
  final GeoPoint? coordinate;

  /// List of points near [coordinate], that represents entries to associated building.
  final List<RoutablePoint>? routablePoints;

  /// [Maki](https://github.com/mapbox/maki/) icon name for the place.
  final String? makiIcon;

  /// Distance in meters from place's coordinate to user location (if available).
  final double? distanceMeters;

  /// Estimated time of arrival (in minutes) based on the specified navigation profile.
  final double? etaMinutes;

  /// The type of result.
  final PlaceAutocompleteType type;

  ///Poi categories. Always empty for non-POI suggestions.
  final List<String>? categories;

  PlaceAutoCompleteSuggestion(
      this.name,
      this.formattedAddress,
      this.coordinate,
      this.routablePoints,
      this.makiIcon,
      this.distanceMeters,
      this.etaMinutes,
      this.type,
      this.categories);
}

class RoutablePoint {
  final GeoPoint point;
  final String name;

  RoutablePoint(this.point, this.name);
}

class PlaceAutocompleteResult {
  /// Result ID
  final String id;

  /// Result MapboxID
  final String? mapboxId;

  /// Place's name.
  final String name;

  /// Place geographic point.
  final GeoPoint coordinate;

  /// List of points near [coordinate], that represents entries to associated building.
  final List<RoutablePoint>? routablePoints;

  /// [Maki](https://github.com/mapbox/maki/) icon name for the place.
  final String? makiIcon;

  /// Distance in meters from place's coordinate to user location (if available).
  final double? distanceMeters;

  /// Estimated time of arrival (in minutes) based on the specified navigation profile.
  final double? etaMinutes;

  /// Place's address.
  // final PlaceAutocompleteAddress? address;

  /// The type of result.
  final PlaceAutocompleteType type;

  /// Poi categories. Always empty for non-POI results.
  /// @see type
  final List<String>? categories;

  /// Business phone number.
  final String? phone;

  /// Business website.
  final String? website;

  /// Number of reviews.
  final int? reviewCount;

  /// Average rating.
  final double? averageRating;

  // /// Business opening hours.
  // final OpenHours? openHours;
  //
  // /// List of place's primary photos.
  // final List<ImageInfo>? primaryPhotos;
  //
  // /// List of place's photos (non-primary).
  // final List<ImageInfo>? otherPhotos;

  PlaceAutocompleteResult({
    required this.id,
    this.mapboxId,
    required this.name,
    required this.coordinate,
    this.routablePoints,
    this.makiIcon,
    this.distanceMeters,
    this.etaMinutes,
    // this.address,
    required this.type,
    this.categories,
    this.phone,
    this.website,
    this.reviewCount,
    this.averageRating,
    // this.openHours,
    // this.primaryPhotos,
    // this.otherPhotos,
  });
}

enum _NavigationEventTypes {
  routeLineChanged,
}

@HostApi()
abstract class _NavigationManager {
  String getHostLanguage();

  // These annotations create more idiomatic naming of methods in Objc and Swift.
  @SwiftFunction('example()')
  void example();

  // These annotations create more idiomatic naming of methods in Objc and Swift.
  void setRoute(GeoPoint origin, GeoPoint destination);

  // These annotations create more idiomatic naming of methods in Objc and Swift.
  void setRouteById(String routeId);

  void cancelRoute();

  String getNavigationSessionState();
}

@HostApi()
abstract class _NavigationInstanceManager {
  // These annotations create more idiomatic naming of methods in Objc and Swift.
  void setupNavigationManager(String channelSuffix);

  // These annotations create more idiomatic naming of methods in Objc and Swift.
  void tearDownNavigationManager(String channelSuffix);
}

@HostApi()
abstract class _NavigationCameraManager {
  void requestNavigationCameraToOverview();

  void requestNavigationCameraToFollowing();
}

@HostApi()
abstract class _PlaceAutocompleteManager {
  @async
  List<PlaceAutoCompleteSuggestion> suggestions(String query);

  @async
  PlaceAutocompleteResult? select(int index);
}

@HostApi()
abstract class _PlaceAutocompleteInstanceManager {
  // These annotations create more idiomatic naming of methods in Objc and Swift.
  void setupPlaceAutocompleteManager(String channelSuffix);

  // These annotations create more idiomatic naming of methods in Objc and Swift.
  void tearDownPlaceAutocompleteManager(String channelSuffix);
}
