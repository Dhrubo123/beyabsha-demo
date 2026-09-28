<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class PurchaseReturn extends Model { protected $fillable=['business_id','branch_id','supplier_id','purchase_invoice_id','user_id','return_number','return_date','total_amount','notes']; protected function casts():array{return ['return_date'=>'date','total_amount'=>'decimal:2'];} public function supplier(){return $this->belongsTo(Supplier::class);} public function invoice(){return $this->belongsTo(PurchaseInvoice::class,'purchase_invoice_id');} public function items(){return $this->hasMany(PurchaseReturnItem::class);} }
