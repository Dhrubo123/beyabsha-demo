<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class InventoryStock extends Model { protected $fillable=['branch_id','product_id','quantity','reorder_level']; protected function casts():array{return ['quantity'=>'decimal:3','reorder_level'=>'decimal:3'];} public function product(){return $this->belongsTo(Product::class);} public function branch(){return $this->belongsTo(Branch::class);} }
