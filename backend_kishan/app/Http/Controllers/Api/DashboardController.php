<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends ApiController
{
    public function summary(Request $request): JsonResponse
    {
        $user = $request->user();
        $activeLands = $user->lands()->where('is_active', true);

        $data = [
            'total_lands' => (int) $activeLands->count(),
            'income_total' => (float) $activeLands->sum('income_total'),
            'expense_total' => (float) $activeLands->sum('expense_total'),
            'crop_production_kg' => (float) $activeLands->sum('crop_production_kg'),
            'fertilizer_kg' => (float) $activeLands->sum('fertilizer_kg'),
            'labor_rupees' => (float) $activeLands->sum('labor_rupees'),
        ];

        return $this->success($data, 'Dashboard summary fetched');
    }
}
