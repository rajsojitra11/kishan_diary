<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

/**
 * @property int $id
 * @property string $name
 * @property string $email
 * @property string $mobile
 * @property \Illuminate\Support\Carbon|null $birth_date
 * @property string $password
 * @property string|null $api_token
 * @property string|null $profile_image_path
 * @property string $preferred_language
 * @property bool $is_active
 * @property \Illuminate\Support\Carbon|null $last_login_at
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 */
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'mobile',
        'birth_date',
        'password',
        'api_token',
        'profile_image_path',
        'preferred_language',
        'is_active',
        'last_login_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'api_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'birth_date' => 'date',
            'last_login_at' => 'datetime',
            'is_active' => 'boolean',
            'password' => 'hashed',
        ];
    }

    public function lands(): HasMany
    {
        return $this->hasMany(\App\Models\Land::class);
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

    public function animals(): HasMany
    {
        return $this->hasMany(\App\Models\Animal::class);
    }

    public function animalRecords(): HasMany
    {
        return $this->hasMany(\App\Models\AnimalRecord::class);
    }
}
