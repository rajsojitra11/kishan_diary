<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('crop_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('land_id')->constrained('lands')->cascadeOnDelete();
            $table->enum('crop_type', [
                'cropTypeWheat',
                'cropTypeCotton',
                'cropTypeGroundnut',
                'cropTypeBajra',
                'cropTypeMaize',
                'cropTypeRice',
                'cropTypeJiru',
                'cropTypeLasan',
                'cropTypeChana',
                'cropTypeTal',
                'cropTypeAnyOther',
            ]);
            $table->decimal('land_size', 10, 2);
            $table->decimal('crop_weight', 14, 2);
            $table->enum('weight_unit', ['kg', 'man']);
            $table->decimal('crop_weight_kg', 14, 2);
            $table->timestamps();

            $table->index('crop_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('crop_entries');
    }
};
