<?php

namespace App\Http\Controllers\Api;

use App\Models\Land;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ReportController extends ApiController
{
    public function currentPage(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'page' => ['required', Rule::in(['home', 'income', 'expense', 'crop', 'labor'])],
            'land_id' => ['nullable', 'integer'],
        ]);

        $user = $request->user();
        $page = $validated['page'];
        $activeLands = $user->lands()->where('is_active', true);

        if ($page === 'home') {
            return $this->success([
                'page' => 'home',
                'summary' => [
                    'total_lands' => (int) $activeLands->count(),
                    'income_total' => (float) $activeLands->sum('income_total'),
                    'expense_total' => (float) $activeLands->sum('expense_total'),
                    'crop_production_kg' => (float) $activeLands->sum('crop_production_kg'),
                    'fertilizer_kg' => (float) $activeLands->sum('fertilizer_kg'),
                    'labor_rupees' => (float) $activeLands->sum('labor_rupees'),
                ],
            ], 'Report payload generated');
        }

        if (empty($validated['land_id'])) {
            return $this->error('land_id is required for this page', [
                'land_id' => ['land_id is required for selected page'],
            ]);
        }

        $land = Land::query()
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->findOrFail($validated['land_id']);

        $payload = [
            'page' => $page,
            'land' => [
                'id' => $land->id,
                'land_name' => $land->land_name,
                'location' => $land->location,
            ],
        ];

        if ($page === 'income') {
            $payload['records'] = $land->incomeEntries()->latest('entry_date')->get();
        }

        if ($page === 'expense') {
            $payload['records'] = $land->expenseEntries()->latest('entry_date')->get();
        }

        if ($page === 'crop') {
            $payload['records'] = $land->cropEntries()->latest('id')->get();
        }

        if ($page === 'labor') {
            $payload['records'] = $land->laborEntries()->latest('id')->get();
        }

        return $this->success($payload, 'Report payload generated');
    }
}
