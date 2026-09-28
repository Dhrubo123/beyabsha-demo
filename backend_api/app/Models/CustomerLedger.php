<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class CustomerLedger extends Model { protected $fillable=['customer_id','branch_id','sales_invoice_id','entry_date','type','reference','debit','credit','balance','notes']; protected function casts():array{return ['entry_date'=>'date','debit'=>'decimal:2','credit'=>'decimal:2','balance'=>'decimal:2'];} }
