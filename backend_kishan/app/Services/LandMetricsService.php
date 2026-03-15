<?php

namespace App\Services;

use App\Models\Land;
use App\Models\User;

class LandMetricsService
{
    public function recalculateLand(Land $land): Land
    {
        $incomeTotal = (float) $land->incomeEntries()->sum('amount');
        $expenseTotal = (float) $land->expenseEntries()->sum('amount');
        $fertilizerKg = (float) $land->expenseEntries()
            ->whereIn('expense_type', ['expenseTypeMedicine', 'expenseTypeSeeds'])
            ->sum('amount');
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

        $user->lands()->update([
            'animal_income_total' => $animalIncomeGlobal,
        ]);

        return $animalIncomeGlobal;
    }
}
