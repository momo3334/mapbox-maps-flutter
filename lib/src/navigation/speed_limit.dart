part of mapbox_maps_flutter;

class LocationMatcherResult {
  EnhancedLocation? enhancedLocation;
  bool? inTunnel;
  bool? isDegradedMapMatching;
  bool? isOffRoad;
  bool? isTeleport;
  double? offRoadProbability;
  SpeedLimit? speedLimit;

  LocationMatcherResult({this.enhancedLocation,
    this.inTunnel,
    this.isDegradedMapMatching,
    this.isOffRoad,
    this.isTeleport,
    this.offRoadProbability,
    this.speedLimit});

  LocationMatcherResult.fromJson(Map<String, dynamic> json) {
    enhancedLocation = json['enhancedLocation'] != null
        ? EnhancedLocation.fromJson(json['enhancedLocation'])
        : null;
    inTunnel = json['inTunnel'];
    isDegradedMapMatching = json['isDegradedMapMatching'];
    isOffRoad = json['isOffRoad'];
    isTeleport = json['isTeleport'];
    offRoadProbability = json['offRoadProbability'];
    speedLimit = json['speedLimitInfo'] != null
        ? SpeedLimit.fromJson(json['speedLimitInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (enhancedLocation != null) {
      data['enhancedLocation'] = enhancedLocation!.toJson();
    }
    data['inTunnel'] = inTunnel;
    data['isDegradedMapMatching'] = isDegradedMapMatching;
    data['isOffRoad'] = isOffRoad;
    data['isTeleport'] = isTeleport;
    data['offRoadProbability'] = offRoadProbability;
    if (speedLimit != null) {
      data['speedLimitInfo'] = speedLimit!.toJson();
    }
    return data;
  }
}

class EnhancedLocation {
  double? latitude;
  double? longitude;
  double? speed;
  double? speedAccuracy;
  int? timestamp;

  EnhancedLocation({this.latitude,
    this.longitude,
    this.speed,
    this.speedAccuracy,
    this.timestamp});

  EnhancedLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    speed = json['speed'];
    speedAccuracy = json['speedAccuracy'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['speed'] = speed;
    data['speedAccuracy'] = speedAccuracy;
    data['timestamp'] = timestamp;
    return data;
  }
}

class SpeedLimit {
  String? sign;
  int? speed;
  String? unit;

  SpeedLimit({this.sign, this.speed, this.unit});

  SpeedLimit.fromJson(Map<String, dynamic> json) {
    sign = json['sign'];
    speed = json['speed'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sign'] = sign;
    data['speed'] = speed;
    data['unit'] = unit;
    return data;
  }
}
