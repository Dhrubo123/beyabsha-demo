import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/LoginView.vue'
import DashboardView from '../views/DashboardView.vue'
import BusinessView from '../views/BusinessView.vue'
import BranchesView from '../views/BranchesView.vue'
import UsersView from '../views/UsersView.vue'
import ProductsView from '../views/ProductsView.vue'
import CustomersView from '../views/CustomersView.vue'
import InvoicesView from '../views/InvoicesView.vue'
import InventoryView from '../views/InventoryView.vue'
import PaymentsView from '../views/PaymentsView.vue'
import ExpensesView from '../views/ExpensesView.vue'
import FieldSalesView from '../views/FieldSalesView.vue'
import ReportsView from '../views/ReportsView.vue'
import SettingsView from '../views/SettingsView.vue'
import NotificationsView from '../views/NotificationsView.vue'
import PurchasesView from '../views/PurchasesView.vue'
import AuditLogsView from '../views/AuditLogsView.vue'
import ImportsView from '../views/ImportsView.vue'
const router = createRouter({ history: createWebHistory(), routes: [
  { path: '/login', component: LoginView }, { path: '/', component: DashboardView, meta: { auth: true } },
  { path: '/business', component: BusinessView, meta: { auth: true } }, { path: '/branches', component: BranchesView, meta: { auth: true } }, { path: '/users', component: UsersView, meta: { auth: true } },
  { path: '/products', component: ProductsView, meta: { auth: true } }, { path: '/customers', component: CustomersView, meta: { auth: true } }, { path: '/invoices', component: InvoicesView, meta: { auth: true } },
  { path: '/inventory', component: InventoryView, meta: { auth: true } },
  { path: '/purchases', component: PurchasesView, meta: { auth: true } },
  { path: '/payments', component: PaymentsView, meta: { auth: true } }, { path: '/expenses', component: ExpensesView, meta: { auth: true } }, { path: '/field-sales', component: FieldSalesView, meta: { auth: true } },
  { path: '/reports', component: ReportsView, meta: { auth: true } }, { path: '/settings', component: SettingsView, meta: { auth: true } }, { path: '/notifications', component: NotificationsView, meta: { auth: true } },
  { path: '/audit-logs', component: AuditLogsView, meta: { auth: true } },
  { path: '/imports', component: ImportsView, meta: { auth: true } },
] })
router.beforeEach((to) => { if (to.meta.auth && !localStorage.getItem('byabsha_token')) return '/login' })
export default router
