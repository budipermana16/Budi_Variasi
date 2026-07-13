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

class ProductController extends Controller
{
    public function __construct(private InventoryAlgorithmService $algorithmService) {}

    public function index(): Response
    {
        $products = Product::with(['supplier', 'inventoryControl'])
            ->latest()
            ->get()
            ->map(fn($p) => [
                'id_barang'     => $p->id_barang,
                'nama_barang'   => $p->nama_barang,
                'kategori'      => $p->kategori,
                'harga_beli'    => $p->harga_beli,
                'harga_jual'    => $p->harga_jual,
                'stok_saat_ini' => $p->stok_saat_ini,
                'satuan'        => $p->satuan,
                'supplier'      => $p->supplier?->nama_supplier,
                'status_stok'   => $p->inventoryControl?->status_stok ?? 'Aman',
                'rop'           => $p->inventoryControl?->reorder_point ?? 0,
                'safety_stock'  => $p->inventoryControl?->safety_stock ?? 0,
            ]);

        return Inertia::render('Admin/Products/Index', [
            'products' => $products,
            'user'     => auth()->user()->only('name', 'role'),
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/Products/Form', [
            'suppliers' => Supplier::select('id_supplier', 'nama_supplier')->get(),
            'user'      => auth()->user()->only('name', 'role'),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'nama_barang'   => 'required|string|max:150',
            'kategori'      => 'required|string|max:80',
            'harga_beli'    => 'required|numeric|min:0',
            'harga_jual'    => 'required|numeric|min:0',
            'stok_saat_ini' => 'required|integer|min:0',
            'satuan'        => 'required|string|max:30',
            'id_supplier'   => 'nullable|exists:suppliers,id_supplier',
            'safety_stock'  => 'required|integer|min:0',
        ]);

        $product = Product::create($validated);

        // Buat record inventory_control awal
        InventoryControl::create([
            'id_barang'    => $product->id_barang,
            'safety_stock' => $validated['safety_stock'],
        ]);

        // Langsung hitung ROP untuk produk baru
        $this->algorithmService->processProduct($product->id_barang);

        return redirect()->route('admin.products.index')
            ->with('success', 'Produk berhasil ditambahkan.');
    }

    public function edit(Product $product): Response
    {
        return Inertia::render('Admin/Products/Form', [
            'product'   => array_merge($product->toArray(), [
                'safety_stock' => $product->inventoryControl?->safety_stock ?? 0,
            ]),
            'suppliers' => Supplier::select('id_supplier', 'nama_supplier')->get(),
            'user'      => auth()->user()->only('name', 'role'),
        ]);
    }

    public function update(Request $request, Product $product): RedirectResponse
    {
        $validated = $request->validate([
            'nama_barang'   => 'required|string|max:150',
            'kategori'      => 'required|string|max:80',
            'harga_beli'    => 'required|numeric|min:0',
            'harga_jual'    => 'required|numeric|min:0',
            'stok_saat_ini' => 'required|integer|min:0',
            'satuan'        => 'required|string|max:30',
            'id_supplier'   => 'nullable|exists:suppliers,id_supplier',
            'safety_stock'  => 'required|integer|min:0',
        ]);

        $product->update($validated);

        // Update safety stock di inventory_controls
        InventoryControl::updateOrCreate(
            ['id_barang' => $product->id_barang],
            ['safety_stock' => $validated['safety_stock']]
        );

        // ⚡ Recalculate ROP & status_stok LANGSUNG setelah stok/SS berubah
        $product->refresh(); // pastikan stok terbaru terbaca dari DB
        $this->algorithmService->processProduct($product->id_barang);

        return redirect()->route('admin.products.index')
            ->with('success', 'Produk berhasil diperbarui. Status stok diperbarui.');
    }

    public function destroy(Product $product): RedirectResponse
    {
        $product->delete();
        return redirect()->route('admin.products.index')
            ->with('success', 'Produk berhasil dihapus.');
    }
}
