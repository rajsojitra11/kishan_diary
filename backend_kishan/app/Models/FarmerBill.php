<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $farmer_id
 * @property \Illuminate\Support\Carbon|null $bill_date
 * @property string $payment_status
 * @property string|float|int $amount
 * @property string|null $note
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 * @property-read User|null $farmer
 */
class FarmerBill extends Model
{
    use HasFactory;

    protected $fillable = [
        'farmer_id',
        'bill_date',
        'payment_status',
        'amount',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'bill_date' => 'date',
            'amount' => 'decimal:2',
        ];
    }

    public function farmer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'farmer_id');
    }
}
