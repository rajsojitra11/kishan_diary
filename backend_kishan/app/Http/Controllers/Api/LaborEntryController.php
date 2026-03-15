<?php

namespace App\Http\Controllers\Api;

use App\Models\LaborEntry;
use App\Models\Land;
use App\Services\LandMetricsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LaborEntryController extends ApiController
{
    public function __construct(private readonly LandMetricsService $landMetricsService) {}

    public function index(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        $laborEntries = $land->laborEntries()->with('upadEntries')->latest('id')->get();

        $records = $laborEntries->map(function (LaborEntry $entry) {
            $totalUpadPaid = (float) $entry->upadEntries->sum('amount');
            $pendingAmount = max((float) $entry->total_wage - $totalUpadPaid, 0);

            return [
                'id' => $entry->id,
                'land_id' => $entry->land_id,
                'labor_name' => $entry->labor_name,
                'mobile' => $entry->mobile,
                'total_days' => (float) $entry->total_days,
                'daily_rate' => (float) $entry->daily_rate,
                'total_wage' => (float) $entry->total_wage,
                'total_upad_paid' => $totalUpadPaid,
                'pending_amount' => $pendingAmount,
                'created_at' => optional($entry->created_at)?->toDateTimeString(),
                'updated_at' => optional($entry->updated_at)?->toDateTimeString(),
            ];
        })->values();

        return $this->success([
            'labor_entries' => $records,
            'totals' => $this->landLaborTotals($land),
        ], 'Labor entries fetched');
    }

    public function store(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        $validated = $request->validate([
            'labor_name' => ['required', 'string', 'max:150'],
            'mobile' => ['required', 'regex:/^\d{10}$/'],
            'total_days' => ['nullable', 'numeric', 'min:0'],
            'daily_rate' => ['nullable', 'numeric', 'min:0'],
        ]);

        $totalDays = (float) ($validated['total_days'] ?? 0);
        $dailyRate = (float) ($validated['daily_rate'] ?? 0);

        $entry = $land->laborEntries()->create([
            'user_id' => $request->user()->id,
            'labor_name' => $validated['labor_name'],
            'mobile' => $validated['mobile'],
            'total_days' => $totalDays,
            'daily_rate' => $dailyRate,
            'total_wage' => $totalDays * $dailyRate,
        ]);

        $land = $this->landMetricsService->recalculateLand($land);

        return $this->success([
            'labor_entry' => [
                'id' => $entry->id,
                'land_id' => $entry->land_id,
                'labor_name' => $entry->labor_name,
                'mobile' => $entry->mobile,
                'total_days' => (float) $entry->total_days,
                'daily_rate' => (float) $entry->daily_rate,
                'total_wage' => (float) $entry->total_wage,
            ],
            'land_totals' => [
                'labor_rupees' => (float) $land->labor_rupees,
            ],
        ], 'Labor entry created', 201);
    }

    public function update(Request $request, LaborEntry $laborEntry): JsonResponse
    {
        $laborEntry = $this->ownedEntry($request, $laborEntry);

        $validated = $request->validate([
            'labor_name' => ['required', 'string', 'max:150'],
            'mobile' => ['required', 'regex:/^\d{10}$/'],
            'total_days' => ['required', 'numeric', 'min:0'],
            'daily_rate' => ['required', 'numeric', 'min:0'],
        ]);

        $totalDays = (float) $validated['total_days'];
        $dailyRate = (float) $validated['daily_rate'];

        $laborEntry->update([
            'labor_name' => $validated['labor_name'],
            'mobile' => $validated['mobile'],
            'total_days' => $totalDays,
            'daily_rate' => $dailyRate,
            'total_wage' => $totalDays * $dailyRate,
        ]);

        $land = $this->landMetricsService->recalculateLand($laborEntry->land);

        return $this->success([
            'labor_entry' => [
                'id' => $laborEntry->id,
                'land_id' => $laborEntry->land_id,
                'labor_name' => $laborEntry->labor_name,
                'mobile' => $laborEntry->mobile,
                'total_days' => (float) $laborEntry->total_days,
                'daily_rate' => (float) $laborEntry->daily_rate,
                'total_wage' => (float) $laborEntry->total_wage,
            ],
            'land_totals' => [
                'labor_rupees' => (float) $land->labor_rupees,
            ],
        ], 'Labor entry updated');
    }

    public function destroy(Request $request, LaborEntry $laborEntry): JsonResponse
    {
        $laborEntry = $this->ownedEntry($request, $laborEntry);
        $land = $laborEntry->land;

        $laborEntry->delete();

        $land = $this->landMetricsService->recalculateLand($land);

        return $this->success([
            'deleted' => true,
            'land_totals' => [
                'labor_rupees' => (float) $land->labor_rupees,
            ],
        ], 'Labor entry deleted');
    }

    private function landLaborTotals(Land $land): array
    {
        $laborEntries = $land->laborEntries()->with('upadEntries')->get();

        $totalWage = (float) $laborEntries->sum('total_wage');
        $totalPaid = (float) $laborEntries->flatMap(fn(LaborEntry $entry) => $entry->upadEntries)->sum('amount');

        return [
            'total_paid' => $totalPaid,
            'total_pending' => max($totalWage - $totalPaid, 0),
            'total_wage' => $totalWage,
        ];
    }

    private function ownedLand(Request $request, Land $land): Land
    {
        if ($land->user_id !== $request->user()->id) {
            abort(404);
        }

        return $land;
    }

    private function ownedEntry(Request $request, LaborEntry $entry): LaborEntry
    {
        if ($entry->user_id !== $request->user()->id) {
            abort(404);
        }

        return $entry;
    }
}
