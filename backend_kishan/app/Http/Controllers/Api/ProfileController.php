<?php

namespace App\Http\Controllers\Api;

use App\Models\AgroBill;
use App\Models\AgroFarmerContact;
use App\Models\FarmerBill;
use App\Support\ApiDate;
use Illuminate\Support\Collection;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\Rule;

class ProfileController extends ApiController
{
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        return $this->success($this->profilePayload($user), 'Profile fetched');
    }

    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:191', Rule::unique('users', 'email')->ignore($user->id)],
            'birth_date' => ['required', 'string'],
            'password' => ['nullable', 'string', 'min:6', 'confirmed'],
        ]);

        $payload = [
            'name' => $validated['name'],
            'email' => $validated['email'],
            'birth_date' => ApiDate::parse($validated['birth_date'], 'birth_date'),
        ];

        if (!empty($validated['password'])) {
            $payload['password'] = $validated['password'];
        }

        $user->update($payload);

        return $this->success([
            'user' => $this->profilePayload($user->fresh()),
        ], 'Profile updated');
    }

    public function updateProfileImage(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'profile_image' => ['required', 'image', 'max:5120'],
        ]);

        $file = $validated['profile_image'];
        $fileName = uniqid() . '_' . $file->getClientOriginalName();

        $supabaseUrl = env('SUPABASE_URL');
        $supabaseKey = env('SUPABASE_KEY');
        $bucket = env('SUPABASE_BUCKET_PROFILE');

        if ($user->profile_image_path) {
            Http::withHeaders([
                'Authorization' => 'Bearer ' . $supabaseKey,
            ])->delete(
                $supabaseUrl . '/storage/v1/object/' . $bucket . '/' . $user->profile_image_path
            );
        }

        Http::withHeaders([
            'Authorization' => 'Bearer ' . $supabaseKey,
        ])->attach(
            'file',
            file_get_contents($file),
            $fileName
        )->post(
            $supabaseUrl . '/storage/v1/object/' . $bucket . '/' . $fileName
        );

        // Save filename
        $user->update([
            'profile_image_path' => $fileName,
        ]);

        return $this->success([
            'profile_image_url' => $supabaseUrl . '/storage/v1/object/public/' . $bucket . '/' . $fileName,
        ], 'Profile image updated');
    }

    public function updateLanguage(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'preferred_language' => ['required', Rule::in(['en', 'gu', 'hi'])],
        ]);

        $user = $request->user();
        $user->update([
            'preferred_language' => $validated['preferred_language'],
        ]);

        return $this->success([
            'preferred_language' => $user->preferred_language,
        ], 'Language updated');
    }

    public function myBills(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user || $user->user_role !== 'farmer') {
            return $this->error('Only farmer users can access this endpoint.', [], 403);
        }

        $source = (string) $request->query('source', 'all');
        if (!in_array($source, ['all', 'agro', 'farmer'], true)) {
            $source = 'all';
        }

        $mobile = trim((string) $user->mobile);
        $normalizedMobile = $this->digitsOnly($mobile);
        $lastTenDigits = $this->lastTenDigits($mobile);

        $agroBills = collect();
        if ($source !== 'farmer' && $normalizedMobile !== '') {
            $matchingContactIds = AgroFarmerContact::query()
                ->get(['id', 'mobile'])
                ->filter(function (AgroFarmerContact $contact) use ($normalizedMobile, $lastTenDigits): bool {
                    return $this->mobilesMatch($normalizedMobile, $lastTenDigits, (string) $contact->mobile);
                })
                ->pluck('id')
                ->values();

            $agroBills = AgroBill::query()
                ->with(['agroOwner:id,name,mobile', 'farmer:id,name,mobile'])
                ->whereIn('farmer_id', $matchingContactIds)
                ->latest('bill_date')
                ->latest('id')
                ->get()
                ->values();
        }

        $farmerBills = collect();
        if ($source !== 'agro') {
            $farmerBills = FarmerBill::query()
                ->where('farmer_id', $user->id)
                ->latest('bill_date')
                ->latest('id')
                ->get();
        }

        $rows = $this->combineBills($agroBills, $farmerBills);

        return $this->success([
            'bills' => $rows,
        ], 'Bills fetched');
    }

    public function storeFarmerBill(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user || $user->user_role !== 'farmer') {
            return $this->error('Only farmer users can access this endpoint.', [], 403);
        }

        $validated = $request->validate([
            'bill_date' => ['required', 'string'],
            'payment_status' => ['required', Rule::in(['pending', 'completed'])],
            'amount' => ['nullable', 'numeric', 'gte:0'],
            'note' => ['nullable', 'string'],
        ]);

        $bill = FarmerBill::query()->create([
            'farmer_id' => $user->id,
            'bill_date' => ApiDate::parse($validated['bill_date'], 'bill_date'),
            'payment_status' => $validated['payment_status'],
            'amount' => (float) ($validated['amount'] ?? 0),
            'note' => $validated['note'] ?? null,
        ]);

        return $this->success([
            'bill' => $this->farmerBillRow($bill),
        ], 'Farmer bill created', 201);
    }

    public function updateFarmerBill(Request $request, FarmerBill $farmerBill): JsonResponse
    {
        $user = $request->user();

        if (!$user || $user->user_role !== 'farmer') {
            return $this->error('Only farmer users can access this endpoint.', [], 403);
        }

        if ((int) $farmerBill->farmer_id !== (int) $user->id) {
            abort(404);
        }

        $validated = $request->validate([
            'bill_date' => ['required', 'string'],
            'payment_status' => ['required', Rule::in(['pending', 'completed'])],
            'amount' => ['nullable', 'numeric', 'gte:0'],
            'note' => ['nullable', 'string'],
        ]);

        $farmerBill->update([
            'bill_date' => ApiDate::parse($validated['bill_date'], 'bill_date'),
            'payment_status' => $validated['payment_status'],
            'amount' => (float) ($validated['amount'] ?? 0),
            'note' => $validated['note'] ?? null,
        ]);

        return $this->success([
            'bill' => $this->farmerBillRow($farmerBill->fresh()),
        ], 'Farmer bill updated');
    }

    public function deleteFarmerBill(Request $request, FarmerBill $farmerBill): JsonResponse
    {
        $user = $request->user();

        if (!$user || $user->user_role !== 'farmer') {
            return $this->error('Only farmer users can access this endpoint.', [], 403);
        }

        if ((int) $farmerBill->farmer_id !== (int) $user->id) {
            abort(404);
        }

        $farmerBill->delete();

        return $this->success([
            'deleted' => true,
        ], 'Farmer bill deleted');
    }

    /**
     * @param Collection<int, AgroBill> $agroBills
     * @param Collection<int, FarmerBill> $farmerBills
     * @return Collection<int, array<string, mixed>>
     */
    private function combineBills(Collection $agroBills, Collection $farmerBills): Collection
    {
        $rows = $agroBills
            ->map(fn(AgroBill $bill) => $this->agroBillRow($bill))
            ->concat($farmerBills->map(fn(FarmerBill $bill) => $this->farmerBillRow($bill)))
            ->sortByDesc(function (array $row): string {
                $date = (string) ($row['bill_date'] ?? '');
                $created = (string) ($row['created_at'] ?? '');

                return $date . ' ' . $created;
            })
            ->values();

        return $rows;
    }

    private function agroBillRow(AgroBill $bill): array
    {
        return [
            'id' => $bill->id,
            'source' => 'agro',
            'bill_date' => optional($bill->bill_date)->format('Y-m-d'),
            'payment_status' => $bill->payment_status,
            'amount' => (float) $bill->amount,
            'note' => $bill->note,
            'agro_owner_name' => $bill->agroOwner?->name,
            'agro_owner_mobile' => $bill->agroOwner?->mobile,
            'bill_photo_path' => $bill->bill_photo_path,
            'bill_photo_url' => $this->billPhotoUrl($bill->bill_photo_path),
            'created_at' => optional($bill->created_at)?->toDateTimeString(),
        ];
    }

    private function farmerBillRow(FarmerBill $bill): array
    {
        return [
            'id' => $bill->id,
            'source' => 'farmer',
            'bill_date' => optional($bill->bill_date)->format('Y-m-d'),
            'payment_status' => $bill->payment_status,
            'amount' => (float) $bill->amount,
            'note' => $bill->note,
            'agro_owner_name' => null,
            'agro_owner_mobile' => null,
            'bill_photo_path' => null,
            'bill_photo_url' => null,
            'created_at' => optional($bill->created_at)?->toDateTimeString(),
        ];
    }

    private function billPhotoUrl(?string $billPhotoPath): ?string
    {
        if (empty($billPhotoPath)) {
            return null;
        }

        $supabaseUrl = env('SUPABASE_URL');
        $bucket = env('SUPABASE_BUCKET_AGRO_BILLS', env('SUPABASE_BUCKET_EXPENSE'));

        if (!empty($supabaseUrl) && !empty($bucket)) {
            return $supabaseUrl . '/storage/v1/object/public/' . $bucket . '/' . $billPhotoPath;
        }

        return asset('storage/' . ltrim($billPhotoPath, '/'));
    }

    private function lastTenDigits(string $mobile): string
    {
        $digits = $this->digitsOnly($mobile);

        if ($digits === '') {
            return '';
        }

        return strlen($digits) > 10 ? substr($digits, -10) : $digits;
    }

    private function digitsOnly(string $mobile): string
    {
        return preg_replace('/\D+/', '', trim($mobile)) ?? '';
    }

    private function mobilesMatch(string $normalizedUserMobile, string $lastTenDigits, string $candidateMobile): bool
    {
        $candidateDigits = $this->digitsOnly($candidateMobile);
        if ($candidateDigits === '') {
            return false;
        }

        if ($candidateDigits === $normalizedUserMobile) {
            return true;
        }

        if ($lastTenDigits !== '' && $this->lastTenDigits($candidateDigits) === $lastTenDigits) {
            return true;
        }

        return false;
    }

    private function profilePayload($user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'mobile' => $user->mobile,
            'birth_date' => optional($user->birth_date)->format('Y-m-d'),
            'preferred_language' => $user->preferred_language,
            'user_role' => $user->user_role,
            'profile_image_url' => $user->profile_image_path
                ? env('SUPABASE_URL') . '/storage/v1/object/public/' . env('SUPABASE_BUCKET_PROFILE') . '/' . $user->profile_image_path
                : null,
            'last_login_at' => optional($user->last_login_at)?->toDateTimeString(),
        ];
    }
}
