<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Testimonial extends Model
{
    protected $fillable = ['name', 'review_text', 'rating', 'profile_photo_url', 'source', 'relative_time_description', 'is_displayed'];

    protected $casts = ['rating' => 'integer', 'is_displayed' => 'boolean'];
}
