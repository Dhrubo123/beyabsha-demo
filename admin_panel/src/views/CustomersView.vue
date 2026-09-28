<script setup>
import { onMounted, reactive, ref } from 'vue'
import api from '../services/api'

const customers = ref([])
const branches = ref([])
const showForm = ref(false)
const selected = ref(null)
const editingCustomer = ref(null)
const error = ref('')
const notice = ref('')
const blankForm = () => ({ name: '', contact_person: '', mobile: '', address: '', branch_id: '', credit_limit: 0, is_active: true })
const form = reactive(blankForm())
const page = response => response.data.data?.data || response.data.data || []
const messageFor = (e, fallback) => e.response?.data?.message || Object.values(e.response?.data?.errors || {})[0]?.[0] || fallback

const resetForm = () => Object.assign(form, blankForm())
const load = async () => {
  try {
    const [customerResponse, businessResponse] = await Promise.all([api.get('/customers'), api.get('/businesses')])
    customers.value = page(customerResponse)
    const business = page(businessResponse)[0]
    branches.value = business ? page(await api.get(`/businesses/${business.id}/branches`)) : []
  } catch (e) { error.value = messageFor(e, 'গ্রাহক তথ্য লোড করা যায়নি।') }
}
const openCreate = () => { error.value = ''; editingCustomer.value = null; resetForm(); showForm.value = true }
const openEdit = customer => { error.value = ''; editingCustomer.value = customer; Object.assign(form, { name: customer.name, contact_person: customer.contact_person || '', mobile: customer.mobile || '', address: customer.address || '', branch_id: customer.branch_id || '', credit_limit: Number(customer.credit_limit || 0), is_active: customer.is_active !== false }); showForm.value = true }
const closeForm = () => { showForm.value = false; editingCustomer.value = null; resetForm() }
const save = async () => {
  error.value = ''; notice.value = ''
  const payload = { ...form, branch_id: form.branch_id || null }
  try {
    if (editingCustomer.value) {
      await api.put(`/customers/${editingCustomer.value.id}`, payload)
      notice.value = 'গ্রাহকের তথ্য আপডেট হয়েছে।'
    } else {
      await api.post('/customers', payload)
      notice.value = 'গ্রাহক সংরক্ষণ হয়েছে।'
    }
    closeForm(); await load()
  } catch (e) { error.value = messageFor(e, editingCustomer.value ? 'গ্রাহক আপডেট করা যায়নি।' : 'গ্রাহক সংরক্ষণ করা যায়নি।') }
}
const ledger = async customer => { error.value = ''; try { const response = await api.get(`/customers/${customer.id}/ledger`); selected.value = { customer, entries: page(response), aging: response.data.aging } } catch (e) { error.value = messageFor(e, 'লেজার লোড করা যায়নি।') } }
onMounted(load)
</script>

<template>
  <section>
    <div class="page-heading inline"><div><p class="eyebrow">CUSTOMER CREDIT</p><h2>গ্রাহক ও বাকি</h2><p>গ্রাহক তথ্য, ক্রেডিট সীমা, বকেয়া এবং লেজার পরিচালনা করুন।</p></div><button class="primary" @click="openCreate">+ নতুন গ্রাহক</button></div>
    <p v-if="notice" class="success notice">✓ {{ notice }}</p><p v-if="error" class="error">{{ error }}</p>
    <div v-if="showForm" class="page-card compact"><h3>{{ editingCustomer ? 'গ্রাহক সম্পাদনা' : 'নতুন গ্রাহক' }}</h3><p v-if="editingCustomer" class="form-help">বর্তমান বকেয়া ও লেজার পরিবর্তন করা যাবে না; এগুলো ইনভয়েস, পেমেন্ট ও ফেরত থেকে স্বয়ংক্রিয়ভাবে হিসাব হয়।</p><form class="form-grid" @submit.prevent="save"><label>দোকান/গ্রাহকের নাম<input v-model="form.name" required /></label><label>যোগাযোগ ব্যক্তি<input v-model="form.contact_person" /></label><label>মোবাইল<input v-model="form.mobile" /></label><label>শাখা<select v-model="form.branch_id"><option value="">ব্যবহারকারীর/সকল শাখা</option><option v-for="branch in branches" :key="branch.id" :value="branch.id">{{ branch.name }}</option></select></label><label>ক্রেডিট সীমা<input v-model.number="form.credit_limit" type="number" min="0" /></label><label>ঠিকানা<input v-model="form.address" /></label><label v-if="editingCustomer" class="checkbox-label"><input v-model="form.is_active" type="checkbox" /> গ্রাহক সক্রিয়</label><div class="full-width form-actions"><button type="button" class="secondary" @click="closeForm">বাতিল</button><button class="primary">{{ editingCustomer ? 'পরিবর্তন সংরক্ষণ করুন' : 'গ্রাহক সংরক্ষণ করুন' }}</button></div></form></div>
    <div class="table-card"><table><thead><tr><th>গ্রাহক</th><th>মোবাইল</th><th>ক্রেডিট সীমা</th><th>বর্তমান বাকি</th><th>বাকি শুরুর তারিখ</th><th>অবস্থা</th><th></th></tr></thead><tbody><tr v-for="customer in customers" :key="customer.id"><td><strong>{{ customer.name }}</strong><small>{{ customer.contact_person || '—' }}</small></td><td>{{ customer.mobile || '—' }}</td><td>৳{{ customer.credit_limit }}</td><td><strong :class="Number(customer.current_due) > 0 ? 'due' : ''">৳{{ customer.current_due }}</strong></td><td>{{ customer.due_since || 'পরিশোধিত' }}</td><td><span class="status" :class="customer.is_active === false ? 'inactive' : 'active'">● {{ customer.is_active === false ? 'নিষ্ক্রিয়' : 'সক্রিয়' }}</span></td><td class="table-actions"><button class="secondary small" @click="ledger(customer)">লেজার</button><button class="secondary small" @click="openEdit(customer)">সম্পাদনা</button></td></tr><tr v-if="!customers.length"><td colspan="7" class="empty">কোনো গ্রাহক নেই। প্রথম গ্রাহক যোগ করুন।</td></tr></tbody></table></div>
    <div v-if="selected" class="modal-backdrop" @click.self="selected = null"><div class="modal ledger-modal"><button class="icon-button close" @click="selected = null">×</button><h3>{{ selected.customer.name }} — লেজার</h3><p class="modal-subtitle">বর্তমান বাকি ৳{{ selected.aging.due }} · {{ selected.aging.bucket }} দিন শ্রেণি</p><table><thead><tr><th>তারিখ</th><th>ধরন</th><th>রেফারেন্স</th><th>ডেবিট</th><th>ক্রেডিট</th><th>ব্যালেন্স</th></tr></thead><tbody><tr v-for="entry in selected.entries" :key="entry.id"><td>{{ entry.entry_date }}</td><td>{{ entry.type }}</td><td>{{ entry.reference }}</td><td>{{ entry.debit }}</td><td>{{ entry.credit }}</td><td>{{ entry.balance }}</td></tr><tr v-if="!selected.entries.length"><td colspan="6" class="empty">কোনো লেনদেন নেই।</td></tr></tbody></table></div></div>
  </section>
</template>
