<?php

namespace App\Services;

use App\Models\Land;
use App\Models\User;

class LandMetricsService
{
    public function recalculateLand(Land $land): Land
    {
        $incomeTotal = (float) $land->incomeEntries()->sum('amount');
        $expenseAggregates = $land->expenseEntries()
            ->selectRaw('COALESCE(SUM(amount), 0) as expense_total')
            ->selectRaw(
                "COALESCE(SUM(CASE WHEN expense_type IN ('expenseTypeMedicine', 'expenseTypeSeeds') THEN amount ELSE 0 END), 0) as fertilizer_kg"
            )
            ->first();
        $expenseTotal = (float) ($expenseAggregates?->expense_total ?? 0);
        $fertilizerKg = (float) ($expenseAggregates?->fertilizer_kg ?? 0);
        $cropProductionKg = (float) $land->cropEntries()->sum('crop_weight_kg');
        $laborRupees = (float) $land->laborEntries()->sum('total_wage');

        $land->update([
            'income_total' => $incomeTotal,
            'expense_total' => $expenseTotal,
            'fertilizer_kg' => $fertilizerKg,
            'crop_production_kg' => $cropProductionKg,
            'labor_rupees' => $laborRupees,
        ]);

        return $land->fresh();
    }

    public function syncAnimalIncomeForUser(User $user): float
    {
        $animalIncomeGlobal = (float) $user->animalRecords()->sum('amount');

        $user->lands()->where('is_active', true)->update([
            'animal_income_total' => $animalIncomeGlobal,
        ]);

        return $animalIncomeGlobal;
    }
}
