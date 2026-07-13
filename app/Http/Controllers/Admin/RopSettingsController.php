<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\InventoryControl;
use App\Models\Product;
use App\Models\Supplier;
use App\Services\InventoryAlgorithmService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class RopSettingsController extends Controller
{
    public function __construct(private InventoryAlgorithmService $algorithmService) {}

    public function index(): Response
    {
        $products = Product::with(['supplier:id_supplier,nama_supplier,lead_time_rata_rata', 'inventoryControl'])
            ->select('id_barang', 'nama_barang', 'kategori', 'satuan', 'id_supplier')
            ->get()
            ->map(fn($p) => [
                'id_barang'    => $p->id_barang,
                'nama_barang'  => $p->nama_barang,
                'kategori'     => $p->kategori,
                'satuan'       => $p->satuan,
                'safety_stock' => $p->inventoryControl?->safety_stock ?? 0,
                'lead_time'    => $p->supplier?->lead_time_rata_rata ?? 0,
                'rop'          => $p->inventoryControl?->reorder_point ?? 0,
                'status_stok'  => $p->inventoryControl?->status_stok ?? 'Aman',
                'nama_supplier'=> $p->supplier?->nama_supplier ?? '—',
                'id_supplier'  => $p->id_supplier,
            ]);

        $suppliers = Supplier::select('id_supplier', 'nama_supplier', 'lead_time_rata_rata')->get();

        return Inertia::render('Admin/Inventory/Settings', [
            'products'  => $products,
            'suppliers' => $suppliers,
            'user'      => auth()->user()->only('name', 'role'),
        ]);
    }

    public function updateSafetyStock(Request $request, Product $product): RedirectResponse
    {
        $validated = $request->validate([
            'safety_stock' => 'required|integer|min:0',
        ]);

        // Update di tabel inventory_controls
        InventoryControl::updateOrCreate(
            ['id_barang' => $product->id_barang],
            ['safety_stock' => $validated['safety_stock']]
        );

        // Recalculate ROP setelah safety stock diubah
        $this->algorithmService->processProduct($product->id_barang);

        return back()->with('success', "Safety Stock {$product->nama_barang} diperbarui & ROP dihitung ulang.");
    }

    public function recalculateAll(): RedirectResponse
    {
        $products = Product::all();
        foreach ($products as $product) {
            $this->algorithmService->processProduct($product->id_barang);
        }

        return back()->with('success', 'Semua nilai ROP berhasil dihitung ulang.');
    }
}
