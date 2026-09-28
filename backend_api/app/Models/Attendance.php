<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Attendance extends Model {protected $fillable=['user_id','branch_id','attendance_date','check_in_at','check_out_at','check_in_latitude','check_in_longitude'];protected function casts():array{return ['attendance_date'=>'date','check_in_at'=>'datetime','check_out_at'=>'datetime'];}public function user(){return $this->belongsTo(User::class);}public function branch(){return $this->belongsTo(Branch::class);}}
