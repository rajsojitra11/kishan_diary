<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $agro_owner_id
 * @property string $name
 * @property string $mobile
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 * @property-read User|null $agroOwner
 */
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
