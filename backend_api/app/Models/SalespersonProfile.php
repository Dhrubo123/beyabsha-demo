<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class SalespersonProfile extends Model {protected $fillable=['user_id','branch_id','daily_target','is_active'];protected function casts():array{return ['daily_target'=>'decimal:2','is_active'=>'boolean'];}public function user(){return $this->belongsTo(User::class);} }
