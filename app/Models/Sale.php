<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Sale extends Model
{
    protected $primaryKey = 'id_penjualan';

    protected $fillable = [
        'id_barang',
        'tanggal_keluar',
        'jumlah_terjual',
        'total_harga',
    ];

    protected $casts = [
        'tanggal_keluar' => 'date',
        'jumlah_terjual' => 'integer',
        'total_harga'    => 'decimal:2',
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class, 'id_barang', 'id_barang');
    }
}
