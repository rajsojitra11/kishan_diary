<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver === 'mysql') {
            DB::statement("ALTER TABLE income_entries MODIFY income_type ENUM('incomeTypeCropSale','incomeTypeTractorHarvester','incomeTypeVegetables','incomeTypeAnimalPasu','incomeTypeSubsidy','incomeTypeOther') NOT NULL");
            return;
        }

        if ($driver === 'pgsql') {
            // Support both PostgreSQL enum-type and check-constraint implementations.
            DB::statement("DO $$ BEGIN IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'income_entries_income_type') THEN ALTER TYPE income_entries_income_type ADD VALUE IF NOT EXISTS 'incomeTypeAnimalPasu'; END IF; END $$;");
            DB::statement('ALTER TABLE income_entries DROP CONSTRAINT IF EXISTS income_entries_income_type_check');
            DB::statement("ALTER TABLE income_entries ADD CONSTRAINT income_entries_income_type_check CHECK (income_type IN ('incomeTypeCropSale','incomeTypeTractorHarvester','incomeTypeVegetables','incomeTypeAnimalPasu','incomeTypeSubsidy','incomeTypeOther'))");
        }
    }

    public function down(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver === 'mysql') {
            DB::statement("ALTER TABLE income_entries MODIFY income_type ENUM('incomeTypeCropSale','incomeTypeTractorHarvester','incomeTypeVegetables','incomeTypeSubsidy','incomeTypeOther') NOT NULL");
            return;
        }

        if ($driver === 'pgsql') {
            DB::statement('ALTER TABLE income_entries DROP CONSTRAINT IF EXISTS income_entries_income_type_check');
            DB::statement("ALTER TABLE income_entries ADD CONSTRAINT income_entries_income_type_check CHECK (income_type IN ('incomeTypeCropSale','incomeTypeTractorHarvester','incomeTypeVegetables','incomeTypeSubsidy','incomeTypeOther'))");
        }
    }
};
