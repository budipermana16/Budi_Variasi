<?php

use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\InventoryReportController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\PurchaseController;
use App\Http\Controllers\Admin\RopSettingsController;
use App\Http\Controllers\Admin\SaleController;
use App\Http\Controllers\Admin\ServiceController;
use App\Http\Controllers\Admin\SupplierController;
use App\Http\Controllers\Admin\TestimonialController;
use App\Http\Controllers\Admin\InventoryStatusController;
use App\Http\Controllers\Admin\PurchaseOrderController;
use App\Http\Controllers\Auth\AdminAuthController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\ProfileController;
use App\Http\Controllers\LandingPageController;
use Illuminate\Support\Facades\Route;

// ─── Landing Page ──────────────────────────────────────────────────────────────
Route::get('/', [LandingPageController::class, 'index'])->name('home');

// ─── Auth ──────────────────────────────────────────────────────────────────────
Route::get('/admin/login', [AdminAuthController::class, 'showLogin'])->name('login')->middleware('guest');
Route::post('/admin/login', [AdminAuthController::class, 'login'])->name('admin.login.post');
Route::post('/admin/logout', [AdminAuthController::class, 'logout'])->name('admin.logout')->middleware('auth');

// ─── Admin Panel ───────────────────────────────────────────────────────────────
Route::prefix('admin')->name('admin.')->middleware(['auth'])->group(function () {

    // ─── Rute Bersama (Owner & Admin Gudang) ───
    Route::middleware(['role:owner,admin_gudang'])->group(function () {
        // Dashboard
        Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

        // Produk
        Route::resource('products', ProductController::class, [
            'parameters' => ['products' => 'product'],
        ])->except(['show']);
        Route::get('/products/{product}/edit', [ProductController::class, 'edit'])->name('products.edit');

        // Penjualan
        Route::get('/sales', [SaleController::class, 'index'])->name('sales.index');
        Route::get('/sales/create', [SaleController::class, 'create'])->name('sales.create');
        Route::post('/sales', [SaleController::class, 'store'])->name('sales.store');
        Route::delete('/sales/{sale}', [SaleController::class, 'destroy'])->name('sales.destroy');

        // Pembelian / Barang Masuk (dengan riwayat)
        Route::get('/purchases', [PurchaseController::class, 'index'])->name('purchases.index');
        Route::get('/purchases/create', [PurchaseController::class, 'create'])->name('purchases.create');
        Route::post('/purchases', [PurchaseController::class, 'store'])->name('purchases.store');
        Route::delete('/purchases/{purchase}', [PurchaseController::class, 'destroy'])->name('purchases.destroy');

        // Update Status On Order
        Route::put('/inventory/{inventoryControl}/status', [InventoryStatusController::class, 'update'])->name('inventory.status.update');

        // Cetak PDF PO
        Route::get('/purchase-order/{product}/pdf', [PurchaseOrderController::class, 'exportPdf'])->name('purchase-order.pdf');

        // Cetak Laporan Bulanan
        Route::get('/sales/monthly-report/pdf', [\App\Http\Controllers\Admin\MonthlyReportController::class, 'exportSalesPdf'])->name('sales.monthly-report.pdf');

        // Kelola Layanan Jasa (sinkron Landing Page)
        Route::get('/services', [ServiceController::class, 'index'])->name('services.index');
        Route::post('/services', [ServiceController::class, 'store'])->name('services.store');
        Route::put('/services/{service}', [ServiceController::class, 'update'])->name('services.update');
        Route::delete('/services/{service}', [ServiceController::class, 'destroy'])->name('services.destroy');

        // Halaman Profil Mandiri
        Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
        Route::put('/profile', [ProfileController::class, 'update'])->name('profile.update');
    });

    // ─── Rute Eksklusif (Owner Saja) ───
    Route::middleware(['role:owner'])->group(function () {
        // Supplier
        Route::get('/suppliers', [SupplierController::class, 'index'])->name('suppliers.index');
        Route::post('/suppliers', [SupplierController::class, 'store'])->name('suppliers.store');
        Route::put('/suppliers/{supplier}', [SupplierController::class, 'update'])->name('suppliers.update');
        Route::delete('/suppliers/{supplier}', [SupplierController::class, 'destroy'])->name('suppliers.destroy');

        // Laporan Inventory & ROP
        Route::get('/inventory/report', [InventoryReportController::class, 'index'])->name('inventory.report');
        Route::get('/inventory/settings', [RopSettingsController::class, 'index'])->name('inventory.settings');
        Route::put('/inventory/settings/{product}/safety-stock', [RopSettingsController::class, 'updateSafetyStock'])->name('inventory.settings.safety-stock');
        Route::post('/inventory/settings/recalculate-all', [RopSettingsController::class, 'recalculateAll'])->name('inventory.settings.recalculate');
        Route::get('/inventory/{product}', [InventoryReportController::class, 'show'])->name('inventory.show');

        // Kelola Testimoni
        Route::get('/testimonials', [TestimonialController::class, 'index'])->name('testimonials.index');
        Route::post('/testimonials', [TestimonialController::class, 'store'])->name('testimonials.store');
        Route::put('/testimonials/{testimonial}/toggle', [TestimonialController::class, 'toggleDisplay'])->name('testimonials.toggle');
        Route::delete('/testimonials/{testimonial}', [TestimonialController::class, 'destroy'])->name('testimonials.destroy');

        // Kelola User / Admin
        Route::get('/users', [UserController::class, 'index'])->name('users.index');
        Route::post('/users', [UserController::class, 'store'])->name('users.store');
        Route::put('/users/{user}', [UserController::class, 'update'])->name('users.update');
        Route::delete('/users/{user}', [UserController::class, 'destroy'])->name('users.destroy');
    });

});
