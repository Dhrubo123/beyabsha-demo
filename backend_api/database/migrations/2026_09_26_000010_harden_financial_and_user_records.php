<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up():void{
  Schema::table('users',fn(Blueprint $t)=>$t->boolean('is_active')->default(true)->after('branch_id'));
  Schema::table('sales_invoice_items',fn(Blueprint $t)=>$t->decimal('unit_cost',14,2)->default(0)->after('unit_price'));
  Schema::table('payments',fn(Blueprint $t)=>$t->foreignId('sales_invoice_id')->nullable()->after('customer_id')->constrained()->nullOnDelete());
  Schema::table('supplier_payments',fn(Blueprint $t)=>$t->foreignId('purchase_invoice_id')->nullable()->after('supplier_id')->constrained()->nullOnDelete());
  Schema::table('notifications',function(Blueprint $t){$t->string('dedupe_key')->nullable()->after('type');$t->unique(['business_id','dedupe_key']);});
 }
 public function down():void{
  Schema::table('notifications',function(Blueprint $t){$t->dropUnique(['business_id','dedupe_key']);$t->dropColumn('dedupe_key');});
  Schema::table('supplier_payments',fn(Blueprint $t)=>$t->dropConstrainedForeignId('purchase_invoice_id'));
  Schema::table('payments',fn(Blueprint $t)=>$t->dropConstrainedForeignId('sales_invoice_id'));
  Schema::table('sales_invoice_items',fn(Blueprint $t)=>$t->dropColumn('unit_cost'));
  Schema::table('users',fn(Blueprint $t)=>$t->dropColumn('is_active'));
 }
};
