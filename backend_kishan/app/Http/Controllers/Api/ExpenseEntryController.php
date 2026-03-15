<?php

namespace App\Http\Controllers\Api;

use App\Models\ExpenseEntry;
use App\Models\Land;
use App\Services\LandMetricsService;
use App\Support\ApiDate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ExpenseEntryController extends ApiController
{
    public function __construct(private readonly LandMetricsService $landMetricsService) {}

    public function index(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        $query = $land->expenseEntries()->orderByDesc('entry_date');

        if ($request->filled('from_date')) {
            $query->whereDate('entry_date', '>=', ApiDate::parse((string) $request->query('from_date'), 'from_date'));
        }

        if ($request->filled('to_date')) {
            $query->whereDate('entry_date', '<=', ApiDate::parse((string) $request->query('to_date'), 'to_date'));
        }

        if ($request->filled('expense_type')) {
            $query->where('expense_type', (string) $request->query('expense_type'));
        }

        $entries = $query->get();

        return $this->success([
            'expense_entries' => $entries->map(fn(ExpenseEntry $entry) => $this->entryPayload($entry))->values(),
            'total_expense' => (float) $entries->sum('amount'),
            'fertilizer_kg' => (float) $entries
                ->whereIn('expense_type', ['expenseTypeMedicine', 'expenseTypeSeeds'])
                ->sum('amount'),
        ], 'Expense entries fetched');
    }

    public function store(Request $request, Land $land): JsonResponse
    {
        $land = $this->ownedLand($request, $land);

        $validated = $request->validate([
            'expense_type' => ['required', Rule::in([
                'expenseTypeMedicine',
                'expenseTypeSeeds',
                'expenseTypeTractor',
                'expenseTypeLightBill',
                'expenseTypeOther',
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
            $billPhotoPath = $file->store('expense-bills', 'public');
            $billPhotoMime = $file->getMimeType();
        }

        $entry = $land->expenseEntries()->create([
            'user_id' => $request->user()->id,
            'expense_type' => $validated['expense_type'],
            'amount' => $validated['amount'],
            'entry_date' => ApiDate::parse($validated['entry_date'], 'entry_date'),
            'note' => $validated['note'] ?? null,
            'bill_photo_path' => $billPhotoPath,
            'bill_photo_mime' => $billPhotoMime,
        ]);

        $land = $this->landMetricsService->recalculateLand($land);

        return $this->success([
            'expense_entry' => $this->entryPayload($entry->fresh()),
            'land_totals' => [
                'expense_total' => (float) $land->expense_total,
                'fertilizer_kg' => (float) $land->fertilizer_kg,
            ],
        ], 'Expense entry created', 201);
    }

    public function update(Request $request, ExpenseEntry $expenseEntry): JsonResponse
    {
        $expenseEntry = $this->ownedEntry($request, $expenseEntry);

        $validated = $request->validate([
            'expense_type' => ['required', Rule::in([
                'expenseTypeMedicine',
                'expenseTypeSeeds',
                'expenseTypeTractor',
                'expenseTypeLightBill',
                'expenseTypeOther',
            ])],
            'amount' => ['required', 'numeric', 'gt:0'],
            'entry_date' => ['required', 'string'],
            'note' => ['nullable', 'string'],
            'bill_photo' => ['nullable', 'image', 'max:5120'],
        ]);

        $updatePayload = [
            'expense_type' => $validated['expense_type'],
            'amount' => $validated['amount'],
            'entry_date' => ApiDate::parse($validated['entry_date'], 'entry_date'),
            'note' => $validated['note'] ?? null,
        ];

        if ($request->hasFile('bill_photo')) {
            if ($expenseEntry->bill_photo_path) {
                Storage::disk('public')->delete($expenseEntry->bill_photo_path);
            }

            $file = $request->file('bill_photo');
            $updatePayload['bill_photo_path'] = $file->store('expense-bills', 'public');
            $updatePayload['bill_photo_mime'] = $file->getMimeType();
        }

        $expenseEntry->update($updatePayload);

        $land = $this->landMetricsService->recalculateLand($expenseEntry->land);

        return $this->success([
            'expense_entry' => $this->entryPayload($expenseEntry->fresh()),
            'land_totals' => [
                'expense_total' => (float) $land->expense_total,
                'fertilizer_kg' => (float) $land->fertilizer_kg,
            ],
        ], 'Expense entry updated');
    }

    public function destroy(Request $request, ExpenseEntry $expenseEntry): JsonResponse
    {
        $expenseEntry = $this->ownedEntry($request, $expenseEntry);
        $land = $expenseEntry->land;

        if ($expenseEntry->bill_photo_path) {
            Storage::disk('public')->delete($expenseEntry->bill_photo_path);
        }

        $expenseEntry->delete();

        $land = $this->landMetricsService->recalculateLand($land);

        return $this->success([
            'deleted' => true,
            'land_totals' => [
                'expense_total' => (float) $land->expense_total,
                'fertilizer_kg' => (float) $land->fertilizer_kg,
            ],
        ], 'Expense entry deleted');
    }

    private function ownedLand(Request $request, Land $land): Land
    {
        if ($land->user_id !== $request->user()->id) {
            abort(404);
        }

        return $land;
    }

    private function ownedEntry(Request $request, ExpenseEntry $entry): ExpenseEntry
    {
        if ($entry->user_id !== $request->user()->id) {
            abort(404);
        }

        return $entry;
    }

    private function entryPayload(ExpenseEntry $entry): array
    {
        return [
            'id' => $entry->id,
            'land_id' => $entry->land_id,
            'expense_type' => $entry->expense_type,
            'amount' => (float) $entry->amount,
            'entry_date' => optional($entry->entry_date)->format('Y-m-d'),
            'note' => $entry->note,
            'bill_photo_path' => $entry->bill_photo_path,
            'bill_photo_url' => $entry->bill_photo_path ? url('/api/v1/media/' . $entry->bill_photo_path) : null,
            'bill_photo_mime' => $entry->bill_photo_mime,
            'created_at' => optional($entry->created_at)?->toDateTimeString(),
            'updated_at' => optional($entry->updated_at)?->toDateTimeString(),
        ];
    }
}
