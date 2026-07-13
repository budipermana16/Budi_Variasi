<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InventoryControl extends Model
{
    protected $primaryKey = 'id_control';

    protected $fillable = [
        'id_barang',
        'hasil_regresi_linear',
        'safety_stock',
        'reorder_point',
        'status_stok',
        'diperbarui_pada',
    ];

    protected $casts = [
        'hasil_regresi_linear' => 'float',
        'safety_stock'         => 'integer',
        'reorder_point'        => 'integer',
        'diperbarui_pada'      => 'datetime',
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class, 'id_barang', 'id_barang');
    }
}
