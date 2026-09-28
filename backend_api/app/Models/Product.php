<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Product extends Model { protected $fillable=['business_id','category_id','unit_id','name','sku','barcode','purchase_price','selling_price','is_active']; protected function casts():array{return ['purchase_price'=>'decimal:2','selling_price'=>'decimal:2','is_active'=>'boolean'];} public function category(){return $this->belongsTo(Category::class);} public function unit(){return $this->belongsTo(Unit::class);} public function stocks(){return $this->hasMany(InventoryStock::class);} }
