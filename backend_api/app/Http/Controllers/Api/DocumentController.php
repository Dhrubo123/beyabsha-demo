<?php

namespace App\Http\Controllers\Api;

use App\Exports\ArrayExport;
use App\Http\Controllers\Controller;
use App\Imports\RowsImport;
use App\Models\Branch;
use App\Models\Business;
use App\Models\Category;
use App\Models\Customer;
use App\Models\InventoryStock;
use App\Models\Payment;
use App\Models\Product;
use App\Models\SalesInvoice;
use App\Models\Unit;
use App\Services\ReportMetrics;
use App\Support\BusinessAccess;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Maatwebsite\Excel\Facades\Excel;

class DocumentController extends Controller
{
    public function invoicePdf(Request $request, SalesInvoice $invoice)
    {
        $this->authorizeInvoice($request, $invoice);
        $invoice->load(['items.product', 'customer', 'branch']);
        $business = Business::findOrFail($invoice->business_id);
        return Pdf::loadView('documents.invoice', compact('invoice', 'business'))
            ->setPaper('a4')
            ->download("{$invoice->invoice_number}.pdf");
    }

    public function receiptPdf(Request $request, Payment $payment)
    {
        $this->authorizePayment($request, $payment);
        $payment->load(['customer', 'invoice', 'branch']);
        $business = Business::findOrFail($payment->business_id);
        return Pdf::loadView('documents.receipt', compact('payment', 'business'))
            ->setPaper('a5')
            ->download("{$payment->receipt_number}.pdf");
    }

    public function reportPdf(Request $request, ReportMetrics $metrics)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'accountant', 'super_admin']);
        $report = $metrics->for($request);
        $business = Business::findOrFail(BusinessAccess::id($request));
        return Pdf::loadView('documents.report', compact('report', 'business'))
            ->setPaper('a4')
            ->download("business-report-{$report['from']}-{$report['to']}.pdf");
    }

    public function reportExcel(Request $request, ReportMetrics $metrics)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'accountant', 'super_admin']);
        $report = $metrics->for($request);
        $rows = [
            ['Business report', '', ''], ['Period', $report['from'], $report['to']], [],
            ['Metric', 'Amount (BDT)'], ['Sales', $report['sales']], ['Collections', $report['net_collections']],
            ['Expenses', $report['expenses']], ['Gross profit', $report['gross_profit']], ['Net profit', $report['net_profit']],
            ['Customer due', $report['due']], ['Stock value', $report['stockValue']], ['Low stock items', $report['low']], [],
            ['Branch performance', 'Sales (BDT)'],
        ];
        foreach ($report['branches'] as $branch) $rows[] = [$branch->branch?->name ?? 'Branch', $branch->total];
        return Excel::download(new ArrayExport($rows, 'Business report'), "business-report-{$report['from']}-{$report['to']}.xlsx");
    }

    public function productTemplate(Request $request)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'super_admin']);
        $rows = [
            ['name', 'sku', 'barcode', 'category', 'unit', 'purchase_price', 'selling_price', 'reorder_level', 'opening_stock', 'branch_code'],
            ['Sample product', 'SKU-001', '', 'General', 'pcs', 80, 100, 5, 20, 'HEAD'],
        ];
        return $request->query('format') === 'csv'
            ? $this->csv($rows, 'product-import-template.csv')
            : Excel::download(new ArrayExport($rows, 'Products'), 'product-import-template.xlsx');
    }

    public function customerTemplate(Request $request)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'accountant', 'super_admin']);
        $rows = [
            ['name', 'contact_person', 'mobile', 'address', 'credit_limit', 'branch_code'],
            ['Sample customer', 'Contact name', '01700000000', 'Dhaka', 50000, 'HEAD'],
        ];
        return $request->query('format') === 'csv'
            ? $this->csv($rows, 'customer-import-template.csv')
            : Excel::download(new ArrayExport($rows, 'Customers'), 'customer-import-template.xlsx');
    }

    public function importProducts(Request $request)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'super_admin']);
        $request->validate(['file' => ['required', 'file', 'mimes:xlsx,csv,txt', 'max:10240']]);
        $businessId = BusinessAccess::id($request);
        $rows = $this->rows($request);
        $created = $updated = 0;
        DB::transaction(function () use ($rows, $businessId, $request, &$created, &$updated) {
            foreach ($rows as $index => $row) {
                $data = Validator::make($row, [
                    'name' => ['required', 'string', 'max:160'], 'sku' => ['required', 'string', 'max:60'],
                    'barcode' => ['nullable', 'string', 'max:80'], 'category' => ['nullable', 'string', 'max:100'],
                    'unit' => ['nullable', 'string', 'max:50'], 'purchase_price' => ['nullable', 'numeric', 'min:0'],
                    'selling_price' => ['required', 'numeric', 'min:0'], 'reorder_level' => ['nullable', 'numeric', 'min:0'],
                    'opening_stock' => ['nullable', 'numeric', 'min:0'], 'branch_code' => ['nullable', 'string', 'max:30'],
                ])->validate();
                $branch = $this->branchFor($businessId, $data['branch_code'] ?? null, $request);
                $category = empty($data['category']) ? null : Category::firstOrCreate(['business_id' => $businessId, 'name' => $data['category']]);
                $unit = empty($data['unit']) ? null : Unit::firstOrCreate(['business_id' => $businessId, 'symbol' => $data['unit']], ['name' => $data['unit']]);
                $product = Product::where('business_id', $businessId)->where('sku', $data['sku'])->first();
                $attributes = ['name' => $data['name'], 'barcode' => $data['barcode'] ?? null, 'category_id' => $category?->id, 'unit_id' => $unit?->id, 'purchase_price' => $data['purchase_price'] ?? 0, 'selling_price' => $data['selling_price']];
                if ($product) { $product->update($attributes); $updated++; continue; }
                $product = Product::create([...$attributes, 'business_id' => $businessId, 'sku' => $data['sku']]);
                InventoryStock::create(['branch_id' => $branch->id, 'product_id' => $product->id, 'quantity' => $data['opening_stock'] ?? 0, 'reorder_level' => $data['reorder_level'] ?? 0]);
                $created++;
            }
        });
        return response()->json(['message' => "Products imported: {$created} created, {$updated} updated.", 'created' => $created, 'updated' => $updated]);
    }

    public function importCustomers(Request $request)
    {
        BusinessAccess::requireRole($request, ['owner', 'manager', 'accountant', 'super_admin']);
        $request->validate(['file' => ['required', 'file', 'mimes:xlsx,csv,txt', 'max:10240']]);
        $businessId = BusinessAccess::id($request);
        $rows = $this->rows($request);
        $created = $updated = 0;
        DB::transaction(function () use ($rows, $businessId, $request, &$created, &$updated) {
            foreach ($rows as $row) {
                $data = Validator::make($row, [
                    'name' => ['required', 'string', 'max:160'], 'contact_person' => ['nullable', 'string', 'max:120'],
                    'mobile' => ['nullable', 'string', 'max:20'], 'address' => ['nullable', 'string'],
                    'credit_limit' => ['nullable', 'numeric', 'min:0'], 'branch_code' => ['nullable', 'string', 'max:30'],
                ])->validate();
                $branch = $this->branchFor($businessId, $data['branch_code'] ?? null, $request);
                $query = Customer::where('business_id', $businessId)->where('branch_id', $branch->id);
                empty($data['mobile']) ? $query->where('name', $data['name']) : $query->where('mobile', $data['mobile']);
                $customer = $query->first();
                $attributes = ['name' => $data['name'], 'contact_person' => $data['contact_person'] ?? null, 'mobile' => $data['mobile'] ?? null, 'address' => $data['address'] ?? null, 'credit_limit' => $data['credit_limit'] ?? 0];
                if ($customer) { $customer->update($attributes); $updated++; } else { Customer::create([...$attributes, 'business_id' => $businessId, 'branch_id' => $branch->id]); $created++; }
            }
        });
        return response()->json(['message' => "Customers imported: {$created} created, {$updated} updated.", 'created' => $created, 'updated' => $updated]);
    }

    private function rows(Request $request): array
    {
        $import = new RowsImport(); Excel::import($import, $request->file('file'));
        $sheet = $import->rows ?? collect();
        abort_if($sheet->isEmpty(), 422, 'The uploaded file has no rows.');
        $headers = $sheet->shift()->map(fn ($value) => strtolower(trim((string) $value)))->all();
        $required = $request->routeIs('imports.products') ? ['name', 'sku', 'selling_price'] : ['name'];
        foreach ($required as $field) abort_unless(in_array($field, $headers, true), 422, "Missing required column: {$field}.");
        return $sheet->filter(fn ($row) => $row->filter()->isNotEmpty())->map(function ($row) use ($headers) {
            $values = $row->values()->all(); return array_combine($headers, array_pad($values, count($headers), null));
        })->values()->all();
    }

    private function branchFor(int $businessId, ?string $code, Request $request): Branch
    {
        $branch = $code ? Branch::where('business_id', $businessId)->where('code', $code)->first() : null;
        $branch ??= Branch::where('business_id', $businessId)->whereKey($request->user()->branch_id)->first();
        $branch ??= Branch::where('business_id', $businessId)->orderBy('id')->first();
        abort_unless($branch, 422, 'Create a branch before importing.');
        BusinessAccess::branch($request, $branch->id);
        return $branch;
    }

    private function authorizeInvoice(Request $request, SalesInvoice $invoice): void
    {
        abort_unless($invoice->business_id === BusinessAccess::id($request), 403);
        BusinessAccess::branch($request, $invoice->branch_id);
        if ($request->user()->role === 'salesperson') abort_unless($invoice->user_id === $request->user()->id, 403);
    }

    private function authorizePayment(Request $request, Payment $payment): void
    {
        abort_unless($payment->business_id === BusinessAccess::id($request), 403);
        BusinessAccess::branch($request, $payment->branch_id);
        if ($request->user()->role === 'salesperson') abort_unless($payment->user_id === $request->user()->id, 403);
    }

    private function csv(array $rows, string $filename)
    {
        return response()->streamDownload(function () use ($rows) { $stream = fopen('php://output', 'w'); foreach ($rows as $row) fputcsv($stream, $row); fclose($stream); }, $filename, ['Content-Type' => 'text/csv']);
    }
}
