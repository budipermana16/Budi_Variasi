<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Purchase extends Model
{
    protected $primaryKey = 'id_pembelian';

    protected $fillable = [
        'id_barang',
        'id_supplier',
        'tanggal_masuk',
        'jumlah_masuk',
    ];

    protected $casts = [
        'tanggal_masuk' => 'date',
        'jumlah_masuk'  => 'integer',
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class, 'id_barang', 'id_barang');
    }

    public function supplier(): BelongsTo
    {
        return $this->belongsTo(Supplier::class, 'id_supplier', 'id_supplier');
    }
}
