<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Testimonial;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class TestimonialController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Admin/Testimonials/Index', [
            'testimonials' => Testimonial::orderByDesc('created_at')->get(),
            'user'         => auth()->user()->only('name', 'role'),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name'        => 'required|string|max:100',
            'review_text' => 'required|string|max:1000',
            'rating'      => 'required|integer|min:1|max:5',
            'is_displayed'=> 'boolean',
        ]);

        Testimonial::create($validated);

        return back()->with('success', 'Testimoni berhasil ditambahkan.');
    }

    public function toggleDisplay(Testimonial $testimonial): RedirectResponse
    {
        $testimonial->update(['is_displayed' => !$testimonial->is_displayed]);

        return back()->with('success', $testimonial->is_displayed
            ? 'Testimoni ditampilkan di Landing Page.'
            : 'Testimoni disembunyikan dari Landing Page.');
    }

    public function destroy(Testimonial $testimonial): RedirectResponse
    {
        $testimonial->delete();
        return back()->with('success', 'Testimoni berhasil dihapus.');
    }
}
