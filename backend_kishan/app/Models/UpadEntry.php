<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $user_id
 * @property int $land_id
 * @property int $labor_entry_id
 * @property string $labor_name_snapshot
 * @property string $amount
 * @property string|null $note
 * @property \Illuminate\Support\Carbon $payment_date
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 * @property-read LaborEntry $laborEntry
 */
class UpadEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'land_id',
        'labor_entry_id',
        'labor_name_snapshot',
        'amount',
        'note',
        'payment_date',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'payment_date' => 'date',
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

    public function laborEntry(): BelongsTo
    {
        return $this->belongsTo(LaborEntry::class);
    }
}
