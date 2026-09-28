<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Payment extends Model {protected $fillable=['business_id','branch_id','customer_id','sales_invoice_id','user_id','receipt_number','collection_date','amount','method','transaction_id','notes','status'];protected function casts():array{return ['collection_date'=>'date','amount'=>'decimal:2'];}public function customer(){return $this->belongsTo(Customer::class);}public function invoice(){return $this->belongsTo(SalesInvoice::class,'sales_invoice_id');}public function branch(){return $this->belongsTo(Branch::class);}}
