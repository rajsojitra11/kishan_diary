<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('user_role', 20)->default('farmer')->after('preferred_language');
            $table->index('user_role');
        });

        Schema::create('agro_bills', function (Blueprint $table) {
            $table->id();
            $table->foreignId('agro_owner_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('farmer_id')->constrained('users')->cascadeOnDelete();
            $table->date('bill_date');
            $table->enum('payment_status', ['pending', 'completed'])->default('pending');
            $table->decimal('amount', 14, 2)->default(0);
            $table->text('note')->nullable();
            $table->string('bill_photo_path', 500)->nullable();
            $table->string('bill_photo_mime', 100)->nullable();
            $table->timestamps();

            $table->index(['agro_owner_id', 'farmer_id']);
            $table->index(['agro_owner_id', 'payment_status']);
            $table->index(['agro_owner_id', 'bill_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('agro_bills');

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['user_role']);
            $table->dropColumn('user_role');
        });
    }
};
