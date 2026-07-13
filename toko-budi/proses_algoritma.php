<?php
/**
 * proses_algoritma.php
 * =====================================================================
 * Core engine untuk kalkulasi Regresi Linear dan Reorder Point (ROP).
 *
 * CARA PENGGUNAAN:
 * - Include file ini di halaman manapun yang membutuhkan perhitungan.
 * - Panggil jalankanProsesAlgoritma() untuk memproses SEMUA barang.
 * - Panggil hitungRegresiDanROP($id_barang) untuk barang tertentu.
 *
 * Lokasi: laragon/www/toko-budi/proses_algoritma.php
 * =====================================================================
 */

require_once __DIR__ . '/config.php';


// ====================================================================
// BAGIAN 1: REGRESI LINEAR SEDERHANA
// ====================================================================

/**
 * Mengambil data penjualan historis per bulan dari database untuk
 * satu barang tertentu, lalu mengembalikannya sebagai array.
 *
 * Teknik agregasi: GROUP BY tahun & bulan, ORDER BY waktu ASC.
 * Setiap baris hasil = data satu bulan (satu titik data regresi).
 *
 * @param int $id_barang
 * @return array  Array of ['periode' => int, 'total_terjual' => int, 'label' => string]
 */
function getDataHistorisPenjualan(int $id_barang): array
{
    $pdo = getPDO();

    $sql = "
        SELECT
            YEAR(tanggal_keluar)  AS tahun,
            MONTH(tanggal_keluar) AS bulan,
            SUM(jumlah_terjual)   AS total_terjual
        FROM sales
        WHERE id_barang = :id_barang
        GROUP BY YEAR(tanggal_keluar), MONTH(tanggal_keluar)
        ORDER BY tahun ASC, bulan ASC
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([':id_barang' => $id_barang]);
    $rows = $stmt->fetchAll();

    // Assign nomor periode (X = 1, 2, 3, ..., n) ke setiap baris
    $data = [];
    foreach ($rows as $urutan => $row) {
        $data[] = [
            'periode'       => $urutan + 1,                           // X
            'total_terjual' => (int) $row['total_terjual'],           // Y
            'label'         => $row['bulan'] . '/' . $row['tahun'],   // Untuk tampilan tabel
        ];
    }

    return $data;
}

/**
 * Menghitung nilai koefisien Regresi Linear Sederhana (a dan b).
 *
 * Rumus:
 *   b = (n*ΣXY - ΣX*ΣY) / (n*ΣX² - (ΣX)²)
 *   a = (ΣY - b*ΣX) / n
 *   Y' = a + b*X   (Prediksi untuk periode X berikutnya)
 *
 * @param array $data  Output dari getDataHistorisPenjualan()
 * @return array       Hasil lengkap atau ['error' => string] jika data kurang.
 */
function hitungRegresiLinear(array $data): array
{
    $n = count($data);

    if ($n < 2) {
        return ['error' => 'Data penjualan historis tidak cukup (minimal 2 bulan).'];
    }

    $sum_x  = 0;
    $sum_y  = 0;
    $sum_xy = 0;
    $sum_x2 = 0;

    foreach ($data as $row) {
        $x = $row['periode'];
        $y = $row['total_terjual'];

        $sum_x  += $x;
        $sum_y  += $y;
        $sum_xy += ($x * $y);
        $sum_x2 += ($x * $x);
    }

    // Cegah pembagian dengan nol
    $denominator = ($n * $sum_x2) - ($sum_x * $sum_x);
    if ($denominator == 0) {
        return ['error' => 'Tidak dapat menghitung regresi: denominator = 0 (nilai X identik).'];
    }

    // Hitung koefisien b dan a
    $b = (($n * $sum_xy) - ($sum_x * $sum_y)) / $denominator;
    $a = ($sum_y - ($b * $sum_x)) / $n;

    // Prediksi untuk periode BERIKUTNYA (X = n+1)
    $x_prediksi = $n + 1;
    $y_prediksi = $a + ($b * $x_prediksi);

    // Penjualan tidak mungkin negatif
    $y_prediksi = max(0, round($y_prediksi, 4));

    return [
        'n'           => $n,
        'a'           => round($a, 4),
        'b'           => round($b, 4),
        'sum_x'       => $sum_x,
        'sum_y'       => $sum_y,
        'sum_xy'      => $sum_xy,
        'sum_x2'      => $sum_x2,
        'x_prediksi'  => $x_prediksi,
        'y_prediksi'  => $y_prediksi,   // Y' = Prediksi unit terjual bulan depan
        'data'        => $data,          // Data asli untuk ditampilkan di tabel
    ];
}


// ====================================================================
// BAGIAN 2: PERHITUNGAN REORDER POINT (ROP)
// ====================================================================

/**
 * Mengambil Safety Stock dan Lead Time untuk satu barang.
 *
 * @param int $id_barang
 * @return array|null
 */
function getDataPendukungROP(int $id_barang): ?array
{
    $pdo = getPDO();

    $sql = "
        SELECT
            ic.safety_stock,
            s.lead_time_rata_rata AS lead_time
        FROM inventory_controls ic
        JOIN products p ON ic.id_barang = p.id_barang
        LEFT JOIN suppliers s ON p.id_supplier = s.id_supplier
        WHERE ic.id_barang = :id_barang
        LIMIT 1
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([':id_barang' => $id_barang]);
    $row = $stmt->fetch();

    return $row ?: null;
}

/**
 * Menghitung nilai Reorder Point (ROP).
 *
 * Rumus:
 *   d   = Y' / 30        (Rata-rata permintaan per hari)
 *   ROP = (d * L) + SS
 *
 * @param float $y_prediksi    Hasil prediksi regresi (unit/bulan)
 * @param int   $lead_time     Nilai L dari tabel suppliers (hari)
 * @param int   $safety_stock  Nilai SS dari inventory_controls
 * @return array
 */
function hitungROP(float $y_prediksi, int $lead_time, int $safety_stock): array
{
    $d   = $y_prediksi / 30;
    $rop = ($d * $lead_time) + $safety_stock;

    return [
        'd'            => round($d, 4),
        'lead_time'    => $lead_time,
        'safety_stock' => $safety_stock,
        'rop'          => (int) ceil($rop),  // Bulatkan ke atas (konservatif)
    ];
}

/**
 * Menentukan status stok berdasarkan perbandingan stok saat ini vs ROP.
 *
 * Logika:
 *   - stok <= ROP        : "Segera Pesan"
 *   - stok <= ROP * 1.5  : "Waspada"
 *   - stok > ROP * 1.5   : "Aman"
 *
 * @param int $stok_saat_ini
 * @param int $rop
 * @return string  Nilai ENUM: 'Aman' | 'Waspada' | 'Segera Pesan'
 */
function menentukanStatusStok(int $stok_saat_ini, int $rop): string
{
    if ($stok_saat_ini <= $rop) {
        return 'Segera Pesan';
    } elseif ($stok_saat_ini <= (int) ceil($rop * 1.5)) {
        return 'Waspada';
    } else {
        return 'Aman';
    }
}


// ====================================================================
// BAGIAN 3: FUNGSI INTI - PROSES & SIMPAN KE DATABASE
// ====================================================================

/**
 * Menjalankan seluruh proses algoritma (Regresi + ROP) untuk satu barang,
 * lalu menyimpan hasilnya ke tabel inventory_controls.
 *
 * Menggunakan INSERT ... ON DUPLICATE KEY UPDATE agar aman untuk
 * insert pertama maupun update berikutnya.
 *
 * CATATAN: safety_stock TIDAK diupdate secara otomatis di sini,
 * agar nilai manual yang diinput admin tidak tertimpa.
 *
 * @param int $id_barang
 * @return array  Hasil kalkulasi lengkap atau array dengan kunci 'error'.
 */
function hitungRegresiDanROP(int $id_barang): array
{
    $pdo = getPDO();

    // --- Langkah 1: Ambil dan hitung Regresi Linear ---
    $data_historis = getDataHistorisPenjualan($id_barang);
    $hasil_regresi = hitungRegresiLinear($data_historis);

    if (isset($hasil_regresi['error'])) {
        return [
            'id_barang' => $id_barang,
            'status'    => 'error',
            'pesan'     => $hasil_regresi['error'],
        ];
    }

    $y_prediksi = $hasil_regresi['y_prediksi'];

    // --- Langkah 2: Ambil data pendukung ROP ---
    $data_rop     = getDataPendukungROP($id_barang);
    $safety_stock = $data_rop ? (int) $data_rop['safety_stock'] : 0;
    $lead_time    = $data_rop ? (int) ($data_rop['lead_time'] ?? 7) : 7;

    // --- Langkah 3: Hitung ROP ---
    $hasil_rop = hitungROP($y_prediksi, $lead_time, $safety_stock);
    $rop       = $hasil_rop['rop'];

    // --- Langkah 4: Ambil stok saat ini ---
    $stmt_stok = $pdo->prepare("SELECT stok_saat_ini FROM products WHERE id_barang = :id");
    $stmt_stok->execute([':id' => $id_barang]);
    $stok_saat_ini = (int) ($stmt_stok->fetchColumn() ?? 0);

    // --- Langkah 5: Tentukan status stok ---
    $status_stok = menentukanStatusStok($stok_saat_ini, $rop);

    // --- Langkah 6: Simpan/Update ke tabel inventory_controls ---
    $sql_upsert = "
        INSERT INTO inventory_controls
            (id_barang, hasil_regresi_linear, safety_stock, reorder_point, status_stok)
        VALUES
            (:id_barang, :hasil_regresi, :safety_stock, :rop, :status)
        ON DUPLICATE KEY UPDATE
            hasil_regresi_linear = VALUES(hasil_regresi_linear),
            reorder_point        = VALUES(reorder_point),
            status_stok          = VALUES(status_stok),
            diperbarui_pada      = CURRENT_TIMESTAMP
    ";

    $stmt_save = $pdo->prepare($sql_upsert);
    $stmt_save->execute([
        ':id_barang'     => $id_barang,
        ':hasil_regresi' => $y_prediksi,
        ':safety_stock'  => $safety_stock,
        ':rop'           => $rop,
        ':status'        => $status_stok,
    ]);

    // --- Langkah 7: Kembalikan seluruh hasil ---
    return [
        'id_barang'     => $id_barang,
        'status'        => 'success',
        'regresi'       => [
            'n'             => $hasil_regresi['n'],
            'a'             => $hasil_regresi['a'],
            'b'             => $hasil_regresi['b'],
            'persamaan'     => "Y = {$hasil_regresi['a']} + {$hasil_regresi['b']}X",
            'x_prediksi'    => $hasil_regresi['x_prediksi'],
            'y_prediksi'    => $y_prediksi,
            'data_historis' => $hasil_regresi['data'],
        ],
        'rop_detail'    => [
            'd'            => $hasil_rop['d'],
            'lead_time'    => $lead_time,
            'safety_stock' => $safety_stock,
            'rop'          => $rop,
        ],
        'stok_saat_ini' => $stok_saat_ini,
        'status_stok'   => $status_stok,
    ];
}

/**
 * Menjalankan proses algoritma untuk SEMUA barang di database.
 * Cocok dipanggil saat load dashboard atau via cron job.
 *
 * @return array  Ringkasan hasil proses semua barang.
 */
function jalankanProsesAlgoritma(): array
{
    $pdo = getPDO();

    $stmt         = $pdo->query("SELECT id_barang, nama_barang FROM products ORDER BY id_barang ASC");
    $semua_barang = $stmt->fetchAll();

    $hasil_semua   = [];
    $jumlah_sukses = 0;
    $jumlah_error  = 0;
    $perlu_pesan   = 0;

    foreach ($semua_barang as $barang) {
        $hasil                  = hitungRegresiDanROP((int) $barang['id_barang']);
        $hasil['nama_barang']   = $barang['nama_barang'];
        $hasil_semua[]          = $hasil;

        if ($hasil['status'] === 'success') {
            $jumlah_sukses++;
            if ($hasil['status_stok'] === 'Segera Pesan') {
                $perlu_pesan++;
            }
        } else {
            $jumlah_error++;
        }
    }

    return [
        'waktu_proses'       => date('Y-m-d H:i:s'),
        'total_barang'       => count($semua_barang),
        'sukses'             => $jumlah_sukses,
        'error'              => $jumlah_error,
        'perlu_segera_pesan' => $perlu_pesan,
        'detail'             => $hasil_semua,
    ];
}


// ====================================================================
// BAGIAN 4: FUNGSI QUERY HELPER
// ====================================================================

/**
 * Mengambil semua data inventory control + info barang + supplier
 * untuk ditampilkan di tabel dashboard utama.
 * Diurutkan: Segera Pesan > Waspada > Aman.
 *
 * @return array
 */
function getDashboardInventory(): array
{
    $pdo = getPDO();

    $sql = "
        SELECT
            p.id_barang,
            p.nama_barang,
            p.kategori,
            p.stok_saat_ini,
            p.satuan,
            ic.hasil_regresi_linear AS prediksi_bulan_depan,
            ic.safety_stock,
            ic.reorder_point        AS rop,
            ic.status_stok,
            ic.diperbarui_pada,
            s.lead_time_rata_rata   AS lead_time
        FROM products p
        LEFT JOIN inventory_controls ic ON p.id_barang = ic.id_barang
        LEFT JOIN suppliers s ON p.id_supplier = s.id_supplier
        ORDER BY
            CASE ic.status_stok
                WHEN 'Segera Pesan' THEN 1
                WHEN 'Waspada'      THEN 2
                WHEN 'Aman'         THEN 3
                ELSE 4
            END ASC,
            p.nama_barang ASC
    ";

    return $pdo->query($sql)->fetchAll();
}

/**
 * Mendapatkan jumlah barang yang berstatus 'Segera Pesan'
 * untuk notifikasi badge di navbar/dashboard.
 *
 * @return int
 */
function getJumlahAlertAktif(): int
{
    $pdo  = getPDO();
    $stmt = $pdo->query("SELECT COUNT(*) FROM inventory_controls WHERE status_stok = 'Segera Pesan'");
    return (int) $stmt->fetchColumn();
}
