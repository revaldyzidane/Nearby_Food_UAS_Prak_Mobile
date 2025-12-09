import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'nearby.dart';
import 'restaurant_detail_page.dart';
import '../geoapify_places_service.dart';
import '../place_geoapify.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _geoService = GeoapifyPlacesService();

  String? _currentAddress;

  bool _isLoadingNearby = true;
  String? _nearbyError;
  List<PlaceGeoapify> _nearbyPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentAddressAndNearby();
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

    // Default
    return 'assets/images/sambel.jpg';
  }

  Future<void> _loadCurrentAddressAndNearby() async {
    try {
      // Cek service lokasi
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLoadingNearby = false;
          _nearbyError = 'Location service tidak aktif.';
        });
        return;
      }

      // Cek & minta izin
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _isLoadingNearby = false;
            _nearbyError = 'Izin lokasi ditolak.';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLoadingNearby = false;
          _nearbyError = 'Izin lokasi ditolak permanen.';
        });
        return;
      }

      // Posisi sekarang
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _loadNearbyRestaurants(pos);

      // alamat
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[];
          if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
          if (p.subLocality != null && p.subLocality!.isNotEmpty) {
            parts.add(p.subLocality!);
          }
          if (p.locality != null && p.locality!.isNotEmpty) {
            parts.add(p.locality!);
          }
          final addr = parts.join(', ');
          if (mounted) {
            setState(() {
              _currentAddress =
                  addr.isNotEmpty ? addr : "Lokasi tidak diketahui";
            });
          }
        }
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _currentAddress ??= "Lokasi tidak diketahui";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingNearby = false;
        _nearbyError = 'Gagal mendapatkan lokasi: $e';
      });
    }
  }

  Future<void> _loadNearbyRestaurants(Position pos) async {
    if (!mounted) return;
    setState(() {
      _isLoadingNearby = true;
      _nearbyError = null;
    });

    try {
      final all = await _geoService.getNearbyPlaces(
        lat: pos.latitude,
        lon: pos.longitude,
        categories: 'catering',
      );
      final limited =
          all.length <= 5 ? all : all.take(5).toList(growable: false);

      if (!mounted) return;
      setState(() {
        _nearbyPlaces = limited;
        _isLoadingNearby = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingNearby = false;
        _nearbyError = 'Gagal memuat tempat makan terdekat: $e';
      });
    }
  }

  String _formatDistance(PlaceGeoapify p) {
    final d = p.distanceMeters;
    if (d == null) return '';
    if (d >= 1000) {
      final km = d / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
    return '$d m';
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"icon": Icons.restaurant, "name": "Restaurant", "key": "restaurant"},
      {"icon": Icons.local_cafe, "name": "Cafe", "key": "cafe"},
      {"icon": Icons.fastfood, "name": "Fast Food", "key": "fast_food"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER 
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.asset(
                    "assets/images/GadoGado.jpeg",
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const Text(
                        "Revaldy Zidane",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Text(
                              _currentAddress ?? 'Menentukan lokasi...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // SEARCH BAR 
                Positioned(
                  bottom: 15,
                  left: 20,
                  right: 20,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(25),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Search for food/stores etc...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // KATEGORI 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Explore by Category",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: categories.map((c) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Nearby(
                                initialCategoryKey: c["key"] as String,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.redAccent.shade100,
                              child: Icon(
                                c["icon"] as IconData,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c["name"].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // TEMPAT MAKAN TERDEKAT 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tempat Makan Terdekat",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: _buildNearbyList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyList() {
    if (_isLoadingNearby) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_nearbyError != null) {
      return Center(
        child: Text(
          _nearbyError!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_nearbyPlaces.isEmpty) {
      return const Center(child: Text('Tidak ada tempat makan terdekat.'));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _nearbyPlaces.length,
      itemBuilder: (context, index) {
        final place = _nearbyPlaces[index];
        final distance = _formatDistance(place);
        final imagePath = _assetForPlace(place);

        return SizedBox(
          width: 140,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
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
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distance.isNotEmpty ? distance : "-",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
