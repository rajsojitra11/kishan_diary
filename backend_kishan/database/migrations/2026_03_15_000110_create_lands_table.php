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
        Schema::create('lands', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('land_name', 150);
            $table->decimal('land_size', 10, 2);
            $table->string('location', 255);
            $table->decimal('labor_rupees', 14, 2)->default(0);
            $table->decimal('fertilizer_kg', 14, 2)->default(0);
            $table->decimal('income_total', 14, 2)->default(0);
            $table->decimal('expense_total', 14, 2)->default(0);
            $table->decimal('crop_production_kg', 14, 2)->default(0);
            $table->decimal('animal_income_total', 14, 2)->default(0);
            $table->timestamps();

            $table->index(['land_name', 'location']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('lands');
    }
};
