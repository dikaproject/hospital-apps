# HospitalLink

Smart Healthcare Queue System

## Overview
HospitalLink adalah aplikasi Flutter untuk sistem antrean rumah sakit yang modern, efisien, dan terintegrasi. Aplikasi ini memudahkan pasien dalam mengambil antrean, memantau status antrean, konsultasi dengan dokter (AI & langsung), melihat hasil lab, notifikasi, dan fitur kesehatan lainnya.

## Fitur Utama
- **Ambil Antrean**: Daftar antrean rumah sakit secara online.
- **Status Antrean**: Lihat posisi, estimasi tunggu, dan detail antrean.
- **Konsultasi AI**: Screening kesehatan dengan AI.
- **Chat Dokter**: Konsultasi langsung dengan dokter.
- **Jadwal Konsultasi**: Lihat dan kelola jadwal konsultasi.
- **Riwayat Kunjungan**: Riwayat kunjungan dan rekam medis.
- **Hasil Lab & Resep**: Akses hasil laboratorium dan resep digital.
- **Notifikasi**: Dapatkan notifikasi penting dari rumah sakit.
- **Manajemen Profil**: Edit profil, pengaturan, dan keamanan akun.

## Struktur Proyek

```
lib/
  main.dart                # Entry point aplikasi
  models/                  # Model data (antrean, konsultasi, user, dll)
  screens/                 # Semua tampilan (UI) aplikasi
	 main/                  # Dashboard utama
	 auth/                  # Login, register, dll
	 queue/                 # Antrean
	 consultation/          # Konsultasi AI & dokter
	 lab/                   # Hasil lab
	 notifications/         # Notifikasi
	 ...
  services/                # Layer komunikasi API & logic bisnis
  widgets/                 # Widget custom reusable
android/, ios/, web/, linux/, macos/, windows/  # Platform support
```

## Instalasi & Menjalankan
1. **Clone repository**
	```bash
	git clone https://github.com/dikaproject/hospital-apps.git
	cd hospital-apps
	```
2. **Install dependencies**
	```bash
	flutter pub get
	```
3. **Jalankan aplikasi**
	```bash
	flutter run
	```

## Konfigurasi Penting
- Pastikan sudah mengatur backend API endpoint di `lib/services/http_service.dart` jika perlu.
- Untuk notifikasi, aplikasi menggunakan `flutter_local_notifications` dan `awesome_notifications`.
- Fitur QR code menggunakan `qr_flutter` dan `mobile_scanner`.

## Dependensi Utama
- Flutter SDK >=3.3.4 <4.0.0
- local_auth, qr_flutter, http, permission_handler, mobile_scanner, image_picker, shared_preferences, flutter_local_notifications, awesome_notifications, intl, timezone, webview_flutter

## Kontribusi
Pull request dan issue sangat terbuka untuk pengembangan lebih lanjut.

## Lisensi
MIT
