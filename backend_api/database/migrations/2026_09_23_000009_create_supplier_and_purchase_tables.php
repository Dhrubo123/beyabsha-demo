<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('suppliers', function (Blueprint $t) {
            $t->id(); $t->foreignId('business_id')->constrained()->cascadeOnDelete(); $t->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $t->string('name'); $t->string('contact_person')->nullable(); $t->string('mobile', 20)->nullable(); $t->string('email')->nullable(); $t->string('address')->nullable();
            $t->decimal('credit_limit', 14, 2)->default(0); $t->decimal('current_due', 14, 2)->default(0); $t->date('due_since')->nullable(); $t->boolean('is_active')->default(true); $t->timestamps();
        });
        Schema::create('purchase_orders', function (Blueprint $t) {
            $t->id(); $t->foreignId('business_id')->constrained()->cascadeOnDelete(); $t->foreignId('branch_id')->constrained()->cascadeOnDelete(); $t->foreignId('supplier_id')->constrained()->restrictOnDelete(); $t->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $t->string('order_number')->unique(); $t->date('order_date'); $t->decimal('subtotal', 14, 2); $t->decimal('discount', 14, 2)->default(0); $t->decimal('vat', 14, 2)->default(0); $t->decimal('grand_total', 14, 2); $t->string('status')->default('draft'); $t->text('notes')->nullable(); $t->timestamps();
        });
        Schema::create('purchase_order_items', function (Blueprint $t) {
            $t->id(); $t->foreignId('purchase_order_id')->constrained()->cascadeOnDelete(); $t->foreignId('product_id')->constrained()->restrictOnDelete(); $t->string('product_name'); $t->decimal('ordered_quantity', 14, 3); $t->decimal('received_quantity', 14, 3)->default(0); $t->decimal('unit_cost', 14, 2); $t->decimal('line_total', 14, 2); $t->timestamps();
        });
        Schema::create('purchase_invoices', function (Blueprint $t) {
            $t->id(); $t->foreignId('business_id')->constrained()->cascadeOnDelete(); $t->foreignId('branch_id')->constrained()->cascadeOnDelete(); $t->foreignId('supplier_id')->constrained()->restrictOnDelete(); $t->foreignId('purchase_order_id')->nullable()->constrained()->nullOnDelete(); $t->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $t->string('invoice_number')->unique(); $t->string('supplier_invoice_number')->nullable(); $t->date('invoice_date'); $t->decimal('subtotal', 14, 2); $t->decimal('discount', 14, 2)->default(0); $t->decimal('vat', 14, 2)->default(0); $t->decimal('grand_total', 14, 2); $t->decimal('paid_amount', 14, 2)->default(0); $t->string('payment_status')->default('due'); $t->string('status')->default('draft'); $t->dateTime('received_at')->nullable(); $t->text('notes')->nullable(); $t->timestamps();
        });
        Schema::create('purchase_invoice_items', function (Blueprint $t) {
            $t->id(); $t->foreignId('purchase_invoice_id')->constrained()->cascadeOnDelete(); $t->foreignId('product_id')->constrained()->restrictOnDelete(); $t->string('product_name'); $t->decimal('quantity', 14, 3); $t->decimal('unit_cost', 14, 2); $t->decimal('line_total', 14, 2); $t->timestamps();
        });
        Schema::create('supplier_payments', function (Blueprint $t) {
            $t->id(); $t->foreignId('business_id')->constrained()->cascadeOnDelete(); $t->foreignId('branch_id')->constrained()->cascadeOnDelete(); $t->foreignId('supplier_id')->constrained()->restrictOnDelete(); $t->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $t->string('receipt_number')->unique(); $t->date('payment_date'); $t->decimal('amount', 14, 2); $t->string('method'); $t->string('transaction_id')->nullable(); $t->text('notes')->nullable(); $t->timestamps();
        });
        Schema::create('supplier_ledgers', function (Blueprint $t) {
            $t->id(); $t->foreignId('supplier_id')->constrained()->cascadeOnDelete(); $t->foreignId('branch_id')->constrained()->cascadeOnDelete(); $t->foreignId('purchase_invoice_id')->nullable()->constrained()->nullOnDelete(); $t->foreignId('supplier_payment_id')->nullable()->constrained()->nullOnDelete();
            $t->date('entry_date'); $t->string('type'); $t->string('reference')->nullable(); $t->decimal('debit', 14, 2)->default(0); $t->decimal('credit', 14, 2)->default(0); $t->decimal('balance', 14, 2); $t->text('notes')->nullable(); $t->timestamps();
        });
        Schema::create('purchase_returns', function (Blueprint $t) {
            $t->id(); $t->foreignId('business_id')->constrained()->cascadeOnDelete(); $t->foreignId('branch_id')->constrained()->cascadeOnDelete(); $t->foreignId('supplier_id')->constrained()->restrictOnDelete(); $t->foreignId('purchase_invoice_id')->constrained()->restrictOnDelete(); $t->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $t->string('return_number')->unique(); $t->date('return_date'); $t->decimal('total_amount', 14, 2); $t->text('notes')->nullable(); $t->timestamps();
        });
        Schema::create('purchase_return_items', function (Blueprint $t) {
            $t->id(); $t->foreignId('purchase_return_id')->constrained()->cascadeOnDelete(); $t->foreignId('product_id')->constrained()->restrictOnDelete(); $t->decimal('quantity', 14, 3); $t->decimal('unit_cost', 14, 2); $t->decimal('line_total', 14, 2); $t->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('purchase_return_items'); Schema::dropIfExists('purchase_returns'); Schema::dropIfExists('supplier_ledgers'); Schema::dropIfExists('supplier_payments'); Schema::dropIfExists('purchase_invoice_items'); Schema::dropIfExists('purchase_invoices'); Schema::dropIfExists('purchase_order_items'); Schema::dropIfExists('purchase_orders'); Schema::dropIfExists('suppliers'); }
};
