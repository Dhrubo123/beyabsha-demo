<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;
use App\Models\Business;
use App\Services\AlertService;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('alerts:generate', function (AlertService $alerts) {
    Business::query()->pluck('id')->each(fn ($id) => $alerts->generateForBusiness((int) $id));
    $this->info('Business alerts generated.');
})->purpose('Generate low-stock and overdue-customer alerts');

Schedule::command('alerts:generate')->hourly()->withoutOverlapping();
