class LocationInformations {
  String city;
  String state;
  String country;

  LocationInformations({
    this.city = '',
    this.state = '',
    this.country = ''
  });

  static LocationInformations fromMap(Map<String, dynamic> map) {
    return LocationInformations(
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'state' : state,
      'country': country
    };
  }

  String get display {
    String display = '';

    if (city.isNotEmpty) {
      display += city;
      if (country.isNotEmpty) {
        display += ", $country";
      }
    } else {
      if (country.isNotEmpty) {
        display = country;
      } else {
        display = '--';
      }
    }

    return display;
  }
}