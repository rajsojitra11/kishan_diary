<?php

namespace App\Http\Controllers\Api;

use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class MediaController extends ApiController
{
    public function show(string $path): BinaryFileResponse
    {
        $normalizedPath = ltrim($path, '/');

        if ($normalizedPath === '' || str_contains($normalizedPath, '..')) {
            abort(404);
        }

        if (!Storage::disk('public')->exists($normalizedPath)) {
            abort(404);
        }

        $absolutePath = Storage::disk('public')->path($normalizedPath);

        return response()->file($absolutePath);
    }
}
