<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $user_id
 * @property int $land_id
 * @property string $crop_type
 * @property string $land_size
 * @property string $crop_weight
 * @property string $weight_unit
 * @property string $crop_weight_kg
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 */
class CropEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'land_id',
        'crop_type',
        'land_size',
        'crop_weight',
        'weight_unit',
        'crop_weight_kg',
    ];

    protected function casts(): array
    {
        return [
            'land_size' => 'decimal:2',
            'crop_weight' => 'decimal:2',
            'crop_weight_kg' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function land(): BelongsTo
    {
        return $this->belongsTo(Land::class);
    }
}
