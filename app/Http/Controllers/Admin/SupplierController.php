<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Supplier;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class SupplierController extends Controller
{
    public function index(): Response
    {
        $suppliers = Supplier::withCount('products')->latest()->get();

        return Inertia::render('Admin/Suppliers/Index', [
            'suppliers' => $suppliers,
            'user'      => auth()->user()->only('name', 'role'),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'nama_supplier'      => 'required|string|max:100',
            'alamat'             => 'nullable|string',
            'kontak_person'      => 'nullable|string|max:100',
            'lead_time_rata_rata'=> 'required|integer|min:1|max:365',
        ]);

        Supplier::create($validated);

        return redirect()->route('admin.suppliers.index')
            ->with('success', 'Supplier berhasil ditambahkan.');
    }

    public function update(Request $request, Supplier $supplier): RedirectResponse
    {
        $validated = $request->validate([
            'nama_supplier'      => 'required|string|max:100',
            'alamat'             => 'nullable|string',
            'kontak_person'      => 'nullable|string|max:100',
            'lead_time_rata_rata'=> 'required|integer|min:1|max:365',
        ]);

        $supplier->update($validated);

        return redirect()->route('admin.suppliers.index')
            ->with('success', 'Supplier berhasil diperbarui.');
    }

    public function destroy(Supplier $supplier): RedirectResponse
    {
        $supplier->delete();
        return redirect()->route('admin.suppliers.index')
            ->with('success', 'Supplier berhasil dihapus.');
    }
}
