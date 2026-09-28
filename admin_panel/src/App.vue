<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from './stores/auth'
import { language, setLanguage, t } from './services/language'
const route = useRoute(); const router = useRouter(); const auth = useAuthStore()
const isLogin = computed(() => route.path === '/login')
const canManageFieldSales = computed(() => ['owner', 'manager', 'super_admin'].includes(auth.user?.role))
const canManageImports = computed(() => ['owner', 'manager', 'accountant', 'super_admin'].includes(auth.user?.role))
const logout = async () => { await auth.logout(); router.push('/login') }
</script>
<template>
  <router-view v-if="isLogin" />
  <div v-else class="app-shell">
    <aside class="sidebar"><div class="brand"><span class="brand-icon">▦</span><div><strong>Byabsha 360</strong><small>{{ t('adminConsole') }}</small></div></div><nav><RouterLink to="/">⌂ <span>{{ t('dashboard') }}</span></RouterLink><RouterLink to="/business">▣ <span>{{ t('businessProfile') }}</span></RouterLink><RouterLink to="/branches">⌘ <span>{{ t('branches') }}</span></RouterLink><RouterLink to="/products">▤ <span>{{ t('products') }}</span></RouterLink><RouterLink to="/inventory">▤ <span>{{ t('inventory') }}</span></RouterLink><RouterLink to="/purchases">▧ <span>{{ t('purchases') }}</span></RouterLink><RouterLink to="/customers">♙ <span>{{ t('customers') }}</span></RouterLink><RouterLink to="/invoices">▥ <span>{{ t('sales') }}</span></RouterLink><RouterLink to="/payments">৳ <span>{{ t('collections') }}</span></RouterLink><RouterLink to="/expenses">− <span>{{ t('expenses') }}</span></RouterLink><RouterLink v-if="canManageFieldSales" to="/field-sales">⌁ <span>{{ t('fieldSales') }}</span></RouterLink><RouterLink to="/reports">▥ <span>{{ t('reports') }}</span></RouterLink><RouterLink v-if="canManageImports" to="/imports">⇧ <span>{{ t('imports') }}</span></RouterLink><RouterLink to="/notifications">◉ <span>{{ t('notifications') }}</span></RouterLink><RouterLink to="/audit-logs">≡ <span>{{ t('auditLogs') }}</span></RouterLink><RouterLink to="/settings">⚙ <span>{{ t('settings') }}</span></RouterLink><RouterLink to="/users">♙ <span>{{ t('users') }}</span></RouterLink></nav><div class="sidebar-bottom"><span>W3xplorers</span><small>v1.1.0</small></div></aside>
    <main><header><div><p class="eyebrow">{{ t('controlCenter') }}</p><h1>{{ route.name || t('dashboard') }}</h1></div><div class="user-menu"><label class="language-switch"><span class="sr-only">{{ t('language') }}</span><select :value="language" @change="setLanguage($event.target.value)"><option value="bn">{{ t('bangla') }}</option><option value="en">{{ t('english') }}</option></select></label><div class="avatar">{{ auth.user?.name?.slice(0, 1) || 'A' }}</div><div><strong>{{ auth.user?.name || 'Admin' }}</strong><small>{{ auth.user?.role || 'owner' }}</small></div><button class="icon-button" @click="logout" :title="t('logout')">↪</button></div></header><router-view /></main>
  </div>
</template>
