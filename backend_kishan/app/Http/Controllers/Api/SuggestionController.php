<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SuggestionController extends ApiController
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'message' => ['required', 'string', 'max:1000'],
        ]);

        $suggestion = $request->user()->suggestions()->create([
            'message' => $validated['message'],
        ]);

        return $this->success([
            'suggestion' => [
                'id' => $suggestion->id,
                'message' => $suggestion->message,
                'created_at' => optional($suggestion->created_at)?->toDateTimeString(),
            ],
        ], 'Suggestion submitted successfully', 201);
    }
}
