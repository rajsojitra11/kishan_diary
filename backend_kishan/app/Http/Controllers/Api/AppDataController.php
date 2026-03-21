<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppDataController extends ApiController
{
    public function clearAllData(Request $request): JsonResponse
    {
        $user = $request->user();

        $disabledCount = $user->lands()->where('is_active', true)->update([
            'is_active' => false,
        ]);

        return $this->success([
            'disabled' => true,
            'disabled_lands' => (int) $disabledCount,
        ], 'Land data disabled successfully');
    }
}
