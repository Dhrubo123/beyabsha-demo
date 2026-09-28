<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Customer;
use App\Models\RouteVisit;
use App\Models\SalespersonProfile;
use App\Models\SalesRoute;
use App\Models\User;
use App\Support\BusinessAccess;
use Illuminate\Http\Request;

class FieldSalesController extends Controller
{
    private function businessId(Request $request): int
    {
        return BusinessAccess::id($request);
    }

    public function salespeople(Request $request)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'super_admin']);
        return response()->json(['data' => SalespersonProfile::with('user')->whereHas(
            'user', fn ($query) => $query->where('business_id', $this->businessId($request)),
        )->get()]);
    }

    public function storeSalesperson(Request $request)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'super_admin']);
        $data = $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
            'branch_id' => ['required', 'integer', 'exists:branches,id'],
            'daily_target' => ['nullable', 'numeric', 'min:0'],
        ]);
        $business = $this->businessId($request);
        BusinessAccess::branch($request, $data['branch_id']);
        $user = User::where('business_id', $business)->findOrFail($data['user_id']);
        abort_if($user->role === 'owner', 422, 'An owner cannot be changed into a salesperson profile.');
        $user->update(['role' => 'salesperson', 'branch_id' => $data['branch_id']]);

        return response()->json([
            'data' => SalespersonProfile::updateOrCreate(['user_id' => $user->id], $data)->load('user'),
        ], 201);
    }

    public function attendance(Request $request)
    {
        BusinessAccess::requireRole($request, ['salesperson']);
        $data = $request->validate([
            'branch_id' => ['required', 'integer', 'exists:branches,id'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'action' => ['required', 'in:check_in,check_out'],
        ]);
        BusinessAccess::branch($request, $data['branch_id']);
        $record = Attendance::firstOrCreate(
            ['user_id' => $request->user()->id, 'attendance_date' => today()],
            ['branch_id' => $data['branch_id']],
        );
        if ($data['action'] === 'check_in') {
            $record->update([
                'check_in_at' => now(),
                'check_in_latitude' => $data['latitude'] ?? null,
                'check_in_longitude' => $data['longitude'] ?? null,
            ]);
        } else {
            $record->update(['check_out_at' => now()]);
        }

        return response()->json(['data' => $record->fresh()]);
    }

    public function attendances(Request $request)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'super_admin']);
        $query = Attendance::with(['user:id,name,email,mobile', 'branch:id,name'])
            ->whereHas('user', fn ($users) => $users->where('business_id', $this->businessId($request)));

        if ($request->filled('branch_id')) {
            $query->where('branch_id', BusinessAccess::branch($request, $request->integer('branch_id'))->id);
        }
        if ($request->filled('date')) {
            $query->whereDate('attendance_date', $request->date('date'));
        }

        return response()->json(['data' => $query->latest('attendance_date')->latest('check_in_at')->get()]);
    }

    public function routes(Request $request)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'salesperson', 'super_admin']);
        $query = SalesRoute::with(['branch:id,name', 'salesperson', 'visits.customer'])
            ->where('business_id', $this->businessId($request));
        if ($request->user()->role === 'salesperson') {
            $query->where('salesperson_id', $request->user()->id);
        } elseif ($request->filled('branch_id')) {
            $query->where('branch_id', BusinessAccess::branch($request, $request->integer('branch_id'))->id);
        }
        if ($request->filled('date')) {
            $query->whereDate('route_date', $request->date('date'));
        }

        return response()->json(['data' => $query->latest('route_date')->get()]);
    }

    public function storeRoute(Request $request)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'super_admin']);
        $data = $request->validate([
            'branch_id' => ['required', 'integer', 'exists:branches,id'],
            'salesperson_id' => ['required', 'integer', 'exists:users,id'],
            'route_date' => ['required', 'date'],
            'name' => ['nullable', 'string', 'max:100'],
            'visits' => ['required', 'array', 'min:1'],
            'visits.*.customer_id' => ['required', 'integer', 'exists:customers,id'],
            'visits.*.scheduled_time' => ['nullable', 'date_format:H:i'],
        ]);
        $business = $this->businessId($request);
        BusinessAccess::branch($request, $data['branch_id']);
        User::where('business_id', $business)->where('role', 'salesperson')->findOrFail($data['salesperson_id']);
        $customerIds = collect($data['visits'])->pluck('customer_id')->unique();
        $validCustomers = Customer::where('business_id', $business)
            ->whereIn('id', $customerIds)
            ->where(fn ($query) => $query->whereNull('branch_id')->orWhere('branch_id', $data['branch_id']))
            ->count();
        abort_unless($validCustomers === $customerIds->count(), 422, 'Each planned visit must use a customer from the selected branch.');
        $route = SalesRoute::create([
            'business_id' => $business,
            'branch_id' => $data['branch_id'],
            'salesperson_id' => $data['salesperson_id'],
            'route_date' => $data['route_date'],
            'name' => $data['name'] ?? null,
        ]);
        foreach ($data['visits'] as $index => $visit) {
            $route->visits()->create([
                'customer_id' => $visit['customer_id'],
                'sequence' => $index + 1,
                'scheduled_time' => $visit['scheduled_time'] ?? null,
            ]);
        }

        return response()->json(['data' => $route->load('visits.customer')], 201);
    }

    public function visit(Request $request, RouteVisit $visit)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'salesperson', 'super_admin']);
        $data = $request->validate([
            'action' => ['required', 'in:check_in,check_out'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'notes' => ['nullable', 'string'],
        ]);
        $route = SalesRoute::where('business_id', $this->businessId($request))->findOrFail($visit->sales_route_id);
        BusinessAccess::branch($request, $route->branch_id);
        if ($request->user()->role === 'salesperson') {
            abort_unless($route->salesperson_id === $request->user()->id, 403, 'You can only update your assigned visits.');
        }
        if ($data['action'] === 'check_in') {
            $visit->update([
                'status' => 'current',
                'checked_in_at' => now(),
                'latitude' => $data['latitude'] ?? null,
                'longitude' => $data['longitude'] ?? null,
            ]);
        } else {
            $visit->update([
                'status' => 'completed',
                'checked_out_at' => now(),
                'notes' => $data['notes'] ?? null,
            ]);
        }

        return response()->json(['data' => $visit->fresh('customer')]);
    }
}
