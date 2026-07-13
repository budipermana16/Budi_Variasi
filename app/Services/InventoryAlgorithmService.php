<?php

namespace App\Services;

use App\Models\InventoryControl;
use App\Models\Product;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;

class InventoryAlgorithmService
{
    /**
     * Mengambil data penjualan historis per bulan untuk satu produk.
     * Setiap baris = total penjualan satu bulan = satu titik data regresi (X, Y).
     */
    public function getHistoricalSalesData(int $productId): array
    {
        $currentMonth = Carbon::now()->month;
        $currentYear = Carbon::now()->year;

        $rows = DB::table('sales')
            ->selectRaw('YEAR(tanggal_keluar) as tahun, MONTH(tanggal_keluar) as bulan, SUM(jumlah_terjual) as total_terjual')
            ->where('id_barang', $productId)
            ->where(function ($query) use ($currentMonth, $currentYear) {
                $query->whereRaw('YEAR(tanggal_keluar) < ?', [$currentYear])
                      ->orWhere(function ($q) use ($currentMonth, $currentYear) {
                          $q->whereRaw('YEAR(tanggal_keluar) = ?', [$currentYear])
                            ->whereRaw('MONTH(tanggal_keluar) < ?', [$currentMonth]);
                      });
            })
            ->groupByRaw('YEAR(tanggal_keluar), MONTH(tanggal_keluar)')
            ->orderByRaw('tahun ASC, bulan ASC')
            ->get();

        return $rows->values()->map(function ($row, $index) {
            return [
                'periode'       => $index + 1,   // X: periode ke-1, ke-2, ...
                'total_terjual' => (int) $row->total_terjual,  // Y
                'label'         => $row->bulan . '/' . $row->tahun,
            ];
        })->toArray();
    }

    /**
     * Menghitung koefisien Regresi Linear Sederhana.
     *
     * b = (n*ΣXY - ΣX*ΣY) / (n*ΣX² - (ΣX)²)
     * a = (ΣY - b*ΣX) / n
     * Y' = a + b*(n+1)
     */
    public function calculateLinearRegression(array $data): array
    {
        $n = count($data);

        if ($n < 2) {
            return ['error' => 'Data historis tidak cukup (minimal 2 bulan).'];
        }

        $sumX  = 0;
        $sumY  = 0;
        $sumXY = 0;
        $sumX2 = 0;

        foreach ($data as $row) {
            $x = $row['periode'];
            $y = $row['total_terjual'];
            $sumX  += $x;
            $sumY  += $y;
            $sumXY += ($x * $y);
            $sumX2 += ($x * $x);
        }

        $denominator = ($n * $sumX2) - ($sumX * $sumX);

        if ($denominator == 0) {
            return ['error' => 'Tidak dapat menghitung regresi: denominator = 0.'];
        }

        $b = (($n * $sumXY) - ($sumX * $sumY)) / $denominator;
        $a = ($sumY - ($b * $sumX)) / $n;

        $xPrediksi = $n + 1;
        $yPrediksi = max(0, round($a + ($b * $xPrediksi), 4));

        return [
            'n'            => $n,
            'a'            => round($a, 4),
            'b'            => round($b, 4),
            'sum_x'        => $sumX,
            'sum_y'        => $sumY,
            'sum_xy'       => $sumXY,
            'sum_x2'       => $sumX2,
            'persamaan'    => 'Y = ' . round($a, 4) . ' + ' . round($b, 4) . 'X',
            'x_prediksi'   => $xPrediksi,
            'y_prediksi'   => $yPrediksi,
            'data'         => $data,
        ];
    }

    /**
     * Menghitung Reorder Point (ROP).
     *
     * d   = Y' / 30  (rata-rata permintaan per hari, asumsi 30 hari/bulan)
     * ROP = (d * L) + SS
     */
    public function calculateROP(float $yPredicted, int $leadTime, int $safetyStock): array
    {
        $d   = $yPredicted / 30;
        $rop = ($d * $leadTime) + $safetyStock;

        return [
            'd'            => round($d, 4),
            'lead_time'    => $leadTime,
            'safety_stock' => $safetyStock,
            'rop'          => (int) ceil($rop),
        ];
    }

    /**
     * Menentukan status stok:
     *   stok <= ROP        → "Segera Pesan"
     *   stok <= ROP * 1.5  → "Waspada"
     *   stok > ROP * 1.5   → "Aman"
     */
    public function determineStockStatus(int $currentStock, int $rop, string $currentStatus = null): string
    {
        // Jika sudah dipesan dan stok belum melebihi ROP, tahan statusnya
        if ($currentStatus === 'Dalam Pemesanan' && $currentStock <= $rop) {
            return 'Dalam Pemesanan';
        }

        if ($currentStock <= $rop) {
            return 'Segera Pesan';
        } elseif ($currentStock <= (int) ceil($rop * 1.5)) {
            return 'Waspada';
        }
        return 'Aman';
    }

    /**
     * Menjalankan seluruh proses algoritma untuk SATU produk
     * dan menyimpan hasilnya ke tabel inventory_controls.
     *
     * Safety stock TIDAK ditimpa — nilai manual admin terlindungi.
     */
    public function processProduct(int $productId): array
    {
        $product = Product::with(['supplier', 'inventoryControl'])->find($productId);

        if (! $product) {
            return ['status' => 'error', 'pesan' => 'Produk tidak ditemukan.'];
        }

        // Langkah 1: Regresi Linear
        $historicalData = $this->getHistoricalSalesData($productId);
        $regression     = $this->calculateLinearRegression($historicalData);

        if (isset($regression['error'])) {
            return ['status' => 'error', 'id_barang' => $productId, 'pesan' => $regression['error']];
        }

        $yPredicted = $regression['y_prediksi'];

        // Langkah 2: Ambil Safety Stock & Lead Time
        $ic           = $product->inventoryControl;
        $safetyStock  = $ic ? $ic->safety_stock : 0;
        $leadTime     = $product->supplier ? $product->supplier->lead_time_rata_rata : 7;

        // Langkah 3: Hitung ROP
        $ropResult    = $this->calculateROP($yPredicted, $leadTime, $safetyStock);
        $rop          = $ropResult['rop'];

        // Langkah 4: Tentukan status stok
        $currentStatus = $ic ? $ic->status_stok : null;
        $statusStok = $this->determineStockStatus($product->stok_saat_ini, $rop, $currentStatus);

        // Langkah 5: Simpan ke DB (upsert agar aman untuk insert & update)
        InventoryControl::updateOrCreate(
            ['id_barang' => $productId],
            [
                'hasil_regresi_linear' => $yPredicted,
                'reorder_point'        => $rop,
                'status_stok'          => $statusStok,
                'diperbarui_pada'      => Carbon::now(),
                // safety_stock TIDAK diupdate secara otomatis
            ]
        );

        return [
            'status'        => 'success',
            'id_barang'     => $productId,
            'nama_barang'   => $product->nama_barang,
            'regresi'       => $regression,
            'rop_detail'    => $ropResult,
            'stok_saat_ini' => $product->stok_saat_ini,
            'status_stok'   => $statusStok,
        ];
    }

    /**
     * Menjalankan proses algoritma untuk SEMUA produk.
     * Dipanggil saat load dashboard atau via scheduled job.
     */
    public function processAllProducts(): array
    {
        $products = Product::all();

        $results       = [];
        $successCount  = 0;
        $errorCount    = 0;
        $alertCount    = 0;

        foreach ($products as $product) {
            $result  = $this->processProduct($product->id_barang);
            $results[] = $result;

            if ($result['status'] === 'success') {
                $successCount++;
                if ($result['status_stok'] === 'Segera Pesan') {
                    $alertCount++;
                }
            } else {
                $errorCount++;
            }
        }

        return [
            'waktu_proses'       => Carbon::now()->toDateTimeString(),
            'total_produk'       => $products->count(),
            'sukses'             => $successCount,
            'error'              => $errorCount,
            'perlu_segera_pesan' => $alertCount,
            'detail'             => $results,
        ];
    }
}
