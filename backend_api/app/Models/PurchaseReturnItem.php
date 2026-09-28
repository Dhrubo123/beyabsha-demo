<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class PurchaseReturnItem extends Model { protected $fillable=['product_id','quantity','unit_cost','line_total']; protected function casts():array{return ['quantity'=>'decimal:3','unit_cost'=>'decimal:2','line_total'=>'decimal:2'];} public function product(){return $this->belongsTo(Product::class);} }
