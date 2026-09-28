<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Supplier extends Model { protected $fillable=['business_id','branch_id','name','contact_person','mobile','email','address','credit_limit','current_due','due_since','is_active']; protected function casts():array{return ['credit_limit'=>'decimal:2','current_due'=>'decimal:2','due_since'=>'date','is_active'=>'boolean'];} public function ledgers(){return $this->hasMany(SupplierLedger::class);} }
