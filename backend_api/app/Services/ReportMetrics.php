<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Expense;
use App\Models\InventoryStock;
use App\Models\Payment;
use App\Models\SalesInvoice;
use App\Models\SalesInvoiceItem;
use App\Models\SalesReturn;
use App\Models\SalesReturnItem;
use App\Models\Supplier;
use App\Support\BusinessAccess;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportMetrics
{
    public function for(Request $request): array
    {
        $business = BusinessAccess::id($request);
        $from = $request->filled('from') ? $request->date('from') : now()->startOfMonth();
        $to = $request->filled('to') ? $request->date('to') : now()->endOfMonth();
        $invoices = SalesInvoice::where('business_id', $business)->where('status', 'completed')->whereBetween('invoice_date', [$from, $to]);
        BusinessAccess::scopeBranch($invoices, $request);
        $grossSales = (clone $invoices)->sum('grand_total');
        $soldCost = SalesInvoiceItem::whereHas('salesInvoice', function ($query) use ($business, $from, $to, $request) {
            $query->where('business_id', $business)->where('status', 'completed')->whereBetween('invoice_date', [$from, $to]);
            BusinessAccess::scopeBranch($query, $request);
        })->selectRaw('COALESCE(SUM(quantity * unit_cost),0) total')->value('total');
        $returns = SalesReturn::where('business_id', $business)->whereBetween('return_date', [$from, $to]);
        BusinessAccess::scopeBranch($returns, $request);
        $salesReturns = (clone $returns)->sum('total_amount');
        $returnedCost = SalesReturnItem::whereHas('salesReturn', function ($query) use ($business, $from, $to, $request) {
            $query->where('business_id', $business)->whereBetween('return_date', [$from, $to]);
            BusinessAccess::scopeBranch($query, $request);
        })->selectRaw('COALESCE(SUM(quantity * unit_cost),0) total')->value('total');
        $payments = Payment::where('business_id', $business)->whereBetween('collection_date', [$from, $to]);
        BusinessAccess::scopeBranch($payments, $request);
        $expenses = Expense::where('business_id', $business)->where('approval_status', 'approved')->whereBetween('expense_date', [$from, $to]);
        BusinessAccess::scopeBranch($expenses, $request);
        $customers = Customer::where('business_id', $business);
        BusinessAccess::scopeBranch($customers, $request);
        $stocks = InventoryStock::whereHas('product', fn ($query) => $query->where('business_id', $business));
        BusinessAccess::scopeBranch($stocks, $request);

        $sales = $grossSales - $salesReturns;
        $cogs = $soldCost - $returnedCost;
        $collection = $payments->sum('amount');
        $refunds = (clone $returns)->sum('refund_amount');
        $branches = (clone $invoices)->select('branch_id', DB::raw('SUM(grand_total) total'))->with('branch:id,name')->groupBy('branch_id')->get();

        return [
            'from' => $from->toDateString(), 'to' => $to->toDateString(),
            'sales' => $sales, 'grossSales' => $grossSales, 'sales_returns' => $salesReturns,
            'collections' => $collection, 'refunds' => $refunds, 'net_collections' => $collection - $refunds,
            'expenses' => $expenses->sum('amount'), 'due' => $customers->sum('current_due'),
            'stockValue' => (clone $stocks)->join('products', 'products.id', '=', 'inventory_stocks.product_id')->selectRaw('COALESCE(SUM(inventory_stocks.quantity * products.purchase_price),0) total')->value('total'),
            'low' => (clone $stocks)->whereColumn('quantity', '<=', 'reorder_level')->count(),
            'branches' => $branches, 'cogs' => $cogs, 'gross_profit' => $sales - $cogs,
            'net_profit' => $sales - $cogs - $expenses->sum('amount'),
            'supplier_due' => Supplier::where('business_id', $business)->sum('current_due'),
        ];
    }
}
