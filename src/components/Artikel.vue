<template>
  <div class="min-h-screen bg-white dark:bg-black transition-colors duration-300">
    <!-- Hero Section -->
     <section class="relative w-full h-[200px] sm:h-[280px] md:h-[320px] overflow-hidden">
      <img 
        src="/term.png" 
        alt="Syarat & Ketentuan" 
        class="w-full h-full object-cover object-center"
      >
      <div class="absolute inset-0 flex items-center justify-center">
        <h1 class="text-3xl sm:text-4xl md:text-5xl font-serif 
                   text-black dark:text-white">
          Artikel & Blog
        </h1>
      </div>
    </section>

    <!-- Featured Article -->
    <div class="max-w-6xl mx-auto px-6 sm:px-8 py-16">
      <div class="bg-gray-50 dark:bg-gray-900 rounded-lg overflow-hidden shadow-lg mb-16 transition-colors">
        <div class="grid md:grid-cols-2 gap-0">
          <div class="relative h-64 md:h-full">
            <img 
              src="/gamis.png" 
              alt="Featured Article"
              class="w-full h-full object-cover"
            />
            <span class="absolute top-4 left-4 bg-seera-gold text-black px-4 py-1 text-sm font-semibold">
              FEATURED
            </span>
          </div>
          <div class="p-8 md:p-12 flex flex-col justify-center">
            <span class="text-seera-gold dark:text-[#C99F53] text-sm font-semibold mb-2">
              FASHION TIPS
            </span>
            <h2 class="font-serif text-3xl font-bold text-gray-900 dark:text-white mb-4">
              10 Cara Mix & Match Gamis untuk Berbagai Acara
            </h2>
            <p class="text-gray-600 dark:text-gray-400 mb-6 leading-relaxed">
              Gamis bukan hanya untuk acara formal. Pelajari cara styling gamis yang tepat untuk berbagai kesempatan, dari casual hingga formal dengan tetap terlihat modest dan fashionable.
            </p>
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-500 dark:text-gray-500">
                3 Desember 2025
              </span>
              <button class="text-seera-gold dark:text-[#C99F53] font-semibold hover:underline">
                Baca Selengkapnya →
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Category Filter -->
      <div class="flex flex-wrap gap-3 mb-12">
        <button 
          v-for="category in categories" 
          :key="category"
          @click="selectedCategory = category"
          :class="[
            'px-6 py-2 rounded-full font-medium transition-all',
            selectedCategory === category 
              ? 'bg-seera-gold text-black' 
              : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700'
          ]"
        >
          {{ category }}
        </button>
      </div>

      <!-- Articles Grid -->
      <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-8">
        <article 
          v-for="article in filteredArticles" 
          :key="article.id"
          class="bg-white dark:bg-gray-900 rounded-lg overflow-hidden shadow-md hover:shadow-xl transition-all group"
        >
          <div class="relative overflow-hidden">
            <img 
              :src="article.image" 
              :alt="article.title"
              class="w-full h-56 object-cover group-hover:scale-110 transition-transform duration-300"
            />
            <span class="absolute top-4 left-4 bg-black/70 text-white px-3 py-1 text-xs font-semibold">
              {{ article.category }}
            </span>
          </div>
          
          <div class="p-6">
            <h3 class="font-serif text-xl font-semibold text-gray-900 dark:text-white mb-3 line-clamp-2 group-hover:text-seera-gold dark:group-hover:text-[#C99F53] transition-colors">
              {{ article.title }}
            </h3>
            
            <p class="text-gray-600 dark:text-gray-400 text-sm mb-4 line-clamp-3">
              {{ article.excerpt }}
            </p>
            
            <div class="flex items-center justify-between pt-4 border-t dark:border-gray-700">
              <span class="text-xs text-gray-500 dark:text-gray-500">
                {{ article.date }}
              </span>
              <button class="text-seera-gold dark:text-[#C99F53] text-sm font-semibold hover:underline">
                Baca →
              </button>
            </div>
          </div>
        </article>
      </div>

      <!-- Load More Button -->
      <div class="text-center mt-12">
        <button class="bg-seera-gold dark:bg-[#C99F53] text-black dark:text-white px-12 py-3 font-semibold rounded-md hover:bg-opacity-90 transition-all">
          Muat Lebih Banyak
        </button>
      </div>
    </div>

    <!-- Newsletter Section -->
    <div class="bg-gray-50 dark:bg-gray-900 py-16 transition-colors">
      <div class="max-w-3xl mx-auto px-6 sm:px-8 text-center">
        <h2 class="font-serif text-3xl font-bold text-gray-900 dark:text-white mb-4">
          Dapatkan Update Artikel Terbaru
        </h2>
        <p class="text-gray-600 dark:text-gray-400 mb-8">
          Subscribe newsletter kami untuk mendapatkan tips fashion, promo eksklusif, dan artikel terbaru langsung ke email Anda
        </p>
        
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const selectedCategory = ref('Semua')

const categories = [
  'Semua',
  'Fashion Tips',
  'Styling Guide',
  'Trend 2025',
  'Product Review',
  'Behind The Scene'
]

const articles = [
  {
    id: 1,
    title: '10 Cara Mix & Match Gamis untuk Berbagai Acara',
    excerpt: 'Gamis bukan hanya untuk acara formal. Pelajari cara styling yang tepat untuk berbagai kesempatan.',
    category: 'Fashion Tips',
    image: '/gamis.png',
    date: '3 Des 2025'
  },
  {
    id: 2,
    title: 'Tren Warna Hijab Favorit di 2025',
    excerpt: 'Warna-warna earth tone masih mendominasi. Simak kombinasi warna yang tepat untuk penampilanmu.',
    category: 'Trend 2025',
    image: '/koko.png',
    date: '2 Des 2025'
  },
  {
    id: 3,
    title: 'Panduan Memilih Koko Modern untuk Pria',
    excerpt: 'Koko tidak harus terlihat kaku. Temukan style koko modern yang cocok untuk berbagai aktivitas.',
    category: 'Styling Guide',
    image: '/koko-hijau.png',
    date: '1 Des 2025'
  },
  {
    id: 4,
    title: 'Review: Koleksi Abaya Premium Seera',
    excerpt: 'Detail review lengkap tentang kualitas bahan, jahitan, dan kenyamanan abaya premium kami.',
    category: 'Product Review',
    image: '/gamis.png',
    date: '30 Nov 2025'
  },
  {
    id: 5,
    title: 'Behind The Scene: Proses Produksi Gamis',
    excerpt: 'Intip proses di balik pembuatan gamis berkualitas dari pemilihan bahan hingga finishing.',
    category: 'Behind The Scene',
    image: '/koko.png',
    date: '29 Nov 2025'
  },
  {
    id: 6,
    title: 'Tips Merawat Pakaian Muslim Agar Awet',
    excerpt: 'Cara mencuci, menyimpan, dan merawat gamis, koko, dan abaya agar tetap terlihat seperti baru.',
    category: 'Fashion Tips',
    image: '/koko-hijau.png',
    date: '28 Nov 2025'
  },
  {
    id: 7,
    title: 'Aksesoris Pelengkap untuk Modest Fashion',
    excerpt: 'Aksesoris yang tepat bisa mengangkat penampilanmu. Simak rekomendasi aksesoris terbaik.',
    category: 'Styling Guide',
    image: '/gamis.png',
    date: '27 Nov 2025'
  },
  {
    id: 8,
    title: 'Modest Fashion untuk Acara Pernikahan',
    excerpt: 'Tampil anggun dan sopan di acara pernikahan dengan pilihan outfit modest yang stylish.',
    category: 'Fashion Tips',
    image: '/koko.png',
    date: '26 Nov 2025'
  },
  {
    id: 9,
    title: 'Trend Hijab 2025: Dari Pashmina hingga Turkish',
    excerpt: 'Berbagai style hijab yang sedang trending dan cara memakainya untuk berbagai bentuk wajah.',
    category: 'Trend 2025',
    image: '/koko-hijau.png',
    date: '25 Nov 2025'
  }
]

const filteredArticles = computed(() => {
  if (selectedCategory.value === 'Semua') {
    return articles
  }
  return articles.filter(article => article.category === selectedCategory.value)
})
</script>