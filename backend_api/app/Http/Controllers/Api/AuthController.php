<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\Business;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $data = $request->validate([
            'business_name' => ['required', 'string', 'max:150'],
            'trade_name' => ['nullable', 'string', 'max:150'],
            'branch_name' => ['nullable', 'string', 'max:150'],
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:120', 'unique:users,email'],
            'mobile' => ['nullable', 'string', 'max:20', 'unique:users,mobile'],
            'address' => ['nullable', 'string', 'max:1000'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'device_name' => ['required', 'string', 'max:100'],
        ]);

        [$business, $branch, $user] = DB::transaction(function () use ($data) {
            $business = Business::create([
                'name' => $data['business_name'],
                'trade_name' => $data['trade_name'] ?? null,
                'mobile' => $data['mobile'] ?? null,
                'email' => $data['email'],
                'address' => $data['address'] ?? null,
                'is_active' => true,
            ]);

            $branch = Branch::create([
                'business_id' => $business->id,
                'name' => $data['branch_name'] ?: 'Head Office',
                'code' => 'HEAD',
                'mobile' => $data['mobile'] ?? null,
                'address' => $data['address'] ?? null,
                'is_active' => true,
            ]);

            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'mobile' => $data['mobile'] ?? null,
                'password' => $data['password'],
                'role' => 'owner',
                'business_id' => $business->id,
                'branch_id' => $branch->id,
                'is_active' => true,
            ]);

            return [$business, $branch, $user];
        });

        return response()->json([
            'user' => $user->load(['business', 'branch']),
            'business' => $business,
            'branch' => $branch,
            'token' => $user->createToken($data['device_name'])->plainTextToken,
        ], 201);
    }

    public function login(Request $request)
    {
        $data = $request->validate([
            'login' => ['required', 'string'],
            'password' => ['required', 'string'],
            'device_name' => ['required', 'string', 'max:100'],
        ]);

        $user = User::query()->where('email', $data['login'])->orWhere('mobile', $data['login'])->first();
        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages(['login' => ['The supplied credentials are invalid.']]);
        }
        abort_if(isset($user->is_active) && ! $user->is_active, 403, 'This account is inactive. Contact the business owner.');

        return response()->json(['user' => $user->load(['business', 'branch']), 'token' => $user->createToken($data['device_name'])->plainTextToken]);
    }

    public function me(Request $request)
    {
        return response()->json(['user' => $request->user()->load(['business', 'branch'])]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();
        return response()->noContent();
    }
}
