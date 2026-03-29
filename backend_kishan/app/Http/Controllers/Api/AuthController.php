<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use App\Support\ApiDate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AuthController extends ApiController
{
    public function mobileCheck(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile' => ['required', 'regex:/^\d{10}$/'],
        ]);

        $user = User::query()->where('mobile', $validated['mobile'])->first();

        if (!$user) {
            return $this->success([
                'exists' => false,
                'user' => null,
                'next_action' => 'register',
            ], 'Mobile checked');
        }

        return $this->success([
            'exists' => true,
            'user' => $this->userPayload($user),
            'next_action' => 'login_password',
        ], 'Mobile checked');
    }

    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['nullable', 'email', 'max:191', 'unique:users,email'],
            'mobile' => ['required', 'regex:/^\d{10}$/', 'unique:users,mobile'],
            'birth_date' => ['required', 'string'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'preferred_language' => ['nullable', Rule::in(['en', 'gu', 'hi'])],
            'user_role' => ['nullable', Rule::in(['farmer', 'agro_center'])],
        ]);

        $birthDate = ApiDate::parse($validated['birth_date'], 'birth_date');

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'] ?? null,
            'mobile' => $validated['mobile'],
            'birth_date' => $birthDate,
            'password' => $validated['password'],
            'preferred_language' => $validated['preferred_language'] ?? 'gu',
            'user_role' => $validated['user_role'] ?? 'farmer',
            'is_active' => true,
            'last_login_at' => now(),
            'last_login_ip' => $request->ip(),
        ]);

        $token = $this->issueToken($user);

        return $this->success([
            'token' => $token,
            'user' => $this->userPayload($user->fresh()),
        ], 'Registered successfully', 201);
    }

    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile' => ['required', 'regex:/^\d{10}$/'],
            'password' => ['required', 'string'],
            'user_role' => ['required', Rule::in(['farmer', 'agro_center'])],
        ]);

        $user = User::query()->where('mobile', $validated['mobile'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return $this->error('Invalid mobile or password', [], 401);
        }

        if ($user->user_role !== $validated['user_role']) {
            return $this->error('Login type does not match this account', [], 403);
        }

        if (!$user->is_active) {
            return $this->error('User account is inactive', [], 403);
        }

        $user->update([
            'last_login_at' => now(),
            'last_login_ip' => $request->ip(),
        ]);

        $token = $this->issueToken($user);

        return $this->success([
            'token' => $token,
            'user' => $this->userPayload($user->fresh()),
        ], 'Login successful');
    }

    public function resetForgotPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'mobile' => ['required', 'regex:/^\d{10}$/'],
            'birth_date' => ['required', 'string'],
            'new_password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $birthDate = ApiDate::parse($validated['birth_date'], 'birth_date');

        $user = User::query()
            ->where('mobile', $validated['mobile'])
            ->whereDate('birth_date', $birthDate)
            ->first();

        if (!$user) {
            return $this->error('Mobile and birth date do not match', [], 404);
        }

        $user->update([
            'password' => $validated['new_password'],
            'api_token' => null,
        ]);

        return $this->success([
            'password_reset' => true,
        ], 'Password reset successful');
    }

    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return $this->error('Unauthenticated.', [], 401);
        }

        $user->update([
            'api_token' => null,
        ]);

        return $this->success([
            'logged_out' => true,
        ], 'Logout successful');
    }

    private function issueToken(User $user): string
    {
        $plainTextToken = Str::random(80);

        $user->update([
            'api_token' => hash('sha256', $plainTextToken),
        ]);

        return $plainTextToken;
    }

    private function userPayload(User $user): array
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
                ? asset('storage/' . $user->profile_image_path)
                : null,
            'last_login_at' => optional($user->last_login_at)?->toDateTimeString(),
        ];
    }
}
