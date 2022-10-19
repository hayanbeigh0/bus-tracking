class UserCurrentLocation {
  double? latitude;
  double? longitude;
  double? speed;

  UserCurrentLocation({this.latitude, this.longitude, this.speed});

  UserCurrentLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    speed = json['speed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['speed'] = speed;
    return data;
  }
}
