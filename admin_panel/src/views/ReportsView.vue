<script setup>
import { onMounted, reactive, ref } from 'vue'
import api from '../services/api'
import { downloadFile } from '../services/files'

const report = ref(null)
const error = ref('')
const exporting = ref('')
const today = new Date()
const filters = reactive({
  from: new Date(today.getFullYear(), today.getMonth(), 2).toISOString().slice(0, 10),
  to: today.toISOString().slice(0, 10),
})
const money = (value) => new Intl.NumberFormat('bn-BD', { maximumFractionDigits: 0 }).format(Number(value || 0))

async function load() {
  error.value = ''
  try {
    report.value = (await api.get('/reports/dashboard', { params: filters })).data.data
  } catch (exception) {
    error.value = exception.response?.data?.message ?? 'রিপোর্ট লোড করা যায়নি।'
  }
}

async function exportReport(format) {
  exporting.value = format
  error.value = ''
  try {
    const extension = format === 'excel' ? 'xlsx' : 'pdf'
    await downloadFile(`/reports/export/${format}`, `business-report-${filters.from}-to-${filters.to}.${extension}`, filters)
  } catch (exception) {
    error.value = 'রিপোর্ট ফাইল ডাউনলোড করা যায়নি।'
  } finally {
    exporting.value = ''
  }
}

onMounted(load)
</script>

<template>
  <section>
    <div class="page-heading inline">
      <div>
        <p class="eyebrow">BUSINESS REPORTS</p>
        <h2>ব্যবসা রিপোর্ট</h2>
        <p>বিক্রয়, পণ্যের খরচ, লাভ, সংগ্রহ, বকেয়া ও স্টক কর্মক্ষমতা।</p>
      </div>
      <div class="report-actions">
        <form class="button-row" @submit.prevent="load">
          <input v-model="filters.from" type="date">
          <input v-model="filters.to" type="date">
          <button class="secondary">প্রয়োগ করুন</button>
        </form>
        <div class="button-row export-row">
          <button class="secondary" :disabled="!!exporting" @click="exportReport('pdf')">{{ exporting === 'pdf' ? 'PDF তৈরি হচ্ছে…' : 'PDF এক্সপোর্ট' }}</button>
          <button class="primary" :disabled="!!exporting" @click="exportReport('excel')">{{ exporting === 'excel' ? 'Excel তৈরি হচ্ছে…' : 'Excel এক্সপোর্ট' }}</button>
        </div>
      </div>
    </div>
    <p v-if="error" class="error-message">{{ error }}</p>
    <template v-if="report">
      <div class="metrics">
        <article><span class="metric-icon green">৳</span><div><small>বিক্রয়</small><strong>৳{{ money(report.sales) }}</strong><em>নির্বাচিত সময়</em></div></article>
        <article><span class="metric-icon blue">◉</span><div><small>সংগ্রহ</small><strong>৳{{ money(report.collections) }}</strong><em>রেকর্ডকৃত পেমেন্ট</em></div></article>
        <article><span class="metric-icon amber">−</span><div><small>পণ্যের খরচ (COGS)</small><strong>৳{{ money(report.cogs) }}</strong><em>বিক্রীত পণ্যের মূল্য</em></div></article>
        <article><span class="metric-icon red">!</span><div><small>গ্রাহক বকেয়া</small><strong>৳{{ money(report.due) }}</strong><em>বর্তমান মোট বাকি</em></div></article>
      </div>
      <div class="dashboard-grid">
        <article class="panel"><h3>লাভ ও স্টক</h3><div class="report-list"><p>মোট লাভ <strong>৳{{ money(report.gross_profit) }}</strong></p><p>অনুমোদিত খরচ <strong>৳{{ money(report.expenses) }}</strong></p><p>নিট লাভ <strong>৳{{ money(report.net_profit) }}</strong></p><p>স্টক মূল্য <strong>৳{{ money(report.stockValue) }}</strong></p><p>কম স্টক <strong>{{ report.low }}টি</strong></p></div></article>
        <article class="panel"><h3>শাখা কর্মক্ষমতা</h3><div class="report-list"><p v-for="branch in report.branches" :key="branch.branch_id">{{ branch.branch?.name }} <strong>৳{{ money(branch.total) }}</strong></p><p v-if="!report.branches.length" class="empty">কোনো বিক্রয় নেই।</p></div></article>
      </div>
    </template>
  </section>
</template>

<style scoped>
.report-actions { display: flex; flex-wrap: wrap; justify-content: flex-end; gap: .7rem; }
.export-row { margin: 0; }
@media (max-width: 760px) { .report-actions { justify-content: flex-start; } }
</style>
