# Aplikasi Pencarian Tempat Makan Terdekat

## Penjelasan Aplikasi

Aplikasi ini adalah **aplikasi mobile Flutter** untuk mencari **tempat makan terdekat** berdasarkan lokasi pengguna secara real-time. Data tempat makan diambil dari **Geoapify Places API** dan ditampilkan dalam beberapa tampilan utama:

* **Home**

  * Menampilkan sapaan pengguna dan **alamat lokasi saat ini** (hasil reverse geocoding).
  * Menampilkan menu kategori:

    * Restaurant
    * Fast Food
    * Cafe
  * Menampilkan **“Tempat Makan Terdekat”** (maks. 5 hasil) dalam bentuk list horizontal.
    Setiap kartu berisi:

    * Nama tempat
    * Jarak dari lokasi pengguna
    * Gambar ilustrasi yang dipilih otomatis berdasarkan `cuisine` / kategori (ayam, warung, fast food, cafe, dll).

* **Nearby**

  * Menampilkan **Google Maps** dengan:

    * Marker lokasi pengguna
    * Marker tempat makan di sekitar (hasil query Geoapify).
  * Di bagian bawah ada **bottom sheet** berisi list tempat makan lengkap:

    * Nama
    * Alamat singkat
    * Jarak
  * Kategori yang tampil mengikuti pilihan di Home (Restaurant / Fast Food / Cafe), atau semua tempat makan jika tidak ada filter.

* **Restaurant Detail Page**

  * Menampilkan detail 1 tempat makan:

    * Gambar ilustrasi (otomatis dari `cuisine` / kategori).
    * Nama tempat dan jenis kategori (Restaurant/Fast Food/Cafe).
    * Jarak dari lokasi pengguna.
    * Alamat singkat (`street + housenumber + city` atau `formatted`).
    * `catering.cuisine` → ditampilkan sebagai jenis masakan (mis. *chicken, asian*).
    * `opening_hours`.
    * `payment_options` (cash, Google Pay, dompet elektronik, dll) dalam bentuk kalimat.
    * `contact.phone` (jika ada).
    * `website` (jika ada).
  * Bagian **Deskripsi** disusun otomatis dari data-data di atas dengan template, sehingga setiap tempat punya deskripsi yang konsisten tapi tetap spesifik.
  * Tombol **“Lihat di Maps”** akan membuka Google Maps dengan query `nama + alamat`, bukan sekadar koordinat mentah.

Aplikasi juga sudah menangani beberapa kondisi error umum, seperti:

* Izin lokasi ditolak.
* Layanan lokasi dimatikan.
* Gagal memanggil API Geoapify (misalnya internet bermasalah).

---

## Daftar Endpoint API yang Digunakan

Aplikasi hanya menggunakan **satu endpoint utama** dari Geoapify, yaitu **Places API**, dengan variasi parameter kategori sesuai kebutuhan (semua tempat makan / restoran / fast food / cafe).

### Base URL

```text
https://api.geoapify.com/v2/places
```

### Pola Query Umum

```text
https://api.geoapify.com/v2/places
  ?categories={CATEGORIES}
  &filter=circle:{LON},{LAT},{RADIUS_IN_METERS}
  &bias=proximity:{LON},{LAT}
  &limit={LIMIT}
  &apiKey={GEOAPIFY_API_KEY}
```

* **categories**

  * `catering` → semua tempat makan (restaurant, fast food, cafe, dll).
  * `catering.restaurant` → hanya restoran.
  * `catering.fast_food` → fast food.
  * `catering.cafe` → cafe.
* **filter**
  `circle:{lon},{lat},{radius}` → mencari tempat dalam radius tertentu dari posisi pengguna (misal 10.000 meter).
* **bias=proximity**
  Memprioritaskan hasil yang paling dekat dengan koordinat pengguna.
* **limit**
  Jumlah maks. hasil (misal 50, atau dibatasi 5 di sisi aplikasi).
* **apiKey**
  API key dari Geoapify (disimpan di `app_config.dart`).

### Contoh Penggunaan di Aplikasi

* **Home – “Tempat Makan Terdekat” (semua jenis kuliner)**

  ```text
  categories=catering
  filter=circle:{lon_pengguna},{lat_pengguna},10000
  bias=proximity:{lon_pengguna},{lat_pengguna}
  limit=50 (diambil 5 terdekat di UI)
  ```

* **Nearby – mode Restaurant**

  ```text
  categories=catering.restaurant
  filter=circle:{lon_pengguna},{lat_pengguna},10000
  ```

* **Nearby – mode Fast Food**

  ```text
  categories=catering.fast_food
  ```

* **Nearby – mode Cafe**

  ```text
  categories=catering.cafe
  ```

> Selain Geoapify, aplikasi juga memakai:
>
> * `geolocator` dan `geocoding` → untuk lokasi pengguna + reverse geocoding.
> * `google_maps_flutter` → untuk tampilan peta.
> * `url_launcher` → untuk membuka Google Maps eksternal.

---

## Cara Instalasi & Menjalankan Proyek

Bagian ini untuk developer yang ingin menjalankan proyek di lokal.

### 1. Prasyarat

Pastikan sudah terpasang:

* **Flutter SDK**
* **Android Studio** / emulator / device fisik Android
* **VS Code** (opsional tapi disarankan)
* **Git** (kalau ingin clone dari GitHub)
* Akun **Geoapify** untuk mendapatkan `apiKey`
* (Jika diperlukan) **Google Maps API Key** untuk `google_maps_flutter` di Android/iOS

### 2. Clone / Download Proyek

Jika menggunakan Git:

```bash
git clone https://github.com/username/nearby_food.git
cd nearby_food
```

Atau download sebagai ZIP lalu ekstrak, kemudian buka foldernya di VS Code.

### 3. Install Dependency Flutter

Di root project (folder yang ada `pubspec.yaml`):

```bash
flutter pub get
```

### 4. Konfigurasi API Key Geoapify

Buat / edit file `lib/app_config.dart` (nama bisa sesuaikan dengan yang kamu pakai di proyek, tapi dari diskusi kita ini formatnya seperti ini):

```dart
const String geoapifyApiKey = "ISI_DENGAN_API_KEY_GEOAPIFY_ANDA";
```

Pastikan `GeoapifyPlacesService` menggunakan konstanta ini.

### 5. Konfigurasi Google Maps API Key

Jika belum, tambahkan Google Maps API key ke:

* `android/app/src/main/AndroidManifest.xml`
* dan jika build ke iOS: `ios/Runner/AppDelegate` / `Info.plist`

Contoh di Android (kurang lebih):

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="ISI_DENGAN_GOOGLE_MAPS_API_KEY_ANDA" />
```

### 6. Jalankan Aplikasi

Jalankan di emulator / device:

```bash
flutter run
```

Atau dari VS Code:

1. Pilih device (emulator / HP).
2. Tekan **Run** (F5).

Pastikan:

* Izin lokasi diizinkan saat prompt muncul.
* Device/emulator punya koneksi internet.
* API key Geoapify benar dan masih aktif.
