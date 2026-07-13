<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\InventoryControl;
use Illuminate\Http\Request;

class InventoryStatusController extends Controller
{
    public function update(Request $request, InventoryControl $inventoryControl)
    {
        $validated = $request->validate([
            'status_stok' => 'required|in:Aman,Waspada,Segera Pesan,Dalam Pemesanan'
        ]);

        $inventoryControl->update([
            'status_stok' => $validated['status_stok']
        ]);

        return back()->with('success', 'Status stok berhasil diperbarui.');
    }
}
