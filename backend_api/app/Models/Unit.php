<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Unit extends Model { protected $fillable=['business_id','name','symbol']; public function business(){return $this->belongsTo(Business::class);} }
