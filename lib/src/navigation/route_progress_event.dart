part of mapbox_maps_flutter;

class RouteProgressEvent extends ChangeNotifier {
  CurrentLegProgress? currentLegProgress;
  double? distanceRemaining;
  double? distanceTraveled;
  double? durationRemaining;
  bool? inTunnel;
  int? remainingWaypoints;
  bool? stale;
  BannerInstructionData? bannerInstructions;

  RouteProgressEvent(
      {this.currentLegProgress,
      this.distanceRemaining,
      this.distanceTraveled,
      this.durationRemaining,
      this.inTunnel,
      this.remainingWaypoints,
      this.stale,
      this.bannerInstructions});

  RouteProgressEvent.fromJson(Map<String, dynamic> json) {
    bannerInstructions = json['bannerInstructions'] != null
        ? new BannerInstructionData.fromJson(json['bannerInstructions'])
        : null;
    currentLegProgress = json['currentLegProgress'] != null
        ? new CurrentLegProgress.fromJson(json['currentLegProgress'])
        : null;
    distanceRemaining = json['distanceRemaining'];
    distanceTraveled = json['distanceTraveled'];
    durationRemaining = json['durationRemaining'];
    inTunnel = json['inTunnel'];
    remainingWaypoints = json['remainingWaypoints'];
    stale = json['stale'];

    //a
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.bannerInstructions != null) {
      data['bannerInstructions'] = this.bannerInstructions!.toJson();
    }
    if (this.currentLegProgress != null) {
      data['currentLegProgress'] = this.currentLegProgress!.toJson();
    }
    data['distanceRemaining'] = this.distanceRemaining;
    data['distanceTraveled'] = this.distanceTraveled;
    data['durationRemaining'] = this.durationRemaining;
    data['inTunnel'] = this.inTunnel;
    data['remainingWaypoints'] = this.remainingWaypoints;
    data['stale'] = this.stale;
    return data;
  }
}
