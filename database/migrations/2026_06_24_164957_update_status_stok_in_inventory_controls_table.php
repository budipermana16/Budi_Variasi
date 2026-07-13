<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        \Illuminate\Support\Facades\DB::statement("ALTER TABLE inventory_controls MODIFY status_stok ENUM('Aman', 'Waspada', 'Segera Pesan', 'Dalam Pemesanan') DEFAULT 'Aman'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert to old ENUM
        \Illuminate\Support\Facades\DB::statement("ALTER TABLE inventory_controls MODIFY status_stok ENUM('Aman', 'Waspada', 'Segera Pesan') DEFAULT 'Aman'");
    }
};
