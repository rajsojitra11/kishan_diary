<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends ApiController
{
    public function summary(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = [
            'total_lands' => (int) $user->lands()->count(),
            'income_total' => (float) $user->lands()->sum('income_total'),
            'expense_total' => (float) $user->lands()->sum('expense_total'),
            'crop_production_kg' => (float) $user->lands()->sum('crop_production_kg'),
            'fertilizer_kg' => (float) $user->lands()->sum('fertilizer_kg'),
            'labor_rupees' => (float) $user->lands()->sum('labor_rupees'),
            'animal_income_global' => (float) $user->animalRecords()->sum('amount'),
        ];

        return $this->success($data, 'Dashboard summary fetched');
    }
}
