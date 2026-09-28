<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class SalesInvoiceItem extends Model { protected $fillable=['sales_invoice_id','product_id','product_name','quantity','unit_price','unit_cost','discount','line_total']; protected function casts():array{return ['quantity'=>'decimal:3','unit_price'=>'decimal:2','unit_cost'=>'decimal:2','discount'=>'decimal:2','line_total'=>'decimal:2'];} public function product(){return $this->belongsTo(Product::class);} public function salesInvoice(){return $this->belongsTo(SalesInvoice::class);} }
