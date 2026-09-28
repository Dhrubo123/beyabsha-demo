<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class PurchaseOrderItem extends Model { protected $fillable=['product_id','product_name','ordered_quantity','received_quantity','unit_cost','line_total']; protected function casts():array{return ['ordered_quantity'=>'decimal:3','received_quantity'=>'decimal:3','unit_cost'=>'decimal:2','line_total'=>'decimal:2'];} public function product(){return $this->belongsTo(Product::class);} }
