class BannerInstructionData{
  double? distanceAlongGeometry;
  Primary? primary;

  BannerInstructionData({this.distanceAlongGeometry, this.primary});

  BannerInstructionData.fromJson(Map<String, dynamic> json) {
    distanceAlongGeometry = json['distanceAlongGeometry'];
    primary =
    json['primary'] != null ? new Primary.fromJson(json['primary']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['distanceAlongGeometry'] = this.distanceAlongGeometry;
    if (this.primary != null) {
      data['primary'] = this.primary!.toJson();
    }
    return data;
  }
}

class Primary {
  List<Components>? components;
  String? modifier;
  String? text;
  String? type;

  Primary({this.components, this.modifier, this.text, this.type});

  Primary.fromJson(Map<String, dynamic> json) {
    if (json['components'] != null) {
      components = <Components>[];
      json['components'].forEach((v) {
        components!.add(new Components.fromJson(v));
      });
    }
    modifier = json['modifier'];
    text = json['text'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.components != null) {
      data['components'] = this.components!.map((v) => v.toJson()).toList();
    }
    data['modifier'] = this.modifier;
    data['text'] = this.text;
    data['type'] = this.type;
    return data;
  }
}

class Components {
  String? text;
  String? type;

  Components({this.text, this.type});

  Components.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['type'] = this.type;
    return data;
  }
}
class CurrentLegProgress {
  CurrentStepProgress? currentStepProgress;
  double? distanceRemaining;
  double? distanceTraveled;
  double? durationRemaining;

  CurrentLegProgress(
      {this.currentStepProgress,
        this.distanceRemaining,
        this.distanceTraveled,
        this.durationRemaining});

  CurrentLegProgress.fromJson(Map<String, dynamic> json) {
    currentStepProgress = json['currentStepProgress'] != null
        ? new CurrentStepProgress.fromJson(json['currentStepProgress'])
        : null;
    distanceRemaining = json['distanceRemaining'];
    distanceTraveled = json['distanceTraveled'];
    durationRemaining = json['durationRemaining'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.currentStepProgress != null) {
      data['currentStepProgress'] = this.currentStepProgress!.toJson();
    }
    data['distanceRemaining'] = this.distanceRemaining;
    data['distanceTraveled'] = this.distanceTraveled;
    data['durationRemaining'] = this.durationRemaining;
    return data;
  }
}

class CurrentStepProgress {
  double? distanceRemaining;
  double? distanceTraveled;
  double? durationRemaining;
  double? fractionTraveled;

  CurrentStepProgress(
      {this.distanceRemaining,
        this.distanceTraveled,
        this.durationRemaining,
        this.fractionTraveled});

  CurrentStepProgress.fromJson(Map<String, dynamic> json) {
    distanceRemaining = json['distanceRemaining'];
    distanceTraveled = json['distanceTraveled'];
    durationRemaining = json['durationRemaining'];
    fractionTraveled = json['fractionTraveled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['distanceRemaining'] = this.distanceRemaining;
    data['distanceTraveled'] = this.distanceTraveled;
    data['durationRemaining'] = this.durationRemaining;
    data['fractionTraveled'] = this.fractionTraveled;
    return data;
  }
}
