part of mapbox_maps_flutter;

class RouteChangedEventData {
  NavigationRoute? navigationRoute;

  RouteChangedEventData({this.navigationRoute});

  RouteChangedEventData.fromJson(Map<String, dynamic> json) {
    navigationRoute = json['navigationRoute'] != null
        ? new NavigationRoute.fromJson(json['navigationRoute'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.navigationRoute != null) {
      data['navigationRoute'] = this.navigationRoute!.toJson();
    }
    return data;
  }
}

class NavigationRoute {
  DirectionsRoute? directionsRoute;
  String? id;

  NavigationRoute({this.directionsRoute, this.id});

  NavigationRoute.fromJson(Map<String, dynamic> json) {
    directionsRoute = json['directionsRoute'] != null
        ? new DirectionsRoute.fromJson(json['directionsRoute'])
        : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.directionsRoute != null) {
      data['directionsRoute'] = this.directionsRoute!.toJson();
    }
    data['id'] = this.id;
    return data;
  }
}

class DirectionsRoute {
  double? distance;
  double? duration;
  double? durationTypical;
  String? requestUuid;
  String? routeIndex;
  String? voiceLanguage;

  DirectionsRoute(
      {this.distance,
      this.duration,
      this.durationTypical,
      this.requestUuid,
      this.routeIndex,
      this.voiceLanguage});

  DirectionsRoute.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    duration = json['duration'];
    durationTypical = json['durationTypical'];
    requestUuid = json['requestUuid'];
    routeIndex = json['routeIndex'];
    voiceLanguage = json['voiceLanguage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['distance'] = this.distance;
    data['duration'] = this.duration;
    data['durationTypical'] = this.durationTypical;
    data['requestUuid'] = this.requestUuid;
    data['routeIndex'] = this.routeIndex;
    data['voiceLanguage'] = this.voiceLanguage;
    return data;
  }
}
