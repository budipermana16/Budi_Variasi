<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Barryvdh\DomPDF\Facade\Pdf;

class PurchaseOrderController extends Controller
{
    public function exportPdf(Product $product)
    {
        $product->load(['supplier', 'inventoryControl']);
        
        $data = [
            'product' => $product,
            'supplier' => $product->supplier,
            'inventoryControl' => $product->inventoryControl,
            'date' => now()->format('d F Y'),
            'po_number' => 'PO-' . now()->format('Ymd') . '-' . str_pad($product->id_barang, 4, '0', STR_PAD_LEFT),
        ];

        $pdf = Pdf::loadView('pdf.purchase_order', $data);

        return $pdf->stream('Purchase_Order_' . $data['po_number'] . '.pdf');
    }
}
