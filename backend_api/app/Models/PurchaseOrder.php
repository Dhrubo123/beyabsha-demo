<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class PurchaseOrder extends Model { protected $fillable=['business_id','branch_id','supplier_id','user_id','order_number','order_date','subtotal','discount','vat','grand_total','status','notes']; protected function casts():array{return ['order_date'=>'date','subtotal'=>'decimal:2','discount'=>'decimal:2','vat'=>'decimal:2','grand_total'=>'decimal:2'];} public function supplier(){return $this->belongsTo(Supplier::class);} public function branch(){return $this->belongsTo(Branch::class);} public function items(){return $this->hasMany(PurchaseOrderItem::class);} }
