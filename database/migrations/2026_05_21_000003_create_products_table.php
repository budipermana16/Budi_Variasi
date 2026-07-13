<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id('id_barang');
            $table->string('nama_barang', 150);
            $table->string('kategori', 80);
            $table->decimal('harga_beli', 15, 2)->default(0);
            $table->decimal('harga_jual', 15, 2)->default(0);
            $table->unsignedInteger('stok_saat_ini')->default(0);
            $table->string('satuan', 30)->default('pcs');
            $table->foreignId('id_supplier')->nullable()->constrained('suppliers', 'id_supplier')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
