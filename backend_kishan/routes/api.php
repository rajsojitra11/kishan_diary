<?php

use App\Http\Controllers\Api\AgroCenterController;
use App\Http\Controllers\Api\AppDataController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CropEntryController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ExpenseEntryController;
use App\Http\Controllers\Api\IncomeEntryController;
use App\Http\Controllers\Api\LaborEntryController;
use App\Http\Controllers\Api\LandController;
use App\Http\Controllers\Api\MediaController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SuggestionController;
use App\Http\Controllers\Api\UpadEntryController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('/media/{path}', [MediaController::class, 'show'])->where('path', '.*');

    Route::prefix('auth')->group(function () {
        Route::post('/mobile-check', [AuthController::class, 'mobileCheck']);
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/forgot-password/reset', [AuthController::class, 'resetForgotPassword']);
    });

    Route::middleware('api.token')->group(function () {
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        Route::get('/me', [ProfileController::class, 'me']);
        Route::get('/me/bills', [ProfileController::class, 'myBills']);
        Route::post('/me/farmer-bills', [ProfileController::class, 'storeFarmerBill']);
        Route::put('/me/farmer-bills/{farmerBill}', [ProfileController::class, 'updateFarmerBill']);
        Route::delete('/me/farmer-bills/{farmerBill}', [ProfileController::class, 'deleteFarmerBill']);
        Route::put('/me', [ProfileController::class, 'update']);
        Route::post('/me/profile-image', [ProfileController::class, 'updateProfileImage']);
        Route::patch('/me/language', [ProfileController::class, 'updateLanguage']);
        Route::delete('/me/all-data', [AppDataController::class, 'clearAllData']);
        Route::post('/me/suggestions', [SuggestionController::class, 'store']);

        Route::get('/dashboard/summary', [DashboardController::class, 'summary']);
        Route::get('/reports/current-page', [ReportController::class, 'currentPage']);

        Route::get('/lands', [LandController::class, 'index']);
        Route::post('/lands', [LandController::class, 'store']);
        Route::get('/lands/{land}', [LandController::class, 'show']);
        Route::put('/lands/{land}', [LandController::class, 'update']);
        Route::delete('/lands/{land}', [LandController::class, 'destroy']);
        Route::get('/lands/{land}/summary', [LandController::class, 'summary']);

        Route::get('/lands/{land}/income-entries', [IncomeEntryController::class, 'index']);
        Route::post('/lands/{land}/income-entries', [IncomeEntryController::class, 'store']);
        Route::put('/income-entries/{incomeEntry}', [IncomeEntryController::class, 'update']);
        Route::delete('/income-entries/{incomeEntry}', [IncomeEntryController::class, 'destroy']);

        Route::get('/lands/{land}/expense-entries', [ExpenseEntryController::class, 'index']);
        Route::post('/lands/{land}/expense-entries', [ExpenseEntryController::class, 'store']);
        Route::put('/expense-entries/{expenseEntry}', [ExpenseEntryController::class, 'update']);
        Route::delete('/expense-entries/{expenseEntry}', [ExpenseEntryController::class, 'destroy']);

        Route::get('/lands/{land}/crop-entries', [CropEntryController::class, 'index']);
        Route::post('/lands/{land}/crop-entries', [CropEntryController::class, 'store']);
        Route::put('/crop-entries/{cropEntry}', [CropEntryController::class, 'update']);
        Route::delete('/crop-entries/{cropEntry}', [CropEntryController::class, 'destroy']);

        Route::get('/lands/{land}/labor-entries', [LaborEntryController::class, 'index']);
        Route::post('/lands/{land}/labor-entries', [LaborEntryController::class, 'store']);
        Route::put('/labor-entries/{laborEntry}', [LaborEntryController::class, 'update']);
        Route::delete('/labor-entries/{laborEntry}', [LaborEntryController::class, 'destroy']);

        Route::get('/labor-entries/{laborEntry}/upad-entries', [UpadEntryController::class, 'index']);
        Route::post('/labor-entries/{laborEntry}/upad-entries', [UpadEntryController::class, 'store']);
        Route::put('/upad-entries/{upadEntry}', [UpadEntryController::class, 'update']);
        Route::delete('/upad-entries/{upadEntry}', [UpadEntryController::class, 'destroy']);

        Route::prefix('agro-center')->group(function () {
            Route::get('/dashboard', [AgroCenterController::class, 'dashboardSummary']);
            Route::get('/farmers', [AgroCenterController::class, 'farmers']);
            Route::post('/farmers', [AgroCenterController::class, 'storeFarmer']);
            Route::put('/farmers/{farmer}', [AgroCenterController::class, 'updateFarmer']);
            Route::delete('/farmers/{farmer}', [AgroCenterController::class, 'deleteFarmer']);
            Route::get('/bills', [AgroCenterController::class, 'bills']);
            Route::post('/bills', [AgroCenterController::class, 'storeBill']);
            Route::put('/bills/{agroBill}', [AgroCenterController::class, 'updateBill']);
            Route::delete('/bills/{agroBill}', [AgroCenterController::class, 'deleteBill']);
            Route::get('/reports', [AgroCenterController::class, 'report']);
        });
    });
});
