<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up(): void {
  Schema::create('payments',function(Blueprint $t){$t->id();$t->foreignId('business_id')->constrained()->cascadeOnDelete();$t->foreignId('branch_id')->constrained()->cascadeOnDelete();$t->foreignId('customer_id')->constrained()->restrictOnDelete();$t->foreignId('user_id')->nullable()->constrained()->nullOnDelete();$t->string('receipt_number')->unique();$t->date('collection_date');$t->decimal('amount',14,2);$t->string('method');$t->string('transaction_id')->nullable();$t->text('notes')->nullable();$t->string('status')->default('completed');$t->timestamps();});
  Schema::create('expense_categories',function(Blueprint $t){$t->id();$t->foreignId('business_id')->constrained()->cascadeOnDelete();$t->string('name');$t->boolean('is_active')->default(true);$t->timestamps();$t->unique(['business_id','name']);});
  Schema::create('expenses',function(Blueprint $t){$t->id();$t->foreignId('business_id')->constrained()->cascadeOnDelete();$t->foreignId('branch_id')->constrained()->cascadeOnDelete();$t->foreignId('expense_category_id')->constrained()->restrictOnDelete();$t->foreignId('user_id')->nullable()->constrained()->nullOnDelete();$t->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete();$t->date('expense_date');$t->decimal('amount',14,2);$t->string('reference')->nullable();$t->text('notes')->nullable();$t->string('approval_status')->default('pending');$t->timestamps();});
 }
 public function down(): void {Schema::dropIfExists('expenses');Schema::dropIfExists('expense_categories');Schema::dropIfExists('payments');}
};
