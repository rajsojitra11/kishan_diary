<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppDataController extends ApiController
{
    public function clearAllData(Request $request): JsonResponse
    {
        $user = $request->user();

        $user->lands()->delete();
        $user->animals()->delete();

        return $this->success([
            'cleared' => true,
        ], 'All app data cleared');
    }
}
