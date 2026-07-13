<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Sale;
use App\Services\InventoryAlgorithmService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;
use Inertia\Response;

class SaleController extends Controller
{
    public function __construct(private InventoryAlgorithmService $algorithmService) {}

    public function index(): Response
    {
        $sales = Sale::with('product')
            ->latest('tanggal_keluar')
            ->paginate(20)
            ->through(fn($s) => [
                'id_penjualan'   => $s->id_penjualan,
                'nama_barang'    => $s->product?->nama_barang,
                'tanggal_keluar' => $s->tanggal_keluar->format('d/m/Y'),
                'jumlah_terjual' => $s->jumlah_terjual,
                'satuan'         => $s->product?->satuan,
                'total_harga'    => $s->total_harga,
            ]);

        return Inertia::render('Admin/Sales/Index', [
            'sales' => $sales,
            'user'  => auth()->user()->only('name', 'role'),
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/Sales/Create', [
            'products' => Product::select('id_barang', 'nama_barang', 'harga_jual', 'stok_saat_ini', 'satuan')->get(),
            'user'     => auth()->user()->only('name', 'role'),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'tanggal_keluar' => 'required|date',
            'items' => 'required|array|min:1',
            'items.*.id_barang' => 'required|exists:products,id_barang',
            'items.*.jumlah_terjual' => 'required|integer|min:1',
        ]);

        $errors = [];
        $productsToUpdate = [];

        foreach ($validated['items'] as $index => $item) {
            $product = Product::find($item['id_barang']);
            if (!$product) continue;

            $id = $product->id_barang;
            if (!isset($productsToUpdate[$id])) {
                $productsToUpdate[$id] = [
                    'product' => $product,
                    'requested_qty' => 0,
                    'indices' => []
                ];
            }
            $productsToUpdate[$id]['requested_qty'] += $item['jumlah_terjual'];
            $productsToUpdate[$id]['indices'][] = $index;
        }

        foreach ($productsToUpdate as $id => $data) {
            $product = $data['product'];
            if ($product->stok_saat_ini < $data['requested_qty']) {
                foreach ($data['indices'] as $idx) {
                    $errors["items.{$idx}.jumlah_terjual"] = "Stok tidak cukup. Stok tersedia: {$product->stok_saat_ini} {$product->satuan}. Total diminta: {$data['requested_qty']} {$product->satuan}.";
                }
            }
        }

        if (!empty($errors)) {
            return back()->withErrors($errors);
        }

        \DB::transaction(function() use ($validated) {
            foreach ($validated['items'] as $item) {
                $product = Product::findOrFail($item['id_barang']);

                Sale::create([
                    'id_barang'      => $item['id_barang'],
                    'tanggal_keluar' => $validated['tanggal_keluar'],
                    'jumlah_terjual' => $item['jumlah_terjual'],
                    'total_harga'    => $product->harga_jual * $item['jumlah_terjual'],
                ]);

                // Kurangi stok produk secara otomatis
                $product->decrement('stok_saat_ini', $item['jumlah_terjual']);

                // ⚡ Recalculate ROP & status_stok LANGSUNG setelah stok berkurang
                $this->algorithmService->processProduct($product->id_barang);

                // 🚨 Telegram EWS Alert
                $product->refresh();
                $ic = $product->inventoryControl;

                if ($ic && $product->stok_saat_ini <= $ic->reorder_point && $ic->status_stok !== 'Dalam Pemesanan') {
                    
                    // Pastikan status menjadi Segera Pesan
                    $ic->update(['status_stok' => 'Segera Pesan']);

                    $token = env('TELEGRAM_BOT_TOKEN');
                    $chatId = env('TELEGRAM_CHAT_ID');

                    if ($token && $chatId && $chatId !== 'ISI_DENGAN_CHAT_ID_TELEGRAM_USER') {
                        $message = "🚨 *PERINGATAN STOK KRITIS* 🚨\n\n"
                                 . "Barang: *{$product->nama_barang}*\n"
                                 . "Sisa Stok: *{$product->stok_saat_ini} {$product->satuan}*\n"
                                 . "Batas ROP: *{$ic->reorder_point} {$product->satuan}*\n\n"
                                 . "⚠️ _Stok telah menyentuh atau berada di bawah batas Reorder Point. Harap segera lakukan pemesanan (Purchase Order) ke Supplier._";

                        try {
                            // Gunakan Http::post agar request berhasil terkirim sebelum script mati
                            \Illuminate\Support\Facades\Http::post("https://api.telegram.org/bot{$token}/sendMessage", [
                                'chat_id'    => $chatId,
                                'text'       => $message,
                                'parse_mode' => 'Markdown',
                            ]);
                        } catch (\Exception $e) {
                            \Illuminate\Support\Facades\Log::error("Gagal mengirim Telegram Alert: " . $e->getMessage());
                        }
                    }
                }
            }
        });

        return redirect()->route('admin.sales.index')
            ->with('success', 'Penjualan berhasil dicatat. Stok & status ROP diperbarui.');
    }

    public function destroy(Sale $sale): RedirectResponse
    {
        $product = $sale->product;
        $jumlahDikembalikan = $sale->jumlah_terjual;

        // Hapus histori data penjualan
        $sale->delete();

        // Kembalikan stok fisik produk (increment)
        if ($product) {
            $product->increment('stok_saat_ini', $jumlahDikembalikan);
            
            // Recalculate prediksi & ROP setelah stok kembali (agar status Waspada/Segera Pesan bisa kembali Aman)
            $this->algorithmService->processProduct($product->id_barang);
        }

        return redirect()->route('admin.sales.index')
            ->with('success', 'Transaksi penjualan dibatalkan. Histori dihapus dan Stok berhasil dipulihkan.');
    }
}
