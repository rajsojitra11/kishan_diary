<?php

namespace App\Http\Controllers\Api;

use App\Models\Land;
use App\Services\LandMetricsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LandController extends ApiController
{
    public function __construct(private readonly LandMetricsService $landMetricsService) {}

    public function index(Request $request): JsonResponse
    {
        $lands = $request->user()
            ->lands()
            ->where('is_active', true)
            ->latest('id')
            ->get()
            ->map(fn(Land $land) => $this->landPayload($land))
            ->values();

        return $this->success([
            'lands' => $lands,
        ], 'Lands fetched');
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'land_name' => ['required', 'string', 'max:150'],
            'land_size' => ['required', 'numeric', 'gt:0'],
            'location' => ['required', 'string', 'max:255'],
        ]);

        $land = $request->user()->lands()->create([
            'is_active' => true,
            'land_name' => $validated['land_name'],
            'land_size' => $validated['land_size'],
            'location' => $validated['location'],
        ]);

        return $this->success([
            'land' => $this->landPayload($land),
        ], 'Land created', 201);
    }

    public function show(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        return $this->success([
            'land' => $this->landPayload($land),
        ], 'Land fetched');
    }

    public function update(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        $validated = $request->validate([
            'land_name' => ['required', 'string', 'max:150'],
            'land_size' => ['required', 'numeric', 'gt:0'],
            'location' => ['required', 'string', 'max:255'],
        ]);

        $land->update([
            'land_name' => $validated['land_name'],
            'land_size' => $validated['land_size'],
            'location' => $validated['location'],
        ]);

        return $this->success([
            'land' => $this->landPayload($land->fresh()),
        ], 'Land updated');
    }

    public function destroy(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);
        $land->update([
            'is_active' => false,
        ]);

        return $this->success([
            'disabled' => true,
        ], 'Land disabled');
    }

    public function summary(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);
        $land = $this->landMetricsService->recalculateLand($land);

        return $this->success([
            'income_total' => (float) $land->income_total,
            'expense_total' => (float) $land->expense_total,
            'crop_production_kg' => (float) $land->crop_production_kg,
            'fertilizer_kg' => (float) $land->fertilizer_kg,
            'labor_rupees' => (float) $land->labor_rupees,
        ], 'Land summary fetched');
    }

    private function ownedLand(Request $request, Land $land): Land
    {
        if ($land->user_id !== $request->user()->id || !$land->is_active) {
            abort(404);
        }

        return $land;
    }

    private function landPayload(Land $land): array
    {
        return [
            'id' => $land->id,
            'land_name' => $land->land_name,
            'land_size' => (float) $land->land_size,
            'location' => $land->location,
            'labor_rupees' => (float) $land->labor_rupees,
            'fertilizer_kg' => (float) $land->fertilizer_kg,
            'income_total' => (float) $land->income_total,
            'expense_total' => (float) $land->expense_total,
            'crop_production_kg' => (float) $land->crop_production_kg,
            'created_at' => optional($land->created_at)?->toDateTimeString(),
            'updated_at' => optional($land->updated_at)?->toDateTimeString(),
        ];
    }
}
