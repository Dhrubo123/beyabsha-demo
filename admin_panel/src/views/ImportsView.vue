<script setup>
import { ref } from 'vue'
import { downloadFile, uploadFile } from '../services/files'

const notice = ref('')
const error = ref('')
const uploading = ref('')

function template(type, format) {
  const extension = format === 'csv' ? 'csv' : 'xlsx'
  downloadFile(`/imports/${type}/template`, `${type}-import-template.${extension}`, { format })
}

async function importFile(type, event) {
  const file = event.target.files?.[0]
  if (!file) return

  notice.value = ''
  error.value = ''
  uploading.value = type
  try {
    const response = await uploadFile(`/imports/${type}`, file)
    const data = response.data
    notice.value = `${data.message} Created: ${data.created ?? 0}, updated: ${data.updated ?? 0}.`
  } catch (exception) {
    const messages = exception.response?.data?.errors
    error.value = messages
      ? Object.values(messages).flat().join(' ')
      : (exception.response?.data?.message ?? 'The import could not be completed.')
  } finally {
    uploading.value = ''
    event.target.value = ''
  }
}
</script>

<template>
  <section class="page-grid">
    <div class="page-card">
      <p class="eyebrow">Bulk data tools</p>
      <h1>Import products and customers</h1>
      <p class="muted">Download the supplied template, complete one row for each record, then upload it. Existing products are matched by SKU and customers by mobile number.</p>
      <p v-if="notice" class="success-message">{{ notice }}</p>
      <p v-if="error" class="error-message">{{ error }}</p>
    </div>

    <div class="page-grid two-columns">
      <article class="page-card">
        <p class="eyebrow">Catalog</p>
        <h2>Products</h2>
        <p class="muted">Required: <code>name</code>, <code>sku</code>. Optional stock is only used when a product is first created.</p>
        <div class="button-row">
          <button class="secondary" @click="template('products', 'xlsx')">Excel template</button>
          <button class="secondary" @click="template('products', 'csv')">CSV template</button>
          <label class="primary upload-button">
            {{ uploading === 'products' ? 'Uploading…' : 'Import products' }}
            <input type="file" accept=".xlsx,.csv,.txt" :disabled="!!uploading" @change="importFile('products', $event)">
          </label>
        </div>
        <p class="muted small">Columns: name, sku, barcode, category, unit, purchase_price, selling_price, reorder_level, opening_stock, branch_code</p>
      </article>

      <article class="page-card">
        <p class="eyebrow">Credit customers</p>
        <h2>Customers</h2>
        <p class="muted">Required: <code>name</code>. Existing customers with the same mobile number in a branch are updated.</p>
        <div class="button-row">
          <button class="secondary" @click="template('customers', 'xlsx')">Excel template</button>
          <button class="secondary" @click="template('customers', 'csv')">CSV template</button>
          <label class="primary upload-button">
            {{ uploading === 'customers' ? 'Uploading…' : 'Import customers' }}
            <input type="file" accept=".xlsx,.csv,.txt" :disabled="!!uploading" @change="importFile('customers', $event)">
          </label>
        </div>
        <p class="muted small">Columns: name, contact_person, mobile, address, credit_limit, branch_code</p>
      </article>
    </div>
  </section>
</template>

<style scoped>
.button-row { display: flex; flex-wrap: wrap; gap: .65rem; margin: 1.25rem 0; }
.upload-button { display: inline-flex; align-items: center; cursor: pointer; }
.upload-button input { display: none; }
.small { font-size: .78rem; line-height: 1.6; }
code { background: #eff5f2; border-radius: 4px; padding: .1rem .25rem; }
</style>
