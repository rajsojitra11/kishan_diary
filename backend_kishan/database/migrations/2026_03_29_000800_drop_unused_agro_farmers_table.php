<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::dropIfExists('agro_farmers');
    }

    public function down(): void
    {
        // This table is intentionally removed as obsolete.
    }
};
