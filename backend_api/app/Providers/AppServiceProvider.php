<?php

namespace App\Providers;

use App\Models\{Branch,Business,Customer,Expense,InventoryStock,Payment,Product,PurchaseInvoice,PurchaseOrder,PurchaseReturn,SalesInvoice,SalesReturn,StockAdjustment,StockTransfer,Supplier,SupplierPayment};
use App\Observers\AuditableObserver;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        foreach ([Business::class,Branch::class,Product::class,InventoryStock::class,StockAdjustment::class,StockTransfer::class,Customer::class,SalesInvoice::class,SalesReturn::class,Payment::class,Expense::class,Supplier::class,PurchaseOrder::class,PurchaseInvoice::class,PurchaseReturn::class,SupplierPayment::class] as $model) {
            $model::observe(AuditableObserver::class);
        }
    }
}
