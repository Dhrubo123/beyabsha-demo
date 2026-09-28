<?php
namespace App\Support;
use App\Models\Branch;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
final class BusinessAccess{
 public static function id(Request $r):int{abort_unless($r->user()?->business_id,422,'Create a business first.');return(int)$r->user()->business_id;}
 public static function requireRole(Request $r,array $roles):void{abort_unless(in_array($r->user()->role,$roles,true),403,'You are not allowed to perform this action.');}
 public static function branch(Request $r,int $branchId):Branch{$branch=Branch::where('business_id',self::id($r))->findOrFail($branchId);if(!in_array($r->user()->role,['owner','super_admin'],true))abort_unless((int)$r->user()->branch_id===$branch->id,403,'You can only access your assigned branch.');return $branch;}
 public static function scopeBranch(Builder $query,Request $r,string $column='branch_id'):Builder{
  if($r->filled('branch_id')){
   $branch=self::branch($r,$r->integer('branch_id'));
   return $query->where($column,$branch->id);
  }
  if(!in_array($r->user()->role,['owner','super_admin'],true))$query->where($column,$r->user()->branch_id);
  return $query;
 }
}
