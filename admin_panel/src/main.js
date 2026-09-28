import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './style.css'
import './purchases.css'
import './inventory.css'
import './language.css'

createApp(App).use(createPinia()).use(router).mount('#app')
