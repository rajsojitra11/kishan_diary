<?php

namespace App\Support;

use Carbon\Carbon;
use Illuminate\Validation\ValidationException;

class ApiDate
{
    public static function parse(string $date, string $fieldName = 'date'): string
    {
        $value = trim($date);

        foreach (['Y-m-d', 'd/m/Y'] as $format) {
            try {
                $parsed = Carbon::createFromFormat($format, $value);
                if ($parsed && $parsed->format($format) === $value) {
                    return $parsed->format('Y-m-d');
                }
            } catch (\Throwable) {
                // Continue to next format.
            }
        }

        throw ValidationException::withMessages([
            $fieldName => ['Invalid date format. Use dd/MM/yyyy or yyyy-MM-dd.'],
        ]);
    }
}
