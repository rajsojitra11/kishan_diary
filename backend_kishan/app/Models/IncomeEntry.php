<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $user_id
 * @property int $land_id
 * @property string $income_type
 * @property string $amount
 * @property \Illuminate\Support\Carbon|null $entry_date
 * @property string|null $note
 * @property string|null $bill_photo_path
 * @property string|null $bill_photo_mime
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 */
class IncomeEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'land_id',
        'income_type',
        'amount',
        'entry_date',
        'note',
        'bill_photo_path',
        'bill_photo_mime',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'entry_date' => 'date',
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
