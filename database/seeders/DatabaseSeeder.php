<?php

namespace Database\Seeders;

use App\Models\InventoryControl;
use App\Models\Product;
use App\Models\Purchase;
use App\Models\Sale;
use App\Models\Supplier;
use App\Models\Testimonial;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ─── Users ─────────────────────────────────────────────────────────────
        User::create([
            'name'     => 'Budi Hartanto',
            'email'    => 'owner@budivariasi.com',
            'password' => Hash::make('admin123'),
            'role'     => 'owner',
        ]);
        User::create([
            'name'     => 'Sukamto',
            'email'    => 'admin@budivariasi.com',
            'password' => Hash::make('admin123'),
            'role'     => 'admin_gudang',
        ]);

        // ─── Services (untuk landing page) ─────────────────────────────────────
        \App\Models\Service::create([
            'title'       => 'Kaca Film Premium',
            'slug'        => Str::slug('Kaca Film Premium'),
            'description' => 'Pemasangan kaca film anti panas dan UV dengan berbagai tingkat kegelapan, garansi hingga 5 tahun.',
            'image'       => '/images/services/kaca_film.png',
            'price_range' => 'Mulai Rp 500.000',
        ]);
        \App\Models\Service::create([
            'title'       => 'Audio & Multimedia',
            'slug'        => Str::slug('Audio & Multimedia'),
            'description' => 'Upgrade sistem audio mobil Anda. Tersedia head unit android, speaker, subwoofer, dan peredam suara.',
            'image'       => '/images/services/audio.png',
            'price_range' => 'Mulai Rp 1.200.000',
        ]);
        \App\Models\Service::create([
            'title'       => 'Lampu LED & Projie',
            'slug'        => Str::slug('Lampu LED & Projie'),
            'description' => 'Tingkatkan visibilitas malam hari dengan lampu LED berkualitas tinggi dan proyektor custom.',
            'image'       => '/images/services/led.png',
            'price_range' => 'Mulai Rp 350.000',
        ]);

        // ─── Testimonials (Real Reviews from Google Maps - scraped 2026-06-25) ────
        $testimonials = [
            ['name' => 'WSukma',                  'rating' => 5, 'review_text' => 'Pelayanan ramah top bgt gratisannya banyak banget makasih pak sukses selalu 😍',             'source' => 'Google Maps'],
            ['name' => 'Bayu Aji',                'rating' => 5, 'review_text' => 'Pelayanan ramah. Jujur. Harga sesuai. Kerapian ok. Puas pokoknya.',                           'source' => 'Google Maps'],
            ['name' => 'Ilham Bintang',           'rating' => 4, 'review_text' => 'Pelayanan ramah, pemasangan rapi, harga net, garansi 2 bulan. Pilihan barang audio beragam.',  'source' => 'Google Maps'],
            ['name' => 'Arya Kusuma',             'rating' => 5, 'review_text' => 'Tempat variasi mobil berkualitas tinggi, kerjaan rapi, owner ramah, jujur harga terjangkau puas pelayanannya.', 'source' => 'Google Maps'],
            ['name' => 'KaKa 03',                 'rating' => 5, 'review_text' => 'Murah, harga benar-benar bersahabat. Pemilik selalu memberi saran yang terbaik. Gak salah kalau tempat mas Budi selalu ramai. Ada suguhan kopi juga.', 'source' => 'Google Maps'],
            ['name' => 'Julis Stianto',           'rating' => 5, 'review_text' => 'Mantap, barang berkualitas harga terjangkau.',                                                 'source' => 'Google Maps'],
            ['name' => 'Abdul Faqih',             'rating' => 5, 'review_text' => 'Memuaskan sangat rekomendasi.',                                                                 'source' => 'Google Maps'],
            ['name' => 'Muhammad Nino Sutrisno',  'rating' => 5, 'review_text' => 'Pemilik ramah pengerjaan cepat harga relatif terjangkau.',                                      'source' => 'Google Maps'],
            ['name' => 'Rahmat Rizal',            'rating' => 5, 'review_text' => 'Joss mantab murah berkualitas pelayanan ramah.',                                                'source' => 'Google Maps'],
            ['name' => 'GG TiVi',                 'rating' => 5, 'review_text' => 'Murah kualitas bagus, berani garansi, ownernya jujur.',                                        'source' => 'Google Maps'],
            ['name' => 'Satriyadi Putra',         'rating' => 5, 'review_text' => 'Pelayanan cepat dan ramah.',                                                                    'source' => 'Google Maps'],
            ['name' => 'Miftakhul Huda',          'rating' => 5, 'review_text' => 'Pelayanan jujur dan terjangkau.',                                                               'source' => 'Google Maps'],
            ['name' => 'Farras Kens',             'rating' => 5, 'review_text' => 'Direkomendasikan, ownernya asik dan komunikatif.',                                              'source' => 'Google Maps'],
            ['name' => 'Suhari Ngawi',            'rating' => 3, 'review_text' => 'Layanan sangat baik, pandai, dan memuaskan.',                                                   'source' => 'Google Maps'],
        ];
        foreach ($testimonials as $t) {
            Testimonial::create($t);
        }

        // ─── Load data from Excel JSON ─────────────────────────────────────────
        $jsonPath = database_path('seeders/excel_contents.json');
        if (!file_exists($jsonPath)) {
            throw new \Exception("File excel_contents.json tidak ditemukan di database/seeders");
        }
        $excelData = json_decode(file_get_contents($jsonPath), true);

        // ─── Suppliers ─────────────────────────────────────────────────────────
        $supplierSheet = $excelData['Supplier'] ?? [];
        $supplierDataStart = 4; // Row 5 (index 4) is the first data row
        for ($i = $supplierDataStart; $i < count($supplierSheet); $i++) {
            $row = $supplierSheet[$i];
            if (isset($row[0]) && $row[0] !== null) {
                Supplier::create([
                    'id_supplier'         => (int)$row[0],
                    'nama_supplier'       => $row[1],
                    'kontak_person'       => $row[2],
                    'alamat'              => $row[3],
                    'lead_time_rata_rata' => (int)($row[4] ?? 7),
                ]);
            }
        }

        // ─── Products ──────────────────────────────────────────────────────────
        $productSheet = $excelData['products'] ?? [];
        for ($i = 1; $i < count($productSheet); $i++) {
            $row = $productSheet[$i];
            if (isset($row[0]) && $row[0] !== null) {
                Product::create([
                    'id_barang'     => (int)$row[0],
                    'nama_barang'   => $row[1],
                    'kategori'      => $row[2],
                    'harga_beli'    => (float)$row[3],
                    'harga_jual'    => (float)$row[4],
                    'satuan'        => $row[5],
                    'stok_saat_ini' => (int)$row[7],
                    'id_supplier'   => $row[8] !== null ? (int)$row[8] : null,
                    'created_at'    => $row[9] ? \Illuminate\Support\Carbon::parse($row[9]) : now(),
                ]);
            }
        }

        // ─── Sales dari Excel ──────────────────────────────────────────────────
        $salesSheet = $excelData['sales'] ?? [];
        for ($i = 1; $i < count($salesSheet); $i++) {
            $row = $salesSheet[$i];
            if (isset($row[0]) && $row[0] !== null) {
                Sale::create([
                    'id_penjualan'   => (int)$row[0],
                    'id_barang'      => (int)$row[1],
                    'tanggal_keluar' => \Illuminate\Support\Carbon::parse($row[2])->toDateString(),
                    'jumlah_terjual' => (int)$row[3],
                    'total_harga'    => (float)$row[4],
                    'created_at'     => $row[5] ? \Illuminate\Support\Carbon::parse($row[5]) : now(),
                ]);
            }
        }

        // ─── Sales tambahan untuk produk yang data-nya kurang dari 2 bulan ─────
        // (Kecuali ID 26 "Kaca Film 3M Black Beauty" yang memang data tidak cukup)
        //
        // ID 2: Tempat Plat Nomor Akrilik (harga jual 150000) - hanya 1 bulan (Mei)
        // ID 10: Talang Air Mobil (harga jual 250000) - 0 bulan
        // ID 14: Lampu Plafon LED (harga jual 40000) - 0 bulan
        // ID 20: Sensor Parkir (harga jual 250000) - 1 bulan (Apr)
        // ID 22: Cover Jok Mobil (harga jual 500000) - 0 bulan

        $extraSales = [
            // Tempat Plat Nomor Akrilik (ID 2) - tambah penjualan Feb dan Mar
            ['id_barang' => 2, 'tanggal_keluar' => '2026-02-15', 'jumlah_terjual' => 2, 'total_harga' => 300000, 'created_at' => '2026-02-15 10:30:00'],
            ['id_barang' => 2, 'tanggal_keluar' => '2026-03-20', 'jumlah_terjual' => 3, 'total_harga' => 450000, 'created_at' => '2026-03-20 14:15:00'],

            // Talang Air Mobil (ID 10) - tambah penjualan Jan, Feb, Mar
            ['id_barang' => 10, 'tanggal_keluar' => '2026-01-18', 'jumlah_terjual' => 1, 'total_harga' => 250000, 'created_at' => '2026-01-18 09:45:00'],
            ['id_barang' => 10, 'tanggal_keluar' => '2026-02-22', 'jumlah_terjual' => 2, 'total_harga' => 500000, 'created_at' => '2026-02-22 11:20:00'],
            ['id_barang' => 10, 'tanggal_keluar' => '2026-03-15', 'jumlah_terjual' => 1, 'total_harga' => 250000, 'created_at' => '2026-03-15 15:30:00'],

            // Lampu Plafon LED (ID 14) - tambah penjualan Jan, Mar, Apr
            ['id_barang' => 14, 'tanggal_keluar' => '2026-01-11', 'jumlah_terjual' => 2, 'total_harga' => 80000, 'created_at' => '2026-01-11 08:50:00'],
            ['id_barang' => 14, 'tanggal_keluar' => '2026-03-08', 'jumlah_terjual' => 3, 'total_harga' => 120000, 'created_at' => '2026-03-08 13:40:00'],
            ['id_barang' => 14, 'tanggal_keluar' => '2026-04-19', 'jumlah_terjual' => 2, 'total_harga' => 80000, 'created_at' => '2026-04-19 10:15:00'],

            // Sensor Parkir (ID 20) - tambah penjualan Feb dan Mar
            ['id_barang' => 20, 'tanggal_keluar' => '2026-02-08', 'jumlah_terjual' => 1, 'total_harga' => 250000, 'created_at' => '2026-02-08 09:30:00'],
            ['id_barang' => 20, 'tanggal_keluar' => '2026-03-22', 'jumlah_terjual' => 2, 'total_harga' => 500000, 'created_at' => '2026-03-22 14:50:00'],

            // Cover Jok Mobil (ID 22) - tambah penjualan Jan, Mar, Apr
            ['id_barang' => 22, 'tanggal_keluar' => '2026-01-25', 'jumlah_terjual' => 1, 'total_harga' => 500000, 'created_at' => '2026-01-25 11:00:00'],
            ['id_barang' => 22, 'tanggal_keluar' => '2026-03-12', 'jumlah_terjual' => 2, 'total_harga' => 1000000, 'created_at' => '2026-03-12 09:20:00'],
            ['id_barang' => 22, 'tanggal_keluar' => '2026-04-28', 'jumlah_terjual' => 1, 'total_harga' => 500000, 'created_at' => '2026-04-28 16:10:00'],
        ];

        foreach ($extraSales as $sale) {
            Sale::create($sale);
        }

        // ─── Purchases ─────────────────────────────────────────────────────────
        $purchasesSheet = $excelData['purchases'] ?? [];
        for ($i = 1; $i < count($purchasesSheet); $i++) {
            $row = $purchasesSheet[$i];
            if (isset($row[0]) && $row[0] !== null) {
                Purchase::create([
                    'id_pembelian'  => (int)$row[0],
                    'id_barang'     => (int)$row[1],
                    'id_supplier'   => $row[2] !== null ? (int)$row[2] : null,
                    'tanggal_masuk' => \Illuminate\Support\Carbon::parse($row[3])->toDateString(),
                    'jumlah_masuk'  => (int)$row[4],
                    'created_at'    => $row[5] ? \Illuminate\Support\Carbon::parse($row[5]) : now(),
                ]);
            }
        }

        // ─── Inventory Controls ────────────────────────────────────────────────
        $icSheet = $excelData['inventory_controls'] ?? [];
        for ($i = 1; $i < count($icSheet); $i++) {
            $row = $icSheet[$i];
            if (isset($row[0]) && $row[0] !== null) {
                InventoryControl::create([
                    'id_control'           => (int)$row[0],
                    'id_barang'            => (int)$row[1],
                    'hasil_regresi_linear' => (float)$row[2],
                    'safety_stock'         => (int)$row[3],
                    'reorder_point'        => (int)$row[4],
                    'status_stok'          => $row[5],
                    'diperbarui_pada'      => $row[6] ? \Illuminate\Support\Carbon::parse($row[6]) : now(),
                ]);
            }
        }
    }
}
