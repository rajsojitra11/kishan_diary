<?php

namespace App\Http\Controllers\Api;

use App\Models\Animal;
use App\Services\LandMetricsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AnimalController extends ApiController
{
    public function __construct(private readonly LandMetricsService $landMetricsService) {}

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $animals = $user->animals()
            ->withSum('records as total_amount', 'amount')
            ->withSum('records as total_milk', 'milk_liter')
            ->latest('id')
            ->get();

        return $this->success([
            'animals' => $animals->map(function (Animal $animal) {
                return [
                    'id' => $animal->id,
                    'animal_name' => $animal->animal_name,
                    'total_amount' => (float) ($animal->total_amount ?? 0),
                    'total_milk' => (float) ($animal->total_milk ?? 0),
                    'created_at' => optional($animal->created_at)?->toDateTimeString(),
                    'updated_at' => optional($animal->updated_at)?->toDateTimeString(),
                ];
            })->values(),
            'animal_income_global' => (float) $animals->sum('total_amount'),
        ], 'Animals fetched');
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'animal_name' => [
                'required',
                'string',
                'max:100',
                Rule::unique('animals', 'animal_name')->where(fn($query) => $query->where('user_id', $request->user()->id)),
            ],
        ]);

        $animal = $request->user()->animals()->create([
            'animal_name' => $validated['animal_name'],
        ]);

        $animalIncomeGlobal = $this->landMetricsService->syncAnimalIncomeForUser($request->user());

        return $this->success([
            'animal' => [
                'id' => $animal->id,
                'animal_name' => $animal->animal_name,
            ],
            'animal_income_global' => $animalIncomeGlobal,
        ], 'Animal created', 201);
    }

    public function update(Request $request, Animal $animal): JsonResponse
    {
        $animal = $this->ownedAnimal($request, $animal);

        $validated = $request->validate([
            'animal_name' => [
                'required',
                'string',
                'max:100',
                Rule::unique('animals', 'animal_name')
                    ->where(fn($query) => $query->where('user_id', $request->user()->id))
                    ->ignore($animal->id),
            ],
        ]);

        $animal->update([
            'animal_name' => $validated['animal_name'],
        ]);

        return $this->success([
            'animal' => [
                'id' => $animal->id,
                'animal_name' => $animal->animal_name,
            ],
        ], 'Animal updated');
    }

    public function destroy(Request $request, Animal $animal): JsonResponse
    {
        $animal = $this->ownedAnimal($request, $animal);
        $animal->delete();

        $animalIncomeGlobal = $this->landMetricsService->syncAnimalIncomeForUser($request->user());

        return $this->success([
            'deleted' => true,
            'animal_income_global' => $animalIncomeGlobal,
        ], 'Animal deleted');
    }

    private function ownedAnimal(Request $request, Animal $animal): Animal
    {
        if ($animal->user_id !== $request->user()->id) {
            abort(404);
        }

        return $animal;
    }
}
