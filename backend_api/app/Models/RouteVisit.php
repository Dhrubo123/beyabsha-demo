<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class RouteVisit extends Model {protected $fillable=['sales_route_id','customer_id','sequence','scheduled_time','status','checked_in_at','checked_out_at','latitude','longitude','notes'];protected function casts():array{return ['checked_in_at'=>'datetime','checked_out_at'=>'datetime'];}public function customer(){return $this->belongsTo(Customer::class);}}
