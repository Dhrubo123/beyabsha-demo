<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class SalesInvoice extends Model { protected $fillable=['business_id','branch_id','customer_id','user_id','invoice_number','invoice_date','subtotal','discount','vat','grand_total','paid_amount','payment_status','status','return_status','notes']; protected function casts():array{return ['invoice_date'=>'date','subtotal'=>'decimal:2','discount'=>'decimal:2','vat'=>'decimal:2','grand_total'=>'decimal:2','paid_amount'=>'decimal:2'];} public function items(){return $this->hasMany(SalesInvoiceItem::class);} public function customer(){return $this->belongsTo(Customer::class);} public function branch(){return $this->belongsTo(Branch::class);} public function returns(){return $this->hasMany(SalesReturn::class);} }
