<?php
namespace App\Models;use Illuminate\Database\Eloquent\Model;class Notification extends Model{protected $fillable=['business_id','user_id','type','dedupe_key','title','body','severity','read_at'];protected function casts():array{return ['read_at'=>'datetime'];}}
