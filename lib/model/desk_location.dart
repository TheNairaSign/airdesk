class DeskLocation {
  final String? country;
  final String? city;
  final String? region;
  final String? ip;

  const DeskLocation({
    this.country,
    this.city,
    this.region,
    this.ip,
  });

  factory DeskLocation.fromJson(Map<String, dynamic> json) {
    return DeskLocation(
      country: json['country'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      ip: json['ip'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'country': country,
    'city': city,
    'region': region,
    'ip': ip,
  };
}
