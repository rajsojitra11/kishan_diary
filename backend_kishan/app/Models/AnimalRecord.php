<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $user_id
 * @property int $animal_id
 * @property string $amount
 * @property string $milk_liter
 * @property \Illuminate\Support\Carbon|null $record_date
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 */
class AnimalRecord extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'animal_id',
        'amount',
        'milk_liter',
        'record_date',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'milk_liter' => 'decimal:2',
            'record_date' => 'date',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }
}
