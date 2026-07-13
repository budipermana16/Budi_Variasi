<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sales', function (Blueprint $table) {
            $table->id('id_penjualan');
            $table->foreignId('id_barang')->constrained('products', 'id_barang')->cascadeOnDelete();
            $table->date('tanggal_keluar');
            $table->unsignedInteger('jumlah_terjual');
            $table->decimal('total_harga', 15, 2)->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sales');
    }
};
