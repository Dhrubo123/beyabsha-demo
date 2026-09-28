<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('customers', function (Blueprint $table) {
            $table->id(); $table->foreignId('business_id')->constrained()->cascadeOnDelete(); $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name'); $table->string('contact_person')->nullable(); $table->string('mobile', 20)->nullable(); $table->string('address')->nullable(); $table->decimal('credit_limit', 14, 2)->default(0); $table->decimal('current_due', 14, 2)->default(0); $table->date('due_since')->nullable(); $table->boolean('is_active')->default(true); $table->timestamps();
        });
        Schema::create('sales_invoices', function (Blueprint $table) {
            $table->id(); $table->foreignId('business_id')->constrained()->cascadeOnDelete(); $table->foreignId('branch_id')->constrained()->cascadeOnDelete(); $table->foreignId('customer_id')->constrained()->restrictOnDelete(); $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('invoice_number')->unique(); $table->date('invoice_date'); $table->decimal('subtotal', 14, 2); $table->decimal('discount', 14, 2)->default(0); $table->decimal('vat', 14, 2)->default(0); $table->decimal('grand_total', 14, 2); $table->decimal('paid_amount', 14, 2)->default(0); $table->string('payment_status')->default('due'); $table->string('status')->default('completed'); $table->text('notes')->nullable(); $table->timestamps();
        });
        Schema::create('sales_invoice_items', function (Blueprint $table) {
            $table->id(); $table->foreignId('sales_invoice_id')->constrained()->cascadeOnDelete(); $table->foreignId('product_id')->constrained()->restrictOnDelete();
            $table->string('product_name'); $table->decimal('quantity', 14, 3); $table->decimal('unit_price', 14, 2); $table->decimal('discount', 14, 2)->default(0); $table->decimal('line_total', 14, 2); $table->timestamps();
        });
        Schema::create('customer_ledgers', function (Blueprint $table) {
            $table->id(); $table->foreignId('customer_id')->constrained()->cascadeOnDelete(); $table->foreignId('branch_id')->constrained()->cascadeOnDelete(); $table->foreignId('sales_invoice_id')->nullable()->constrained()->nullOnDelete();
            $table->date('entry_date'); $table->string('type'); $table->string('reference')->nullable(); $table->decimal('debit', 14, 2)->default(0); $table->decimal('credit', 14, 2)->default(0); $table->decimal('balance', 14, 2); $table->text('notes')->nullable(); $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('customer_ledgers'); Schema::dropIfExists('sales_invoice_items'); Schema::dropIfExists('sales_invoices'); Schema::dropIfExists('customers'); }
};
