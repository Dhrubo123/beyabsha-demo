<?php

namespace Database\Seeders;

use App\Models\Business;
use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $business = Business::firstOrCreate(
            ['name' => 'রহমান ডিস্ট্রিবিউশন'],
            ['trade_name' => 'Rahman Distribution', 'mobile' => '01700000000', 'address' => 'ঢাকা, বাংলাদেশ']
        );

        $branch = $business->branches()->firstOrCreate(
            ['code' => 'HEAD'],
            ['name' => 'প্রধান শাখা', 'mobile' => '01700000000', 'address' => 'ঢাকা, বাংলাদেশ']
        );

        User::updateOrCreate(
            ['email' => 'admin@byabsha360.test'],
            ['name' => 'Byabsha 360 Admin', 'mobile' => '01700000000', 'password' => 'Admin@12345', 'role' => 'owner', 'business_id' => $business->id, 'branch_id' => $branch->id]
        );
    }
}
