<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class StockTransfer extends Model { protected $fillable=['from_branch_id','to_branch_id','product_id','user_id','quantity','status','reference','notes']; protected function casts():array{return ['quantity'=>'decimal:3'];} }
