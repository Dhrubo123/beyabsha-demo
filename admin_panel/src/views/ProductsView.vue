<script setup>
import { onMounted, reactive, ref } from 'vue'
import api from '../services/api'

const products = ref([])
const units = ref([])
const categories = ref([])
const showProduct = ref(false)
const showUnit = ref(false)
const showCategory = ref(false)
const editingProduct = ref(null)
const error = ref('')
const notice = ref('')
const blankProduct = () => ({ name: '', sku: '', barcode: '', unit_id: '', category_id: '', purchase_price: 0, selling_price: 0, is_active: true })
const product = reactive(blankProduct())
const unit = reactive({ name: '', symbol: '' })
const category = reactive({ name: '' })
const page = response => response.data.data?.data || response.data.data || []
const messageFor = (e, fallback) => e.response?.data?.message || Object.values(e.response?.data?.errors || {})[0]?.[0] || fallback
const resetProduct = () => Object.assign(product, blankProduct())

const load = async () => {
  try {
    const [productResponse, unitResponse, categoryResponse] = await Promise.all([api.get('/products'), api.get('/units'), api.get('/categories')])
    products.value = page(productResponse); units.value = page(unitResponse); categories.value = page(categoryResponse)
  } catch (e) { error.value = messageFor(e, 'পণ্য তথ্য লোড করা যায়নি।') }
}
const openCreate = () => { error.value = ''; editingProduct.value = null; resetProduct(); showProduct.value = true }
const openEdit = item => { error.value = ''; editingProduct.value = item; Object.assign(product, { name: item.name, sku: item.sku, barcode: item.barcode || '', unit_id: item.unit_id || '', category_id: item.category_id || '', purchase_price: Number(item.purchase_price || 0), selling_price: Number(item.selling_price || 0), is_active: item.is_active !== false }); showProduct.value = true }
const closeProduct = () => { showProduct.value = false; editingProduct.value = null; resetProduct() }
const saveProduct = async () => {
  error.value = ''; notice.value = ''
  const payload = { ...product, unit_id: product.unit_id || null, category_id: product.category_id || null }
  if (editingProduct.value) delete payload.sku
  try {
    if (editingProduct.value) {
      await api.put(`/products/${editingProduct.value.id}`, payload)
      notice.value = 'পণ্যের তথ্য আপডেট হয়েছে। SKU পরিবর্তন করা যায় না, যাতে পূর্বের বিক্রয় ও স্টক রেকর্ড সঠিক থাকে।'
    } else {
      await api.post('/products', payload)
      notice.value = 'পণ্য সংরক্ষণ হয়েছে।'
    }
    closeProduct(); await load()
  } catch (e) { error.value = messageFor(e, editingProduct.value ? 'পণ্য আপডেট করা যায়নি।' : 'পণ্য সংরক্ষণ করা যায়নি।') }
}
const saveUnit = async () => { error.value = ''; try { await api.post('/units', unit); Object.assign(unit, { name: '', symbol: '' }); showUnit.value = false; notice.value = 'ইউনিট সংরক্ষণ হয়েছে।'; await load() } catch (e) { error.value = messageFor(e, 'ইউনিট সংরক্ষণ করা যায়নি।') } }
const saveCategory = async () => { error.value = ''; try { await api.post('/categories', category); category.name = ''; showCategory.value = false; notice.value = 'ক্যাটাগরি সংরক্ষণ হয়েছে।'; await load() } catch (e) { error.value = messageFor(e, 'ক্যাটাগরি সংরক্ষণ করা যায়নি।') } }
onMounted(load)
</script>

<template>
  <section>
    <div class="page-heading inline"><div><p class="eyebrow">PRODUCT CATALOG</p><h2>পণ্য ক্যাটালগ</h2><p>পণ্য, SKU, বারকোড, ইউনিট, ক্যাটাগরি ও মূল্য পরিচালনা করুন।</p></div><div class="button-row"><button class="secondary" @click="showUnit = true">+ ইউনিট</button><button class="secondary" @click="showCategory = true">+ ক্যাটাগরি</button><button class="primary" @click="openCreate">+ নতুন পণ্য</button></div></div>
    <p v-if="notice" class="success notice">✓ {{ notice }}</p><p v-if="error" class="error">{{ error }}</p>
    <div v-if="showProduct" class="page-card compact"><h3>{{ editingProduct ? 'পণ্য সম্পাদনা' : 'নতুন পণ্য' }}</h3><p v-if="editingProduct" class="form-help">SKU অপরিবর্তনীয়, কারণ এটি বিক্রয়, ক্রয় এবং স্টক লেনদেনের স্থায়ী পরিচয়।</p><form class="form-grid" @submit.prevent="saveProduct"><label>পণ্যের নাম<input v-model="product.name" required /></label><label>SKU<input v-model="product.sku" :readonly="Boolean(editingProduct)" required /></label><label>বারকোড<input v-model="product.barcode" /></label><label>ইউনিট<select v-model="product.unit_id"><option value="">নির্বাচন করুন</option><option v-for="item in units" :key="item.id" :value="item.id">{{ item.name }} ({{ item.symbol }})</option></select></label><label>ক্যাটাগরি<select v-model="product.category_id"><option value="">নির্বাচন করুন</option><option v-for="item in categories" :key="item.id" :value="item.id">{{ item.name }}</option></select></label><label>ক্রয় মূল্য<input v-model.number="product.purchase_price" type="number" min="0" /></label><label>বিক্রয় মূল্য<input v-model.number="product.selling_price" type="number" min="0" required /></label><label v-if="editingProduct" class="checkbox-label"><input v-model="product.is_active" type="checkbox" /> পণ্য সক্রিয়</label><div class="full-width form-actions"><button type="button" class="secondary" @click="closeProduct">বাতিল</button><button class="primary">{{ editingProduct ? 'পরিবর্তন সংরক্ষণ করুন' : 'পণ্য সংরক্ষণ করুন' }}</button></div></form></div>
    <div v-if="showUnit" class="page-card compact"><form class="inline-form" @submit.prevent="saveUnit"><strong>নতুন ইউনিট</strong><input v-model="unit.name" placeholder="যেমন: পিস" required /><input v-model="unit.symbol" placeholder="যেমন: pcs" required /><button class="primary">সংরক্ষণ</button><button type="button" class="secondary" @click="showUnit = false">বাতিল</button></form></div>
    <div v-if="showCategory" class="page-card compact"><form class="inline-form" @submit.prevent="saveCategory"><strong>নতুন ক্যাটাগরি</strong><input v-model="category.name" placeholder="যেমন: খাদ্যপণ্য" required /><button class="primary">সংরক্ষণ</button><button type="button" class="secondary" @click="showCategory = false">বাতিল</button></form></div>
    <div class="catalog-summary"><article><small>মোট পণ্য</small><strong>{{ products.length }}</strong></article><article><small>ক্যাটাগরি</small><strong>{{ categories.length }}</strong></article><article><small>ইউনিট</small><strong>{{ units.length }}</strong></article><RouterLink to="/inventory" class="secondary">স্টক ব্যবস্থাপনা →</RouterLink></div>
    <div class="table-card"><table><thead><tr><th>পণ্য</th><th>SKU / বারকোড</th><th>ক্যাটাগরি</th><th>ক্রয় মূল্য</th><th>বিক্রয় মূল্য</th><th>অবস্থা</th><th></th></tr></thead><tbody><tr v-for="item in products" :key="item.id"><td><strong>{{ item.name }}</strong><small>{{ item.unit?.name || 'ইউনিট নেই' }}</small></td><td>{{ item.sku }}<small>{{ item.barcode || '—' }}</small></td><td>{{ item.category?.name || '—' }}</td><td>৳{{ item.purchase_price }}</td><td><strong>৳{{ item.selling_price }}</strong></td><td><span class="status" :class="item.is_active === false ? 'inactive' : 'active'">● {{ item.is_active === false ? 'নিষ্ক্রিয়' : 'সক্রিয়' }}</span></td><td><button class="secondary small" @click="openEdit(item)">সম্পাদনা</button></td></tr><tr v-if="!products.length"><td colspan="7" class="empty">কোনো পণ্য নেই। প্রথম পণ্য যোগ করুন।</td></tr></tbody></table></div>
  </section>
</template>
