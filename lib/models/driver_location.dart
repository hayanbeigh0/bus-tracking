class DriverCurrentLocation {
  String? name;
  double? latitude;
  double? longitude;
  num? speed;
  String? phoneNumber;
  num? busNumber;
  bool? isActive;

  DriverCurrentLocation({
    this.name,
    this.latitude,
    this.longitude,
    this.speed,
    this.busNumber,
    this.isActive,
    this.phoneNumber,
  });

  DriverCurrentLocation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    speed = json['speed'];
    busNumber = json['busNumber'];
    isActive = json['isActive'];
    phoneNumber = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['speed'] = speed;
    data['busNumber'] = busNumber;
    data['isActive'] = isActive;
    data['phone'] = phoneNumber;
    return data;
  }
}
