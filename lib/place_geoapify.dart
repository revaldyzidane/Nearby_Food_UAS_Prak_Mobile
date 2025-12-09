class PlaceGeoapify {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final String? address;
  final List<String> categories;
  final int? distanceMeters;

  // === Field tambahan untuk detail page ===
  final String? description;
  final String? cuisine; // catering.cuisine
  final String? openingHours; // opening_hours
  final Map<String, bool>? paymentOptions; // payment_options
  final String? street;
  final String? houseNumber;
  final String? city;
  final String? phone; // contact.phone
  final String? website;

  PlaceGeoapify({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    this.address,
    required this.categories,
    this.distanceMeters,
    this.description,
    this.cuisine,
    this.openingHours,
    this.paymentOptions,
    this.street,
    this.houseNumber,
    this.city,
    this.phone,
    this.website,
  });

  factory PlaceGeoapify.fromFeature(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>;

    // categories
    final categories = (props['categories'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    // distance
    int? distanceMeters;
    final rawDistance = props['distance'];
    if (rawDistance is num) {
      distanceMeters = rawDistance.round();
    }

    // catering.cuisine
    String? cuisine;
    final catering = props['catering'];
    if (catering is Map<String, dynamic>) {
      final c = catering['cuisine'];
      if (c is String && c.isNotEmpty) {
        cuisine = c;
      }
    }

    // contact.phone
    String? phone;
    final contact = props['contact'];
    if (contact is Map<String, dynamic>) {
      final p = contact['phone'];
      if (p != null && p.toString().isNotEmpty) {
        phone = p.toString();
      }
    }

    // payment_options -> Map<String, bool>
    Map<String, bool>? paymentOptions;
    final paymentRaw = props['payment_options'];
    if (paymentRaw is Map<String, dynamic>) {
      final tmp = <String, bool>{};
      paymentRaw.forEach((key, value) {
        if (value is bool) {
          if (value) tmp[key] = true;
        } else if (value is String) {
          final v = value.toLowerCase();
          if (v == 'yes' || v == 'true' || v == '1') {
            tmp[key] = true;
          }
        }
      });
      if (tmp.isNotEmpty) {
        paymentOptions = tmp;
      }
    }

    return PlaceGeoapify(
      id: props['place_id'].toString(),
      name: (props['name'] ?? 'Tanpa nama') as String,
      lat: (props['lat'] as num).toDouble(),
      lon: (props['lon'] as num).toDouble(),
      address: props['formatted'] as String?,
      categories: categories,
      distanceMeters: distanceMeters,
      description: props['description'] as String?,
      cuisine: cuisine,
      openingHours: props['opening_hours'] as String?,
      paymentOptions: paymentOptions,
      street: props['street'] as String?,
      houseNumber: props['housenumber']?.toString(),
      city: props['city'] as String?,
      phone: phone,
      website: props['website'] as String?,
    );
  }
}
