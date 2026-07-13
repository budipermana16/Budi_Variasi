<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inventory_controls', function (Blueprint $table) {
            $table->id('id_control');
            $table->foreignId('id_barang')->unique()->constrained('products', 'id_barang')->cascadeOnDelete();
            $table->float('hasil_regresi_linear')->default(0)->comment('Prediksi penjualan Y periode berikutnya (unit/bulan)');
            $table->unsignedInteger('safety_stock')->default(0)->comment('Nilai SS - diinput manual oleh admin');
            $table->unsignedInteger('reorder_point')->default(0)->comment('Nilai ROP = (d * L) + SS');
            $table->enum('status_stok', ['Aman', 'Waspada', 'Segera Pesan'])->default('Aman');
            $table->timestamp('diperbarui_pada')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventory_controls');
    }
};
