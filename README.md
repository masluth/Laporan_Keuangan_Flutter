Revenant Finance Manager

Revenant Finance Manager adalah aplikasi yang dibuat untuk membantu pengguna dalam mencatat dan mengelola keuangan sehari-hari. Aplikasi ini memungkinkan pengguna untuk mencatat pemasukan dan pengeluaran, melihat riwayat transaksi, serta memantau kondisi keuangan melalui dashboard dan visualisasi data.

Project ini dikembangkan menggunakan Flutter dan Supabase sebagai backend untuk menyimpan serta mengelola data pengguna dan transaksi.

Fitur
Login dan autentikasi pengguna
Menambahkan transaksi pemasukan dan pengeluaran
Mengedit transaksi
Menghapus transaksi
Melihat riwayat transaksi
Memilih dan mengubah tanggal transaksi
Dashboard untuk melihat ringkasan keuangan
Grafik dan visualisasi data keuangan
Data transaksi terpisah berdasarkan akun pengguna
Export laporan keuangan
Mendukung penggunaan pada Android dan Web
Teknologi yang Digunakan
Flutter
Dart
Supabase
PostgreSQL
Riverpod
GoRouter
Requirements

Sebelum menjalankan project, pastikan perangkat sudah memiliki beberapa kebutuhan berikut:

Git
Flutter SDK
Dart SDK
Android Studio dan Android SDK jika ingin menjalankan aplikasi pada Android
Visual Studio Code atau IDE lainnya
Akun Supabase dan project Supabase yang sudah dibuat

Untuk memastikan Flutter sudah terpasang dengan benar, jalankan:

flutter doctor

Cara Instalasi:

1. Clone Repository

Clone repository menggunakan Git dengan perintah berikut:

git clone https://github.com/USERNAME/NAMA-REPOSITORY.git

Setelah proses clone selesai, masuk ke folder project:

cd NAMA-REPOSITORY

Ganti USERNAME/NAMA-REPOSITORY dengan alamat repository GitHub yang sebenarnya.

2. Install Dependency

Setelah masuk ke folder project, jalankan perintah berikut untuk mengunduh semua dependency yang digunakan:

flutter pub get

3. Konfigurasi Supabase

Project ini menggunakan Supabase sebagai backend untuk authentication dan penyimpanan data.

Sebelum menjalankan aplikasi, pastikan project Supabase sudah tersedia dan konfigurasi koneksi Supabase pada aplikasi sudah sesuai dengan project yang digunakan.

Pastikan juga database dan tabel yang dibutuhkan oleh aplikasi sudah tersedia di Supabase.

4. Menjalankan Aplikasi

Untuk melihat perangkat yang tersedia, jalankan:

flutter devices

Setelah perangkat tersedia, jalankan aplikasi menggunakan:

flutter run

Flutter kemudian akan menjalankan aplikasi pada perangkat yang dipilih.

Jika ingin menjalankan aplikasi pada perangkat Android, pastikan Android Emulator atau perangkat Android sudah terhubung dan terdeteksi oleh Flutter.

5. Menjalankan Aplikasi pada Web

Jika ingin menjalankan project pada browser, pastikan Chrome atau browser yang didukung sudah tersedia.

Kemudian jalankan:

flutter run -d chrome
Cara Menggunakan

Setelah aplikasi berhasil dijalankan, pengguna dapat menggunakan aplikasi melalui beberapa tahapan.

Pengguna melakukan login atau membuat akun terlebih dahulu.
Setelah berhasil login, pengguna akan masuk ke halaman dashboard.
Pengguna dapat menambahkan transaksi baru berupa pemasukan atau pengeluaran.
Pengguna dapat menentukan tanggal transaksi sesuai dengan transaksi yang sebenarnya.
Transaksi yang sudah dibuat akan ditampilkan pada halaman riwayat transaksi.
Pengguna dapat membuka transaksi untuk melihat detailnya.
Pengguna dapat mengubah atau menghapus transaksi yang sudah dibuat.
Dashboard menampilkan ringkasan kondisi keuangan berdasarkan transaksi yang dimiliki pengguna.
Pengguna dapat melihat grafik untuk membantu memahami pola pemasukan dan pengeluaran.
Pengguna dapat menggunakan fitur export untuk membuat laporan keuangan.
Alur Penggunaan

Login / Register
       -->
   Dashboard
       -->
Tambah Transaksi
       -->
Riwayat Transaksi
       -->
Detail Transaksi
       -->
Edit / Hapus Transaksi
       -->
Laporan Keuangan
       -->
   Export Laporan
Build Android


Jika ingin membuat file APK untuk Android, jalankan:

flutter build apk --release

Setelah proses build selesai, file APK dapat ditemukan pada:

build/app/outputs/flutter-apk/app-release.apk

File tersebut dapat digunakan untuk melakukan instalasi aplikasi pada perangkat Android.

Project Structure

Struktur utama project menggunakan pendekatan pemisahan antara fitur, data, dan komponen aplikasi agar project lebih mudah dikembangkan dan dipelihara.

lib/
├── core/
├── features/
├── main.dart
└── ...

Struktur folder dapat mengalami perubahan selama proses pengembangan project.

Tujuan Project

Project ini dibuat untuk mempermudah proses pencatatan dan pengelolaan keuangan secara digital. Selain digunakan sebagai aplikasi pengelolaan keuangan, project ini juga menjadi media pembelajaran dalam pengembangan aplikasi menggunakan Flutter, pengelolaan state, autentikasi pengguna, serta integrasi aplikasi dengan backend menggunakan Supabase.

Status Project

Project masih dalam tahap pengembangan. Beberapa fitur dan tampilan dapat mengalami perubahan seiring dengan proses pengembangan aplikasi.

Author

Luthfi Nur Alfian