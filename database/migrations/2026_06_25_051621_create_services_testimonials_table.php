<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Tabel services — data layanan jasa untuk Landing Page (buat jika belum ada)
        if (!Schema::hasTable('services')) {
            Schema::create('services', function (Blueprint $table) {
                $table->id();
                $table->string('title', 100);
                $table->text('description')->nullable();
                $table->string('image', 500)->nullable();
                $table->boolean('is_active')->default(true);
                $table->integer('sort_order')->default(0);
                $table->timestamps();
            });
        } else {
            // Tambah kolom yang mungkin belum ada
            Schema::table('services', function (Blueprint $table) {
                if (!Schema::hasColumn('services', 'sort_order')) $table->integer('sort_order')->default(0);
                if (!Schema::hasColumn('services', 'is_active')) $table->boolean('is_active')->default(true);
            });
        }

        // Tabel testimonials — ulasan pelanggan untuk Landing Page
        if (!Schema::hasTable('testimonials')) {
            Schema::create('testimonials', function (Blueprint $table) {
                $table->id();
                $table->string('name', 100);
                $table->text('review_text');
                $table->tinyInteger('rating')->default(5);
                $table->string('profile_photo_url', 500)->nullable();
                $table->string('source', 50)->nullable()->comment('Google Maps / Manual');
                $table->string('relative_time_description', 100)->nullable();
                $table->boolean('is_displayed')->default(true)->comment('Tampil di Landing Page');
                $table->timestamps();
            });
        } else {
            Schema::table('testimonials', function (Blueprint $table) {
                if (!Schema::hasColumn('testimonials', 'is_displayed')) {
                    $table->boolean('is_displayed')->default(true);
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('testimonials');
        Schema::dropIfExists('services');
    }
};
