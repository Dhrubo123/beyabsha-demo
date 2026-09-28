import { ref } from 'vue'

const savedLanguage = localStorage.getItem('byabsha_language')
export const language = ref(savedLanguage === 'en' ? 'en' : 'bn')

const messages = {
  bn: {
    language: 'ভাষা', bangla: 'বাংলা', english: 'English', adminConsole: 'অ্যাডমিন কনসোল', controlCenter: 'ব্যবসা নিয়ন্ত্রণ কেন্দ্র', dashboard: 'ড্যাশবোর্ড', businessProfile: 'ব্যবসা প্রোফাইল', branches: 'শাখাসমূহ', products: 'পণ্য ক্যাটালগ', inventory: 'স্টক ব্যবস্থাপনা', purchases: 'ক্রয় ও সরবরাহকারী', customers: 'গ্রাহক ও বাকি', sales: 'বিক্রয় ও ইনভয়েস', collections: 'পেমেন্ট সংগ্রহ', expenses: 'খরচ ব্যবস্থাপনা', fieldSales: 'ফিল্ড সেলস ও রুট', reports: 'রিপোর্ট', imports: 'ডেটা ইমপোর্ট', notifications: 'নোটিফিকেশন', auditLogs: 'অডিট লগ', settings: 'সেটিংস', users: 'ব্যবহারকারী ও রোল', logout: 'লগআউট', login: 'লগইন করুন', loginHelp: 'অ্যাডমিন অ্যাকাউন্টে লগইন করুন', emailOrMobile: 'ইমেইল অথবা মোবাইল', password: 'পাসওয়ার্ড',
  },
  en: {
    language: 'Language', bangla: 'বাংলা', english: 'English', adminConsole: 'Admin Console', controlCenter: 'Business Control Center', dashboard: 'Dashboard', businessProfile: 'Business Profile', branches: 'Branches', products: 'Product Catalog', inventory: 'Inventory', purchases: 'Purchases & Suppliers', customers: 'Customers & Credit', sales: 'Sales & Invoices', collections: 'Payment Collection', expenses: 'Expense Management', fieldSales: 'Field Sales & Routes', reports: 'Reports', imports: 'Data Import', notifications: 'Notifications', auditLogs: 'Audit Logs', settings: 'Settings', users: 'Users & Roles', logout: 'Log out', login: 'Log in', loginHelp: 'Sign in to your admin account', emailOrMobile: 'Email or mobile', password: 'Password',
  },
}

export const t = key => messages[language.value][key] || messages.bn[key] || key

export const setLanguage = value => {
  language.value = value === 'en' ? 'en' : 'bn'
  localStorage.setItem('byabsha_language', language.value)
  document.documentElement.lang = language.value === 'en' ? 'en' : 'bn'
}
