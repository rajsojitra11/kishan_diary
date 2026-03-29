<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AgroFarmerContact extends Model
{
    use HasFactory;

    protected $fillable = [
        'agro_owner_id',
        'name',
        'mobile',
    ];

    public function agroOwner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'agro_owner_id');
    }
}
