<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithTitle;

class ArrayExport implements FromArray, WithTitle
{
    public function __construct(private readonly array $rows, private readonly string $title = 'Export') {}

    public function array(): array { return $this->rows; }
    public function title(): string { return $this->title; }
}
