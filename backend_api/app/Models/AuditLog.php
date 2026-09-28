<?php
namespace App\Models;use Illuminate\Database\Eloquent\Model;class AuditLog extends Model{protected $fillable=['business_id','user_id','event','subject_type','subject_id','properties','ip_address'];protected function casts():array{return ['properties'=>'array'];}public function user(){return $this->belongsTo(User::class);}}
