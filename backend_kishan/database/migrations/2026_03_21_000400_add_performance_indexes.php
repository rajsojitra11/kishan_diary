<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('lands', function (Blueprint $table) {
            $table->index(['user_id', 'is_active', 'id'], 'lands_user_active_id_idx');
        });

        Schema::table('income_entries', function (Blueprint $table) {
            $table->index(['land_id', 'income_type', 'entry_date'], 'income_land_type_date_idx');
        });

        Schema::table('expense_entries', function (Blueprint $table) {
            $table->index(['land_id', 'expense_type', 'entry_date'], 'expense_land_type_date_idx');
        });

        Schema::table('crop_entries', function (Blueprint $table) {
            $table->index(['land_id', 'id'], 'crop_land_id_idx');
        });

        Schema::table('labor_entries', function (Blueprint $table) {
            $table->index(['land_id', 'id'], 'labor_land_id_idx');
        });

        Schema::table('upad_entries', function (Blueprint $table) {
            $table->index(['labor_entry_id', 'payment_date'], 'upad_labor_payment_idx');
            $table->index(['land_id', 'payment_date'], 'upad_land_payment_idx');
        });

        Schema::table('animal_records', function (Blueprint $table) {
            $table->index(['animal_id', 'record_date'], 'animal_record_animal_date_idx');
        });
    }

    public function down(): void
    {
        Schema::table('animal_records', function (Blueprint $table) {
            $table->dropIndex('animal_record_animal_date_idx');
        });

        Schema::table('upad_entries', function (Blueprint $table) {
            $table->dropIndex('upad_land_payment_idx');
            $table->dropIndex('upad_labor_payment_idx');
        });

        Schema::table('labor_entries', function (Blueprint $table) {
            $table->dropIndex('labor_land_id_idx');
        });

        Schema::table('crop_entries', function (Blueprint $table) {
            $table->dropIndex('crop_land_id_idx');
        });

        Schema::table('expense_entries', function (Blueprint $table) {
            $table->dropIndex('expense_land_type_date_idx');
        });

        Schema::table('income_entries', function (Blueprint $table) {
            $table->dropIndex('income_land_type_date_idx');
        });

        Schema::table('lands', function (Blueprint $table) {
            $table->dropIndex('lands_user_active_id_idx');
        });
    }
};
