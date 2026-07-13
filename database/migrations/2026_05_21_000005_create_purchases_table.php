<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('purchases', function (Blueprint $table) {
            $table->id('id_pembelian');
            $table->foreignId('id_barang')->constrained('products', 'id_barang')->cascadeOnDelete();
            $table->foreignId('id_supplier')->nullable()->constrained('suppliers', 'id_supplier')->nullOnDelete();
            $table->date('tanggal_masuk');
            $table->unsignedInteger('jumlah_masuk');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('purchases');
    }
};
