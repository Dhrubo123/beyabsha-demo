<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Expense extends Model {protected $fillable=['business_id','branch_id','expense_category_id','user_id','approved_by','expense_date','amount','reference','notes','approval_status'];protected function casts():array{return ['expense_date'=>'date','amount'=>'decimal:2'];}public function category(){return $this->belongsTo(ExpenseCategory::class,'expense_category_id');}public function branch(){return $this->belongsTo(Branch::class);}}
