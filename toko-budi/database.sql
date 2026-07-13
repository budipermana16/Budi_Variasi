-- ============================================================
-- SKRIP DATABASE: Sistem Inventory Control Budi Variasi Mobil
-- Skripsi: Regresi Linear untuk Penentuan Reorder Point
-- Laragon | MySQL | PhpMyAdmin / HeidiSQL
-- ============================================================

DROP DATABASE IF EXISTS `toko_budi`;
CREATE DATABASE `toko_budi`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `toko_budi`;

-- ============================================================
-- TABEL 1: users
-- ============================================================
CREATE TABLE `users` (
  `id_user`    INT          NOT NULL AUTO_INCREMENT,
  `username`   VARCHAR(50)  NOT NULL UNIQUE,
  `password`   VARCHAR(255) NOT NULL COMMENT 'Hashed dengan password_hash()',
  `role`       ENUM('Owner','Admin Gudang') NOT NULL DEFAULT 'Admin Gudang',
  `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 2: suppliers
-- ============================================================
CREATE TABLE `suppliers` (
  `id_supplier`        INT          NOT NULL AUTO_INCREMENT,
  `nama_supplier`      VARCHAR(100) NOT NULL,
  `alamat`             TEXT,
  `kontak_person`      VARCHAR(100),
  `lead_time_rata_rata` INT         NOT NULL DEFAULT 7 COMMENT 'Nilai L dalam hari untuk rumus ROP',
  `created_at`         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_supplier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 3: products
-- ============================================================
CREATE TABLE `products` (
  `id_barang`     INT             NOT NULL AUTO_INCREMENT,
  `nama_barang`   VARCHAR(150)    NOT NULL,
  `kategori`      VARCHAR(80)     NOT NULL,
  `harga_beli`    DECIMAL(15,2)   NOT NULL DEFAULT 0,
  `harga_jual`    DECIMAL(15,2)   NOT NULL DEFAULT 0,
  `stok_saat_ini` INT             NOT NULL DEFAULT 0,
  `satuan`        VARCHAR(30)     NOT NULL DEFAULT 'pcs',
  `id_supplier`   INT,
  `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_barang`),
  CONSTRAINT `fk_product_supplier` FOREIGN KEY (`id_supplier`)
    REFERENCES `suppliers`(`id_supplier`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 4: sales (Dataset utama Regresi Linear)
-- ============================================================
CREATE TABLE `sales` (
  `id_penjualan`  INT           NOT NULL AUTO_INCREMENT,
  `id_barang`     INT           NOT NULL,
  `tanggal_keluar` DATE         NOT NULL,
  `jumlah_terjual` INT          NOT NULL,
  `total_harga`   DECIMAL(15,2) NOT NULL DEFAULT 0,
  `created_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_penjualan`),
  CONSTRAINT `fk_sales_product` FOREIGN KEY (`id_barang`)
    REFERENCES `products`(`id_barang`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 5: purchases (Barang Masuk)
-- ============================================================
CREATE TABLE `purchases` (
  `id_pembelian`  INT           NOT NULL AUTO_INCREMENT,
  `id_barang`     INT           NOT NULL,
  `id_supplier`   INT,
  `tanggal_masuk` DATE          NOT NULL,
  `jumlah_masuk`  INT           NOT NULL,
  `created_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pembelian`),
  CONSTRAINT `fk_purchases_product` FOREIGN KEY (`id_barang`)
    REFERENCES `products`(`id_barang`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_purchases_supplier` FOREIGN KEY (`id_supplier`)
    REFERENCES `suppliers`(`id_supplier`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 6: inventory_controls (Hasil Algoritma)
-- ============================================================
CREATE TABLE `inventory_controls` (
  `id_control`           INT     NOT NULL AUTO_INCREMENT,
  `id_barang`            INT     NOT NULL UNIQUE,
  `hasil_regresi_linear` FLOAT   NOT NULL DEFAULT 0 COMMENT 'Prediksi penjualan (Y) periode berikutnya dalam unit/bulan',
  `safety_stock`         INT     NOT NULL DEFAULT 0 COMMENT 'Nilai SS - diinput manual',
  `reorder_point`        INT     NOT NULL DEFAULT 0 COMMENT 'Nilai ROP = (d * L) + SS',
  `status_stok`          ENUM('Aman','Waspada','Segera Pesan') NOT NULL DEFAULT 'Aman',
  `diperbarui_pada`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_control`),
  CONSTRAINT `fk_ic_product` FOREIGN KEY (`id_barang`)
    REFERENCES `products`(`id_barang`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- DATA AWAL: users
-- password: 'admin123'
-- ============================================================
INSERT INTO `users` (`username`, `password`, `role`) VALUES
('owner',        '$2y$12$GWI0RXfh7C1b7FxUgz5fUu6Xv/Qn.kBbT1e/vQ4Z3P3j4mO2A5Oa', 'Owner'),
('admin_gudang',  '$2y$12$GWI0RXfh7C1b7FxUgz5fUu6Xv/Qn.kBbT1e/vQ4Z3P3j4mO2A5Oa', 'Admin Gudang');


-- ============================================================
-- DATA AWAL: suppliers (Dari Excel)
-- ============================================================
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (1, 'Prayogo Variasi & Aksesoris Mobil', 'Jl. Panglima Sudirman, Mojorejo, Kec. Wonoasri, Madiun, Jawa Timur', 'Prayogo Santoso', 2, '2026-01-01 08:02:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (2, 'Victory Variasi Madiun', 'Jl. Diponegoro No.10, Oro-oro Ombo, Kec. Kartoharjo, Madiun, Jawa Timur', 'Victor Hendra', 2, '2026-01-01 08:03:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (3, 'Bintang Variasi Madiun', 'Jl. Sri Langka No.7, Kanigoro, Kec. Kartoharjo, Madiun, Jawa Timur', 'Bintang Prasetyo', 3, '2026-01-01 08:04:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (4, 'Surya Abadi Motor Madiun', 'Jl. Serayu Timur No.156, Pandean, Kec. Taman, Madiun, Jawa Timur', 'Surya Wibowo', 3, '2026-01-01 08:05:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (5, 'PT. Jaya Utama Santikah', 'Jl. Raya Ngagel No.209, Kec. Gubeng, Surabaya, Jawa Timur', 'Santikah Wulandari', 5, '2026-01-01 08:06:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (6, 'HN Variasi Surabaya', 'Jl. Kedung Doro No.39, Kedungdoro, Kec. Tegalsari, Surabaya, Jawa Timur', 'Hendra Nugroho', 5, '2026-01-01 08:07:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (7, 'Master Motor Surabaya', 'Jl. Tenggilis Lama IV B No.34, Tenggilis Mejoyo, Surabaya, Jawa Timur', 'Aris Mastono', 5, '2026-01-01 08:08:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (8, 'Chandra Variasi Audio & AC Mobil', 'Jl. Slamet Riyadi No.513, Kec. Laweyan, Pajang, Solo, Jawa Tengah', 'Chandra Budiman', 4, '2026-01-01 08:09:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (9, 'Kikim Variasi Mobil Yogyakarta', 'Jl. Kaliurang KM.8, Kec. Ngaglik, Kab. Sleman, Yogyakarta', 'Kikim Prasetya', 4, '2026-01-01 08:10:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (10, 'Auto Frontier Karpet Mobil', 'Jl. Raya Cicalengka Timur No.564, Margaasih, Cicalengka, Kab. Bandung', 'Frontier Utama', 6, '2026-01-01 08:11:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (11, 'PT. Motorzoom Indonesia', 'Ruko Sunter ICON Blok D No.18, Sunter Griya Sejahtera, Jakarta Utara', 'Rizky Motorzoom', 7, '2026-01-01 08:12:00');
INSERT INTO `suppliers` (`id_supplier`, `nama_supplier`, `alamat`, `kontak_person`, `lead_time_rata_rata`, `created_at`) VALUES (12, 'PT. Tri Duta Perkasa', 'Jl. Industri Selatan V Blok GG No.8, Kawasan Industri Jababeka, Cikarang, Bekasi', 'Tri Duta Alam', 7, '2026-01-01 08:13:00');

-- ============================================================
-- DATA AWAL: products (Dari Excel)
-- ============================================================
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (1, 'Kaca Film 3M Black Beauty', 'Kaca Film', 450000, 720000, 11, 'lembar', 1, '2026-01-01 09:02:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (2, 'Kaca Film V-Kool VK40', 'Kaca Film', 600000, 960000, 6, 'lembar', 1, '2026-01-01 09:03:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (3, 'Kaca Film Huper Optik Ceramic', 'Kaca Film', 380000, 620000, 7, 'lembar', 2, '2026-01-01 09:04:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (4, 'Karpet Dasar Avanza/Xenia Frontier', 'Karpet', 280000, 450000, 1, 'set', 10, '2026-01-01 09:05:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (5, 'Karpet Dasar Honda Brio Frontier', 'Karpet', 260000, 420000, 16, 'set', 10, '2026-01-01 09:06:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (6, 'Karpet Dasar Innova Reborn Frontier', 'Karpet', 320000, 510000, 5, 'set', 10, '2026-01-01 09:07:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (7, 'Karpet Dasar Xpander Frontier', 'Karpet', 300000, 480000, 4, 'set', 10, '2026-01-01 09:08:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (8, 'Karpet Lumpur / Mud Guard Universal', 'Karpet', 55000, 95000, 4, 'set', 2, '2026-01-01 09:09:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (9, 'Cover Jok Mobil Universal Hitam', 'Aksesoris Interior', 200000, 350000, 4, 'set', 1, '2026-01-01 09:10:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (10, 'Sarung Stir Carinn Import Diameter 38', 'Aksesoris Interior', 55000, 95000, 6, 'pcs', 2, '2026-01-01 09:11:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (11, 'Bantal Mobil Sandaran Kepala Berpasang', 'Aksesoris Interior', 80000, 140000, 4, 'pasang', 3, '2026-01-01 09:12:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (12, 'Dashboard Cover Anti Panas Universal', 'Aksesoris Interior', 95000, 160000, 1, 'pcs', 3, '2026-01-01 09:13:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (13, 'Sill Plate Stainless Universal 4 Pintu', 'Aksesoris Interior', 130000, 220000, 19, 'set', 6, '2026-01-01 09:14:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (14, 'Parfum Mobil Vent Clip Karton', 'Parfum', 25000, 48000, 1, 'pcs', 2, '2026-01-01 09:15:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (15, 'Parfum Mobil Gantung California Scents', 'Parfum', 18000, 35000, 16, 'pcs', 2, '2026-01-01 09:16:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (16, 'Parfum Mobil Botol Kaca Premium', 'Parfum', 65000, 115000, 5, 'pcs', 3, '2026-01-01 09:17:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (17, 'Parfum Mobil Gel Karakter Lucu', 'Parfum', 30000, 55000, 2, 'pcs', 3, '2026-01-01 09:18:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (18, 'Wiper Blade Bosch Aerotwin 18 Inch', 'Wiper', 70000, 120000, 15, 'pcs', 5, '2026-01-01 09:19:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (19, 'Wiper Blade Valeo Silencio 16 Inch', 'Wiper', 60000, 105000, 17, 'pcs', 5, '2026-01-01 09:20:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (20, 'Wiper Blade KW Flat Universal 20 Inch', 'Wiper', 35000, 65000, 4, 'pcs', 4, '2026-01-01 09:21:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (21, 'Talang Air Avanza/Xenia Niken', 'Eksterior', 120000, 200000, 13, 'set', 5, '2026-01-01 09:22:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (22, 'Talang Air Honda Brio/Jazz Niken', 'Eksterior', 115000, 190000, 6, 'set', 5, '2026-01-01 09:23:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (23, 'Talang Air Innova Reborn Niken', 'Eksterior', 135000, 220000, 6, 'set', 5, '2026-01-01 09:24:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (24, 'Cover Spion Chrome Avanza/Xenia', 'Eksterior', 65000, 110000, 7, 'pasang', 3, '2026-01-01 09:25:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (25, 'Door Visor/Talang Angin Avanza 4 Pintu', 'Eksterior', 110000, 185000, 1, 'set', 4, '2026-01-01 09:26:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (26, 'Lampu LED H4 DNY Putih 6000K', 'Lampu', 130000, 220000, 6, 'pasang', 11, '2026-01-01 09:27:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (27, 'Lampu LED H11 Foglamp Kuning 55W', 'Lampu', 110000, 185000, 2, 'pasang', 11, '2026-01-01 09:28:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (28, 'Lampu DRL LED Strip 30cm Putih', 'Lampu', 65000, 120000, 3, 'pasang', 11, '2026-01-01 09:29:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (29, 'Lampu Angel Eyes Ring 3 Inch Universal', 'Lampu', 85000, 150000, 6, 'pasang', 11, '2026-01-01 09:30:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (30, 'Lampu Sein LED Blink Sequential', 'Lampu', 90000, 155000, 10, 'pasang', 12, '2026-01-01 09:31:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (31, 'Bohlam T10 LED Senja 5 Titik Putih', 'Lampu', 15000, 28000, 6, 'pasang', 11, '2026-01-01 09:32:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (32, 'Kamera Mundur Parkir Universal CMOS', 'Elektronik', 180000, 300000, 3, 'unit', 8, '2026-01-01 09:33:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (33, 'GPS Tracker TK103B GSM/GPRS', 'Elektronik', 250000, 420000, 4, 'unit', 8, '2026-01-01 09:34:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (34, 'Central Lock Universal 4 Pintu', 'Elektronik', 130000, 230000, 11, 'unit', 7, '2026-01-01 09:35:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (35, 'Alarm Mobil Remote Paging Model 525', 'Elektronik', 200000, 370000, 4, 'unit', 7, '2026-01-01 09:36:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (36, 'Power Window Universal per Pintu', 'Elektronik', 155000, 270000, 5, 'unit', 7, '2026-01-01 09:37:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (37, 'Sensor Parkir 4 Titik Buzzer', 'Elektronik', 175000, 300000, 3, 'unit', 8, '2026-01-01 09:38:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (38, 'Dashcam Kamera Depan Full HD 1080P', 'Elektronik', 280000, 480000, 7, 'unit', 8, '2026-01-01 09:39:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (39, 'Speaker Coaxial Pioneer TS-G1320F 5in', 'Audio', 220000, 380000, 19, 'pasang', 6, '2026-01-01 09:40:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (40, 'Head Unit Single DIN USB/Bluetooth', 'Audio', 350000, 590000, 3, 'unit', 6, '2026-01-01 09:41:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (41, 'Subwoofer 10 Inch Aktif 400W', 'Audio', 480000, 800000, 3, 'unit', 6, '2026-01-01 09:42:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (42, 'Tweeter Silk Dome 1 Inch Sepasang', 'Audio', 120000, 210000, 14, 'pasang', 6, '2026-01-01 09:43:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (43, 'Anti Karat Underseal Kaleng 400ml', 'Perawatan', 90000, 150000, 3, 'kaleng', 9, '2026-01-01 09:44:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (44, 'Semir Ban Cair Armor All 500ml', 'Perawatan', 55000, 95000, 11, 'botol', 9, '2026-01-01 09:45:00');
INSERT INTO `products` (`id_barang`, `nama_barang`, `kategori`, `harga_beli`, `harga_jual`, `stok_saat_ini`, `satuan`, `id_supplier`, `created_at`) VALUES (45, 'Emblem Krom Logo Universal Huruf', 'Eksterior', 35000, 65000, 17, 'set', 3, '2026-01-01 09:46:00');

-- ============================================================
-- DATA AWAL: sales (Dari Excel)
-- ============================================================
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (1, 10, '2026-01-01', 4, 380000, '2026-01-01 09:59:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (2, 43, '2026-01-02', 4, 600000, '2026-01-02 15:14:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (3, 10, '2026-01-04', 2, 190000, '2026-01-04 10:26:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (4, 32, '2026-01-05', 3, 900000, '2026-01-05 14:33:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (5, 12, '2026-01-05', 2, 320000, '2026-01-05 15:38:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (6, 43, '2026-01-05', 3, 450000, '2026-01-05 15:51:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (7, 19, '2026-01-07', 2, 210000, '2026-01-07 13:52:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (8, 42, '2026-01-07', 1, 210000, '2026-01-07 11:28:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (9, 38, '2026-01-08', 1, 480000, '2026-01-08 13:11:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (10, 24, '2026-01-09', 2, 220000, '2026-01-09 13:44:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (11, 38, '2026-01-10', 2, 960000, '2026-01-10 12:06:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (12, 36, '2026-01-11', 4, 1080000, '2026-01-11 14:26:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (13, 45, '2026-01-12', 1, 65000, '2026-01-12 15:33:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (14, 39, '2026-01-13', 2, 760000, '2026-01-13 10:29:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (15, 4, '2026-01-13', 1, 450000, '2026-01-13 14:13:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (16, 28, '2026-01-14', 2, 240000, '2026-01-14 12:39:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (17, 32, '2026-01-15', 1, 300000, '2026-01-15 15:26:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (18, 43, '2026-01-16', 2, 300000, '2026-01-16 17:49:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (19, 6, '2026-01-22', 3, 1530000, '2026-01-22 08:37:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (20, 31, '2026-01-22', 1, 28000, '2026-01-22 17:31:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (21, 11, '2026-01-22', 3, 420000, '2026-01-22 09:45:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (22, 10, '2026-01-24', 4, 380000, '2026-01-24 09:06:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (23, 31, '2026-01-26', 2, 56000, '2026-01-26 14:18:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (24, 17, '2026-01-27', 1, 55000, '2026-01-27 10:56:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (25, 5, '2026-01-27', 2, 840000, '2026-01-27 14:25:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (26, 30, '2026-01-28', 3, 465000, '2026-01-28 11:48:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (27, 11, '2026-01-29', 4, 560000, '2026-01-29 08:22:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (28, 45, '2026-01-30', 2, 130000, '2026-01-30 08:07:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (29, 43, '2026-01-31', 1, 150000, '2026-01-31 16:18:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (30, 45, '2026-02-01', 3, 195000, '2026-02-01 09:37:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (31, 45, '2026-02-02', 4, 260000, '2026-02-02 12:23:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (32, 18, '2026-02-02', 1, 120000, '2026-02-02 13:32:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (33, 16, '2026-02-04', 4, 460000, '2026-02-04 09:21:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (34, 45, '2026-02-04', 4, 260000, '2026-02-04 14:50:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (35, 14, '2026-02-06', 3, 144000, '2026-02-06 10:56:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (36, 8, '2026-02-07', 2, 190000, '2026-02-07 12:17:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (37, 24, '2026-02-08', 3, 330000, '2026-02-08 10:53:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (38, 19, '2026-02-10', 2, 210000, '2026-02-10 12:24:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (39, 19, '2026-02-11', 2, 210000, '2026-02-11 10:37:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (40, 41, '2026-02-11', 3, 2400000, '2026-02-11 08:42:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (41, 31, '2026-02-12', 2, 56000, '2026-02-12 10:50:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (42, 25, '2026-02-15', 4, 740000, '2026-02-15 10:52:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (43, 5, '2026-02-15', 4, 1680000, '2026-02-15 11:51:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (44, 25, '2026-02-16', 4, 740000, '2026-02-16 10:04:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (45, 24, '2026-02-17', 1, 110000, '2026-02-17 16:19:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (46, 14, '2026-02-18', 4, 192000, '2026-02-18 16:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (47, 27, '2026-02-18', 3, 555000, '2026-02-18 11:48:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (48, 31, '2026-02-21', 3, 84000, '2026-02-21 08:37:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (49, 14, '2026-02-21', 4, 192000, '2026-02-21 11:26:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (50, 29, '2026-02-22', 4, 600000, '2026-02-22 11:24:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (51, 45, '2026-02-22', 2, 130000, '2026-02-22 16:50:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (52, 17, '2026-02-22', 2, 110000, '2026-02-22 16:11:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (53, 11, '2026-02-23', 3, 420000, '2026-02-23 11:17:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (54, 20, '2026-02-26', 2, 130000, '2026-02-26 12:47:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (55, 21, '2026-02-26', 2, 400000, '2026-02-26 12:27:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (56, 31, '2026-02-28', 4, 112000, '2026-02-28 16:33:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (57, 39, '2026-02-28', 4, 1520000, '2026-02-28 08:07:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (58, 32, '2026-03-02', 4, 1200000, '2026-03-02 10:22:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (59, 42, '2026-03-02', 4, 840000, '2026-03-02 11:19:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (60, 36, '2026-03-05', 2, 540000, '2026-03-05 16:05:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (61, 14, '2026-03-06', 4, 192000, '2026-03-06 11:45:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (62, 31, '2026-03-06', 2, 56000, '2026-03-06 15:41:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (63, 26, '2026-03-06', 3, 660000, '2026-03-06 14:08:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (64, 24, '2026-03-08', 1, 110000, '2026-03-08 12:47:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (65, 10, '2026-03-09', 1, 95000, '2026-03-09 14:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (66, 11, '2026-03-09', 4, 560000, '2026-03-09 10:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (67, 19, '2026-03-13', 2, 210000, '2026-03-13 10:33:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (68, 45, '2026-03-14', 2, 130000, '2026-03-14 11:41:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (69, 31, '2026-03-16', 2, 56000, '2026-03-16 10:53:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (70, 43, '2026-03-16', 1, 150000, '2026-03-16 13:32:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (71, 15, '2026-03-18', 1, 35000, '2026-03-18 15:27:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (72, 44, '2026-03-19', 2, 190000, '2026-03-19 10:57:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (73, 45, '2026-03-21', 1, 65000, '2026-03-21 09:46:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (74, 14, '2026-03-22', 1, 48000, '2026-03-22 11:15:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (75, 15, '2026-03-22', 3, 105000, '2026-03-22 13:51:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (76, 45, '2026-03-25', 2, 130000, '2026-03-25 13:49:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (77, 6, '2026-03-26', 3, 1530000, '2026-03-26 10:38:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (78, 45, '2026-03-27', 4, 260000, '2026-03-27 12:39:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (79, 34, '2026-03-28', 2, 460000, '2026-03-28 17:38:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (80, 8, '2026-03-28', 2, 190000, '2026-03-28 10:08:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (81, 30, '2026-03-30', 1, 155000, '2026-03-30 11:36:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (82, 28, '2026-03-30', 4, 480000, '2026-03-30 15:04:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (83, 10, '2026-03-31', 1, 95000, '2026-03-31 12:51:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (84, 23, '2026-03-31', 1, 220000, '2026-03-31 11:24:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (85, 20, '2026-04-01', 4, 260000, '2026-04-01 09:44:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (86, 15, '2026-04-02', 1, 35000, '2026-04-02 12:11:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (87, 14, '2026-04-03', 3, 144000, '2026-04-03 17:21:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (88, 43, '2026-04-03', 2, 300000, '2026-04-03 12:20:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (89, 27, '2026-04-05', 4, 740000, '2026-04-05 08:22:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (90, 20, '2026-04-07', 1, 65000, '2026-04-07 13:14:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (91, 12, '2026-04-08', 4, 640000, '2026-04-08 16:01:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (92, 42, '2026-04-09', 3, 630000, '2026-04-09 08:36:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (93, 35, '2026-04-12', 3, 1110000, '2026-04-12 16:15:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (94, 40, '2026-04-14', 1, 590000, '2026-04-14 08:07:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (95, 16, '2026-04-16', 1, 115000, '2026-04-16 08:03:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (96, 15, '2026-04-17', 3, 105000, '2026-04-17 09:10:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (97, 40, '2026-04-18', 3, 1770000, '2026-04-18 13:45:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (98, 7, '2026-04-19', 2, 960000, '2026-04-19 14:12:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (99, 31, '2026-04-20', 1, 28000, '2026-04-20 14:07:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (100, 8, '2026-04-20', 3, 285000, '2026-04-20 17:39:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (101, 31, '2026-04-20', 1, 28000, '2026-04-20 12:25:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (102, 31, '2026-04-22', 4, 112000, '2026-04-22 16:35:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (103, 3, '2026-04-24', 4, 2480000, '2026-04-24 15:27:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (104, 12, '2026-04-25', 3, 480000, '2026-04-25 15:47:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (105, 43, '2026-04-26', 3, 450000, '2026-04-26 16:15:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (106, 45, '2026-04-28', 3, 195000, '2026-04-28 15:27:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (107, 31, '2026-05-02', 2, 56000, '2026-05-02 11:51:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (108, 24, '2026-05-03', 3, 330000, '2026-05-03 13:11:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (109, 19, '2026-05-03', 1, 105000, '2026-05-03 09:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (110, 15, '2026-05-04', 2, 70000, '2026-05-04 12:25:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (111, 4, '2026-05-04', 1, 450000, '2026-05-04 12:30:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (112, 11, '2026-05-05', 2, 280000, '2026-05-05 16:14:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (113, 36, '2026-05-05', 3, 810000, '2026-05-05 10:45:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (114, 8, '2026-05-07', 3, 285000, '2026-05-07 12:11:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (115, 38, '2026-05-07', 3, 1440000, '2026-05-07 15:16:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (116, 12, '2026-05-07', 1, 160000, '2026-05-07 08:27:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (117, 38, '2026-05-09', 2, 960000, '2026-05-09 12:46:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (118, 22, '2026-05-11', 4, 760000, '2026-05-11 12:30:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (119, 9, '2026-05-13', 3, 1050000, '2026-05-13 17:30:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (120, 34, '2026-05-14', 1, 230000, '2026-05-14 13:46:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (121, 8, '2026-05-14', 2, 190000, '2026-05-14 14:24:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (122, 14, '2026-05-17', 2, 96000, '2026-05-17 15:18:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (123, 27, '2026-05-18', 2, 370000, '2026-05-18 13:08:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (124, 15, '2026-05-18', 1, 35000, '2026-05-18 16:18:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (125, 17, '2026-05-19', 2, 110000, '2026-05-19 14:02:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (126, 17, '2026-05-20', 2, 110000, '2026-05-20 16:54:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (127, 17, '2026-05-20', 1, 55000, '2026-05-20 11:35:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (128, 10, '2026-05-21', 2, 190000, '2026-05-21 09:30:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (129, 8, '2026-05-21', 3, 285000, '2026-05-21 16:19:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (130, 24, '2026-05-26', 1, 110000, '2026-05-26 08:38:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (131, 28, '2026-05-26', 4, 480000, '2026-05-26 15:10:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (132, 31, '2026-05-26', 1, 28000, '2026-05-26 08:27:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (133, 44, '2026-05-27', 3, 285000, '2026-05-27 10:53:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (134, 24, '2026-06-01', 3, 330000, '2026-06-01 10:15:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (135, 30, '2026-06-02', 4, 620000, '2026-06-02 13:48:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (136, 43, '2026-06-03', 2, 300000, '2026-06-03 13:49:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (137, 18, '2026-06-03', 4, 480000, '2026-06-03 12:38:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (138, 14, '2026-06-03', 1, 48000, '2026-06-03 08:23:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (139, 30, '2026-06-05', 1, 155000, '2026-06-05 16:25:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (140, 30, '2026-06-05', 1, 155000, '2026-06-05 13:36:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (141, 9, '2026-06-05', 2, 700000, '2026-06-05 12:44:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (142, 1, '2026-06-06', 4, 2880000, '2026-06-06 15:17:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (143, 31, '2026-06-07', 1, 28000, '2026-06-07 15:12:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (144, 15, '2026-06-08', 3, 105000, '2026-06-08 14:22:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (145, 11, '2026-06-09', 3, 420000, '2026-06-09 15:53:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (146, 14, '2026-06-09', 1, 48000, '2026-06-09 10:33:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (147, 21, '2026-06-10', 2, 400000, '2026-06-10 08:44:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (148, 14, '2026-06-10', 1, 48000, '2026-06-10 10:29:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (149, 24, '2026-06-12', 2, 220000, '2026-06-12 14:43:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (150, 15, '2026-06-13', 2, 70000, '2026-06-13 17:07:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (151, 10, '2026-06-13', 3, 285000, '2026-06-13 13:50:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (152, 14, '2026-06-13', 2, 96000, '2026-06-13 13:08:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (153, 23, '2026-06-14', 2, 440000, '2026-06-14 12:19:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (154, 31, '2026-06-14', 1, 28000, '2026-06-14 13:01:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (155, 13, '2026-06-16', 1, 220000, '2026-06-16 15:56:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (156, 33, '2026-06-16', 3, 1260000, '2026-06-16 17:22:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (157, 28, '2026-06-16', 2, 240000, '2026-06-16 13:36:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (158, 32, '2026-06-17', 4, 1200000, '2026-06-17 08:13:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (159, 45, '2026-06-18', 1, 65000, '2026-06-18 08:53:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (160, 29, '2026-06-20', 3, 450000, '2026-06-20 12:26:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (161, 18, '2026-04-18', 4, 935736, '2026-04-18 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (162, 6, '2026-06-26', 7, 1752863, '2026-06-26 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (163, 34, '2026-04-30', 7, 1957697, '2026-04-30 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (164, 20, '2026-03-30', 1, 77775, '2026-03-30 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (165, 43, '2026-05-06', 8, 405808, '2026-05-06 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (166, 27, '2026-04-13', 2, 284554, '2026-04-13 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (167, 44, '2026-06-16', 5, 1234375, '2026-06-16 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (168, 45, '2026-05-30', 2, 246622, '2026-05-30 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (169, 10, '2026-02-19', 5, 1276760, '2026-02-19 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (170, 12, '2026-03-16', 7, 1681736, '2026-03-16 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (171, 24, '2026-03-02', 1, 269189, '2026-03-02 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (172, 1, '2026-05-17', 4, 821256, '2026-05-17 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (173, 29, '2026-01-06', 4, 739884, '2026-01-06 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (174, 31, '2026-04-17', 2, 475308, '2026-04-17 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (175, 28, '2026-03-12', 5, 911695, '2026-03-12 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (176, 37, '2026-06-05', 6, 457818, '2026-06-05 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (177, 18, '2026-03-16', 4, 899372, '2026-03-16 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (178, 3, '2026-02-17', 4, 717276, '2026-02-17 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (179, 32, '2026-04-22', 6, 1712586, '2026-04-22 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (180, 20, '2026-04-22', 2, 424618, '2026-04-22 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (181, 26, '2026-02-07', 5, 377015, '2026-02-07 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (182, 41, '2026-04-24', 2, 395398, '2026-04-24 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (183, 37, '2026-01-03', 4, 1148752, '2026-01-03 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (184, 10, '2026-03-01', 7, 1961827, '2026-03-01 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (185, 36, '2026-02-07', 7, 524426, '2026-02-07 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (186, 40, '2026-03-31', 6, 1512948, '2026-03-31 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (187, 16, '2026-06-15', 8, 1239816, '2026-06-15 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (188, 44, '2026-03-30', 1, 105140, '2026-03-30 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (189, 1, '2026-03-26', 2, 236294, '2026-03-26 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (190, 9, '2026-02-19', 5, 1249350, '2026-02-19 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (191, 34, '2026-04-16', 7, 1015049, '2026-04-16 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (192, 29, '2026-05-12', 8, 2106192, '2026-05-12 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (193, 39, '2026-02-01', 5, 1485235, '2026-02-01 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (194, 45, '2026-05-21', 6, 1602126, '2026-05-21 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (195, 13, '2026-03-04', 6, 913098, '2026-03-04 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (196, 28, '2026-01-20', 7, 1031023, '2026-01-20 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (197, 20, '2026-03-27', 2, 337384, '2026-03-27 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (198, 45, '2026-04-06', 5, 1369210, '2026-04-06 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (199, 10, '2026-02-27', 3, 883047, '2026-02-27 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (200, 3, '2026-03-04', 6, 429900, '2026-03-04 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (201, 32, '2026-06-02', 7, 1518979, '2026-06-02 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (202, 16, '2026-04-24', 5, 414935, '2026-04-24 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (203, 5, '2026-06-29', 6, 1081536, '2026-06-29 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (204, 16, '2026-03-28', 6, 1488828, '2026-03-28 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (205, 16, '2026-06-19', 8, 679624, '2026-06-19 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (206, 27, '2026-02-23', 7, 1201529, '2026-02-23 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (207, 44, '2026-04-03', 2, 209040, '2026-04-03 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (208, 31, '2026-06-04', 7, 1238097, '2026-06-04 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (209, 26, '2026-05-25', 2, 128898, '2026-05-25 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (210, 34, '2026-06-14', 8, 1089488, '2026-06-14 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (211, 17, '2026-04-17', 2, 542686, '2026-04-17 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (212, 40, '2026-05-02', 6, 1277490, '2026-05-02 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (213, 12, '2026-06-12', 3, 520065, '2026-06-12 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (214, 41, '2026-02-24', 8, 1496416, '2026-02-24 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (215, 17, '2026-06-02', 3, 771453, '2026-06-02 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (216, 15, '2026-02-03', 8, 1268168, '2026-02-03 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (217, 12, '2026-05-17', 2, 165940, '2026-05-17 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (218, 29, '2026-01-12', 1, 94141, '2026-01-12 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (219, 43, '2026-04-24', 5, 1364775, '2026-04-24 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (220, 23, '2026-04-28', 5, 1003065, '2026-04-28 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (221, 18, '2026-01-26', 8, 1005472, '2026-01-26 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (222, 11, '2026-03-14', 8, 2387744, '2026-03-14 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (223, 39, '2026-01-19', 4, 1156208, '2026-01-19 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (224, 8, '2026-02-07', 8, 1029688, '2026-02-07 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (225, 25, '2026-06-06', 7, 1870428, '2026-06-06 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (226, 31, '2026-05-18', 7, 1280734, '2026-05-18 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (227, 11, '2026-06-11', 6, 618498, '2026-06-11 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (228, 12, '2026-05-07', 1, 73524, '2026-05-07 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (229, 6, '2026-03-19', 7, 2031750, '2026-03-19 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (230, 1, '2026-06-04', 7, 1895565, '2026-06-04 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (231, 33, '2026-04-18', 8, 949912, '2026-04-18 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (232, 33, '2026-03-09', 8, 1415320, '2026-03-09 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (233, 12, '2026-02-27', 4, 204760, '2026-02-27 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (234, 4, '2026-04-10', 6, 1495380, '2026-04-10 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (235, 35, '2026-01-29', 5, 1238880, '2026-01-29 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (236, 39, '2026-04-10', 7, 785505, '2026-04-10 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (237, 21, '2026-03-26', 8, 1088344, '2026-03-26 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (238, 28, '2026-05-17', 2, 509800, '2026-05-17 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (239, 39, '2026-02-01', 3, 630297, '2026-02-01 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (240, 31, '2026-01-22', 6, 446814, '2026-01-22 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (241, 27, '2026-04-16', 4, 682128, '2026-04-16 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (242, 17, '2026-02-14', 1, 51133, '2026-02-14 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (243, 38, '2026-06-06', 5, 516005, '2026-06-06 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (244, 30, '2026-01-04', 2, 411430, '2026-01-04 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (245, 45, '2026-02-18', 5, 271945, '2026-02-18 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (246, 38, '2026-01-25', 4, 490684, '2026-01-25 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (247, 28, '2026-01-03', 2, 576222, '2026-01-03 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (248, 37, '2026-05-04', 7, 1981609, '2026-05-04 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (249, 36, '2026-04-05', 7, 491477, '2026-04-05 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (250, 14, '2026-01-01', 8, 666624, '2026-01-01 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (251, 32, '2026-04-19', 3, 785211, '2026-04-19 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (252, 35, '2026-03-04', 7, 588364, '2026-03-04 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (253, 30, '2026-05-01', 8, 1861152, '2026-05-01 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (254, 12, '2026-06-12', 8, 1414024, '2026-06-12 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (255, 32, '2026-01-30', 5, 1248590, '2026-01-30 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (256, 8, '2026-01-22', 7, 1860334, '2026-01-22 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (257, 37, '2026-01-09', 5, 763780, '2026-01-09 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (258, 14, '2026-06-22', 3, 393150, '2026-06-22 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (259, 31, '2026-02-25', 7, 830067, '2026-02-25 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (260, 35, '2026-06-19', 8, 2322632, '2026-06-19 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (261, 19, '2026-03-15', 8, 1167168, '2026-03-15 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (262, 31, '2026-06-27', 2, 343986, '2026-06-27 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (263, 31, '2026-04-27', 2, 451564, '2026-04-27 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (264, 1, '2026-01-12', 2, 391412, '2026-01-12 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (265, 28, '2026-02-15', 5, 1375760, '2026-02-15 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (266, 29, '2026-02-26', 7, 798077, '2026-02-26 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (267, 13, '2026-06-23', 2, 378460, '2026-06-23 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (268, 39, '2026-01-28', 5, 662165, '2026-01-28 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (269, 16, '2026-01-29', 5, 816005, '2026-01-29 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (270, 26, '2026-02-04', 5, 1460685, '2026-02-04 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (271, 21, '2026-01-24', 5, 1476265, '2026-01-24 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (272, 12, '2026-06-18', 6, 1402116, '2026-06-18 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (273, 41, '2026-05-01', 2, 249140, '2026-05-01 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (274, 1, '2026-05-31', 2, 298192, '2026-05-31 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (275, 8, '2026-02-28', 4, 503616, '2026-02-28 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (276, 39, '2026-04-15', 5, 1256940, '2026-04-15 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (277, 45, '2026-04-30', 4, 934860, '2026-04-30 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (278, 41, '2026-05-28', 1, 247209, '2026-05-28 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (279, 25, '2026-01-23', 7, 1921164, '2026-01-23 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (280, 38, '2026-02-10', 4, 1049712, '2026-02-10 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (281, 39, '2026-04-04', 8, 1237424, '2026-04-04 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (282, 29, '2026-01-24', 2, 192008, '2026-01-24 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (283, 12, '2026-05-24', 8, 899960, '2026-05-24 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (284, 26, '2026-01-21', 4, 464680, '2026-01-21 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (285, 37, '2026-04-11', 2, 296358, '2026-04-11 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (286, 15, '2026-06-24', 3, 699576, '2026-06-24 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (287, 24, '2026-04-05', 6, 403656, '2026-04-05 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (288, 24, '2026-04-14', 5, 1189270, '2026-04-14 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (289, 15, '2026-01-24', 6, 1099086, '2026-01-24 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (290, 42, '2026-03-08', 1, 92562, '2026-03-08 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (291, 10, '2026-01-30', 7, 1673455, '2026-01-30 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (292, 5, '2026-05-28', 2, 542636, '2026-05-28 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (293, 17, '2026-05-21', 5, 260120, '2026-05-21 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (294, 6, '2026-02-11', 5, 260110, '2026-02-11 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (295, 38, '2026-06-21', 7, 936257, '2026-06-21 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (296, 25, '2026-04-10', 2, 393240, '2026-04-10 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (297, 45, '2026-03-12', 5, 608855, '2026-03-12 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (298, 1, '2026-03-23', 7, 913388, '2026-03-23 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (299, 19, '2026-05-26', 3, 844569, '2026-05-26 00:00:00');
INSERT INTO `sales` (`id_penjualan`, `id_barang`, `tanggal_keluar`, `jumlah_terjual`, `total_harga`, `created_at`) VALUES (300, 7, '2026-06-18', 5, 1226530, '2026-06-18 00:00:00');

-- ============================================================
-- DATA AWAL: purchases (Dari Excel)
-- ============================================================
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (1, 14, 2, '2026-01-02', 15, '2026-01-02 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (2, 9, 1, '2026-01-03', 22, '2026-01-03 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (3, 31, 11, '2026-01-04', 12, '2026-01-04 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (4, 45, 3, '2026-01-05', 19, '2026-01-05 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (5, 24, 3, '2026-01-06', 31, '2026-01-06 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (6, 18, 5, '2026-01-08', 23, '2026-01-08 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (7, 17, 3, '2026-01-08', 18, '2026-01-08 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (8, 38, 8, '2026-01-09', 15, '2026-01-09 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (9, 31, 11, '2026-01-09', 16, '2026-01-09 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (10, 24, 3, '2026-01-09', 19, '2026-01-09 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (11, 8, 2, '2026-01-09', 31, '2026-01-09 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (12, 13, 6, '2026-01-10', 16, '2026-01-10 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (13, 31, 11, '2026-01-10', 15, '2026-01-10 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (14, 15, 2, '2026-01-11', 16, '2026-01-11 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (15, 34, 7, '2026-01-13', 23, '2026-01-13 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (16, 4, 10, '2026-01-15', 12, '2026-01-15 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (17, 12, 3, '2026-01-16', 11, '2026-01-16 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (18, 24, 3, '2026-01-16', 14, '2026-01-16 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (19, 32, 8, '2026-01-18', 12, '2026-01-18 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (20, 21, 5, '2026-01-21', 31, '2026-01-21 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (21, 27, 11, '2026-01-22', 35, '2026-01-22 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (22, 31, 11, '2026-01-23', 15, '2026-01-23 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (23, 2, 1, '2026-01-23', 17, '2026-01-23 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (24, 8, 2, '2026-01-26', 25, '2026-01-26 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (25, 43, 9, '2026-01-28', 14, '2026-01-28 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (26, 11, 3, '2026-01-29', 14, '2026-01-29 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (27, 37, 8, '2026-01-29', 18, '2026-01-29 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (28, 38, 8, '2026-01-31', 35, '2026-01-31 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (29, 32, 8, '2026-02-01', 12, '2026-02-01 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (30, 10, 2, '2026-02-01', 27, '2026-02-01 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (31, 7, 10, '2026-02-04', 25, '2026-02-04 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (32, 28, 11, '2026-02-05', 29, '2026-02-05 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (33, 6, 10, '2026-02-06', 25, '2026-02-06 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (34, 15, 2, '2026-02-12', 28, '2026-02-12 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (35, 44, 9, '2026-02-13', 29, '2026-02-13 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (36, 39, 6, '2026-02-13', 30, '2026-02-13 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (37, 24, 3, '2026-02-15', 15, '2026-02-15 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (38, 5, 10, '2026-02-16', 30, '2026-02-16 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (39, 7, 10, '2026-02-16', 24, '2026-02-16 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (40, 38, 8, '2026-02-16', 16, '2026-02-16 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (41, 34, 7, '2026-02-16', 25, '2026-02-16 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (42, 16, 3, '2026-02-17', 32, '2026-02-17 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (43, 3, 2, '2026-02-17', 11, '2026-02-17 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (44, 11, 3, '2026-02-18', 14, '2026-02-18 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (45, 27, 11, '2026-02-19', 20, '2026-02-19 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (46, 29, 11, '2026-02-20', 24, '2026-02-20 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (47, 34, 7, '2026-02-20', 26, '2026-02-20 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (48, 10, 2, '2026-02-20', 14, '2026-02-20 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (49, 36, 7, '2026-02-21', 11, '2026-02-21 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (50, 21, 5, '2026-02-21', 13, '2026-02-21 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (51, 30, 12, '2026-02-22', 13, '2026-02-22 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (52, 13, 6, '2026-02-22', 16, '2026-02-22 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (53, 38, 8, '2026-02-24', 13, '2026-02-24 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (54, 1, 1, '2026-02-25', 32, '2026-02-25 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (55, 29, 11, '2026-02-28', 34, '2026-02-28 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (56, 28, 11, '2026-03-01', 16, '2026-03-01 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (57, 26, 11, '2026-03-03', 11, '2026-03-03 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (58, 40, 6, '2026-03-03', 16, '2026-03-03 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (59, 32, 8, '2026-03-05', 12, '2026-03-05 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (60, 2, 1, '2026-03-05', 35, '2026-03-05 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (61, 26, 11, '2026-03-05', 20, '2026-03-05 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (62, 26, 11, '2026-03-05', 18, '2026-03-05 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (63, 12, 3, '2026-03-06', 10, '2026-03-06 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (64, 4, 10, '2026-03-09', 24, '2026-03-09 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (65, 19, 5, '2026-03-09', 22, '2026-03-09 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (66, 33, 8, '2026-03-10', 35, '2026-03-10 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (67, 19, 5, '2026-03-11', 20, '2026-03-11 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (68, 31, 11, '2026-03-11', 23, '2026-03-11 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (69, 29, 11, '2026-03-13', 23, '2026-03-13 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (70, 29, 11, '2026-03-14', 26, '2026-03-14 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (71, 25, 4, '2026-03-15', 30, '2026-03-15 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (72, 35, 7, '2026-03-21', 31, '2026-03-21 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (73, 1, 1, '2026-03-22', 20, '2026-03-22 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (74, 35, 7, '2026-03-24', 12, '2026-03-24 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (75, 18, 5, '2026-03-26', 13, '2026-03-26 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (76, 4, 10, '2026-03-28', 26, '2026-03-28 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (77, 14, 2, '2026-03-28', 17, '2026-03-28 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (78, 3, 2, '2026-03-29', 12, '2026-03-29 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (79, 23, 5, '2026-03-29', 20, '2026-03-29 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (80, 42, 6, '2026-03-30', 34, '2026-03-30 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (81, 9, 1, '2026-03-30', 25, '2026-03-30 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (82, 25, 4, '2026-04-01', 28, '2026-04-01 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (83, 35, 7, '2026-04-01', 15, '2026-04-01 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (84, 19, 5, '2026-04-02', 21, '2026-04-02 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (85, 45, 3, '2026-04-03', 29, '2026-04-03 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (86, 14, 2, '2026-04-04', 21, '2026-04-04 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (87, 18, 5, '2026-04-06', 32, '2026-04-06 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (88, 33, 8, '2026-04-06', 15, '2026-04-06 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (89, 4, 10, '2026-04-08', 16, '2026-04-08 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (90, 34, 7, '2026-04-09', 29, '2026-04-09 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (91, 45, 3, '2026-04-09', 15, '2026-04-09 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (92, 28, 11, '2026-04-09', 21, '2026-04-09 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (93, 23, 5, '2026-04-12', 15, '2026-04-12 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (94, 1, 1, '2026-04-12', 20, '2026-04-12 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (95, 3, 2, '2026-04-15', 17, '2026-04-15 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (96, 45, 3, '2026-04-18', 34, '2026-04-18 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (97, 1, 1, '2026-04-19', 27, '2026-04-19 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (98, 10, 2, '2026-04-20', 27, '2026-04-20 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (99, 5, 10, '2026-04-20', 29, '2026-04-20 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (100, 28, 11, '2026-04-20', 26, '2026-04-20 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (101, 26, 11, '2026-04-21', 13, '2026-04-21 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (102, 6, 10, '2026-04-22', 20, '2026-04-22 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (103, 9, 1, '2026-04-22', 20, '2026-04-22 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (104, 7, 10, '2026-04-24', 24, '2026-04-24 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (105, 15, 2, '2026-04-26', 13, '2026-04-26 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (106, 42, 6, '2026-04-29', 27, '2026-04-29 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (107, 14, 2, '2026-04-29', 18, '2026-04-29 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (108, 14, 2, '2026-05-02', 21, '2026-05-02 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (109, 38, 8, '2026-05-04', 35, '2026-05-04 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (110, 21, 5, '2026-05-04', 12, '2026-05-04 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (111, 36, 7, '2026-05-12', 27, '2026-05-12 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (112, 41, 6, '2026-05-13', 24, '2026-05-13 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (113, 40, 6, '2026-05-13', 34, '2026-05-13 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (114, 7, 10, '2026-05-13', 25, '2026-05-13 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (115, 40, 6, '2026-05-18', 10, '2026-05-18 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (116, 20, 4, '2026-05-18', 12, '2026-05-18 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (117, 8, 2, '2026-05-18', 24, '2026-05-18 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (118, 37, 8, '2026-05-22', 23, '2026-05-22 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (119, 22, 5, '2026-05-22', 18, '2026-05-22 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (120, 42, 6, '2026-05-24', 34, '2026-05-24 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (121, 41, 6, '2026-05-28', 18, '2026-05-28 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (122, 24, 3, '2026-05-29', 35, '2026-05-29 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (123, 19, 5, '2026-05-31', 20, '2026-05-31 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (124, 11, 3, '2026-05-31', 33, '2026-05-31 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (125, 39, 6, '2026-05-31', 18, '2026-05-31 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (126, 27, 11, '2026-06-01', 31, '2026-06-01 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (127, 7, 10, '2026-06-02', 29, '2026-06-02 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (128, 20, 4, '2026-06-04', 17, '2026-06-04 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (129, 18, 5, '2026-06-04', 12, '2026-06-04 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (130, 41, 6, '2026-06-05', 24, '2026-06-05 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (131, 37, 8, '2026-06-06', 24, '2026-06-06 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (132, 8, 2, '2026-06-07', 24, '2026-06-07 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (133, 41, 6, '2026-06-07', 24, '2026-06-07 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (134, 41, 6, '2026-06-08', 18, '2026-06-08 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (135, 4, 10, '2026-06-11', 25, '2026-06-11 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (136, 36, 7, '2026-06-13', 16, '2026-06-13 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (137, 17, 3, '2026-06-15', 25, '2026-06-15 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (138, 23, 5, '2026-06-16', 10, '2026-06-16 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (139, 45, 3, '2026-06-18', 19, '2026-06-18 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (140, 20, 4, '2026-06-20', 19, '2026-06-20 09:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (141, 22, 3, '2026-01-29', 25, '2026-01-29 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (142, 43, 9, '2026-01-15', 31, '2026-01-15 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (143, 25, 6, '2026-05-24', 27, '2026-05-24 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (144, 7, 11, '2026-03-17', 23, '2026-03-17 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (145, 42, 5, '2026-05-26', 18, '2026-05-26 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (146, 30, 7, '2026-06-22', 17, '2026-06-22 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (147, 7, 3, '2026-03-17', 35, '2026-03-17 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (148, 38, 4, '2026-04-19', 37, '2026-04-19 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (149, 24, 8, '2026-01-26', 15, '2026-01-26 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (150, 38, 6, '2026-05-03', 36, '2026-05-03 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (151, 33, 9, '2026-02-10', 12, '2026-02-10 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (152, 34, 11, '2026-05-09', 28, '2026-05-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (153, 25, 5, '2026-05-30', 34, '2026-05-30 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (154, 15, 6, '2026-06-16', 20, '2026-06-16 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (155, 45, 12, '2026-01-27', 21, '2026-01-27 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (156, 12, 11, '2026-03-03', 28, '2026-03-03 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (157, 30, 4, '2026-05-17', 38, '2026-05-17 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (158, 39, 4, '2026-05-23', 23, '2026-05-23 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (159, 35, 12, '2026-04-26', 10, '2026-04-26 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (160, 16, 6, '2026-02-18', 38, '2026-02-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (161, 6, 12, '2026-06-01', 19, '2026-06-01 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (162, 39, 4, '2026-04-04', 34, '2026-04-04 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (163, 32, 7, '2026-02-10', 26, '2026-02-10 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (164, 37, 8, '2026-04-01', 24, '2026-04-01 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (165, 7, 7, '2026-03-18', 20, '2026-03-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (166, 39, 3, '2026-04-21', 24, '2026-04-21 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (167, 20, 4, '2026-06-12', 25, '2026-06-12 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (168, 14, 12, '2026-03-06', 14, '2026-03-06 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (169, 12, 4, '2026-05-26', 22, '2026-05-26 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (170, 27, 4, '2026-03-11', 36, '2026-03-11 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (171, 3, 10, '2026-03-13', 31, '2026-03-13 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (172, 32, 12, '2026-03-27', 17, '2026-03-27 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (173, 16, 10, '2026-06-05', 39, '2026-06-05 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (174, 21, 9, '2026-06-02', 32, '2026-06-02 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (175, 15, 5, '2026-01-30', 19, '2026-01-30 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (176, 15, 8, '2026-06-08', 21, '2026-06-08 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (177, 7, 11, '2026-02-08', 37, '2026-02-08 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (178, 29, 7, '2026-01-25', 30, '2026-01-25 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (179, 24, 4, '2026-05-08', 38, '2026-05-08 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (180, 22, 5, '2026-04-20', 27, '2026-04-20 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (181, 20, 7, '2026-05-15', 39, '2026-05-15 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (182, 37, 6, '2026-05-04', 14, '2026-05-04 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (183, 13, 1, '2026-05-18', 19, '2026-05-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (184, 36, 5, '2026-04-05', 26, '2026-04-05 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (185, 20, 10, '2026-06-09', 28, '2026-06-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (186, 3, 6, '2026-02-18', 10, '2026-02-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (187, 40, 2, '2026-03-06', 21, '2026-03-06 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (188, 3, 5, '2026-03-15', 28, '2026-03-15 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (189, 25, 5, '2026-05-05', 23, '2026-05-05 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (190, 29, 3, '2026-04-21', 24, '2026-04-21 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (191, 41, 10, '2026-03-02', 35, '2026-03-02 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (192, 27, 2, '2026-03-25', 32, '2026-03-25 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (193, 17, 4, '2026-02-06', 10, '2026-02-06 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (194, 11, 9, '2026-05-28', 36, '2026-05-28 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (195, 36, 9, '2026-02-24', 15, '2026-02-24 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (196, 22, 7, '2026-02-18', 35, '2026-02-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (197, 15, 2, '2026-01-18', 17, '2026-01-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (198, 1, 12, '2026-06-16', 23, '2026-06-16 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (199, 6, 5, '2026-01-26', 34, '2026-01-26 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (200, 15, 10, '2026-06-20', 40, '2026-06-20 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (201, 32, 8, '2026-02-18', 36, '2026-02-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (202, 10, 3, '2026-05-22', 34, '2026-05-22 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (203, 39, 12, '2026-02-24', 29, '2026-02-24 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (204, 24, 2, '2026-06-13', 13, '2026-06-13 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (205, 31, 2, '2026-05-01', 21, '2026-05-01 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (206, 34, 3, '2026-01-18', 33, '2026-01-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (207, 31, 8, '2026-02-12', 35, '2026-02-12 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (208, 19, 5, '2026-05-08', 14, '2026-05-08 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (209, 31, 7, '2026-03-08', 22, '2026-03-08 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (210, 26, 11, '2026-01-14', 26, '2026-01-14 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (211, 42, 10, '2026-04-16', 19, '2026-04-16 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (212, 25, 9, '2026-04-06', 26, '2026-04-06 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (213, 7, 10, '2026-06-17', 10, '2026-06-17 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (214, 3, 1, '2026-01-19', 31, '2026-01-19 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (215, 34, 8, '2026-03-04', 20, '2026-03-04 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (216, 36, 5, '2026-01-03', 32, '2026-01-03 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (217, 23, 3, '2026-03-18', 40, '2026-03-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (218, 37, 6, '2026-04-21', 37, '2026-04-21 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (219, 33, 2, '2026-02-09', 13, '2026-02-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (220, 17, 5, '2026-05-20', 22, '2026-05-20 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (221, 27, 11, '2026-06-09', 13, '2026-06-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (222, 11, 4, '2026-05-20', 11, '2026-05-20 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (223, 3, 5, '2026-03-01', 21, '2026-03-01 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (224, 1, 6, '2026-06-12', 13, '2026-06-12 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (225, 10, 4, '2026-01-26', 19, '2026-01-26 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (226, 37, 1, '2026-05-04', 12, '2026-05-04 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (227, 1, 9, '2026-02-02', 18, '2026-02-02 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (228, 31, 1, '2026-01-31', 12, '2026-01-31 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (229, 28, 3, '2026-01-26', 26, '2026-01-26 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (230, 13, 11, '2026-06-18', 24, '2026-06-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (231, 13, 8, '2026-03-06', 40, '2026-03-06 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (232, 23, 9, '2026-01-17', 17, '2026-01-17 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (233, 28, 4, '2026-03-17', 37, '2026-03-17 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (234, 13, 9, '2026-04-28', 31, '2026-04-28 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (235, 42, 11, '2026-04-21', 27, '2026-04-21 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (236, 16, 9, '2026-01-04', 32, '2026-01-04 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (237, 44, 4, '2026-03-16', 22, '2026-03-16 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (238, 33, 7, '2026-06-09', 38, '2026-06-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (239, 12, 11, '2026-03-03', 36, '2026-03-03 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (240, 31, 8, '2026-05-04', 31, '2026-05-04 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (241, 31, 3, '2026-03-13', 19, '2026-03-13 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (242, 16, 11, '2026-05-20', 27, '2026-05-20 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (243, 43, 10, '2026-06-16', 18, '2026-06-16 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (244, 13, 1, '2026-06-23', 21, '2026-06-23 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (245, 19, 12, '2026-06-09', 25, '2026-06-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (246, 44, 3, '2026-05-23', 39, '2026-05-23 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (247, 26, 11, '2026-04-15', 14, '2026-04-15 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (248, 42, 4, '2026-06-12', 15, '2026-06-12 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (249, 24, 5, '2026-05-31', 15, '2026-05-31 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (250, 29, 4, '2026-02-10', 16, '2026-02-10 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (251, 26, 6, '2026-05-12', 33, '2026-05-12 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (252, 5, 4, '2026-05-21', 28, '2026-05-21 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (253, 31, 11, '2026-04-01', 16, '2026-04-01 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (254, 5, 3, '2026-04-23', 11, '2026-04-23 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (255, 8, 9, '2026-04-26', 27, '2026-04-26 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (256, 30, 7, '2026-06-06', 30, '2026-06-06 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (257, 21, 11, '2026-01-15', 28, '2026-01-15 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (258, 38, 1, '2026-02-10', 34, '2026-02-10 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (259, 42, 12, '2026-01-19', 29, '2026-01-19 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (260, 35, 5, '2026-06-13', 23, '2026-06-13 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (261, 11, 10, '2026-06-07', 22, '2026-06-07 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (262, 10, 2, '2026-03-04', 11, '2026-03-04 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (263, 1, 2, '2026-04-13', 12, '2026-04-13 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (264, 4, 1, '2026-03-01', 37, '2026-03-01 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (265, 43, 3, '2026-01-23', 23, '2026-01-23 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (266, 15, 3, '2026-04-15', 21, '2026-04-15 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (267, 34, 9, '2026-02-08', 38, '2026-02-08 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (268, 3, 7, '2026-06-09', 13, '2026-06-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (269, 15, 6, '2026-02-25', 23, '2026-02-25 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (270, 33, 10, '2026-03-16', 27, '2026-03-16 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (271, 44, 3, '2026-04-23', 32, '2026-04-23 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (272, 10, 9, '2026-02-24', 35, '2026-02-24 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (273, 6, 4, '2026-03-28', 13, '2026-03-28 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (274, 32, 6, '2026-05-02', 13, '2026-05-02 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (275, 2, 7, '2026-01-09', 34, '2026-01-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (276, 33, 11, '2026-03-01', 14, '2026-03-01 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (277, 31, 3, '2026-06-21', 28, '2026-06-21 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (278, 9, 11, '2026-02-28', 22, '2026-02-28 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (279, 39, 5, '2026-01-27', 23, '2026-01-27 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (280, 37, 2, '2026-01-07', 31, '2026-01-07 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (281, 13, 9, '2026-04-29', 31, '2026-04-29 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (282, 4, 8, '2026-05-14', 32, '2026-05-14 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (283, 26, 10, '2026-03-20', 23, '2026-03-20 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (284, 19, 4, '2026-02-21', 38, '2026-02-21 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (285, 26, 10, '2026-01-28', 15, '2026-01-28 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (286, 1, 9, '2026-01-09', 32, '2026-01-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (287, 32, 4, '2026-04-06', 26, '2026-04-06 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (288, 23, 4, '2026-03-07', 20, '2026-03-07 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (289, 4, 10, '2026-02-22', 27, '2026-02-22 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (290, 12, 7, '2026-02-18', 39, '2026-02-18 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (291, 29, 5, '2026-04-22', 15, '2026-04-22 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (292, 35, 7, '2026-04-06', 26, '2026-04-06 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (293, 1, 3, '2026-01-09', 15, '2026-01-09 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (294, 16, 1, '2026-04-15', 34, '2026-04-15 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (295, 4, 5, '2026-04-21', 36, '2026-04-21 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (296, 34, 1, '2026-06-04', 16, '2026-06-04 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (297, 44, 5, '2026-06-24', 39, '2026-06-24 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (298, 17, 5, '2026-01-06', 14, '2026-01-06 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (299, 45, 2, '2026-02-02', 23, '2026-02-02 00:00:00');
INSERT INTO `purchases` (`id_pembelian`, `id_barang`, `id_supplier`, `tanggal_masuk`, `jumlah_masuk`, `created_at`) VALUES (300, 44, 1, '2026-05-04', 14, '2026-05-04 00:00:00');

-- ============================================================
-- DATA AWAL: inventory_controls (Dari Excel)
-- ============================================================
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (1, 1, 0, 2, 2, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (2, 2, 0, 2, 2, 'Segera Pesan', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (3, 3, 2, 6, 6, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (4, 4, 0.4, 3, 3, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (5, 5, 0, 6, 6, 'Segera Pesan', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (6, 6, 0, 4, 4, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (7, 7, 1, 4, 4, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (8, 8, 8.1, 3, 4, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (9, 9, 2.4, 3, 3, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (10, 10, 0, 5, 5, 'Segera Pesan', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (11, 11, 0.4, 4, 4, 'Segera Pesan', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (12, 12, 2.7, 6, 6, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (13, 13, 0, 5, 5, 'Segera Pesan', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (14, 14, 3, 3, 3, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (15, 15, 5.2, 4, 4, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (16, 16, 1.6, 4, 4, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (17, 17, 3.4, 3, 3, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (18, 18, 0.6, 3, 3, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (19, 19, 0, 4, 4, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (20, 20, 2.3, 4, 4, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (21, 21, 0, 3, 3, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (22, 22, 3.2, 6, 7, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (23, 23, 0.2, 6, 6, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (24, 24, 3.8, 6, 6, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (25, 25, 0, 2, 2, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (26, 26, 1.4, 5, 5, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (27, 27, 3, 6, 7, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (28, 28, 3.2, 3, 4, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (29, 29, 1.6, 5, 5, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (30, 30, 0, 4, 4, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (31, 31, 4.3, 4, 5, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (32, 32, 0, 5, 5, 'Segera Pesan', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (33, 33, 0, 3, 3, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (34, 34, 1.2, 3, 3, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (35, 35, 1.5, 6, 6, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (36, 36, 1.2, 4, 4, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (37, 37, 0.8, 2, 2, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (38, 38, 2.8, 6, 6, 'Segera Pesan', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (39, 39, 0, 5, 5, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (40, 40, 2, 4, 4, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (41, 41, 0.7, 2, 2, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (42, 42, 1.5, 4, 4, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (43, 43, 0, 2, 2, 'Waspada', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (44, 44, 2.8, 5, 5, 'Aman', '2026-06-20 20:00:00');
INSERT INTO `inventory_controls` (`id_control`, `id_barang`, `hasil_regresi_linear`, `safety_stock`, `reorder_point`, `status_stok`, `diperbarui_pada`) VALUES (45, 45, 0.8, 3, 3, 'Segera Pesan', '2026-06-20 20:00:00');