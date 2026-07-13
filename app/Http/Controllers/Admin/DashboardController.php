<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\InventoryControl;
use App\Models\Product;
use App\Models\Sale;
use App\Services\InventoryAlgorithmService;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function __construct(private InventoryAlgorithmService $algorithmService) {}

    public function index(): Response
    {
        // Jalankan proses algoritma setiap load dashboard
        $this->algorithmService->processAllProducts();

        $month = request('month', now()->month);
        $year = request('year', now()->year);

        $inventory = Product::with(['supplier', 'inventoryControl'])
            ->get()
            ->map(function ($product) {
                $ic = $product->inventoryControl;
                return [
                    'id_barang'            => $product->id_barang,
                    'nama_barang'          => $product->nama_barang,
                    'kategori'             => $product->kategori,
                    'stok_saat_ini'        => $product->stok_saat_ini,
                    'satuan'               => $product->satuan,
                    'prediksi_bulan_depan' => $ic ? round($ic->hasil_regresi_linear, 1) : 0,
                    'safety_stock'         => $ic ? $ic->safety_stock : 0,
                    'rop'                  => $ic ? $ic->reorder_point : 0,
                    'status_stok'          => $ic ? $ic->status_stok : 'Aman',
                    'id_control'           => $ic ? $ic->id_control : null,
                    'lead_time'            => $product->supplier?->lead_time_rata_rata ?? 7,
                    'diperbarui_pada'      => $ic?->diperbarui_pada?->format('d/m/Y H:i'),
                ];
            })
            ->sortBy(function ($item) {
                return match ($item['status_stok']) {
                    'Segera Pesan' => 0,
                    'Waspada'      => 1,
                    default        => 2,
                };
            })
            ->values();

        $stats = [
            'total_produk'    => Product::count(),
            'segera_pesan'    => InventoryControl::where('status_stok', 'Segera Pesan')->count(),
            'waspada'         => InventoryControl::where('status_stok', 'Waspada')->count(),
            'total_penjualan' => Sale::whereMonth('tanggal_keluar', $month)
                                     ->whereYear('tanggal_keluar', $year)
                                     ->sum('jumlah_terjual'),
        ];

        $monthlySales = \DB::table('sales')
            ->selectRaw('YEAR(tanggal_keluar) as tahun, MONTH(tanggal_keluar) as bulan, SUM(jumlah_terjual) as total_terjual')
            ->groupByRaw('YEAR(tanggal_keluar), MONTH(tanggal_keluar)')
            ->orderByRaw('tahun ASC, bulan ASC')
            ->get()
            ->map(function ($row) {
                $months = [
                    1 => '1', 2 => '2', 3 => '3', 4 => '4', 5 => '5', 6 => '6',
                    7 => '7', 8 => '8', 9 => '9', 10 => '10', 11 => '11', 12 => '12'
                ];
                $label = ($months[(int)$row->bulan] ?? $row->bulan) . '/' . $row->tahun;
                return [
                    'label' => $label,
                    'total_terjual' => (int) $row->total_terjual,
                ];
            });

        $chartData = [
            'badge' => 'Penjualan Bulanan',
            'title' => 'Grafik Penjualan Bulanan',
            'subtitle' => 'Grafik total transaksi penjualan semua produk per bulan.',
            'data' => $monthlySales->toArray(),
        ];

        return Inertia::render('Admin/Dashboard', [
            'inventory'    => $inventory,
            'stats'        => $stats,
            'chartData'    => $chartData,
            'user'         => auth()->user()->only('name', 'email', 'role'),
            'currentMonth' => (int) $month,
            'currentYear'  => (int) $year,
        ]);
    }
}
