<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::dropIfExists('animal_records');
        Schema::dropIfExists('animals');
    }

    public function down(): void
    {
        // Intentionally left empty because legacy animal table structures are no longer used.
    }
};
