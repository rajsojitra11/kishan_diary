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
            'page' => ['required', Rule::in(['home', 'income', 'expense', 'crop', 'labor', 'animal'])],
            'land_id' => ['nullable', 'integer'],
        ]);

        $user = $request->user();
        $page = $validated['page'];

        if ($page === 'home') {
            return $this->success([
                'page' => 'home',
                'summary' => [
                    'total_lands' => (int) $user->lands()->count(),
                    'income_total' => (float) $user->lands()->sum('income_total'),
                    'expense_total' => (float) $user->lands()->sum('expense_total'),
                    'crop_production_kg' => (float) $user->lands()->sum('crop_production_kg'),
                    'fertilizer_kg' => (float) $user->lands()->sum('fertilizer_kg'),
                    'labor_rupees' => (float) $user->lands()->sum('labor_rupees'),
                    'animal_income_global' => (float) $user->animalRecords()->sum('amount'),
                ],
            ], 'Report payload generated');
        }

        if ($page === 'animal') {
            $animals = $user->animals()
                ->withSum('records as total_amount', 'amount')
                ->withSum('records as total_milk', 'milk_liter')
                ->get();

            return $this->success([
                'page' => 'animal',
                'animal_income_global' => (float) $animals->sum('total_amount'),
                'animals' => $animals->map(function ($animal) {
                    return [
                        'id' => $animal->id,
                        'animal_name' => $animal->animal_name,
                        'total_amount' => (float) ($animal->total_amount ?? 0),
                        'total_milk' => (float) ($animal->total_milk ?? 0),
                    ];
                })->values(),
            ], 'Report payload generated');
        }

        if (empty($validated['land_id'])) {
            return $this->error('land_id is required for this page', [
                'land_id' => ['land_id is required for selected page'],
            ]);
        }

        $land = Land::query()
            ->where('user_id', $user->id)
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
