<?php

namespace App\Http\Controllers\Api;

use App\Support\ApiDate;
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

    private function profilePayload($user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'mobile' => $user->mobile,
            'birth_date' => optional($user->birth_date)->format('Y-m-d'),
            'preferred_language' => $user->preferred_language,
            'profile_image_url' => $user->profile_image_path
                ? env('SUPABASE_URL') . '/storage/v1/object/public/' . env('SUPABASE_BUCKET_PROFILE') . '/' . $user->profile_image_path
                : null,
            'last_login_at' => optional($user->last_login_at)?->toDateTimeString(),
        ];
    }
}
