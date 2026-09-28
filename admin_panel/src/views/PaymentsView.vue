<script setup>
import { onMounted, reactive, ref } from 'vue'
import api from '../services/api'
import { downloadFile } from '../services/files'
import { useAuthStore } from '../stores/auth'

const auth = useAuthStore()
const payments = ref([])
const customers = ref([])
const loading = ref(false)
const notice = ref('')
const error = ref('')
const form = reactive({
  customer_id: '',
  amount: '',
  method: 'cash',
  transaction_id: '',
  collection_date: new Date().toISOString().slice(0, 10),
  notes: '',
})

async function load() {
  loading.value = true
  try {
    const [paymentResponse, customerResponse] = await Promise.all([
      api.get('/payments'),
      api.get('/customers'),
    ])
    payments.value = paymentResponse.data.data ?? paymentResponse.data
    customers.value = customerResponse.data.data ?? customerResponse.data
  } catch (exception) {
    error.value = exception.response?.data?.message ?? 'Could not load payment data.'
  } finally {
    loading.value = false
  }
}

async function save() {
  notice.value = ''
  error.value = ''
  try {
    await api.post('/payments', {
      ...form,
      customer_id: Number(form.customer_id),
      branch_id: auth.user?.branch_id,
      amount: Number(form.amount),
    })
    notice.value = 'Payment collection saved and customer due updated.'
    Object.assign(form, {
      customer_id: '', amount: '', method: 'cash',
      transaction_id: '', collection_date: new Date().toISOString().slice(0, 10), notes: '',
    })
    await load()
  } catch (exception) {
    error.value = exception.response?.data?.message ?? 'Could not save this payment.'
  }
}

function receipt(payment) {
  downloadFile(`/payments/${payment.id}/receipt`, `receipt-${payment.id}.pdf`)
}

onMounted(load)
</script>

<template>
  <section class="page-grid two-columns">
    <div class="page-card">
      <p class="eyebrow">Cash, bank & mobile payments</p>
      <h1>Collect a payment</h1>
      <p class="muted">A collection automatically reduces the selected customer's outstanding balance.</p>
      <p v-if="notice" class="success-message">{{ notice }}</p>
      <p v-if="error" class="error-message">{{ error }}</p>

      <form class="form-grid" @submit.prevent="save">
        <label>Customer
          <select v-model="form.customer_id" required>
            <option value="">Select customer</option>
            <option v-for="customer in customers" :key="customer.id" :value="customer.id">
              {{ customer.name }} — due ৳{{ Number(customer.current_due || 0).toLocaleString() }}
            </option>
          </select>
        </label>
        <label>Amount
          <input v-model="form.amount" type="number" min="0.01" step="0.01" required>
        </label>
        <label>Method
          <select v-model="form.method">
            <option value="cash">Cash</option>
            <option value="bank">Bank</option>
            <option value="bkash">bKash</option>
            <option value="nagad">Nagad</option>
          </select>
        </label>
        <label>Transaction ID
          <input v-model="form.transaction_id" placeholder="Optional reference">
        </label>
        <label>Collection date
          <input v-model="form.collection_date" type="date" required>
        </label>
        <label class="full-width">Note
          <textarea v-model="form.notes" rows="3" placeholder="Optional note for this receipt" />
        </label>
        <button class="primary full-width" type="submit">Save payment collection</button>
      </form>
    </div>

    <div class="page-card">
      <div class="row-between">
        <div>
          <p class="eyebrow">Receipts</p>
          <h2>Recent collections</h2>
        </div>
        <button class="secondary" :disabled="loading" @click="load">Refresh</button>
      </div>
      <div class="table-wrap">
        <table>
          <thead><tr><th>Date</th><th>Customer</th><th>Method</th><th>Amount</th><th>Receipt</th></tr></thead>
          <tbody>
            <tr v-for="payment in payments" :key="payment.id">
              <td>{{ payment.collection_date || payment.created_at?.slice(0, 10) }}</td>
              <td>{{ payment.customer?.name || 'Customer' }}</td>
              <td class="capitalize">{{ payment.method }}</td>
              <td>৳{{ Number(payment.amount || 0).toLocaleString() }}</td>
              <td><button class="table-action" @click="receipt(payment)">PDF receipt</button></td>
            </tr>
            <tr v-if="!loading && !payments.length"><td colspan="5" class="muted">No payment collections yet.</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </section>
</template>
