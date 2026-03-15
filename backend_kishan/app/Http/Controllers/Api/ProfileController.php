<?php

namespace App\Http\Controllers\Api;

use App\Support\ApiDate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
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

        if ($user->profile_image_path) {
            Storage::disk('public')->delete($user->profile_image_path);
        }

        $path = $validated['profile_image']->store('profile-images', 'public');

        $user->update([
            'profile_image_path' => $path,
        ]);

        return $this->success([
            'profile_image_url' => url('/api/v1/media/' . $path),
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
                ? url('/api/v1/media/' . $user->profile_image_path)
                : null,
            'last_login_at' => optional($user->last_login_at)?->toDateTimeString(),
        ];
    }
}
