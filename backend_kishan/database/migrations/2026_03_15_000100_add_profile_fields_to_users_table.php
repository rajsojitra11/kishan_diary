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
        Schema::table('users', function (Blueprint $table) {
            $table->string('mobile', 15)->nullable()->after('email');
            $table->date('birth_date')->nullable()->after('mobile');
            $table->string('profile_image_path', 500)->nullable()->after('password');
            $table->string('preferred_language', 5)->default('gu')->after('profile_image_path');
            $table->boolean('is_active')->default(true)->after('remember_token');
            $table->dateTime('last_login_at')->nullable()->after('is_active');

            $table->unique('mobile');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique('users_mobile_unique');
            $table->dropColumn([
                'mobile',
                'birth_date',
                'profile_image_path',
                'preferred_language',
                'is_active',
                'last_login_at',
            ]);
        });
    }
};
