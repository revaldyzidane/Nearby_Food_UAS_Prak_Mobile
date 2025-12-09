import 'dart:convert';
import 'package:http/http.dart' as http;
import 'place_geoapify.dart';
import 'app_config.dart';

class GeoapifyPlacesService {
  final String apiKey;

  GeoapifyPlacesService({String? apiKeyOverride})
      : apiKey = apiKeyOverride ?? geoapifyApiKey;

  /// 🔹 Fungsi generik: bisa untuk restaurant, fast_food, cafe, dll
  Future<List<PlaceGeoapify>> getNearbyPlaces({
    required double lat,
    required double lon,
    String categories = 'catering.restaurant', // default: restoran
    int radiusInMeters = 10000,
    int limit = 50,
  }) async {
    final url = Uri.parse(
      'https://api.geoapify.com/v2/places'
      '?categories=$categories'
      '&filter=circle:$lon,$lat,$radiusInMeters'
      '&bias=proximity:$lon,$lat'
      '&limit=$limit'
      '&apiKey=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data Geoapify: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>? ?? [];

    return features
        .map((f) => PlaceGeoapify.fromFeature(f as Map<String, dynamic>))
        .toList();
  }

  /// 🔹 Wrapper lama: untuk kode lain yang masih pakai "restaurants"
  Future<List<PlaceGeoapify>> getNearbyRestaurants(
    double lat,
    double lon, {
    int radiusInMeters = 10000,
    int limit = 50,
  }) {
    return getNearbyPlaces(
      lat: lat,
      lon: lon,
      categories: 'catering.restaurant',
      radiusInMeters: radiusInMeters,
      limit: limit,
    );
  }
}
