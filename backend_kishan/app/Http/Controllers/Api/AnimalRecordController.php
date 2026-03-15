<?php

namespace App\Http\Controllers\Api;

use App\Models\Animal;
use App\Models\AnimalRecord;
use App\Services\LandMetricsService;
use App\Support\ApiDate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnimalRecordController extends ApiController
{
    public function __construct(private readonly LandMetricsService $landMetricsService) {}

    public function index(Request $request, Animal $animal): JsonResponse
    {
        $animal = $this->ownedAnimal($request, $animal);

        $records = $animal->records()->latest('record_date')->get();

        return $this->success([
            'records' => $records->map(fn(AnimalRecord $record) => $this->recordPayload($record))->values(),
            'totals' => [
                'total_amount' => (float) $records->sum('amount'),
                'total_milk' => (float) $records->sum('milk_liter'),
            ],
        ], 'Animal records fetched');
    }

    public function store(Request $request, Animal $animal): JsonResponse
    {
        $animal = $this->ownedAnimal($request, $animal);

        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'gt:0'],
            'milk_liter' => ['required', 'numeric', 'gt:0'],
            'record_date' => ['required', 'string'],
        ]);

        $record = $animal->records()->create([
            'user_id' => $request->user()->id,
            'amount' => $validated['amount'],
            'milk_liter' => $validated['milk_liter'],
            'record_date' => ApiDate::parse($validated['record_date'], 'record_date'),
        ]);

        $animalIncomeGlobal = $this->landMetricsService->syncAnimalIncomeForUser($request->user());

        $totals = [
            'total_amount' => (float) $animal->records()->sum('amount'),
            'total_milk' => (float) $animal->records()->sum('milk_liter'),
        ];

        return $this->success([
            'record' => $this->recordPayload($record->fresh()),
            'totals' => $totals,
            'animal_income_global' => $animalIncomeGlobal,
        ], 'Animal record created', 201);
    }

    public function destroy(Request $request, AnimalRecord $animalRecord): JsonResponse
    {
        $animalRecord = $this->ownedRecord($request, $animalRecord);
        $animal = $animalRecord->animal;

        $animalRecord->delete();

        $animalIncomeGlobal = $this->landMetricsService->syncAnimalIncomeForUser($request->user());

        $totals = [
            'total_amount' => (float) $animal->records()->sum('amount'),
            'total_milk' => (float) $animal->records()->sum('milk_liter'),
        ];

        return $this->success([
            'deleted' => true,
            'totals' => $totals,
            'animal_income_global' => $animalIncomeGlobal,
        ], 'Animal record deleted');
    }

    private function ownedAnimal(Request $request, Animal $animal): Animal
    {
        if ($animal->user_id !== $request->user()->id) {
            abort(404);
        }

        return $animal;
    }

    private function ownedRecord(Request $request, AnimalRecord $record): AnimalRecord
    {
        if ($record->user_id !== $request->user()->id) {
            abort(404);
        }

        return $record;
    }

    private function recordPayload(AnimalRecord $record): array
    {
        return [
            'id' => $record->id,
            'animal_id' => $record->animal_id,
            'amount' => (float) $record->amount,
            'milk_liter' => (float) $record->milk_liter,
            'record_date' => optional($record->record_date)->format('Y-m-d'),
            'created_at' => optional($record->created_at)?->toDateTimeString(),
            'updated_at' => optional($record->updated_at)?->toDateTimeString(),
        ];
    }
}
