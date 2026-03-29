<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property int $id
 * @property int $user_id
 * @property bool $is_active
 * @property string $land_name
 * @property string $land_size
 * @property string|null $location
 * @property string $labor_rupees
 * @property string $fertilizer_kg
 * @property string $income_total
 * @property string $expense_total
 * @property string $crop_production_kg
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 */
class Land extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'is_active',
        'land_name',
        'land_size',
        'location',
        'labor_rupees',
        'fertilizer_kg',
        'income_total',
        'expense_total',
        'crop_production_kg',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'land_size' => 'decimal:2',
            'labor_rupees' => 'decimal:2',
            'fertilizer_kg' => 'decimal:2',
            'income_total' => 'decimal:2',
            'expense_total' => 'decimal:2',
            'crop_production_kg' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(\App\Models\User::class);
    }

    public function incomeEntries(): HasMany
    {
        return $this->hasMany(\App\Models\IncomeEntry::class);
    }

    public function expenseEntries(): HasMany
    {
        return $this->hasMany(\App\Models\ExpenseEntry::class);
    }

    public function cropEntries(): HasMany
    {
        return $this->hasMany(\App\Models\CropEntry::class);
    }

    public function laborEntries(): HasMany
    {
        return $this->hasMany(\App\Models\LaborEntry::class);
    }

    public function upadEntries(): HasMany
    {
        return $this->hasMany(\App\Models\UpadEntry::class);
    }
}
