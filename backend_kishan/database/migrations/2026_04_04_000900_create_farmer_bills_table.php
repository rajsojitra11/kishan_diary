<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('farmer_bills', function (Blueprint $table) {
            $table->id();
            $table->foreignId('farmer_id')->constrained('users')->cascadeOnDelete();
            $table->date('bill_date');
            $table->enum('payment_status', ['pending', 'completed'])->default('pending');
            $table->decimal('amount', 14, 2)->default(0);
            $table->text('note')->nullable();
            $table->timestamps();

            $table->index(['farmer_id', 'payment_status']);
            $table->index(['farmer_id', 'bill_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('farmer_bills');
    }
};
