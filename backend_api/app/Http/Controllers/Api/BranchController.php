<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\Business;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class BranchController extends Controller
{
    public function index(Request $request, Business $business)
    {
        $this->authorizeBusiness($request, $business);
        $query = $business->branches()->orderBy('name');
        if (! in_array($request->user()->role, ['owner', 'super_admin'], true)) $query->whereKey($request->user()->branch_id);
        return response()->json(['data' => $query->get()]);
    }

    public function store(Request $request, Business $business)
    {
        $this->authorizeOwner($request, $business);
        $data = $request->validate([
            'name' => ['required', 'string', 'max:150'],
            'code' => ['nullable', 'string', 'max:30', Rule::unique('branches', 'code')->where('business_id', $business->id)],
            'mobile' => ['nullable', 'string', 'max:20'],
            'address' => ['nullable', 'string'],
        ]);
        $data['business_id'] = $business->id;
        $branch = Branch::create($data);
        return response()->json(['data' => $branch], 201);
    }

    public function update(Request $request, Branch $branch)
    {
        $this->authorizeManager($request, $branch->business);
        if ($request->user()->role === 'manager') abort_unless((int) $request->user()->branch_id === $branch->id, 403);
        $branch->update($request->validate([
            'name' => ['sometimes', 'string', 'max:150'],
            'code' => ['nullable', 'string', 'max:30', Rule::unique('branches', 'code')->where('business_id', $branch->business_id)->ignore($branch->id)],
            'mobile' => ['nullable', 'string', 'max:20'],
            'address' => ['nullable', 'string'],
            'is_active' => ['sometimes', 'boolean'],
        ]));
        return response()->json(['data' => $branch->fresh()]);
    }

    private function authorizeBusiness(Request $request, Business $business): void
    {
        abort_unless($request->user()->role === 'super_admin' || $request->user()->business_id === $business->id, 403);
    }

    private function authorizeManager(Request $request, Business $business): void
    {
        $this->authorizeBusiness($request, $business);
        abort_unless(in_array($request->user()->role, ['super_admin', 'owner', 'manager'], true), 403);
    }

    private function authorizeOwner(Request $request, Business $business): void
    {
        $this->authorizeBusiness($request, $business);
        abort_unless(in_array($request->user()->role, ['super_admin', 'owner'], true), 403);
    }
}
