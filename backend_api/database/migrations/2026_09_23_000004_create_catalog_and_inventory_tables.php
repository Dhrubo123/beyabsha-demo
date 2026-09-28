<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('units', function (Blueprint $table) {
            $table->id(); $table->foreignId('business_id')->constrained()->cascadeOnDelete();
            $table->string('name'); $table->string('symbol', 20); $table->timestamps();
            $table->unique(['business_id', 'name']);
        });
        Schema::create('categories', function (Blueprint $table) {
            $table->id(); $table->foreignId('business_id')->constrained()->cascadeOnDelete();
            $table->string('name'); $table->foreignId('parent_id')->nullable()->constrained('categories')->nullOnDelete(); $table->timestamps();
            $table->unique(['business_id', 'name']);
        });
        Schema::create('products', function (Blueprint $table) {
            $table->id(); $table->foreignId('business_id')->constrained()->cascadeOnDelete();
            $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete(); $table->foreignId('unit_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name'); $table->string('sku'); $table->string('barcode')->nullable(); $table->decimal('purchase_price', 14, 2)->default(0); $table->decimal('selling_price', 14, 2)->default(0); $table->boolean('is_active')->default(true); $table->timestamps();
            $table->unique(['business_id', 'sku']); $table->unique(['business_id', 'barcode']);
        });
        Schema::create('inventory_stocks', function (Blueprint $table) {
            $table->id(); $table->foreignId('branch_id')->constrained()->cascadeOnDelete(); $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->decimal('quantity', 14, 3)->default(0); $table->decimal('reorder_level', 14, 3)->default(0); $table->timestamps();
            $table->unique(['branch_id', 'product_id']);
        });
        Schema::create('stock_adjustments', function (Blueprint $table) {
            $table->id(); $table->foreignId('branch_id')->constrained()->cascadeOnDelete(); $table->foreignId('product_id')->constrained()->cascadeOnDelete(); $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->decimal('quantity', 14, 3); $table->string('reason'); $table->string('reference')->nullable(); $table->text('notes')->nullable(); $table->timestamps();
        });
        Schema::create('stock_transfers', function (Blueprint $table) {
            $table->id(); $table->foreignId('from_branch_id')->constrained('branches')->cascadeOnDelete(); $table->foreignId('to_branch_id')->constrained('branches')->cascadeOnDelete(); $table->foreignId('product_id')->constrained()->cascadeOnDelete(); $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->decimal('quantity', 14, 3); $table->string('status')->default('completed'); $table->string('reference')->nullable(); $table->text('notes')->nullable(); $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('stock_transfers'); Schema::dropIfExists('stock_adjustments'); Schema::dropIfExists('inventory_stocks'); Schema::dropIfExists('products'); Schema::dropIfExists('categories'); Schema::dropIfExists('units'); }
};
