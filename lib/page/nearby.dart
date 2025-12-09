import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import '../geoapify_places_service.dart';
import '../place_geoapify.dart';
import 'restaurant_detail_page.dart';

class Nearby extends StatefulWidget {
  final String? initialCategoryKey; 

  const Nearby({super.key, this.initialCategoryKey});

  @override
  State<Nearby> createState() => _NearbyState();
}

class _NearbyState extends State<Nearby> {
  final _geoService = GeoapifyPlacesService();

  late Future<List<PlaceGeoapify>> _futurePlaces;
  Position? _currentPosition;
  String? _currentAddress;
  List<PlaceGeoapify> _places = [];

  String _mapCategoryKeyToGeoapify(String? key) {
    if (key == null) {
      return 'catering';
    }

    switch (key) {
      case 'fast_food':
        return 'catering.fast_food';
      case 'cafe':
        return 'catering.cafe';
      case 'restaurant':
        return 'catering.restaurant';
      default:
        return 'catering';
    }
  }

  String _assetForPlace(PlaceGeoapify p) {
    final cuisine = (p.cuisine ?? '').toLowerCase();
    final cats = p.categories.map((c) => c.toLowerCase()).toList();

    if (cuisine.contains('chicken')) {
      return 'assets/images/ayam.jpg';
    }

    if (cats.any((c) => c.contains('fast_food')) ||
        cuisine.contains('fast_food') ||
        cuisine.contains('burger') ||
        cuisine.contains('pizza')) {
      return 'assets/images/pizza.jpg';
    }

    if (cats.any((c) => c.contains('cafe')) ||
        cuisine.contains('coffee') ||
        cuisine.contains('cafe')) {
      return 'assets/images/cafe.jpg';
    }

    if (cuisine.contains('asian')) {
      return 'assets/images/warung.jpg';
    }

    return 'assets/images/sambel.jpg';
  }

  @override
  void initState() {
    super.initState();
    _futurePlaces = _loadNearby();
  }

  Future<List<PlaceGeoapify>> _loadNearby() async {
    // cek & minta izin lokasi
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service tidak aktif.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen.');
    }

    // ambil posisi
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = pos;
    });

    // alamat
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final parts = <String>[];
        if (p.street != null && p.street!.isNotEmpty) {
          parts.add(p.street!);
        }
        if (p.subLocality != null && p.subLocality!.isNotEmpty) {
          parts.add(p.subLocality!);
        }
        if (p.locality != null && p.locality!.isNotEmpty) {
          parts.add(p.locality!);
        }

        final addr = parts.join(', ');

        setState(() {
          _currentAddress = addr.isNotEmpty ? addr : null;
        });
      }
    } catch (_) {
      
    }

    // panggil Geoapify
    final places = await _geoService.getNearbyPlaces(
      lat: pos.latitude,
      lon: pos.longitude,
      categories: _mapCategoryKeyToGeoapify(widget.initialCategoryKey),
    );

    setState(() {
      _places = places;
    });

    return places;
  }

  String _formatDistance(PlaceGeoapify p) {
    final d = p.distanceMeters;
    if (d == null) return '';
    if (d >= 1000) return '${(d / 1000).toStringAsFixed(1)} km';
    return '$d m';
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('me'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    for (final p in _places) {
      markers.add(
        Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.lat, p.lon),
          infoWindow: InfoWindow(title: p.name),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // GMAPS
          Positioned.fill(
            child: _currentPosition == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 14,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: _buildMarkers(),
                  ),
          ),

          // TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _currentAddress ?? 'Menentukan lokasi...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.filter_list_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM SHEET
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: size.height * 0.45,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text(
                    'Tempat Makan di Sekitar Anda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<List<PlaceGeoapify>>(
                      future: _futurePlaces,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Terjadi error:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final places = snapshot.data ?? [];

                        if (places.isEmpty) {
                          return const Center(
                            child: Text('Tidak ada rumah makan terdekat.'),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: places.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final place = places[index];
                            final distance = _formatDistance(place);
                            final imagePath = _assetForPlace(place);

                            return _nearbyCard(
                              context: context,
                              place: place,
                              distance: distance,
                              imagePath: imagePath,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nearbyCard({
    required BuildContext context,
    required PlaceGeoapify place,
    required String distance,
    required String imagePath,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailPage(
                place: place,
                distance: distance,
                imagePath: imagePath,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (place.address != null)
                      Text(
                        place.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      distance.isNotEmpty ? distance : 'Jarak tidak diketahui',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
