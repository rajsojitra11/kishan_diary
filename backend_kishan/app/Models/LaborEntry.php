<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property int $id
 * @property int $user_id
 * @property int $land_id
 * @property string $labor_name
 * @property string $mobile
 * @property string $total_days
 * @property string $daily_rate
 * @property string $total_wage
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 */
class LaborEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'land_id',
        'labor_name',
        'mobile',
        'total_days',
        'daily_rate',
        'total_wage',
    ];

    protected function casts(): array
    {
        return [
            'total_days' => 'decimal:2',
            'daily_rate' => 'decimal:2',
            'total_wage' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(\App\Models\User::class);
    }

    public function land(): BelongsTo
    {
        return $this->belongsTo(\App\Models\Land::class);
    }

    public function upadEntries(): HasMany
    {
        return $this->hasMany(\App\Models\UpadEntry::class);
    }
}
