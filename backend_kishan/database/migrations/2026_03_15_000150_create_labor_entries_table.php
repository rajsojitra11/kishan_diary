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
        Schema::create('labor_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('land_id')->constrained('lands')->cascadeOnDelete();
            $table->string('labor_name', 150);
            $table->string('mobile', 15);
            $table->decimal('total_days', 8, 2)->default(0);
            $table->decimal('daily_rate', 12, 2)->default(0);
            $table->decimal('total_wage', 14, 2)->default(0);
            $table->timestamps();

            $table->index('labor_name');
            $table->index('mobile');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('labor_entries');
    }
};
