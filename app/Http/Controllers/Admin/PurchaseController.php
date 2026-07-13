<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Purchase;
use App\Models\Supplier;
use App\Services\InventoryAlgorithmService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class PurchaseController extends Controller
{
    public function __construct(private InventoryAlgorithmService $algorithmService) {}

    public function index(): Response
    {
        $purchases = Purchase::with(['product:id_barang,nama_barang,satuan', 'supplier:id_supplier,nama_supplier'])
            ->orderByDesc('tanggal_masuk')
            ->paginate(20);

        return Inertia::render('Admin/Purchases/Index', [
            'purchases' => $purchases,
            'user'      => auth()->user()->only('name', 'role'),
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/Purchases/Create', [
            'products'  => Product::select('id_barang', 'nama_barang', 'satuan', 'stok_saat_ini')->get(),
            'suppliers' => Supplier::select('id_supplier', 'nama_supplier')->get(),
            'user'      => auth()->user()->only('name', 'role'),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'tanggal_masuk' => 'required|date',
            'id_supplier'   => 'nullable|exists:suppliers,id_supplier',
            'items'         => 'required|array|min:1',
            'items.*.id_barang'    => 'required|exists:products,id_barang',
            'items.*.jumlah_masuk' => 'required|integer|min:1',
        ]);

        \DB::transaction(function() use ($validated) {
            foreach ($validated['items'] as $item) {
                Purchase::create([
                    'id_barang'     => $item['id_barang'],
                    'id_supplier'   => $validated['id_supplier'],
                    'tanggal_masuk' => $validated['tanggal_masuk'],
                    'jumlah_masuk'  => $item['jumlah_masuk'],
                ]);

                // Tambah stok produk secara otomatis
                Product::find($item['id_barang'])->increment('stok_saat_ini', $item['jumlah_masuk']);

                // ⚡ Recalculate ROP & status_stok LANGSUNG setelah stok bertambah
                $this->algorithmService->processProduct((int) $item['id_barang']);
            }
        });

        return redirect()->route('admin.purchases.index')
            ->with('success', 'Barang masuk berhasil dicatat. Stok & status ROP diperbarui.');
    }

    public function destroy(Purchase $purchase): RedirectResponse
    {
        // Kembalikan stok sebelum hapus
        Product::find($purchase->id_barang)->decrement('stok_saat_ini', $purchase->jumlah_masuk);

        // Recalculate ROP setelah stok dikembalikan
        $this->algorithmService->processProduct((int) $purchase->id_barang);

        $purchase->delete();

        return back()->with('success', 'Data barang masuk dihapus. Stok dikembalikan.');
    }
}
