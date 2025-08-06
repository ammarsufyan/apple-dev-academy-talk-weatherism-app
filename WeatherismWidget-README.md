# WeatherismWidget Implementation

## Overview
WeatherismWidget adalah widget iOS native yang menampilkan informasi cuaca terkini berdasarkan lokasi pengguna saat ini. Widget ini mendukung tiga ukuran (small, medium, large) dan diperbarui setiap 30 menit dengan data cuaca terbaru.

## Features
- **Location-based Weather**: Otomatis mendeteksi lokasi pengguna menggunakan Core Location
- **Real-time Data**: Mengambil data cuaca dari Open-Meteo API
- **Dynamic Backgrounds**: Background gradient berubah sesuai kondisi cuaca
- **Multiple Sizes**: Mendukung widget ukuran small (2x2), medium (4x2), dan large (4x4)
- **Auto-refresh**: Timeline diperbarui setiap 30 menit
- **Shared Data**: Menggunakan App Groups untuk berbagi data antara aplikasi dan widget
- **Offline Support**: Cache data cuaca untuk akses offline

## Technical Implementation

### Architecture
- **Provider**: Menggunakan `AppIntentTimelineProvider` untuk mengelola timeline dan mengambil data
- **LocationManager**: Menangani permission lokasi dan mengambil koordinat
- **WeatherService**: `WidgetWeatherService` mengambil data cuaca dari Open-Meteo API
- **Shared Storage**: `UserDefaults` dengan App Groups untuk berbagi data
- **Views**: View terpisah untuk setiap ukuran widget (small, medium, large)

### Key Components

#### WeatherWidgetModels.swift
- `WidgetWeatherData`: Model data cuaca untuk widget
- `WidgetWeatherCondition`: Enum untuk kondisi cuaca dengan ikon dan gradient

#### WidgetWeatherService.swift  
- Mengelola permintaan lokasi dan data cuaca
- Fallback ke lokasi dan data tersimpan jika gagal
- Timeout handling untuk permintaan lokasi

#### SharedUserDefaults.swift
- Extension untuk berbagi data menggunakan App Groups
- Cache data cuaca dan lokasi terakhir
- Manajemen freshness data

### Weather Data yang Ditampilkan
- **Temperature**: Suhu dalam Celsius
- **Weather Condition**: Kondisi cuaca dengan ikon SF Symbol
- **Humidity**: Persentase kelembaban udara  
- **Wind Speed**: Kecepatan angin dalam km/h
- **Location Name**: Nama lokasi (kota/daerah)
- **Last Updated**: Waktu pembaruan terakhir

### Kondisi Cuaca yang Didukung
- **Clear**: Cerah (weather code 0,1)
- **Partly Cloudy**: Berawan sebagian (weather code 2)
- **Cloudy**: Berawan (weather code 3)
- **Foggy**: Berkabut (weather code 45,48)
- **Drizzle**: Gerimis (weather code 51,53,55)
- **Rainy**: Hujan (weather code 61,63,65,80,81,82)
- **Snowy**: Bersalju (weather code 71,73,75,77,85,86)
- **Stormy**: Badai (weather code 95,96,99)

### Widget Sizes

#### Small Widget (2x2)
- Nama lokasi
- Ikon cuaca besar
- Suhu
- Kondisi cuaca

#### Medium Widget (4x2)  
- Semua info small widget
- Detail kelembaban dan kecepatan angin
- Layout horizontal yang lebih luas

#### Large Widget (4x4)
- Semua informasi cuaca lengkap
- Layout vertikal dengan spacing yang baik
- Waktu pembaruan terakhir
- Detail cuaca yang lebih besar

### Timeline Management
- Diperbarui setiap 30 menit
- Membuat entries untuk 4 jam ke depan (update setiap 30 menit)
- Menggunakan `.after()` policy untuk refresh otomatis
- Fallback handling untuk error lokasi atau network

### Permissions & Entitlements
- **App Groups**: `group.weatherism.shared` untuk berbagi data
- **Network Client**: Akses internet untuk API cuaca
- **Location**: Hanya aplikasi utama yang memerlukan permission lokasi

## Setup Instructions

### 1. Widget Configuration
Widget sudah dikonfigurasi dengan:
- App Groups: `group.weatherism.shared`
- Network access permission
- Timeline provider yang tepat

### 2. Usage Steps
1. Build dan run aplikasi utama
2. Berikan permission lokasi pada aplikasi
3. Tambahkan widget ke home screen:
   - Long press pada home screen
   - Tap tombol "+" di pojok kiri atas
   - Cari "Weatherism"
   - Pilih ukuran widget yang diinginkan
   - Tap "Add Widget"

### 3. Widget akan otomatis:
- Mengambil lokasi dari aplikasi utama
- Menampilkan data cuaca terkini
- Update setiap 30 menit
- Menggunakan cache jika offline

## Error Handling
- **No Location Permission**: Menggunakan data cache terakhir
- **Network Error**: Fallback ke data tersimpan
- **API Error**: Menampilkan data default dengan pesan error
- **Location Timeout**: Menggunakan lokasi tersimpan sebelumnya

## Data Flow
1. Widget meminta data cuaca
2. Service mencoba mendapatkan lokasi saat ini
3. Jika berhasil, ambil data cuaca dari API
4. Simpan data ke shared UserDefaults
5. Jika gagal, gunakan lokasi/data cache terakhir
6. Update widget dengan data yang didapat
3. Widget automatically displays current weather for your location
4. Updates every hour with fresh data

## Error Handling
- Location disabled: Shows "Location Disabled" message
- Network error: Shows "Location Error" message
- Graceful fallbacks ensure widget always displays something useful
