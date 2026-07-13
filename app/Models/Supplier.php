<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Supplier extends Model
{
    protected $primaryKey = 'id_supplier';

    protected $fillable = [
        'nama_supplier',
        'alamat',
        'kontak_person',
        'lead_time_rata_rata',
    ];

    protected $casts = [
        'lead_time_rata_rata' => 'integer',
    ];

    public function products(): HasMany
    {
        return $this->hasMany(Product::class, 'id_supplier', 'id_supplier');
    }

    public function purchases(): HasMany
    {
        return $this->hasMany(Purchase::class, 'id_supplier', 'id_supplier');
    }
}
