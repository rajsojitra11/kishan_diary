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
        Schema::create('expense_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('land_id')->constrained('lands')->cascadeOnDelete();
            $table->enum('expense_type', [
                'expenseTypeMedicine',
                'expenseTypeSeeds',
                'expenseTypeTractor',
                'expenseTypeLightBill',
                'expenseTypeOther',
            ]);
            $table->decimal('amount', 14, 2);
            $table->date('entry_date');
            $table->text('note')->nullable();
            $table->string('bill_photo_path', 500)->nullable();
            $table->string('bill_photo_mime', 100)->nullable();
            $table->timestamps();

            $table->index(['land_id', 'entry_date']);
            $table->index('expense_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('expense_entries');
    }
};
