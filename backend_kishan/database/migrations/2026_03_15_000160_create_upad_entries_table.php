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
        Schema::create('upad_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('land_id')->constrained('lands')->cascadeOnDelete();
            $table->foreignId('labor_entry_id')->constrained('labor_entries')->cascadeOnDelete();
            $table->string('labor_name_snapshot', 150);
            $table->decimal('amount', 14, 2);
            $table->text('note')->nullable();
            $table->date('payment_date');
            $table->timestamps();

            $table->index('payment_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('upad_entries');
    }
};
