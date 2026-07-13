<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GooglePlacesService
{
    protected $apiKey;
    protected $placeId;

    public function __construct()
    {
        $this->apiKey = env('GOOGLE_MAPS_API_KEY');
        $this->placeId = env('GOOGLE_PLACE_ID');
    }

    public function getPlaceDetails()
    {
        if (!$this->apiKey || !$this->placeId) {
            return null; // Fallback to mock data or database
        }

        try {
            $response = Http::get('https://maps.googleapis.com/maps/api/place/details/json', [
                'place_id' => $this->placeId,
                'fields' => 'name,rating,reviews,photos,user_ratings_total',
                'key' => $this->apiKey,
                'language' => 'id'
            ]);

            if ($response->successful() && $response->json('status') === 'OK') {
                $result = $response->json('result');
                
                // Process photos to get actual image URLs
                $photos = [];
                if (isset($result['photos'])) {
                    foreach (array_slice($result['photos'], 0, 5) as $photo) { // get max 5 photos
                        $photos[] = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=" . $photo['photo_reference'] . "&key=" . $this->apiKey;
                    }
                }
                $result['processed_photos'] = $photos;

                return $result;
            }
        } catch (\Exception $e) {
            Log::error('Google Places API Error: ' . $e->getMessage());
        }

        return null;
    }
}
