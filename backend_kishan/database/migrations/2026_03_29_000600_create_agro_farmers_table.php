<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('agro_farmers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('agro_owner_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('farmer_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['agro_owner_id', 'farmer_id']);
            $table->index('farmer_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('agro_farmers');
    }
};
