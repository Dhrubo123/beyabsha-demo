<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class SupplierPayment extends Model { protected $fillable=['business_id','branch_id','supplier_id','purchase_invoice_id','user_id','receipt_number','payment_date','amount','method','transaction_id','notes']; protected function casts():array{return ['payment_date'=>'date','amount'=>'decimal:2'];} public function supplier(){return $this->belongsTo(Supplier::class);} public function invoice(){return $this->belongsTo(PurchaseInvoice::class,'purchase_invoice_id');} }
