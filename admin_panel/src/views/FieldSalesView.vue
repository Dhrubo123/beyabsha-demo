<script setup>
import { onMounted, reactive, ref } from 'vue'
import api from '../services/api'

const routes = ref([])
const salespeople = ref([])
const users = ref([])
const branches = ref([])
const customers = ref([])
const attendance = ref([])
const showRouteForm = ref(false)
const showSalespersonForm = ref(false)
const error = ref('')
const notice = ref('')
const today = new Date().toISOString().slice(0, 10)
const routeForm = reactive({ branch_id: '', salesperson_id: '', route_date: today, name: '', visits: [{ customer_id: '', scheduled_time: '' }] })
const salespersonForm = reactive({ user_id: '', branch_id: '', daily_target: 0 })

const page = response => response.data.data?.data || response.data.data || []
const messageFor = (e, fallback) => e.response?.data?.message || Object.values(e.response?.data?.errors || {})[0]?.[0] || fallback

const load = async () => {
  error.value = ''
  try {
    const [routeResponse, salespersonResponse, userResponse, customerResponse, attendanceResponse, businessResponse] = await Promise.all([
      api.get('/field-sales/routes'), api.get('/field-sales/salespeople'), api.get('/admin/users'),
      api.get('/customers'), api.get('/field-sales/attendances', { params: { date: today } }), api.get('/businesses'),
    ])
    routes.value = page(routeResponse)
    salespeople.value = page(salespersonResponse)
    users.value = page(userResponse)
    customers.value = page(customerResponse)
    attendance.value = page(attendanceResponse)
    const business = page(businessResponse)[0]
    branches.value = business ? page(await api.get(`/businesses/${business.id}/branches`)) : []
    if (!routeForm.branch_id && branches.value.length) routeForm.branch_id = branches.value[0].id
    if (!salespersonForm.branch_id && branches.value.length) salespersonForm.branch_id = branches.value[0].id
  } catch (e) { error.value = messageFor(e, 'ফিল্ড সেলস তথ্য লোড করা যায়নি।') }
}

const addVisit = () => routeForm.visits.push({ customer_id: '', scheduled_time: '' })
const removeVisit = index => routeForm.visits.length > 1 && routeForm.visits.splice(index, 1)
const resetRoute = () => Object.assign(routeForm, { branch_id: branches.value[0]?.id || '', salesperson_id: '', route_date: today, name: '', visits: [{ customer_id: '', scheduled_time: '' }] })
const resetSalesperson = () => Object.assign(salespersonForm, { user_id: '', branch_id: branches.value[0]?.id || '', daily_target: 0 })
const saveSalesperson = async () => { error.value = ''; notice.value = ''; try { await api.post('/field-sales/salespeople', salespersonForm); showSalespersonForm.value = false; resetSalesperson(); notice.value = 'সেলসপারসন প্রোফাইল সংরক্ষণ করা হয়েছে।'; await load() } catch (e) { error.value = messageFor(e, 'সেলসপারসন সংরক্ষণ করা যায়নি।') } }
const saveRoute = async () => { error.value = ''; notice.value = ''; try { await api.post('/field-sales/routes', routeForm); showRouteForm.value = false; resetRoute(); notice.value = 'ফিল্ড রুট ও ভিজিট পরিকল্পনা সংরক্ষণ করা হয়েছে।'; await load() } catch (e) { error.value = messageFor(e, 'রুট তৈরি করা যায়নি।') } }
onMounted(load)
</script>

<template>
  <section>
    <div class="page-heading inline"><div><p class="eyebrow">FIELD SALES</p><h2>ফিল্ড সেলস</h2><p>সেলসপারসন, উপস্থিতি, রুট এবং দোকান ভিজিট পরিচালনা করুন।</p></div><div class="heading-actions"><button class="secondary" @click="showSalespersonForm = true">+ সেলসপারসন সেটআপ</button><button class="primary" @click="showRouteForm = true">+ রুট তৈরি করুন</button></div></div>
    <p v-if="notice" class="success notice">✓ {{ notice }}</p><p v-if="error" class="error">{{ error }}</p>

    <div v-if="showSalespersonForm" class="page-card compact"><h3>সেলসপারসন প্রোফাইল সেটআপ</h3><p class="form-help">আগে “ব্যবহারকারী ও রোল” থেকে একজন ব্যবহারকারী তৈরি করুন, তারপর এখানে তাঁকে ফিল্ড সেলস টিমে যুক্ত করুন।</p><form class="form-grid" @submit.prevent="saveSalesperson"><label>ব্যবহারকারী<select v-model="salespersonForm.user_id" required><option value="">নির্বাচন করুন</option><option v-for="user in users.filter(user => user.is_active && user.role !== 'owner')" :key="user.id" :value="user.id">{{ user.name }}{{ user.role === 'salesperson' ? '' : ' — Salesperson করা হবে' }}</option></select></label><label>শাখা<select v-model="salespersonForm.branch_id" required><option v-for="branch in branches" :key="branch.id" :value="branch.id">{{ branch.name }}</option></select></label><label>দৈনিক বিক্রয় লক্ষ্য (৳)<input v-model.number="salespersonForm.daily_target" type="number" min="0" /></label><div class="full-width form-actions"><button type="button" class="secondary" @click="showSalespersonForm = false; resetSalesperson()">বাতিল</button><button class="primary">প্রোফাইল সংরক্ষণ করুন</button></div></form></div>

    <div v-if="showRouteForm" class="page-card compact"><h3>নতুন রুট ও দোকান ভিজিট পরিকল্পনা</h3><form class="form-grid" @submit.prevent="saveRoute"><label>রুটের নাম<input v-model="routeForm.name" placeholder="যেমন: আগ্রাবাদ সকালের রুট" /></label><label>তারিখ<input v-model="routeForm.route_date" type="date" required /></label><label>শাখা<select v-model="routeForm.branch_id" required><option v-for="branch in branches" :key="branch.id" :value="branch.id">{{ branch.name }}</option></select></label><label>সেলসপারসন<select v-model="routeForm.salesperson_id" required><option value="">নির্বাচন করুন</option><option v-for="profile in salespeople" :key="profile.id" :value="profile.user_id">{{ profile.user?.name }}</option></select></label><div class="full-width route-visits"><div class="section-row"><strong>পরিকল্পিত দোকান ভিজিট</strong><button type="button" class="text-button" @click="addVisit">+ আরেকটি ভিজিট</button></div><div v-for="(visit, index) in routeForm.visits" :key="index" class="visit-row"><span>{{ index + 1 }}</span><select v-model="visit.customer_id" required><option value="">গ্রাহক/দোকান নির্বাচন করুন</option><option v-for="customer in customers" :key="customer.id" :value="customer.id">{{ customer.name }}{{ customer.mobile ? ` · ${customer.mobile}` : '' }}</option></select><input v-model="visit.scheduled_time" type="time" aria-label="নির্ধারিত সময়" /><button type="button" class="icon-button" :disabled="routeForm.visits.length === 1" @click="removeVisit(index)">×</button></div></div><div class="full-width form-actions"><button type="button" class="secondary" @click="showRouteForm = false; resetRoute()">বাতিল</button><button class="primary">রুট সংরক্ষণ করুন</button></div></form></div>

    <div class="metrics"><article><span class="metric-icon green">✓</span><div><small>সক্রিয় সেলসপারসন</small><strong>{{ salespeople.length }}</strong><em>নিবন্ধিত ফিল্ড টিম</em></div></article><article><span class="metric-icon blue">⌖</span><div><small>পরিকল্পিত রুট</small><strong>{{ routes.length }}</strong><em>সব তারিখের রুট</em></div></article><article><span class="metric-icon amber">◉</span><div><small>দোকান ভিজিট</small><strong>{{ routes.reduce((number, route) => number + (route.visits?.length || 0), 0) }}</strong><em>মোট নির্ধারিত</em></div></article><article><span class="metric-icon blue">◷</span><div><small>আজ উপস্থিত</small><strong>{{ attendance.filter(record => record.check_in_at).length }}</strong><em>চেক-ইন করা টিম</em></div></article></div>
    <div class="info-callout"><strong>মোবাইল ফ্লো:</strong> Flutter Field Sales অ্যাপ থেকে সেলসপারসন চেক-ইন/চেক-আউট, রুট ভিজিট, অর্ডার এবং পেমেন্ট সংগ্রহ করবে। এই প্যানেল থেকে রুট পরিকল্পনা ও টিম পর্যবেক্ষণ করুন।</div>
    <div class="two-column"><div class="table-card sales-table"><table><thead><tr><th>রুট</th><th>তারিখ</th><th>সেলসপারসন</th><th>ভিজিট</th><th>অবস্থা</th></tr></thead><tbody><tr v-for="route in routes" :key="route.id"><td><strong>{{ route.name || 'আজকের রুট' }}</strong><small>{{ route.branch?.name || `শাখা #${route.branch_id}` }}</small></td><td>{{ route.route_date }}</td><td>{{ route.salesperson?.name }}</td><td>{{ route.visits?.length || 0 }}</td><td><span class="status active">● {{ route.status }}</span></td></tr><tr v-if="!routes.length"><td colspan="5" class="empty">এখনও কোনো রুট পরিকল্পনা করা হয়নি।</td></tr></tbody></table></div><div class="table-card attendance-card"><table><thead><tr><th>আজকের উপস্থিতি</th><th>চেক-ইন</th><th>চেক-আউট</th></tr></thead><tbody><tr v-for="record in attendance" :key="record.id"><td><strong>{{ record.user?.name }}</strong><small>{{ record.branch?.name }}</small></td><td>{{ record.check_in_at ? new Date(record.check_in_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '—' }}</td><td>{{ record.check_out_at ? new Date(record.check_out_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '—' }}</td></tr><tr v-if="!attendance.length"><td colspan="3" class="empty">আজ কোনো উপস্থিতি রেকর্ড নেই।</td></tr></tbody></table></div></div>
    <div class="table-card team-table"><table><thead><tr><th>সেলসপারসন</th><th>শাখা</th><th>দৈনিক লক্ষ্য</th><th>অবস্থা</th></tr></thead><tbody><tr v-for="profile in salespeople" :key="profile.id"><td><strong>{{ profile.user?.name }}</strong><small>{{ profile.user?.mobile || profile.user?.email }}</small></td><td>{{ branches.find(branch => branch.id === profile.branch_id)?.name || `শাখা #${profile.branch_id}` }}</td><td>৳{{ profile.daily_target }}</td><td><span class="status active">● {{ profile.is_active ? 'সক্রিয়' : 'নিষ্ক্রিয়' }}</span></td></tr><tr v-if="!salespeople.length"><td colspan="4" class="empty">এখনও কোনো সেলসপারসন প্রোফাইল নেই।</td></tr></tbody></table></div>
  </section>
</template>
