<?php

namespace App\Http\Controllers\Api;

use App\Models\AgroBill;
use App\Models\AgroFarmerContact;
use App\Models\User;
use App\Support\ApiDate;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class AgroCenterController extends ApiController
{
    public function dashboardSummary(Request $request): JsonResponse
    {
        $user = $this->agroOwner($request);

        $bills = AgroBill::query()->where('agro_owner_id', $user->id);
        $farmersQuery = $this->agroFarmersQuery($user);

        return $this->success([
            'farmers_count' => (int) (clone $farmersQuery)->count(),
            'bills_total' => (int) $bills->count(),
            'bills_pending' => (int) (clone $bills)->where('payment_status', 'pending')->count(),
            'bills_completed' => (int) (clone $bills)->where('payment_status', 'completed')->count(),
            'amount_total' => (float) (clone $bills)->sum('amount'),
            'amount_pending' => (float) (clone $bills)->where('payment_status', 'pending')->sum('amount'),
            'amount_completed' => (float) (clone $bills)->where('payment_status', 'completed')->sum('amount'),
        ], 'Agro dashboard summary fetched');
    }

    public function farmers(Request $request): JsonResponse
    {
        $user = $this->agroOwner($request);

        $farmers = $this->agroFarmersQuery($user)
            ->orderBy('name')
            ->get(['id', 'name', 'mobile']);

        return $this->success([
            'farmers' => $farmers,
        ], 'Farmers fetched');
    }

    public function storeFarmer(Request $request): JsonResponse
    {
        $agroOwner = $this->agroOwner($request);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'mobile' => [
                'required',
                'regex:/^\d{10}$/',
                Rule::unique('agro_farmer_contacts', 'mobile')->where(fn ($query) => $query->where('agro_owner_id', $agroOwner->id)),
            ],
        ]);

        $farmer = AgroFarmerContact::query()->create([
            'agro_owner_id' => $agroOwner->id,
            'name' => trim((string) $validated['name']),
            'mobile' => (string) $validated['mobile'],
        ]);

        return $this->success([
            'farmer' => [
                'id' => $farmer->id,
                'name' => $farmer->name,
                'mobile' => $farmer->mobile,
            ],
        ], 'Farmer created', 201);
    }

    public function updateFarmer(Request $request, AgroFarmerContact $farmer): JsonResponse
    {
        $agroOwner = $this->agroOwner($request);
        $farmer = $this->ownedFarmer($agroOwner, $farmer);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'mobile' => [
                'required',
                'regex:/^\d{10}$/',
                Rule::unique('agro_farmer_contacts', 'mobile')
                    ->ignore($farmer->id)
                    ->where(fn ($query) => $query->where('agro_owner_id', $agroOwner->id)),
            ],
        ]);

        $farmer->update([
            'name' => trim((string) $validated['name']),
            'mobile' => (string) $validated['mobile'],
        ]);

        return $this->success([
            'farmer' => [
                'id' => $farmer->id,
                'name' => $farmer->name,
                'mobile' => $farmer->mobile,
            ],
        ], 'Farmer updated');
    }

    public function deleteFarmer(Request $request, AgroFarmerContact $farmer): JsonResponse
    {
        $agroOwner = $this->agroOwner($request);
        $farmer = $this->ownedFarmer($agroOwner, $farmer);

        $farmer->delete();

        return $this->success([
            'deleted' => true,
        ], 'Farmer deleted');
    }

    public function bills(Request $request): JsonResponse
    {
        $user = $this->agroOwner($request);

        $query = AgroBill::query()
            ->where('agro_owner_id', $user->id)
            ->with('farmer:id,name,mobile');

        if ($request->filled('farmer_id')) {
            $query->where('farmer_id', (int) $request->query('farmer_id'));
        }

        if ($request->filled('payment_status')) {
            $query->where('payment_status', (string) $request->query('payment_status'));
        }

        if ($request->filled('from_date')) {
            $query->whereDate('bill_date', '>=', ApiDate::parse((string) $request->query('from_date'), 'from_date'));
        }

        if ($request->filled('to_date')) {
            $query->whereDate('bill_date', '<=', ApiDate::parse((string) $request->query('to_date'), 'to_date'));
        }

        $bills = $query->latest('bill_date')->latest('id')->get();

        return $this->success([
            'bills' => $bills->map(fn(AgroBill $bill) => $this->billPayload($bill))->values(),
            'summary' => [
                'total' => (int) $bills->count(),
                'pending' => (int) $bills->where('payment_status', 'pending')->count(),
                'completed' => (int) $bills->where('payment_status', 'completed')->count(),
                'amount_total' => (float) $bills->sum('amount'),
            ],
        ], 'Agro bills fetched');
    }

    public function storeBill(Request $request): JsonResponse
    {
        $user = $this->agroOwner($request);

        $validated = $request->validate([
            'farmer_id' => [
                'required',
                'integer',
                Rule::exists('agro_farmer_contacts', 'id')->where(function ($query) use ($user): void {
                    $query->where('agro_owner_id', $user->id);
                }),
            ],
            'bill_date' => ['required', 'string'],
            'payment_status' => ['required', Rule::in(['pending', 'completed'])],
            'amount' => ['nullable', 'numeric', 'gte:0'],
            'note' => ['nullable', 'string'],
            'bill_photo' => ['required', 'image', 'max:5120'],
        ]);

        [$billPhotoPath, $billPhotoMime] = $this->uploadBillPhoto($request);

        $bill = AgroBill::query()->create([
            'agro_owner_id' => $user->id,
            'farmer_id' => (int) $validated['farmer_id'],
            'bill_date' => ApiDate::parse($validated['bill_date'], 'bill_date'),
            'payment_status' => $validated['payment_status'],
            'amount' => (float) ($validated['amount'] ?? 0),
            'note' => $validated['note'] ?? null,
            'bill_photo_path' => $billPhotoPath,
            'bill_photo_mime' => $billPhotoMime,
        ]);

        $bill->load('farmer:id,name,mobile');

        return $this->success([
            'bill' => $this->billPayload($bill),
        ], 'Agro bill created', 201);
    }

    public function updateBill(Request $request, AgroBill $agroBill): JsonResponse
    {
        $user = $this->agroOwner($request);
        $agroBill = $this->ownedBill($request, $agroBill);

        $validated = $request->validate([
            'farmer_id' => [
                'required',
                'integer',
                Rule::exists('agro_farmer_contacts', 'id')->where(function ($query) use ($user): void {
                    $query->where('agro_owner_id', $user->id);
                }),
            ],
            'bill_date' => ['required', 'string'],
            'payment_status' => ['required', Rule::in(['pending', 'completed'])],
            'amount' => ['nullable', 'numeric', 'gte:0'],
            'note' => ['nullable', 'string'],
            'bill_photo' => ['nullable', 'image', 'max:5120'],
        ]);

        $payload = [
            'farmer_id' => (int) $validated['farmer_id'],
            'bill_date' => ApiDate::parse($validated['bill_date'], 'bill_date'),
            'payment_status' => $validated['payment_status'],
            'amount' => (float) ($validated['amount'] ?? 0),
            'note' => $validated['note'] ?? null,
        ];

        if ($request->hasFile('bill_photo')) {
            $this->deleteBillPhoto($agroBill->bill_photo_path);
            [$billPhotoPath, $billPhotoMime] = $this->uploadBillPhoto($request);
            $payload['bill_photo_path'] = $billPhotoPath;
            $payload['bill_photo_mime'] = $billPhotoMime;
        }

        $agroBill->update($payload);
        $agroBill->load('farmer:id,name,mobile');

        return $this->success([
            'bill' => $this->billPayload($agroBill),
        ], 'Agro bill updated');
    }

    public function deleteBill(Request $request, AgroBill $agroBill): JsonResponse
    {
        $this->agroOwner($request);
        $agroBill = $this->ownedBill($request, $agroBill);

        $this->deleteBillPhoto($agroBill->bill_photo_path);
        $agroBill->delete();

        return $this->success([
            'deleted' => true,
        ], 'Agro bill deleted');
    }

    public function report(Request $request): JsonResponse
    {
        $user = $this->agroOwner($request);

        $query = AgroBill::query()
            ->where('agro_owner_id', $user->id)
            ->with('farmer:id,name,mobile');

        if ($request->filled('from_date')) {
            $query->whereDate('bill_date', '>=', ApiDate::parse((string) $request->query('from_date'), 'from_date'));
        }
        if ($request->filled('to_date')) {
            $query->whereDate('bill_date', '<=', ApiDate::parse((string) $request->query('to_date'), 'to_date'));
        }

        $bills = $query->orderBy('bill_date')->get();

        return $this->success([
            'summary' => [
                'total_bills' => (int) $bills->count(),
                'pending_bills' => (int) $bills->where('payment_status', 'pending')->count(),
                'completed_bills' => (int) $bills->where('payment_status', 'completed')->count(),
                'total_amount' => (float) $bills->sum('amount'),
                'pending_amount' => (float) $bills->where('payment_status', 'pending')->sum('amount'),
                'completed_amount' => (float) $bills->where('payment_status', 'completed')->sum('amount'),
            ],
            'rows' => $bills->map(fn(AgroBill $bill) => [
                'bill_date' => optional($bill->bill_date)->format('Y-m-d'),
                'payment_status' => $bill->payment_status,
                'amount' => (float) $bill->amount,
                'farmer_name' => $bill->farmer?->name,
                'farmer_mobile' => $bill->farmer?->mobile,
            ])->values(),
        ], 'Agro report generated');
    }

    private function agroOwner(Request $request): User
    {
        $user = $request->user();

        if (!$user || $user->user_role !== 'agro_center') {
            abort(403, 'Only agro center users can access this endpoint.');
        }

        return $user;
    }

    private function agroFarmersQuery(User $agroOwner): Builder
    {
        return AgroFarmerContact::query()->where('agro_owner_id', $agroOwner->id);
    }

    private function ownedFarmer(User $agroOwner, AgroFarmerContact $farmer): AgroFarmerContact
    {
        if ((int) $farmer->agro_owner_id !== (int) $agroOwner->id) {
            abort(404);
        }

        return $farmer;
    }

    private function ownedBill(Request $request, AgroBill $bill): AgroBill
    {
        if ($bill->agro_owner_id !== $request->user()->id) {
            abort(404);
        }

        return $bill;
    }

    private function uploadBillPhoto(Request $request): array
    {
        $file = $request->file('bill_photo');
        $fileName = uniqid('agro_bill_') . '_' . $file->getClientOriginalName();

        $supabaseUrl = env('SUPABASE_URL');
        $supabaseKey = env('SUPABASE_KEY');
        $bucket = env('SUPABASE_BUCKET_AGRO_BILLS', env('SUPABASE_BUCKET_EXPENSE'));

        if (!empty($supabaseUrl) && !empty($supabaseKey) && !empty($bucket)) {
            Http::withHeaders([
                'Authorization' => 'Bearer ' . $supabaseKey,
            ])->attach(
                'file',
                file_get_contents($file),
                $fileName
            )->post(
                $supabaseUrl . '/storage/v1/object/' . $bucket . '/' . $fileName
            );

            return [$fileName, $file->getMimeType()];
        }

        $storedPath = $file->storeAs('agro_bills', $fileName, 'public');
        return [$storedPath, $file->getMimeType()];
    }

    private function deleteBillPhoto(?string $path): void
    {
        if (empty($path)) {
            return;
        }

        $supabaseUrl = env('SUPABASE_URL');
        $supabaseKey = env('SUPABASE_KEY');
        $bucket = env('SUPABASE_BUCKET_AGRO_BILLS', env('SUPABASE_BUCKET_EXPENSE'));

        if (!empty($supabaseUrl) && !empty($supabaseKey) && !empty($bucket)) {
            Http::withHeaders([
                'Authorization' => 'Bearer ' . $supabaseKey,
            ])->delete($supabaseUrl . '/storage/v1/object/' . $bucket . '/' . $path);
            return;
        }

        Storage::disk('public')->delete($path);
    }

    private function billPayload(AgroBill $bill): array
    {
        $supabaseUrl = env('SUPABASE_URL');
        $bucket = env('SUPABASE_BUCKET_AGRO_BILLS', env('SUPABASE_BUCKET_EXPENSE'));

        $photoUrl = null;
        if (!empty($bill->bill_photo_path)) {
            if (!empty($supabaseUrl) && !empty($bucket)) {
                $photoUrl = $supabaseUrl . '/storage/v1/object/public/' . $bucket . '/' . $bill->bill_photo_path;
            } else {
                $photoUrl = asset('storage/' . ltrim($bill->bill_photo_path, '/'));
            }
        }

        return [
            'id' => $bill->id,
            'agro_owner_id' => $bill->agro_owner_id,
            'farmer_id' => $bill->farmer_id,
            'farmer_name' => $bill->farmer?->name,
            'farmer_mobile' => $bill->farmer?->mobile,
            'bill_date' => optional($bill->bill_date)->format('Y-m-d'),
            'payment_status' => $bill->payment_status,
            'amount' => (float) $bill->amount,
            'note' => $bill->note,
            'bill_photo_path' => $bill->bill_photo_path,
            'bill_photo_url' => $photoUrl,
            'bill_photo_mime' => $bill->bill_photo_mime,
            'created_at' => optional($bill->created_at)?->toDateTimeString(),
            'updated_at' => optional($bill->updated_at)?->toDateTimeString(),
        ];
    }
}
