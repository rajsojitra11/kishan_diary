<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('agro_farmer_contacts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('agro_owner_id')->constrained('users')->cascadeOnDelete();
            $table->string('name', 120);
            $table->string('mobile', 15);
            $table->timestamps();

            $table->unique(['agro_owner_id', 'mobile']);
            $table->index(['agro_owner_id', 'name']);
        });

        Schema::table('agro_bills', function (Blueprint $table) {
            $table->dropForeign(['farmer_id']);
        });

        $bills = DB::table('agro_bills')
            ->select('id', 'agro_owner_id', 'farmer_id')
            ->orderBy('id')
            ->get();

        foreach ($bills as $bill) {
            $user = DB::table('users')
                ->select('id', 'name', 'mobile')
                ->where('id', $bill->farmer_id)
                ->first();

            $contactName = trim((string) ($user->name ?? 'Farmer ' . $bill->farmer_id));
            if ($contactName === '') {
                $contactName = 'Farmer ' . $bill->farmer_id;
            }

            $contactMobile = preg_replace('/\D+/', '', (string) ($user->mobile ?? ''));
            if (empty($contactMobile)) {
                $contactMobile = str_pad((string) (($bill->id % 9000000000) + 1000000000), 10, '0', STR_PAD_LEFT);
            }
            if (strlen($contactMobile) > 15) {
                $contactMobile = substr($contactMobile, 0, 15);
            }

            $existing = DB::table('agro_farmer_contacts')
                ->where('agro_owner_id', $bill->agro_owner_id)
                ->where('mobile', $contactMobile)
                ->first();

            $contactId = $existing?->id;

            if (!$contactId) {
                $contactId = DB::table('agro_farmer_contacts')->insertGetId([
                    'agro_owner_id' => $bill->agro_owner_id,
                    'name' => $contactName,
                    'mobile' => $contactMobile,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            DB::table('agro_bills')
                ->where('id', $bill->id)
                ->update(['farmer_id' => $contactId]);
        }

        Schema::table('agro_bills', function (Blueprint $table) {
            $table->foreign('farmer_id')->references('id')->on('agro_farmer_contacts')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('agro_bills', function (Blueprint $table) {
            $table->dropForeign(['farmer_id']);
        });

        Schema::dropIfExists('agro_farmer_contacts');

        Schema::table('agro_bills', function (Blueprint $table) {
            $table->foreign('farmer_id')->references('id')->on('users')->cascadeOnDelete();
        });
    }
};
