<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class StockAdjustment extends Model { protected $fillable=['branch_id','product_id','user_id','quantity','reason','reference','notes']; protected function casts():array{return ['quantity'=>'decimal:3'];} }
