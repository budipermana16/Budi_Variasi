<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Service;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class ServiceController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Admin/Services/Index', [
            'services' => Service::orderBy('id')->get(),
            'user'     => auth()->user()->only('name', 'role'),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title'       => 'required|string|max:100',
            'description' => 'nullable|string|max:500',
            'is_active'   => 'boolean',
            'sort_order'  => 'integer|min:0',
        ]);

        if ($request->hasFile('image')) {
            $request->validate([
                'image' => 'image|mimes:jpeg,png,jpg,gif,webp,svg|max:2048',
            ]);
            $file = $request->file('image');
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('images/services'), $filename);
            $validated['image'] = '/images/services/' . $filename;
        }

        Service::create($validated);

        return back()->with('success', 'Layanan berhasil ditambahkan.');
    }

    public function update(Request $request, Service $service): RedirectResponse
    {
        $validated = $request->validate([
            'title'       => 'required|string|max:100',
            'description' => 'nullable|string|max:500',
            'is_active'   => 'boolean',
            'sort_order'  => 'integer|min:0',
        ]);

        if ($request->hasFile('image')) {
            $request->validate([
                'image' => 'image|mimes:jpeg,png,jpg,gif,webp,svg|max:2048',
            ]);
            $file = $request->file('image');
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('images/services'), $filename);
            $validated['image'] = '/images/services/' . $filename;

            // Hapus gambar lama jika ada di server lokal
            if ($service->image && str_starts_with($service->image, '/images/services/') && file_exists(public_path($service->image))) {
                @unlink(public_path($service->image));
            }
        } elseif ($request->exists('image') && empty($request->input('image'))) {
            $validated['image'] = null;
            if ($service->image && str_starts_with($service->image, '/images/services/') && file_exists(public_path($service->image))) {
                @unlink(public_path($service->image));
            }
        }

        $service->update($validated);

        return back()->with('success', 'Layanan berhasil diperbarui.');
    }

    public function destroy(Service $service): RedirectResponse
    {
        $service->delete();
        return back()->with('success', 'Layanan berhasil dihapus.');
    }
}
