<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AgroBill extends Model
{
    use HasFactory;

    protected $fillable = [
        'agro_owner_id',
        'farmer_id',
        'bill_date',
        'payment_status',
        'amount',
        'note',
        'bill_photo_path',
        'bill_photo_mime',
    ];

    protected function casts(): array
    {
        return [
            'bill_date' => 'date',
            'amount' => 'decimal:2',
        ];
    }

    public function agroOwner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'agro_owner_id');
    }

    public function farmer(): BelongsTo
    {
        return $this->belongsTo(AgroFarmerContact::class, 'farmer_id');
    }
}
