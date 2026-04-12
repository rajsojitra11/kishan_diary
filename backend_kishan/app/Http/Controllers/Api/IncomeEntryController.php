<?php

namespace App\Http\Controllers\Api;

use App\Models\IncomeEntry;
use App\Models\Land;
use App\Services\LandMetricsService;
use App\Support\ApiDate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\Rule;

class IncomeEntryController extends ApiController
{
    public function __construct(private readonly LandMetricsService $landMetricsService) {}

    public function index(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        $query = $land->incomeEntries()->orderByDesc('entry_date');

        if ($request->filled('from_date')) {
            $query->whereDate('entry_date', '>=', ApiDate::parse((string) $request->query('from_date'), 'from_date'));
        }

        if ($request->filled('to_date')) {
            $query->whereDate('entry_date', '<=', ApiDate::parse((string) $request->query('to_date'), 'to_date'));
        }

        if ($request->filled('income_type')) {
            $query->where('income_type', (string) $request->query('income_type'));
        }

        $entries = $query->get();

        return $this->success([
            'income_entries' => $entries->map(fn(IncomeEntry $entry) => $this->entryPayload($entry))->values(),
            'total_income' => (float) $entries->sum('amount'),
        ], 'Income entries fetched');
    }

    public function store(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        $validated = $request->validate([
            'income_type' => ['required', Rule::in([
                'incomeTypeCropSale',
                'incomeTypeTractorHarvester',
                'incomeTypeVegetables',
                'incomeTypeAnimalPasu',
                'incomeTypeSubsidy',
                'incomeTypeOther',
            ])],
            'amount' => ['required', 'numeric', 'gt:0'],
            'entry_date' => ['required', 'string'],
            'note' => ['nullable', 'string'],
            'bill_photo' => ['nullable', 'image', 'max:5120'],
        ]);

        $billPhotoPath = null;
        $billPhotoMime = null;

        if ($request->hasFile('bill_photo')) {
            $file = $request->file('bill_photo');
            $fileName = uniqid() . '_' . $file->getClientOriginalName();

            Http::withHeaders([
                'Authorization' => 'Bearer ' . env('SUPABASE_KEY'),
            ])->attach(
                'file',
                file_get_contents($file),
                $fileName
            )->post(
                env('SUPABASE_URL') . '/storage/v1/object/' . env('SUPABASE_BUCKET_INCOME') . '/' . $fileName
            );

            $billPhotoPath = $fileName;
            $billPhotoMime = $file->getMimeType();
        }

        $entry = $land->incomeEntries()->create([
            'user_id' => $request->user()->id,
            'income_type' => $validated['income_type'],
            'amount' => $validated['amount'],
            'entry_date' => ApiDate::parse($validated['entry_date'], 'entry_date'),
            'note' => $validated['note'] ?? null,
            'bill_photo_path' => $billPhotoPath,
            'bill_photo_mime' => $billPhotoMime,
        ]);

        $land = $this->landMetricsService->recalculateLand($land);

        return $this->success([
            'income_entry' => $this->entryPayload($entry->fresh()),
            'land_totals' => [
                'income_total' => (float) $land->income_total,
            ],
        ], 'Income entry created', 201);
    }

    public function update(Request $request, IncomeEntry $incomeEntry): JsonResponse
    {
        $incomeEntry = $this->ownedEntry($request, $incomeEntry);

        $validated = $request->validate([
            'income_type' => ['required', Rule::in([
                'incomeTypeCropSale',
                'incomeTypeTractorHarvester',
                'incomeTypeVegetables',
                'incomeTypeAnimalPasu',
                'incomeTypeSubsidy',
                'incomeTypeOther',
            ])],
            'amount' => ['required', 'numeric', 'gt:0'],
            'entry_date' => ['required', 'string'],
            'note' => ['nullable', 'string'],
            'bill_photo' => ['nullable', 'image', 'max:5120'],
        ]);

        $updatePayload = [
            'income_type' => $validated['income_type'],
            'amount' => $validated['amount'],
            'entry_date' => ApiDate::parse($validated['entry_date'], 'entry_date'),
            'note' => $validated['note'] ?? null,
        ];

        if ($request->hasFile('bill_photo')) {
            if ($incomeEntry->bill_photo_path) {
                Http::withHeaders([
                    'Authorization' => 'Bearer ' . env('SUPABASE_KEY'),
                ])->delete(
                    env('SUPABASE_URL') . '/storage/v1/object/' . env('SUPABASE_BUCKET_INCOME') . '/' . $incomeEntry->bill_photo_path
                );
            }

            $file = $request->file('bill_photo');
            $fileName = uniqid() . '_' . $file->getClientOriginalName();

            Http::withHeaders([
                'Authorization' => 'Bearer ' . env('SUPABASE_KEY'),
            ])->attach(
                'file',
                file_get_contents($file),
                $fileName
            )->post(
                env('SUPABASE_URL') . '/storage/v1/object/' . env('SUPABASE_BUCKET_INCOME') . '/' . $fileName
            );

            $updatePayload['bill_photo_path'] = $fileName;
            $updatePayload['bill_photo_mime'] = $file->getMimeType();
        }

        $incomeEntry->update($updatePayload);

        $land = $this->landMetricsService->recalculateLand($incomeEntry->land);

        return $this->success([
            'income_entry' => $this->entryPayload($incomeEntry->fresh()),
            'land_totals' => [
                'income_total' => (float) $land->income_total,
            ],
        ], 'Income entry updated');
    }

    public function destroy(Request $request, IncomeEntry $incomeEntry): JsonResponse
    {
        $incomeEntry = $this->ownedEntry($request, $incomeEntry);
        $land = $incomeEntry->land;

        if ($incomeEntry->bill_photo_path) {
            Http::withHeaders([
                'Authorization' => 'Bearer ' . env('SUPABASE_KEY'),
            ])->delete(
                env('SUPABASE_URL') . '/storage/v1/object/' . env('SUPABASE_BUCKET_INCOME') . '/' . $incomeEntry->bill_photo_path
            );
        }

        $incomeEntry->delete();

        $land = $this->landMetricsService->recalculateLand($land);

        return $this->success([
            'deleted' => true,
            'land_totals' => [
                'income_total' => (float) $land->income_total,
            ],
        ], 'Income entry deleted');
    }

    private function ownedLand(Request $request, Land $land): Land
    {
        if ($land->user_id !== $request->user()->id || !$land->is_active) {
            abort(404);
        }

        return $land;
    }

    private function ownedEntry(Request $request, IncomeEntry $entry): IncomeEntry
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

    private function entryPayload(IncomeEntry $entry): array
    {
        return [
            'id' => $entry->id,
            'land_id' => $entry->land_id,
            'income_type' => $entry->income_type,
            'amount' => (float) $entry->amount,
            'entry_date' => optional($entry->entry_date)->format('Y-m-d'),
            'note' => $entry->note,
            'bill_photo_path' => $entry->bill_photo_path,
            'bill_photo_url' => $entry->bill_photo_path
                ? env('SUPABASE_URL') . '/storage/v1/object/public/' . env('SUPABASE_BUCKET_INCOME') . '/' . $entry->bill_photo_path
                : null,
            'bill_photo_mime' => $entry->bill_photo_mime,
            'created_at' => optional($entry->created_at)?->toDateTimeString(),
            'updated_at' => optional($entry->updated_at)?->toDateTimeString(),
        ];
    }
}
