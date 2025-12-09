import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../place_geoapify.dart';

class RestaurantDetailPage extends StatelessWidget {
  final PlaceGeoapify place;
  final String imagePath; 
  final String distance;

  const RestaurantDetailPage({
    super.key,
    required this.place,
    required this.imagePath,
    required this.distance,
  });

  String _assetForPlace() {
    final cuisine = (place.cuisine ?? '').toLowerCase();
    final cats = place.categories.map((c) => c.toLowerCase()).toList();

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

  String _primaryCategory() {
    if (place.categories.isEmpty) return 'Catering';

    final raw = place.categories.first;
    final parts = raw.split('.');
    final last = parts.isNotEmpty ? parts.last : raw;
    final label = '${last[0].toUpperCase()}${last.substring(1)}';

    if (label.toLowerCase() == 'catering') return 'Catering';
    return label;
  }

  String _shortAddress() {
    final parts = <String>[];

    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.houseNumber != null &&
        place.houseNumber!.toString().isNotEmpty) {
      parts.add(place.houseNumber!.toString());
    }
    if (place.city != null && place.city!.isNotEmpty) {
      parts.add(place.city!);
    }

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    if (place.address != null && place.address!.isNotEmpty) {
      return place.address!;
    }

    return 'Alamat belum tersedia';
  }

  String? _cuisineText() {
    final raw = place.cuisine;
    if (raw == null || raw.isEmpty) return null;

    final parts = raw
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;

    return parts.join(', ');
  }

  String _openingHoursText() {
    final raw = place.openingHours;
    if (raw == null || raw.isEmpty) {
      return 'Jam buka: info belum tersedia';
    }
    return 'Jam buka: $raw';
  }

  String _paymentOptionsText() {
    final opts = place.paymentOptions;
    if (opts == null || opts.isEmpty) {
      return 'Kisaran harga/pembayaran: belum diatur';
    }

    final labels = <String>[];
    if (opts['cash'] == true) labels.add('tunai');
    if (opts['google_pay'] == true) labels.add('Google Pay');
    if (opts['electronic_purses'] == true) {
      labels.add('dompet elektronik');
    }

    if (labels.isEmpty) {
      return 'Kisaran harga/pembayaran: belum diatur';
    }

    return 'Menerima pembayaran: ${labels.join(', ')}';
  }

  String? _phoneText() {
    final phone = place.phone;
    if (phone == null || phone.isEmpty) return null;
    return phone;
  }

  String? _websiteText() {
    final url = place.website;
    if (url == null || url.isEmpty) return null;
    return url;
  }

  String _descriptionText() {
    final buffer = StringBuffer();

    // Nama + jenis / cuisine
    final cuisine = _cuisineText();
    if (cuisine != null) {
      buffer.write(
        '${place.name} adalah tempat makan yang menyajikan hidangan $cuisine.',
      );
    } else {
      buffer.write(
        '${place.name} adalah tempat makan di sekitar area Anda.',
      );
    }

    final addrParts = <String>[];
    if (place.street != null && place.street!.isNotEmpty) {
      addrParts.add(place.street!);
    }
    if (place.houseNumber != null &&
        place.houseNumber!.toString().isNotEmpty) {
      addrParts.add(place.houseNumber!.toString());
    }
    if (place.city != null && place.city!.isNotEmpty) {
      addrParts.add(place.city!);
    }
    if (addrParts.isNotEmpty) {
      buffer.write(' Berlokasi di ${addrParts.join(', ')}.');
    }

    if (place.openingHours != null && place.openingHours!.isNotEmpty) {
      buffer.write(' Jam operasional: ${place.openingHours}.');
    } else {
      buffer.write(
        ' Informasi jam buka belum tersedia dari penyedia data.',
      );
    }

    final payOpts = place.paymentOptions;
    if (payOpts != null && payOpts.isNotEmpty) {
      final payLabels = <String>[];
      if (payOpts['cash'] == true) payLabels.add('tunai');
      if (payOpts['google_pay'] == true) payLabels.add('Google Pay');
      if (payOpts['electronic_purses'] == true) {
        payLabels.add('dompet elektronik');
      }

      if (payLabels.isNotEmpty) {
        buffer.write(
          ' Metode pembayaran yang diterima antara lain ${payLabels.join(', ')}.',
        );
      }
    }

    if (place.phone != null && place.phone!.isNotEmpty) {
      buffer.write(
        ' Untuk informasi lebih lanjut atau pemesanan, Anda dapat menghubungi ${place.phone}.',
      );
    }

    if (place.website != null && place.website!.isNotEmpty) {
      buffer.write(
        ' Informasi lebih lengkap juga dapat dilihat di ${place.website}.',
      );
    }

    return buffer.toString();
  }

  Future<void> _openInMaps(BuildContext context) async {
    final shortAddress = _shortAddress();
    final queryText = '${place.name}, $shortAddress';

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${Uri.encodeComponent(queryText)}',
    );

    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka Google Maps'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat membuka Maps'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuisine = _cuisineText();
    final phone = _phoneText();
    final website = _websiteText();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          place.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE HEADER
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                _assetForPlace(), // 🔹 pakai mapping otomatis
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            //  CONTENT 
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // kategori + jarak
                  Row(
                    children: [
                      Text(
                        _primaryCategory(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '•',
                        style: TextStyle(color: Colors.black38),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        distance.isNotEmpty
                            ? '$distance dari lokasi Anda'
                            : 'Jarak tidak diketahui',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // cuisine
                  if (cuisine != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      cuisine,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Rating dummy
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star_half, color: Colors.amber, size: 20),
                      SizedBox(width: 6),
                      Text(
                        '4.3',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(124 reviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Alamat
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _shortAddress(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Jam buka
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _openingHoursText(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Pembayaran / kisaran harga
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _paymentOptionsText(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Telepon
                  if (phone != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Website
                  if (website != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.public,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            website,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 16),

                  // DESKRIPSI
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _descriptionText(),
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol aksi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openInMaps(context),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Lihat di Maps'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
