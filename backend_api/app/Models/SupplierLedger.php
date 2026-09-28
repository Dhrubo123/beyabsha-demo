<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class SupplierLedger extends Model { protected $fillable=['supplier_id','branch_id','purchase_invoice_id','supplier_payment_id','entry_date','type','reference','debit','credit','balance','notes']; protected function casts():array{return ['entry_date'=>'date','debit'=>'decimal:2','credit'=>'decimal:2','balance'=>'decimal:2'];} }
