<?php

namespace App\Http\Controllers\Api;

use App\Models\LaborEntry;
use App\Models\UpadEntry;
use App\Support\ApiDate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UpadEntryController extends ApiController
{
    public function index(Request $request, LaborEntry $laborEntry): JsonResponse
    {
        $laborEntry = $this->ownedLabor($request, $laborEntry);

        $entries = $laborEntry->upadEntries()->latest('payment_date')->get();

        return $this->success([
            'upad_entries' => $entries->map(fn(UpadEntry $entry) => $this->entryPayload($entry))->values(),
            'total_upad_amount' => (float) $entries->sum('amount'),
        ], 'Upad entries fetched');
    }

    public function store(Request $request, LaborEntry $laborEntry): JsonResponse
    {
        $laborEntry = $this->ownedLabor($request, $laborEntry);

        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'gt:0'],
            'note' => ['nullable', 'string'],
            'payment_date' => ['required', 'string'],
            'labor_name_snapshot' => ['nullable', 'string', 'max:150'],
        ]);

        $entry = $laborEntry->upadEntries()->create([
            'user_id' => $request->user()->id,
            'land_id' => $laborEntry->land_id,
            'labor_name_snapshot' => $validated['labor_name_snapshot'] ?? $laborEntry->labor_name,
            'amount' => $validated['amount'],
            'note' => $validated['note'] ?? null,
            'payment_date' => ApiDate::parse($validated['payment_date'], 'payment_date'),
        ]);

        return $this->success([
            'upad_entry' => $this->entryPayload($entry->fresh()),
            'labor_summary' => $this->laborSummary($laborEntry->fresh()),
        ], 'Upad entry created', 201);
    }

    public function update(Request $request, UpadEntry $upadEntry): JsonResponse
    {
        $upadEntry = $this->ownedUpad($request, $upadEntry);

        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'gt:0'],
            'note' => ['nullable', 'string'],
            'payment_date' => ['required', 'string'],
            'labor_name_snapshot' => ['nullable', 'string', 'max:150'],
        ]);

        $upadEntry->update([
            'amount' => $validated['amount'],
            'note' => $validated['note'] ?? null,
            'payment_date' => ApiDate::parse($validated['payment_date'], 'payment_date'),
            'labor_name_snapshot' => $validated['labor_name_snapshot'] ?? $upadEntry->laborEntry->labor_name,
        ]);

        return $this->success([
            'upad_entry' => $this->entryPayload($upadEntry->fresh()),
            'labor_summary' => $this->laborSummary($upadEntry->laborEntry->fresh()),
        ], 'Upad entry updated');
    }

    public function destroy(Request $request, UpadEntry $upadEntry): JsonResponse
    {
        $upadEntry = $this->ownedUpad($request, $upadEntry);
        $laborEntry = $upadEntry->laborEntry;

        $upadEntry->delete();

        return $this->success([
            'deleted' => true,
            'labor_summary' => $this->laborSummary($laborEntry->fresh()),
        ], 'Upad entry deleted');
    }

    private function laborSummary(LaborEntry $laborEntry): array
    {
        $totalPaid = (float) $laborEntry->upadEntries()->sum('amount');
        $pendingAmount = max((float) $laborEntry->total_wage - $totalPaid, 0);

        return [
            'total_upad_paid' => $totalPaid,
            'pending_amount' => $pendingAmount,
        ];
    }

    private function ownedLabor(Request $request, LaborEntry $laborEntry): LaborEntry
    {
        if (
            $laborEntry->user_id !== $request->user()->id ||
            !$laborEntry->land ||
            !$laborEntry->land->is_active
        ) {
            abort(404);
        }

        return $laborEntry;
    }

    private function ownedUpad(Request $request, UpadEntry $upadEntry): UpadEntry
    {
        if (
            $upadEntry->user_id !== $request->user()->id ||
            !$upadEntry->land ||
            !$upadEntry->land->is_active
        ) {
            abort(404);
        }

        return $upadEntry;
    }

    private function entryPayload(UpadEntry $entry): array
    {
        return [
            'id' => $entry->id,
            'labor_entry_id' => $entry->labor_entry_id,
            'land_id' => $entry->land_id,
            'labor_name_snapshot' => $entry->labor_name_snapshot,
            'amount' => (float) $entry->amount,
            'note' => $entry->note,
            'payment_date' => optional($entry->payment_date)->format('Y-m-d'),
            'created_at' => optional($entry->created_at)?->toDateTimeString(),
            'updated_at' => optional($entry->updated_at)?->toDateTimeString(),
        ];
    }
}
