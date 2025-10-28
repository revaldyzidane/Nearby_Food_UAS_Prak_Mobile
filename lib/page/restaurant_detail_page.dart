import 'package:flutter/material.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String name;
  final String imagePath;
  final String distance;

  const RestaurantDetailPage({
    super.key,
    required this.name,
    required this.imagePath,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: PageView(
                children: [
                  Image.asset(imagePath, fit: BoxFit.cover),
                  Image.asset("assets/images/contoh1.jpeg", fit: BoxFit.cover),
                  Image.asset("assets/images/contoh2.jpeg", fit: BoxFit.cover),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text(
                        "Jl. Dummy No. 123, Surabaya",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("$distance dari lokasi Anda"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.attach_money, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Rp25.000 - Rp75.000 / orang"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.restaurant_menu, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Jenis: Kafe & Makanan Ringan"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.facebook, color: Colors.blue),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt_outlined, color: Colors.purple),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.link, color: Colors.green),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Deskripsi:",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Cafe Kopi Kita adalah tempat nongkrong nyaman dengan suasana estetik dan menu kopi pilihan. "
                    "Dilengkapi dengan WiFi cepat dan area outdoor yang sejuk. Cocok untuk santai maupun kerja.",
                    style: TextStyle(color: Colors.black87),
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
