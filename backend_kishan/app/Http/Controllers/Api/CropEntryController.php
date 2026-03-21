<?php

namespace App\Http\Controllers\Api;

use App\Models\CropEntry;
use App\Models\Land;
use App\Services\LandMetricsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CropEntryController extends ApiController
{
    public function __construct(private readonly LandMetricsService $landMetricsService) {}

    public function index(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        $entries = $land->cropEntries()->latest('id')->get();

        return $this->success([
            'crop_entries' => $entries->map(fn(CropEntry $entry) => $this->entryPayload($entry))->values(),
            'crop_production_kg_total' => (float) $entries->sum('crop_weight_kg'),
        ], 'Crop entries fetched');
    }

    public function store(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        $validated = $request->validate([
            'crop_type' => ['required', Rule::in([
                'cropTypeWheat',
                'cropTypeCotton',
                'cropTypeGroundnut',
                'cropTypeBajra',
                'cropTypeMaize',
                'cropTypeRice',
                'cropTypeJiru',
                'cropTypeLasan',
                'cropTypeChana',
                'cropTypeTal',
                'cropTypeAnyOther',
            ])],
            'land_size' => ['required', 'numeric', 'gt:0'],
            'crop_weight' => ['required', 'numeric', 'gt:0'],
            'weight_unit' => ['required', Rule::in(['kg', 'man'])],
        ]);

        $cropWeightKg = $this->toKg((float) $validated['crop_weight'], $validated['weight_unit']);

        $entry = $land->cropEntries()->create([
            'user_id' => $request->user()->id,
            'crop_type' => $validated['crop_type'],
            'land_size' => $validated['land_size'],
            'crop_weight' => $validated['crop_weight'],
            'weight_unit' => $validated['weight_unit'],
            'crop_weight_kg' => $cropWeightKg,
        ]);

        $land = $this->landMetricsService->recalculateLand($land);

        return $this->success([
            'crop_entry' => $this->entryPayload($entry->fresh()),
            'land_totals' => [
                'crop_production_kg' => (float) $land->crop_production_kg,
            ],
        ], 'Crop entry created', 201);
    }

    public function update(Request $request, CropEntry $cropEntry): JsonResponse
    {
        $cropEntry = $this->ownedEntry($request, $cropEntry);

        $validated = $request->validate([
            'crop_type' => ['required', Rule::in([
                'cropTypeWheat',
                'cropTypeCotton',
                'cropTypeGroundnut',
                'cropTypeBajra',
                'cropTypeMaize',
                'cropTypeRice',
                'cropTypeJiru',
                'cropTypeLasan',
                'cropTypeChana',
                'cropTypeTal',
                'cropTypeAnyOther',
            ])],
            'land_size' => ['required', 'numeric', 'gt:0'],
            'crop_weight' => ['required', 'numeric', 'gt:0'],
            'weight_unit' => ['required', Rule::in(['kg', 'man'])],
        ]);

        $cropWeightKg = $this->toKg((float) $validated['crop_weight'], $validated['weight_unit']);

        $cropEntry->update([
            'crop_type' => $validated['crop_type'],
            'land_size' => $validated['land_size'],
            'crop_weight' => $validated['crop_weight'],
            'weight_unit' => $validated['weight_unit'],
            'crop_weight_kg' => $cropWeightKg,
        ]);

        $land = $this->landMetricsService->recalculateLand($cropEntry->land);

        return $this->success([
            'crop_entry' => $this->entryPayload($cropEntry->fresh()),
            'land_totals' => [
                'crop_production_kg' => (float) $land->crop_production_kg,
            ],
        ], 'Crop entry updated');
    }

    public function destroy(Request $request, CropEntry $cropEntry): JsonResponse
    {
        $cropEntry = $this->ownedEntry($request, $cropEntry);
        $land = $cropEntry->land;

        $cropEntry->delete();

        $land = $this->landMetricsService->recalculateLand($land);

        return $this->success([
            'deleted' => true,
            'land_totals' => [
                'crop_production_kg' => (float) $land->crop_production_kg,
            ],
        ], 'Crop entry deleted');
    }

    private function toKg(float $weight, string $unit): float
    {
        return $unit === 'man' ? $weight * 20 : $weight;
    }

    private function ownedLand(Request $request, Land $land): Land
    {
        if ($land->user_id !== $request->user()->id || !$land->is_active) {
            abort(404);
        }

        return $land;
    }

    private function ownedEntry(Request $request, CropEntry $entry): CropEntry
    {
        if (
            $entry->user_id !== $request->user()->id ||
            !$entry->land ||
            !$entry->land->is_active
        ) {
            abort(404);
        }

        return $entry;
    }

    private function entryPayload(CropEntry $entry): array
    {
        return [
            'id' => $entry->id,
            'land_id' => $entry->land_id,
            'crop_type' => $entry->crop_type,
            'land_size' => (float) $entry->land_size,
            'crop_weight' => (float) $entry->crop_weight,
            'weight_unit' => $entry->weight_unit,
            'crop_weight_kg' => (float) $entry->crop_weight_kg,
            'created_at' => optional($entry->created_at)?->toDateTimeString(),
            'updated_at' => optional($entry->updated_at)?->toDateTimeString(),
        ];
    }
}
