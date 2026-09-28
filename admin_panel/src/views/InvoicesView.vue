<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import api from '../services/api'
import { downloadFile } from '../services/files'

const invoices = ref([])
const customers = ref([])
const products = ref([])
const branches = ref([])
const show = ref(false)
const showReturn = ref(false)
const selected = ref(null)
const error = ref('')
const notice = ref('')
const today = new Date().toISOString().slice(0, 10)
const form = reactive({ branch_id: '', customer_id: '', discount: 0, vat: 0, paid_amount: 0, payment_method: 'cash', transaction_id: '', notes: '', items: [{ product_id: '', quantity: 1, unit_price: '', discount: 0 }] })
const returnForm = reactive({ return_date: today, refund_method: 'cash', reason: '', items: [] })
const page = response => response.data.data?.data ?? response.data.data ?? []
const messageFor = (e, fallback) => e.response?.data?.message || Object.values(e.response?.data?.errors || {})[0]?.[0] || fallback
const price = id => Number(products.value.find(product => product.id === Number(id))?.selling_price || 0)
const total = computed(() => Math.max(0, form.items.reduce((sum, item) => sum + Number(item.quantity || 0) * Number(item.unit_price || price(item.product_id)) - Number(item.discount || 0), 0) - Number(form.discount || 0) + Number(form.vat || 0)))
const canReturn = computed(() => selected.value?.status === 'completed' && selected.value?.return_status !== 'returned')

const load = async () => {
  try {
    const [invoiceResponse, customerResponse, productResponse, businessResponse] = await Promise.all([api.get('/invoices'), api.get('/customers'), api.get('/products'), api.get('/businesses')])
    invoices.value = page(invoiceResponse); customers.value = page(customerResponse); products.value = page(productResponse)
    const business = page(businessResponse)[0]
    branches.value = business ? page(await api.get(`/businesses/${business.id}/branches`)) : []
    if (!form.branch_id && branches.value.length) form.branch_id = branches.value[0].id
  } catch (e) { error.value = messageFor(e, 'তথ্য লোড করা যায়নি।') }
}

const addItem = () => form.items.push({ product_id: '', quantity: 1, unit_price: '', discount: 0 })
const save = async () => { error.value = ''; notice.value = ''; try { await api.post('/invoices', form); show.value = false; notice.value = 'ইনভয়েস তৈরি হয়েছে।'; await load() } catch (e) { error.value = messageFor(e, 'ইনভয়েস তৈরি করা যায়নি।') } }
const details = async invoice => { error.value = ''; try { selected.value = (await api.get(`/invoices/${invoice.id}`)).data.data; showReturn.value = false } catch (e) { error.value = messageFor(e, 'ইনভয়েস তথ্য লোড করা যায়নি।') } }
const pdf = invoice => downloadFile(`/invoices/${invoice.id}/pdf`, `${invoice.invoice_number}.pdf`)
const returnedQuantity = productId => (selected.value?.returns || []).flatMap(item => item.items || []).filter(item => item.product_id === productId).reduce((sum, item) => sum + Number(item.quantity), 0)
const openReturn = () => {
  returnForm.return_date = today; returnForm.refund_method = 'cash'; returnForm.reason = ''
  returnForm.items = selected.value.items.map(item => ({ product_id: item.product_id, product_name: item.product_name, sold_quantity: Number(item.quantity), returned_quantity: returnedQuantity(item.product_id), quantity: 0 }))
  showReturn.value = true
}
const cancelInvoice = async () => {
  if (!selected.value || !confirm(`আপনি কি নিশ্চিত যে ${selected.value.invoice_number} বাতিল করবেন? এটি স্টকে পণ্য ফেরত দেবে এবং বকেয়া সমন্বয় করবে।`)) return
  error.value = ''; notice.value = ''
  try { selected.value = (await api.post(`/invoices/${selected.value.id}/cancel`)).data.data; notice.value = 'ইনভয়েস বাতিল করা হয়েছে এবং স্টক সমন্বয় করা হয়েছে।'; await load() } catch (e) { error.value = messageFor(e, 'ইনভয়েস বাতিল করা যায়নি।') }
}
const saveReturn = async () => {
  const items = returnForm.items.filter(item => Number(item.quantity) > 0).map(({ product_id, quantity }) => ({ product_id, quantity: Number(quantity) }))
  if (!items.length) { error.value = 'ফেরতের জন্য অন্তত একটি পণ্যের পরিমাণ দিন।'; return }
  error.value = ''; notice.value = ''
  try {
    await api.post(`/invoices/${selected.value.id}/returns`, { return_date: returnForm.return_date, refund_method: returnForm.refund_method, reason: returnForm.reason, items })
    showReturn.value = false; notice.value = 'বিক্রয় ফেরত সংরক্ষণ হয়েছে; স্টক ও গ্রাহক বকেয়া স্বয়ংক্রিয়ভাবে সমন্বয় করা হয়েছে।'
    await details(selected.value); await load()
  } catch (e) { error.value = messageFor(e, 'বিক্রয় ফেরত সংরক্ষণ করা যায়নি।') }
}
onMounted(load)
</script>

<template>
  <section>
    <div class="page-heading inline"><div><p class="eyebrow">SALES</p><h2>বিক্রয় ও ইনভয়েস</h2><p>ইনভয়েস, PDF, বাতিল এবং পণ্য ফেরত নিরাপদভাবে পরিচালনা করুন।</p></div><button class="primary" @click="show = true">+ নতুন ইনভয়েস</button></div>
    <p v-if="notice" class="success notice">✓ {{ notice }}</p><p v-if="error" class="error">{{ error }}</p>

    <div v-if="show" class="page-card compact"><form class="form-grid" @submit.prevent="save"><label>শাখা<select v-model="form.branch_id" required><option v-for="branch in branches" :key="branch.id" :value="branch.id">{{ branch.name }}</option></select></label><label>গ্রাহক<select v-model="form.customer_id" required><option value="">নির্বাচন করুন</option><option v-for="customer in customers" :key="customer.id" :value="customer.id">{{ customer.name }}</option></select></label><div class="full-width"><strong>পণ্য</strong><div v-for="(item, index) in form.items" :key="index" class="line-item sales-line"><select v-model="item.product_id" required><option value="">পণ্য</option><option v-for="product in products" :key="product.id" :value="product.id">{{ product.name }}</option></select><input v-model.number="item.quantity" type="number" min="0.001" step="0.001"/><input v-model.number="item.unit_price" type="number" min="0" :placeholder="String(price(item.product_id))"/><input v-model.number="item.discount" type="number" min="0" placeholder="ছাড়"/></div><button type="button" class="text-button" @click="addItem">+ আরও পণ্য</button></div><label>ছাড়<input v-model.number="form.discount" type="number" min="0"/></label><label>VAT<input v-model.number="form.vat" type="number" min="0"/></label><label>প্রদত্ত টাকা<input v-model.number="form.paid_amount" type="number" min="0" :max="total"/></label><label>মাধ্যম<select v-model="form.payment_method"><option value="cash">Cash</option><option value="bank">Bank</option><option value="bkash">bKash</option><option value="nagad">Nagad</option></select></label><label v-if="form.paid_amount > 0 && form.payment_method !== 'cash'">Transaction ID<input v-model="form.transaction_id" required/></label><label>সর্বমোট<strong>৳{{ total.toFixed(2) }}</strong></label><div class="full-width form-actions"><button type="button" class="secondary" @click="show = false">বাতিল</button><button class="primary">বিক্রয় সম্পন্ন করুন</button></div></form></div>

    <div class="table-card"><table><thead><tr><th>ইনভয়েস</th><th>গ্রাহক</th><th>তারিখ</th><th>মোট</th><th>অবস্থা</th><th></th></tr></thead><tbody><tr v-for="invoice in invoices" :key="invoice.id"><td><button class="text-button" @click="details(invoice)">{{ invoice.invoice_number }}</button></td><td>{{ invoice.customer?.name }}</td><td>{{ invoice.invoice_date }}</td><td>৳{{ invoice.grand_total }}</td><td><span class="role-chip">{{ invoice.status === 'cancelled' ? 'cancelled' : invoice.return_status || invoice.payment_status }}</span></td><td><button class="secondary small" @click="pdf(invoice)">PDF / Print</button></td></tr><tr v-if="!invoices.length"><td colspan="6" class="empty">কোনো ইনভয়েস নেই।</td></tr></tbody></table></div>

    <div v-if="selected" class="modal-backdrop" @click.self="selected = null"><div class="modal invoice-modal"><button class="icon-button close" @click="selected = null">×</button><p class="eyebrow">INVOICE DETAILS</p><h3>{{ selected.invoice_number }}</h3><p class="modal-subtitle">{{ selected.customer?.name }} · {{ selected.invoice_date }} · ৳{{ selected.grand_total }}</p><div class="status-row"><span class="role-chip">{{ selected.status }}</span><span v-if="selected.return_status" class="role-chip">{{ selected.return_status }}</span><span class="role-chip">{{ selected.payment_status }}</span></div><div class="invoice-items"><div v-for="item in selected.items" :key="item.id"><span>{{ item.product_name }}</span><strong>{{ item.quantity }} × ৳{{ item.unit_price }}</strong></div></div><p v-if="selected.status === 'cancelled'" class="warning-note">এই ইনভয়েস ইতিমধ্যে বাতিল করা হয়েছে।</p><p v-else-if="selected.paid_amount > 0" class="form-help">পেইড বা আংশিক পেইড ইনভয়েস বাতিল করা যায় না। পণ্য ফেরত ব্যবহার করুন; বকেয়া কমবে এবং অতিরিক্ত অর্থ রিফান্ড হিসেবে রেকর্ড হবে।</p><div class="modal-actions"><button class="secondary" @click="pdf(selected)">PDF / Print</button><button v-if="canReturn" class="secondary return-button" @click="openReturn">পণ্য ফেরত</button><button v-if="selected.status === 'completed' && Number(selected.paid_amount) === 0" class="danger-button" @click="cancelInvoice">ইনভয়েস বাতিল</button></div>

      <div v-if="showReturn" class="return-form"><h3>বিক্রয় ফেরত</h3><p class="form-help">শুধু গ্রাহকের কাছ থেকে বাস্তবে ফেরত পাওয়া পণ্যের পরিমাণ দিন।</p><label>ফেরতের তারিখ<input v-model="returnForm.return_date" type="date" /></label><label>রিফান্ডের মাধ্যম<select v-model="returnForm.refund_method"><option value="cash">Cash</option><option value="bank">Bank</option><option value="bkash">bKash</option><option value="nagad">Nagad</option></select></label><label class="full-label">কারণ<textarea v-model="returnForm.reason" rows="2" placeholder="যেমন: ক্ষতিগ্রস্ত পণ্য, ভুল অর্ডার"></textarea></label><div v-for="item in returnForm.items" :key="item.product_id" class="return-line"><div><strong>{{ item.product_name }}</strong><small>বিক্রি: {{ item.sold_quantity }} · আগে ফেরত: {{ item.returned_quantity }} · সর্বোচ্চ: {{ item.sold_quantity - item.returned_quantity }}</small></div><input v-model.number="item.quantity" type="number" min="0" :max="item.sold_quantity - item.returned_quantity" step="0.001" /></div><div class="form-actions"><button class="secondary" @click="showReturn = false">বাতিল</button><button class="primary" @click="saveReturn">ফেরত সংরক্ষণ করুন</button></div></div>
    </div></div>
  </section>
</template>
