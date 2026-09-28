<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class SalesRoute extends Model {protected $fillable=['business_id','branch_id','salesperson_id','route_date','name','status'];protected function casts():array{return ['route_date'=>'date'];}public function branch(){return $this->belongsTo(Branch::class);}public function visits(){return $this->hasMany(RouteVisit::class)->orderBy('sequence');}public function salesperson(){return $this->belongsTo(User::class,'salesperson_id');}}
