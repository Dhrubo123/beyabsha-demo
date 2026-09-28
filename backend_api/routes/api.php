<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BranchController;
use App\Http\Controllers\Api\BusinessController;
use App\Http\Controllers\Api\CustomerController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\SalesInvoiceController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ExpenseController;
use App\Http\Controllers\Api\FieldSalesController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\PurchaseController;
use App\Http\Controllers\Api\DocumentController;

Route::prefix('v1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::apiResource('businesses', BusinessController::class)->only(['index', 'store', 'show', 'update']);
        Route::get('/businesses/{business}/branches', [BranchController::class, 'index']);
        Route::post('/businesses/{business}/branches', [BranchController::class, 'store']);
        Route::put('/branches/{branch}', [BranchController::class, 'update']);

        Route::get('/units', [InventoryController::class, 'units']);
        Route::post('/units', [InventoryController::class, 'storeUnit']);
        Route::get('/categories', [InventoryController::class, 'categories']);
        Route::post('/categories', [InventoryController::class, 'storeCategory']);
        Route::get('/products', [InventoryController::class, 'products']);
        Route::post('/products', [InventoryController::class, 'storeProduct']);
        Route::put('/products/{product}', [InventoryController::class, 'updateProduct']);
        Route::get('/inventory/stocks', [InventoryController::class, 'stocks']);
        Route::put('/inventory/stocks/{stock}', [InventoryController::class, 'updateStock']);
        Route::post('/inventory/adjustments', [InventoryController::class, 'adjust']);
        Route::post('/inventory/transfers', [InventoryController::class, 'transfer']);

        Route::get('/suppliers', [PurchaseController::class, 'suppliers']);
        Route::post('/suppliers', [PurchaseController::class, 'storeSupplier']);
        Route::put('/suppliers/{supplier}', [PurchaseController::class, 'updateSupplier']);
        Route::get('/suppliers/{supplier}/ledger', [PurchaseController::class, 'supplierLedger']);
        Route::get('/purchase-orders', [PurchaseController::class, 'orders']);
        Route::post('/purchase-orders', [PurchaseController::class, 'storeOrder']);
        Route::get('/purchase-invoices', [PurchaseController::class, 'invoices']);
        Route::post('/purchase-invoices', [PurchaseController::class, 'storeInvoice']);
        Route::get('/purchase-invoices/{invoice}', [PurchaseController::class, 'showInvoice']);
        Route::post('/purchase-invoices/{invoice}/receive', [PurchaseController::class, 'receive']);
        Route::post('/purchase-invoices/{invoice}/returns', [PurchaseController::class, 'returnPurchase']);
        Route::get('/supplier-payments', [PurchaseController::class, 'supplierPayments']);
        Route::post('/supplier-payments', [PurchaseController::class, 'paySupplier']);
        Route::get('/reports/purchases', [PurchaseController::class, 'report']);

        Route::apiResource('customers', CustomerController::class)->only(['index', 'store', 'show', 'update']);
        Route::get('/customers/{customer}/ledger', [CustomerController::class, 'ledger']);
        Route::get('/invoices', [SalesInvoiceController::class, 'index']);
        Route::post('/invoices', [SalesInvoiceController::class, 'store']);
        Route::get('/invoices/{invoice}', [SalesInvoiceController::class, 'show']);
        Route::get('/invoices/{invoice}/pdf', [DocumentController::class, 'invoicePdf']);
        Route::post('/invoices/{invoice}/cancel', [SalesInvoiceController::class, 'cancel']);
        Route::post('/invoices/{invoice}/returns', [SalesInvoiceController::class, 'returnSale']);
        Route::get('/sales-returns', [SalesInvoiceController::class, 'returns']);

        Route::get('/payments', [PaymentController::class, 'index']);
        Route::post('/payments', [PaymentController::class, 'store']);
        Route::get('/payments/{payment}', [PaymentController::class, 'show']);
        Route::get('/payments/{payment}/receipt', [DocumentController::class, 'receiptPdf']);
        Route::get('/expense-categories', [ExpenseController::class, 'categories']);
        Route::post('/expense-categories', [ExpenseController::class, 'storeCategory']);
        Route::get('/expenses', [ExpenseController::class, 'index']);
        Route::post('/expenses', [ExpenseController::class, 'store']);
        Route::post('/expenses/{expense}/approve', [ExpenseController::class, 'approve']);
        Route::get('/field-sales/salespeople', [FieldSalesController::class, 'salespeople']);
        Route::post('/field-sales/salespeople', [FieldSalesController::class, 'storeSalesperson']);
        Route::post('/field-sales/attendance', [FieldSalesController::class, 'attendance']);
        Route::get('/field-sales/attendances', [FieldSalesController::class, 'attendances']);
        Route::get('/field-sales/routes', [FieldSalesController::class, 'routes']);
        Route::post('/field-sales/routes', [FieldSalesController::class, 'storeRoute']);
        Route::post('/field-sales/visits/{visit}', [FieldSalesController::class, 'visit']);
        Route::get('/reports/dashboard', [ReportController::class, 'dashboard']);
        Route::get('/reports/monthly', [ReportController::class, 'monthly']);
        Route::get('/reports/export/pdf', [DocumentController::class, 'reportPdf']);
        Route::get('/reports/export/excel', [DocumentController::class, 'reportExcel']);
        Route::get('/imports/products/template', [DocumentController::class, 'productTemplate']);
        Route::post('/imports/products', [DocumentController::class, 'importProducts'])->name('imports.products');
        Route::get('/imports/customers/template', [DocumentController::class, 'customerTemplate']);
        Route::post('/imports/customers', [DocumentController::class, 'importCustomers'])->name('imports.customers');
        Route::get('/settings', [SettingsController::class, 'settings']);
        Route::put('/settings', [SettingsController::class, 'saveSettings']);
        Route::get('/admin/users', [SettingsController::class, 'users']);
        Route::post('/admin/users', [SettingsController::class, 'storeUser']);
        Route::put('/admin/users/{user}', [SettingsController::class, 'updateUser']);
        Route::get('/notifications', [SettingsController::class, 'notifications']);
        Route::post('/notifications/{notification}/read', [SettingsController::class, 'readNotification']);
        Route::get('/audit-logs', [SettingsController::class, 'audit']);
    });
});
