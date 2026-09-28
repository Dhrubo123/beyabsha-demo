<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\{Customer,Expense,InventoryStock,Payment,SalesInvoice,SalesInvoiceItem,SalesReturn,SalesReturnItem,Supplier};
use App\Support\BusinessAccess;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
class ReportController extends Controller{
 public function dashboard(Request $r){
  BusinessAccess::requireRole($r,['owner','manager','accountant','super_admin']);
  $business=BusinessAccess::id($r);
  $from=$r->filled('from')?$r->date('from'):now()->startOfMonth();
  $to=$r->filled('to')?$r->date('to'):now()->endOfMonth();
  $invoices=SalesInvoice::where('business_id',$business)->where('status','completed')->whereBetween('invoice_date',[$from,$to]); BusinessAccess::scopeBranch($invoices,$r);
  $grossSales=(clone $invoices)->sum('grand_total');
  $soldCost=SalesInvoiceItem::whereHas('salesInvoice',function($q)use($business,$from,$to,$r){$q->where('business_id',$business)->where('status','completed')->whereBetween('invoice_date',[$from,$to]);BusinessAccess::scopeBranch($q,$r);})->selectRaw('COALESCE(SUM(quantity * unit_cost),0) total')->value('total');
  $returnQuery=SalesReturn::where('business_id',$business)->whereBetween('return_date',[$from,$to]); BusinessAccess::scopeBranch($returnQuery,$r);
  $sales_returns=(clone $returnQuery)->sum('total_amount');
  $returnedCost=SalesReturnItem::whereHas('salesReturn',function($q)use($business,$from,$to,$r){$q->where('business_id',$business)->whereBetween('return_date',[$from,$to]);BusinessAccess::scopeBranch($q,$r);})->selectRaw('COALESCE(SUM(quantity * unit_cost),0) total')->value('total');
  $sales=$grossSales-$sales_returns; $cogs=$soldCost-$returnedCost;
  $paymentQuery=Payment::where('business_id',$business)->whereBetween('collection_date',[$from,$to]); BusinessAccess::scopeBranch($paymentQuery,$r);
  $collections=$paymentQuery->sum('amount'); $refunds=(clone $returnQuery)->sum('refund_amount'); $net_collections=$collections-$refunds;
  $expenseQuery=Expense::where('business_id',$business)->where('approval_status','approved')->whereBetween('expense_date',[$from,$to]); BusinessAccess::scopeBranch($expenseQuery,$r); $expenses=$expenseQuery->sum('amount');
  $customers=Customer::where('business_id',$business); BusinessAccess::scopeBranch($customers,$r); $due=$customers->sum('current_due');
  $stocks=InventoryStock::whereHas('product',fn($q)=>$q->where('business_id',$business)); BusinessAccess::scopeBranch($stocks,$r);
  $stockValue=(clone $stocks)->join('products','products.id','=','inventory_stocks.product_id')->selectRaw('COALESCE(SUM(inventory_stocks.quantity * products.purchase_price),0) total')->value('total');
  $low=(clone $stocks)->whereColumn('quantity','<=','reorder_level')->count();
  $branches=(clone $invoices)->select('branch_id',DB::raw('SUM(grand_total) total'))->with('branch:id,name')->groupBy('branch_id')->get();
  $gross_profit=$sales-$cogs; $net_profit=$gross_profit-$expenses; $supplier_due=Supplier::where('business_id',$business)->sum('current_due');
  return response()->json(['data'=>compact('sales','grossSales','sales_returns','collections','refunds','net_collections','expenses','due','stockValue','low','branches','cogs','gross_profit','net_profit','supplier_due')]);
 }
 public function monthly(Request $r){BusinessAccess::requireRole($r,['owner','manager','accountant','super_admin']);$business=BusinessAccess::id($r);$q=SalesInvoice::where('business_id',$business)->where('status','completed');BusinessAccess::scopeBranch($q,$r);return response()->json(['data'=>$q->selectRaw("DATE_FORMAT(invoice_date,'%Y-%m') month, SUM(grand_total) sales")->groupBy('month')->orderBy('month')->limit(12)->get()]);}
}
