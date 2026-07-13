<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Services\InventoryAlgorithmService;
use Inertia\Inertia;
use Inertia\Response;

class InventoryReportController extends Controller
{
    public function __construct(private InventoryAlgorithmService $algorithmService) {}

    /**
     * Laporan ROP semua produk (ringkasan tabel).
     */
    public function index(): Response
    {
        $products = Product::with(['supplier', 'inventoryControl'])->get();

        $report = $products->map(function ($product) {
            $result = $this->algorithmService->processProduct($product->id_barang);
            return [
                'id_barang'    => $product->id_barang,
                'nama_barang'  => $product->nama_barang,
                'kategori'     => $product->kategori,
                'n'            => $result['regresi']['n']          ?? 0,
                'a'            => $result['regresi']['a']          ?? 0,
                'b'            => $result['regresi']['b']          ?? 0,
                'persamaan'    => $result['regresi']['persamaan']  ?? '-',
                'y_prediksi'   => $result['regresi']['y_prediksi'] ?? 0,
                'd'            => $result['rop_detail']['d']            ?? 0,
                'lead_time'    => $result['rop_detail']['lead_time']    ?? 0,
                'safety_stock' => $result['rop_detail']['safety_stock'] ?? 0,
                'rop'          => $result['rop_detail']['rop']          ?? 0,
                'stok_saat_ini'=> $product->stok_saat_ini,
                'satuan'       => $product->satuan,
                'status_stok'  => $result['status_stok'] ?? 'Aman',
                'error'        => $result['pesan'] ?? null,
            ];
        });

        return Inertia::render('Admin/Inventory/Report', [
            'report' => $report,
            'user'   => auth()->user()->only('name', 'role'),
        ]);
    }

    /**
     * Detail perhitungan regresi per produk + tabel data historis.
     */
    public function show(Product $product): Response
    {
        $result = $this->algorithmService->processProduct($product->id_barang);

        return Inertia::render('Admin/Inventory/Detail', [
            'product' => [
                'id_barang'    => $product->id_barang,
                'nama_barang'  => $product->nama_barang,
                'kategori'     => $product->kategori,
                'satuan'       => $product->satuan,
                'stok_saat_ini'=> $product->stok_saat_ini,
                'supplier'     => $product->supplier?->nama_supplier,
            ],
            'result' => $result,
            'user'   => auth()->user()->only('name', 'role'),
        ]);
    }
}
