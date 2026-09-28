<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Business;
use Illuminate\Http\Request;

class BusinessController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Business::query()->with('branches');
        if ($user->role !== 'super_admin') $query->whereKey($user->business_id);
        return response()->json(['data' => $query->get()]);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        abort_if($user->business_id, 422, 'This user already belongs to a business.');
        $data = $request->validate(['name' => ['required', 'string', 'max:150'], 'trade_name' => ['nullable', 'string', 'max:150'], 'mobile' => ['nullable', 'string', 'max:20'], 'email' => ['nullable', 'email'], 'address' => ['nullable', 'string']]);
        $business = Business::create($data);
        $branch = $business->branches()->create(['name' => 'প্রধান শাখা', 'code' => 'HEAD', 'address' => $business->address, 'mobile' => $business->mobile]);
        $user->update(['business_id' => $business->id, 'branch_id' => $branch->id, 'role' => 'owner']);
        return response()->json(['data' => $business->load('branches')], 201);
    }

    public function show(Request $request, Business $business)
    {
        $this->authorizeBusiness($request, $business);
        return response()->json(['data' => $business->load('branches')]);
    }

    public function update(Request $request, Business $business)
    {
        $this->authorizeBusiness($request, $business);
        abort_unless(in_array($request->user()->role, ['super_admin', 'owner'], true), 403);
        $business->update($request->validate(['name' => ['sometimes', 'string', 'max:150'], 'trade_name' => ['nullable', 'string', 'max:150'], 'mobile' => ['nullable', 'string', 'max:20'], 'email' => ['nullable', 'email'], 'address' => ['nullable', 'string'], 'is_active' => ['sometimes', 'boolean']]));
        return response()->json(['data' => $business->fresh('branches')]);
    }

    private function authorizeBusiness(Request $request, Business $business): void
    {
        abort_unless($request->user()->role === 'super_admin' || $request->user()->business_id === $business->id, 403);
    }
}
