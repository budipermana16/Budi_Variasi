<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Product extends Model
{
    protected $primaryKey = 'id_barang';

    protected $fillable = [
        'nama_barang',
        'kategori',
        'harga_beli',
        'harga_jual',
        'stok_saat_ini',
        'satuan',
        'id_supplier',
    ];

    protected $casts = [
        'harga_beli'    => 'decimal:2',
        'harga_jual'    => 'decimal:2',
        'stok_saat_ini' => 'integer',
        'id_supplier'   => 'integer',
    ];

    public function supplier(): BelongsTo
    {
        return $this->belongsTo(Supplier::class, 'id_supplier', 'id_supplier');
    }

    public function sales(): HasMany
    {
        return $this->hasMany(Sale::class, 'id_barang', 'id_barang');
    }

    public function purchases(): HasMany
    {
        return $this->hasMany(Purchase::class, 'id_barang', 'id_barang');
    }

    public function inventoryControl(): HasOne
    {
        return $this->hasOne(InventoryControl::class, 'id_barang', 'id_barang');
    }
}
